package esp.admin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan({"esp.admin", "io.github.greennlab"})
public class EspAdminApplication {

  public static void main(String[] args) {
    SpringApplication.run(EspAdminApplication.class, args);
  }

}
