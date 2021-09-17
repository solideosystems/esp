package esp.admin.system.bbsconfig.web;

import static io.github.greennlab.ddul.validation.ValidUtils.correct;

import io.github.greennlab.ddul.article.ArticleCategory;
import esp.admin.system.bbsconfig.service.BbsConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.util.ObjectUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("system/bbs-config")
@RequiredArgsConstructor
public class BbsConfigController {

  private final BbsConfigService service;


  @GetMapping
  public Page<ArticleCategory> getPage(Pageable pageable) {
    return service.getPage(pageable);
  }

  @PostMapping
  public void save(@RequestBody ArticleCategory articleCategory) {
    correct("category").in(articleCategory)
        .of(category -> !ObjectUtils.isEmpty(category));

    service.save(articleCategory);
  }
}
