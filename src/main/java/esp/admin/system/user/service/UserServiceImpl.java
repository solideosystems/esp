package esp.admin.system.user.service;

import esp.admin.system.user.ESPUser;
import javax.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.crypto.scrypt.SCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

@Service
@Transactional
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

  private final UserDao dao;

  private final PasswordEncoder passwordEncoder;


  @Override
  public Page<ESPUser> getAllUsers(ESPUser param, Pageable pageable) {
    return dao.getAllUsers(param, pageable);
  }

  @Override
  public void save(ESPUser user) {
    final Long id = user.getId();

    if (ObjectUtils.isEmpty(id)) {
      dao.add(user);
    } else {
      dao.update(user);
    }
  }

  @Override
  public void changePassword(Long id, String oldPassword, String newPassword) {
    final ESPUser user = dao.getUserBy(id);

    checkMatchedPassword(user, oldPassword);

    user.setPassword(passwordEncoder.encode(newPassword));
    dao.updatePassword(user);
  }


  private void checkMatchedPassword(ESPUser user, String password) {
    if (null == user) {
      throw new UsernameNotFoundException("");
    }

    if (!passwordEncoder.matches(password, user.getPassword())) {
      throw new BadCredentialsException("이전 비밀번호가 맞지 않네요.");
    }
  }

}
