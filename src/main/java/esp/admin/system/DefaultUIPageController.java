package esp.admin.system;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class DefaultUIPageController {

  @GetMapping(path = "/ui/{depth1}/{depth2}/{depth3}")
  public String defaultPageMapping(
      @PathVariable String depth1,
      @PathVariable String depth2,
      @PathVariable String depth3) {
    return String
        .format("ui/%s/%s/%s", depth1, depth2, depth3)
        .replaceAll("(/(null)?)+$", "");
  }

  @GetMapping(path = "/ui/{depth1}/{depth2}")
  public String defaultPageMapping(
      @PathVariable String depth1,
      @PathVariable String depth2) {
    return defaultPageMapping(depth1, depth2, null);
  }

  @GetMapping(path = "/ui/{depth1}")
  public String defaultPageMapping(
      @PathVariable String depth1) {
    return defaultPageMapping(depth1, null, null);
  }

}
