package esp.admin.system.scarecrow.service;

import esp.admin.system.scarecrow.__VO;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

@Service
@RequiredArgsConstructor
public class __ServiceImpl implements __Service {

  private final __Dao dao;


  @Override
  public Page<__VO> getPage(__VO ___, Pageable pageable) {
    return dao.select(___, pageable);
  }

  @Override
  public void save(__VO ___) {
    if (ObjectUtils.isEmpty(___.getId())) {
      dao.insert(___);
    }
    else {
      dao.update(___);
    }
  }

  @Override
  public __VO get(Long id) {
    return dao.select(id);
  }

  @Override
  public void remove(Long id) {
    dao.delete(id);
  }
}
