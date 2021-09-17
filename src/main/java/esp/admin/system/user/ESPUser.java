package esp.admin.system.user;

import io.github.greennlab.ddul.mybatis.MapperType;
import io.github.greennlab.ddul.user.dto.UserDTO;
import java.time.LocalDate;
import javax.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

@MapperType
@Getter
@Setter
public class ESPUser extends UserDTO {

  @NotEmpty
  private String name;

  private LocalDate hired;
  private LocalDate retired;
  private LocalDate birthday;

  private String teamName;

  private String dept;

  private String grade;
  private String gradeName;

}
