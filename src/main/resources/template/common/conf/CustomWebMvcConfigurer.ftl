package ${confpackage};

import com.alibaba.fastjson.serializer.SerializerFeature;
import com.alibaba.fastjson.support.config.FastJsonConfig;
import com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter;
import ${corepackage}.common.interceptor.ResponseResultInterceptor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.charset.Charset;
import java.util.List;

@Slf4j
@Configuration
public class CustomWebMvcConfigurer implements WebMvcConfigurer {

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        FastJsonHttpMessageConverter converter = new FastJsonHttpMessageConverter();
        FastJsonConfig config = new FastJsonConfig();
        config.setSerializerFeatures(SerializerFeature.WriteMapNullValue,//保留空的字段
                SerializerFeature.WriteNullStringAsEmpty,//String null -> ""
                SerializerFeature.WriteNullNumberAsZero);//Number null -> 0
        converter.setFastJsonConfig(config);
        converter.setDefaultCharset(Charset.forName("UTF-8"));
        converters.add(converter);
    }

    @Bean
    public FilterRegistrationBean characterEncodingFilter() {
        FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean();
        CharacterEncodingFilter characterEncodingFilter = new CharacterEncodingFilter();
        characterEncodingFilter.setEncoding("UTF-8");
        characterEncodingFilter.setForceEncoding(true);
        filterRegistrationBean.setFilter(characterEncodingFilter);
        filterRegistrationBean.setOrder(Ordered.HIGHEST_PRECEDENCE-1);
        return filterRegistrationBean;
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addRedirectViewController("/", "/home.html");
    <#if enabledSwagger>
        registry.addRedirectViewController("/v2/api-docs", "/v2/api-docs");
        registry.addRedirectViewController("/swagger-resources/configuration/ui","/swagger-resources/configuration/ui");
        registry.addRedirectViewController("/swagger-resources/configuration/security","/swagger-resources/configuration/security");
        registry.addRedirectViewController("/swagger-resources", "/swagger-resources");
    </#if>
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/**.html").addResourceLocations("classpath:/static/");
    <#if enabledSwagger>
        registry.addResourceHandler("/swagger-ui.html**").addResourceLocations("classpath:/META-INF/resources/swagger-ui.html");
        registry.addResourceHandler("/webjars/**").addResourceLocations("classpath:/META-INF/resources/webjars/");
    </#if>
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new ResponseResultInterceptor()).excludePathPatterns("/**.html","/swagger-ui.html**","/webjars/**","/v2/api-docs","/swagger-resources/**","/swagger-resources");
    }

}