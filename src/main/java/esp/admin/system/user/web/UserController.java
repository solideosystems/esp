package esp.admin.system.user.web;

import static io.github.greennlab.ddul.user.service.UserService.REGEXP_PASSWORD;
import static io.github.greennlab.ddul.validation.ValidUtils.correct;

import esp.admin.system.user.ESPUser;
import esp.admin.system.user.service.UserService;
import java.util.Map;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/system/user")
@RequiredArgsConstructor
public class UserController {

  private final UserService service;


  @GetMapping
  public Page<ESPUser> getUsers(ESPUser param, Pageable pageable) {
    return service.getAllUsers(param, pageable);
  }

  @PostMapping
  public ESPUser save(@Valid @RequestBody ESPUser user) {
    service.save(user);
    return user;
  }

  @PostMapping("/{id}/password")
  public void changePassword(@PathVariable Long id, @RequestBody Map<String, String> params) {
    final String newPassword = params.get("newPassword");

    correct("newPassword").in(params)
        .of(v -> !v.matches(REGEXP_PASSWORD), "대/소문자, 숫자, 특수기호로 6자 이상 입력하세요.");

    correct("compareWith").in(params)
        .of(v -> v.equals(newPassword), "입력된 새로운 비밀번호와 일치해야 해요.");

    service.changePassword(id, params.get("oldPassword"), newPassword);
  }

}
