package esp.admin.system.bbsconfig.service;

import io.github.greennlab.ddul.article.ArticleCategory;
import io.github.greennlab.ddul.article.service.ArticleCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BbsConfigServiceImpl implements BbsConfigService {

  private final ArticleCategoryService articleCategoryService;


  @Override
  public Page<ArticleCategory> getPage(Pageable pageable) {
    return articleCategoryService.getPage(pageable);
  }

  @Override
  public void save(ArticleCategory articleCategory) {
    articleCategoryService.save(articleCategory);
  }
}
