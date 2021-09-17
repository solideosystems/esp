package esp.admin;

import io.github.greennlab.ddul.DDulContextInitializer;
import org.springframework.boot.Banner.Mode;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

public class ServletInitializer extends SpringBootServletInitializer {

  @Override
  protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    return application
        .sources(EspAdminApplication.class)
        .initializers(new DDulContextInitializer())
        .bannerMode(Mode.OFF);
  }

}
