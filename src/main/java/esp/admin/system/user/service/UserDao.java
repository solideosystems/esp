package esp.admin.system.user.service;

import esp.admin.system.user.ESPUser;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Mapper
public interface UserDao {

  Page<ESPUser> getAllUsers(ESPUser param, Pageable pageable);

  ESPUser getUserBy(Long id);

  void add(ESPUser user);

  void update(ESPUser user);

  void updatePassword(ESPUser user);
}
