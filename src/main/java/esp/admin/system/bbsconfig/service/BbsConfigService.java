package esp.admin.system.bbsconfig.service;

import io.github.greennlab.ddul.article.ArticleCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface BbsConfigService {

  Page<ArticleCategory> getPage(Pageable pageable);

  void save(ArticleCategory articleCategory);

}
