package ${basePackage};

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.annotation.Bean;

import java.util.concurrent.CountDownLatch;

@SpringBootApplication
public class Application implements ApplicationRunner {

    @Autowired
    private CountDownLatch daemon;

    @Bean
    public CountDownLatch daemon() {
        return new CountDownLatch(1);
    }
    
    public static void main(String[] args) {
        new SpringApplicationBuilder().web(WebApplicationType.NONE)
                .sources(Application.class)
                .run(args);
    }
    
    @Override
    public void run(ApplicationArguments args) throws Exception {
        daemon.await();
    }
}

