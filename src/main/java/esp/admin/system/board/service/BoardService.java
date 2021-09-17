package esp.admin.system.board.service;

import io.github.greennlab.ddul.article.Article;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface BoardService {

  Page<Article> getPage(String category, String searchType, String keyword, Pageable pageable);

  Article getArticle(Long id);

  Article save(Article article);

  void delete(Long id);
}
