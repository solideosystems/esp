package esp.admin.system.user.service;

import esp.admin.system.user.ESPUser;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface UserService {

  Page<ESPUser> getAllUsers(ESPUser param, Pageable pageable);

  void save(ESPUser user);

  void changePassword(Long id, String oldPassword, String newPassword);
}
