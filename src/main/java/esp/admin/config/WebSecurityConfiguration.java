package esp.admin.config;

import io.github.greennlab.ddul.authority.AuthorizedUser;
import io.github.greennlab.ddul.user.User;
import java.util.Arrays;
import java.util.stream.Collectors;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
@EnableWebSecurity
public class WebSecurityConfiguration extends WebSecurityConfigurerAdapter {

  @Bean
  public PasswordEncoder passwordEncoder() {
    return PasswordEncoderFactories.createDelegatingPasswordEncoder();
  }

  @Override
  protected void configure(HttpSecurity http) throws Exception {
    final User user = new User();
    user.setId(-1L);
    user.setUsername("anonymous");
    user.setName("anonymity");
    user.setEmail("anonymous@xxx.xxx");

    final AuthorizedUser principal = new AuthorizedUser(user,
        Arrays.stream(new String[]{"GUEST"}).map(
            SimpleGrantedAuthority::new).collect(Collectors.toSet()));

    http
        .csrf().disable()
        .headers()
        .frameOptions().sameOrigin()
        .and()

        .anonymous()
        .principal(principal)
        .and()

        .authorizeRequests()
        .antMatchers("/*").permitAll()
    ;
  }

}
