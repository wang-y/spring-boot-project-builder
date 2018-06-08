package ${confpackage};

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.awt.*;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;


@Component
public class OpenBrowseCommandRunner implements CommandLineRunner {

    @Autowired
    private Environment environment;

    @Override
    public void run(String... args) {

        String port = environment.getProperty("server.port");
        String context_path=environment.getProperty("server.servlet.context-path");
        String url="http://localhost:"+port+context_path;
        String os = System.getProperty("os.name");
        if(StringUtils.startsWithIgnoreCase(os,"win")) {
            if (Desktop.isDesktopSupported()) {
                Desktop desktop = Desktop.getDesktop();
                try {
                    desktop.browse(new URI(url));
                } catch (IOException | URISyntaxException e) {
                    e.printStackTrace();
                }
            } else {
                Runtime runtime = Runtime.getRuntime();
                try {
                    runtime.exec("cmd /c start " + url);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }else if (StringUtils.startsWithIgnoreCase(os,"linux")){
            Runtime runtime = Runtime.getRuntime();
            try {
                runtime.exec("x-www-browser "+url+"");
            } catch (IOException e) {
                e.printStackTrace();
            }

        }else if (StringUtils.startsWithIgnoreCase(os,"mac")){
            Runtime runtime = Runtime.getRuntime();
            try {
                runtime.exec("open "+url+"");
            } catch (IOException e) {
                e.printStackTrace();
            }

        }

    }
}
