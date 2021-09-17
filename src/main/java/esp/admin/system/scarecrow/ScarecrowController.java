package esp.admin.system.scarecrow;

import io.github.greennlab.ddul.Application;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Stream;
import javax.sql.DataSource;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.web.servlet.WebMvcProperties;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

@Profile('!' + Application.PRODUCTION)
@RestController
@RequestMapping("scarecrow")
@RequiredArgsConstructor
public class ScarecrowController {

  public static final String CHARACTER_TAB = "\t";
  public static final String SEMICOLON_LF = ";\n";
  public static final String AUTHOR_COLUMN_NAMES = "CREATOR|CREATED|UPDATER|UPDATED";
  public static final String RELATIVE_PACKAGE = "system.scarecrow";
  public static final String CLAUSE_PRIVATE = "private ";
  public static final String CLAUSE_STRING = "String ";
  public static final String CLAUSE_GRID_DATE = "valueGetter: function (params) {\n"
      + "            return new Date(params.data.created).format('yyyy-MM-dd')\n"
      + "          }";


  private final DataSource dataSource;

  private final WebMvcProperties webMvcProperties;

  @Value("${project.dir}")
  private String projectDir;


  @GetMapping
  public ModelAndView scarecrowPage() {
    return new ModelAndView("scarecrow/scarecrow");
  }

  @GetMapping("generate")
  public boolean generate(String path, String id, String name, String tableName, String pageType)
      throws IOException {
    final String pkg = __VO.class.getPackage().getName();
    final Path src = path(pkg);
    final String idCamelCased = camelCase(id);
    final Path target = path(pkg.replace(RELATIVE_PACKAGE, ""))
        .resolve(path.replace('.', '/'));

    final String idPascalCased = pascalCase(idCamelCased);
    final List<Column> columns = retrieveTableInfo(tableName);

    javaCode(path, name, tableName, pageType, src, idCamelCased, target, idPascalCased, columns);

    final Path viewDir = Paths.get(projectDir, "src/main/webapp",
        webMvcProperties.getView().getPrefix());
    copy(
        viewDir.resolve("ui/" + path.replace('.', '/') + "/" + idCamelCased + ".jsp"),
        generateJsp(viewDir.resolve("scarecrow/" + pageType + ".jsp"),
            name, idCamelCased, idPascalCased, columns)
    );

    return true;
  }

  @GetMapping("generate/table-info")
  public List<Column> retrieveTableInfo(String tableName) {
    final JdbcTemplate tpl = new JdbcTemplate(dataSource);

    final List<Column> columns = tpl.query(""
            + "SELECT COLUMN_NAME, "
            + "       TYPE_NAME, "
            + "       CHARACTER_MAXIMUM_LENGTH, "
            + "       REMARKS, "
            + "       IS_NULLABLE "
            + "  FROM INFORMATION_SCHEMA.COLUMNS C "
            + " WHERE TABLE_NAME = ? "
            + " ORDER BY ORDINAL_POSITION ",
        (rs, rowNum) -> Column.builder()
            .name(rs.getString("COLUMN_NAME"))
            .type(rs.getString("TYPE_NAME"))
            .size(rs.getInt("CHARACTER_MAXIMUM_LENGTH"))
            .remark(rs.getString("REMARKS"))
            .nullable("YES".equals(rs.getString("IS_NULLABLE")))
            .build(),
        tableName.toUpperCase());

    final String pks = tpl.query(""
            + "SELECT COLUMN_LIST "
            + "  FROM INFORMATION_SCHEMA.CONSTRAINTS "
            + " where TABLE_NAME = ? "
            + "   AND CONSTRAINT_TYPE = 'PRIMARY KEY'",
        rs -> rs.next() ? rs.getString(1) : "",
        tableName.toUpperCase());

    if (!ObjectUtils.isEmpty(pks)) {
      for (String pk : pks.split("\\s*,\\s*")) {
        columns.stream()
            .filter(column -> pk.equals(column.getName()))
            .forEach(column -> column.setPk(true));
      }
    }

    return columns;
  }

  private String generateJsp(Path src, String name, String idCamelCased,
      String idPascalCased,
      List<Column> columns) throws IOException {
    return readInterpolation(src, name, "", idCamelCased, idPascalCased)
        .replace("// {columns}",
            String.join(",\n        ", columns.stream()
                .filter(i -> !i.getName().matches("ID|" + AUTHOR_COLUMN_NAMES))
                .map(i ->
                    camelCase(i.getName()) + ": {name: '" + i.getRemark() + "'"
                        + (i.isDateType() ? CLAUSE_GRID_DATE : "") + "}")
                .toArray(String[]::new))
        )
        .replace("<!-- will be generated -->",
            String.join("\n            ", columns.stream()
                .filter(i -> !i.getName().matches(AUTHOR_COLUMN_NAMES))
                .map(i -> {
                  if (i.isPk()) {
                    return "<input name=\"" + camelCase(i.getName()) + "\" type=\"hidden\">";
                  } else if (i.isCheckbox()) {
                    return "<label title=\"" + i.getRemark() + "\"><input name=\"" + camelCase(
                        i.getName())
                        + "\" type=\"checkbox\"></label>";
                  }

                  return "<label title=\"" + i.getRemark() + "\"><input name=\""
                      + camelCase(i.getName()) + "\" type=\""
                      + (i.isDateType() ? "date" : "text") + "\"></label>";
                })
                .toArray(String[]::new))
        );
  }


