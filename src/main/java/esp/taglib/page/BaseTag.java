package esp.taglib.page;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

@Slf4j
public class BaseTag extends BodyTagSupport {

  private static final long serialVersionUID = 2105728555456273648L;

  private static final char NEW_LINE = '\n';
  private static final String header;
  private static final String footer;

  static {
    header = reader(new ClassPathResource("template/page/header.html"));
    footer = reader(new ClassPathResource("template/page/footer.html"));
  }


  @Setter
  private String title;


  private static String reader(Resource resource) {
    final StringBuilder builder = new StringBuilder();
    try (
        BufferedReader reader = new BufferedReader(new InputStreamReader(resource.getInputStream()))
    ) {
      String line;
      while ((line = reader.readLine()) != null) {
        builder.append(line).append(NEW_LINE);
      }
    } catch (IOException e) {
      log.error(e.getMessage(), e);
    }

    return builder.toString();
  }

  @Override
  public int doEndTag() throws JspException {
    try {
      getPreviousOut().write(header(header));
      getPreviousOut().write(bodyContent.getString());
      getPreviousOut().write(footer(footer));

    } catch (IOException e) {
      e.printStackTrace();
    }
    return super.doEndTag();
  }

  public String header(String html) {
    return html.replace("{{ title }}", title);
  }

  public String footer(String html) {
    return html;
  }

  protected String script(String src) {
    final String contextPath = ((HttpServletRequest) pageContext.getRequest()).getContextPath();
    return "<script src='" + contextPath + src + "'></script>\n";
  }

  protected String css(String src) {
    final String contextPath = ((HttpServletRequest) pageContext.getRequest()).getContextPath();
    return "<link rel='stylesheet' href='" + contextPath + src + "'>\n";
  }

}
