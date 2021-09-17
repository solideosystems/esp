package esp.admin.system.scarecrow.service;

import esp.admin.system.scarecrow.__VO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface __Service {

  Page<__VO> getPage(__VO ___, Pageable pageable);

  void save(__VO ___);

  __VO get(Long id);

  void remove(Long id);

}
