package esp.admin.system.scarecrow.web;

import static org.springframework.http.HttpStatus.NO_CONTENT;

import esp.admin.system.scarecrow.__VO;
import esp.admin.system.scarecrow.service.__Service;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("___")
@RequiredArgsConstructor
public class __Controller {

  private final __Service service;

  /**
   * {} 조회 목록 JSON
   * @param ___ 조회 조건 파라미터
   * @param pageable 페이지관련
   */
  @GetMapping
  public Page<__VO> getPage(__VO ___, Pageable pageable) {
    return service.getPage(___, pageable);
  }

  /**
   * {} 저장
   * @param ___ 저장할 대상 JSON
   */
  @PostMapping
  public __VO save(@Valid @RequestBody __VO ___) {
    service.save(___);
    return ___;
  }

  /**
   * {} 조회 단건 JSON
   * @param id 조회 대상 건의 ID
   */
  @GetMapping("{id}")
  public __VO get(@PathVariable Long id) {
    return service.get(id);
  }

  /**
   * {} 삭제
   * @param id 삭제 대상 건의 ID
   */
  @DeleteMapping("{id}")
  @ResponseStatus(NO_CONTENT)
  public void remove(@PathVariable Long id) {
    service.remove(id);
  }

}
