package esp.admin.system.scarecrow;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.util.ObjectUtils;

@Getter
@AllArgsConstructor
@Builder
public class Column {

  private String name;
  private String type;
  private Integer size;
  private String remark;
  private boolean nullable;

  @Setter
  private boolean pk;

  public String getRemark() {
    return ObjectUtils.isEmpty(remark) ? name : remark;
  }

  public boolean isDateType() {
    return null != type &&
        type.matches("(?i)date.*|time.*");
  }

  public boolean isCheckbox() {
    return null != type &&
        type.equals("CHAR") && size == 1;
  }

  public Integer getSize() {
    return "CLOB".equals(type) ? null : size;
  }

}
