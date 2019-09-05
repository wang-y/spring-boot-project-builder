package ${confpackage};

import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RequestMethod;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.builders.ResponseMessageBuilder;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.ResponseMessage;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;
import ${corepackage}.common.result.ResultCode;

import java.util.ArrayList;
import java.util.List;

@Configuration
@EnableSwagger2
public class SwaggerConf {

    private static final List<ResponseMessage> RESPONSE_MESSAGE_LIST = new ArrayList<>();

    static {
        for (ResultCode value : ResultCode.values()) {
            if (value.code() == 200) {
                continue;
            }
            RESPONSE_MESSAGE_LIST.add(new ResponseMessageBuilder().code(value.code()).message(value.message()).build());
        }
    }

    @Bean
    public Docket createRestApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .useDefaultResponseMessages(false)
                .globalResponseMessage(RequestMethod.GET, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.HEAD, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.POST, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.PUT, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.PATCH, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.DELETE, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.OPTIONS, RESPONSE_MESSAGE_LIST)
                .globalResponseMessage(RequestMethod.TRACE, RESPONSE_MESSAGE_LIST)
                .select()
                .apis(RequestHandlerSelectors.basePackage("${basePackage}"))
                .paths(paths())
                .build();
    }


    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("接口文档")
                .description("接口查询文档")
                .version("1.0")
                .build();
    }

    private Predicate<String> paths() {
        return Predicates.and(PathSelectors.regex("/.*"), Predicates.not(PathSelectors.regex("/error")));
    }
}
