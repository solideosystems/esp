package esp.admin.system.scarecrow.service;

import esp.admin.system.scarecrow.__VO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Mapper
public interface __Dao {

  Page<__VO> select(__VO ___, Pageable pageable);

  __VO select(Long id);

  void insert(__VO ___);

  void update(__VO ___);

  void delete(Long id);

}
