package esp.admin.system.board.web;

import static io.github.greennlab.ddul.validation.ValidUtils.correct;

import esp.admin.system.board.service.BoardService;
import io.github.greennlab.ddul.article.Article;
import io.github.greennlab.ddul.validation.ValidUtils;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("board/{category}")
@RequiredArgsConstructor
public class BoardController {

  private final BoardService service;


  @GetMapping
  public Page<Article> getPage(
      @PathVariable String category,
      String type,
      String keyword,
      Pageable pageable) {
    return service.getPage(category, type, keyword, pageable);
  }

  @PostMapping
  public Article save(
      @PathVariable String category,
      @RequestBody @Valid Article article) {

    correct("title").in(article)
        .of(ObjectUtils::isNotEmpty, "제목을 입력해 주세요.");

    article.setCategory(category);
    return service.save(article);
  }

  @GetMapping("{id}")
  public Article getArticle(@PathVariable Long id) {
    return service.getArticle(id);
  }


  @DeleteMapping("{id}")
  public void delete(@PathVariable Long id) {
    service.delete(id);
  }

}
