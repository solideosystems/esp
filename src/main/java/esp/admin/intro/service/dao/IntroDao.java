package esp.admin.intro.service.dao;

import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Mapper
public interface IntroDao {

  Page<Map<String, Object>> getAllInformation(Pageable page);

}
