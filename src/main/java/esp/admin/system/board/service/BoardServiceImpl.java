package esp.admin.system.board.service;

import io.github.greennlab.ddul.article.Article;
import io.github.greennlab.ddul.article.service.ArticleService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;

@Service
@RequiredArgsConstructor
public class BoardServiceImpl implements BoardService {

  private final ArticleService articleService;


  @Override
  public Page<Article> getPage(String category, String searchType, String keyword,
      Pageable pageable) {
    return articleService.pageBy(category, searchType, keyword, pageable);
  }

  @Override
  public Article getArticle(Long id) {
    return articleService.select(id);
  }

  @Transactional
  @Override
  public Article save(Article article) {
    if (ObjectUtils.isEmpty(article.getId())) {
      return articleService.insert(article);
    } else {
      return articleService.update(article);
    }
  }

  @Transactional
  @Override
  public void delete(Long id) {
    articleService.delete(id);
  }


}