  @SuppressWarnings("java:S107")
  private void javaCode(String path, String name, String tableName, String pageType, Path src,
      String idCamelCased, Path target, String idPascalCased, List<Column> columns)
      throws IOException {
    if (!"board".equals(pageType)) {
      copy(
          target.resolve("service/__Dao.xml".replace("__", idPascalCased)),
          generateMapper(src.resolve("service/__Dao.xml"),
              name, tableName.toUpperCase(), path, idCamelCased, idPascalCased, columns)
      );

      copy(
          target.resolve("__VO.java".replace("__", idPascalCased)),
          generateVO(src.resolve("__VO.java"), name, path, idCamelCased, idPascalCased, columns)
      );

      Arrays.asList("web/__Controller.java", "service/__Service.java", "service/__ServiceImpl.java",
              "service/__Dao.java")
          .forEach(i -> {
            try {
              copy(
                  target.resolve(i.replace("__", idPascalCased)),
                  readInterpolation(src.resolve(i), name, path, idCamelCased,
                      idPascalCased)
              );
            } catch (IOException e) {
              throw new IllegalStateException(e);
            }
          });
    }
  }

  private String generateVO(Path src, String name, String path, String idCamelCased,
      String idPascalCased,
      List<Column> columns) throws IOException {
    String result = readInterpolation(src, name, path, idCamelCased, idPascalCased);

    final StringBuilder lines = new StringBuilder();
    for (Column column : columns) {
      final String colName = column.getName();

      if (!colName.matches("ID|" + AUTHOR_COLUMN_NAMES)) {
        lines.append(CHARACTER_TAB)
            .append(CLAUSE_PRIVATE)
            .append(column.isCheckbox() ? "boolean " : CLAUSE_STRING)
            .append(camelCase(colName))
            .append(SEMICOLON_LF);
      }
    }

    return result.replaceFirst("// will be generated", lines.toString());
  }

  private String generateMapper(Path src, String name, String tableName, String path,
      String idCamelCased,
      String idPascalCased,
      List<Column> columns) throws IOException {

    final String daoClass = __VO.class.getPackage().getName()
        .replace(RELATIVE_PACKAGE, path) + ".service." + idPascalCased + "Dao";

    String code = readInterpolation(src, name, path, idCamelCased, idPascalCased)
        .replaceFirst("namespace=\"(.+?)\"", "namespace=\"" + daoClass + "\"")
        .replace("{daoClass}", daoClass)
        .replace("SELECT", "SELECT " +
            String.join(",\n           ",
                columns.stream().map(Column::getName).toArray(String[]::new)))
        .replace("WHERE", "WHERE " +
            String.join("\n            AND ", columns.stream()
                .filter(Column::isPk)
                .map(i -> i.getName() + " = #{" + camelCase(i.getName()) + "}")
                .toArray(String[]::new)))
        .replace(" FROM TABLE", " FROM " + tableName)
        .replace(" UPDATE TABLE", " UPDATE " + tableName)
        .replace(" INSERT TABLE", " INSERT " + tableName)
        .replace("INTO ()", "INTO("
            + String.join(", ", columns.stream().map(Column::getName).toArray(String[]::new))
            + ")");

    Stream<Column> filteredColumns = columns.stream()
        .filter(i -> !i.getName().matches(AUTHOR_COLUMN_NAMES));

    code = code.replace("VALUES ( ", "VALUES ( "
        + String.join("", filteredColumns
        .map(i -> "#{" + camelCase(i.getName()) + "},\n             ").toArray(String[]::new)));

    filteredColumns = columns.stream()
        .filter(i -> !i.isPk() && !i.getName().matches(AUTHOR_COLUMN_NAMES));

    code = code.replace("SET COLUMNS", "SET "
        + String.join("", filteredColumns
        .map(i -> i.getName() + " = #{" + camelCase(i.getName()) + "},\n           ")
        .toArray(String[]::new)));

    return code;
  }

  private void copy(Path dest, String code) throws IOException {
    Files.createDirectories(dest.getParent());
    if (Files.notExists(dest)) {
      FileCopyUtils.copy(code.getBytes(), dest.toFile());
    }
  }

  private String readInterpolation(Path src, String name, String path, String idCamelCased,
      String idPascalCased) throws IOException {
    try (
        final BufferedReader in = new BufferedReader(
            new InputStreamReader(Files.newInputStream(src)))
    ) {
      return FileCopyUtils.copyToString(in)
          .replace(RELATIVE_PACKAGE, path)
          .replace("{}", name)
          .replace("___", idCamelCased)
          .replace("__", idPascalCased);
    }
  }

  private Path path(String suffix) {
    return Paths.get(
        projectDir,
        "src/main/java",
        suffix.replace('.', '/'));
  }

  private String camelCase(@NonNull String text) {
    if (text.matches("^([a-z]+[A-Z0-9]+[a-z0-9]*){1,9}$")) {
      return text;
    }

    final String result = hungarian(text);
    return result.substring(0, 1).toLowerCase() + result.substring(1);
  }

  private String pascalCase(String text) {
    final String result = text.matches("^([a-z]+[A-Z0-9]+[a-z0-9]*){1,9}$")
        ? text
        : hungarian(text);

    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }

  private String hungarian(String text) {
    final String[] split = text.split("[^a-zA-Z0-9]");
    final StringBuilder result = new StringBuilder();
    for (String part : split) {
      result.append(part.substring(0, 1).toUpperCase())
          .append(part.substring(1).toLowerCase());
    }
    return result.toString();
  }

}
