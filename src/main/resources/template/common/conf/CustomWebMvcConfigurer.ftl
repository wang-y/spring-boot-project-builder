package ${confpackage};

import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.MethodParameter;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import ${corepackage}.common.body.PageRequest;
import ${corepackage}.common.body.PostRequest;
import ${corepackage}.common.interceptor.ResponseResultInterceptor;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;


@Slf4j
@Configuration
public class CustomWebMvcConfigurer implements WebMvcConfigurer {

    @Value("${allowed_cross_domain}")
    private boolean allowedCrossDomain;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        if (allowedCrossDomain) {
            registry.addMapping("/**")
                    .allowedOrigins("*")
                    .allowedMethods("POST", "GET", "OPTIONS", " DELETE", "PUT", "PATCH")
                    .allowCredentials(true).maxAge(0L)
                    .allowedHeaders("Origin", " No-Cache", "X-Requested-With", "If-Modified-Since", "Pragma", "Last-Modified", "Cache-Control", "Expires", "Content-Type", "X-E4M-With", "userId", "token");
        } else {
            WebMvcConfigurer.super.addCorsMappings(registry);
        }
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
        registry.addResourceHandler("/home.html").addResourceLocations("classpath:/static/home.html");
    <#if enabledSwagger>
        registry.addResourceHandler("/doc.html**").addResourceLocations("classpath:/META-INF/resources/doc.html");
        registry.addResourceHandler("/webjars/**").addResourceLocations("classpath:/META-INF/resources/webjars/");
    </#if>
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new ResponseResultInterceptor()).excludePathPatterns("/**.html","/swagger-ui.html**","/webjars/**","/v2/api-docs","/swagger-resources/**","/swagger-resources");
    }
	
	@Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(new PostRequestHandlerMethodArgumentResolver());
    }

    static class PostRequestHandlerMethodArgumentResolver implements HandlerMethodArgumentResolver {
        @Override
        public boolean supportsParameter(MethodParameter parameter) {
            return parameter.getParameterType().equals(PostRequest.class) || parameter.getParameterType().equals(PageRequest.class);
        }

        @Override
        public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer, NativeWebRequest webRequest, WebDataBinderFactory binderFactory) throws Exception {
            PostRequest postRequest;

            HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);
            final String queryParams = request.getParameter("queryParams");
            final String orderBy = request.getParameter("orderBy");

            if (parameter.getParameterType().equals(PostRequest.class)) {
                postRequest = new PostRequest();
            } else {
                final String page = request.getParameter("page");
                final String size = request.getParameter("size");
                postRequest = new PageRequest(StringUtils.isEmpty(page) ? 1 : Integer.parseInt(page), StringUtils.isEmpty(size) ? 1 : Integer.parseInt(size));
            }
            if (!StringUtils.isEmpty(queryParams)) {
                final HashMap p = JSONObject.parseObject(queryParams, HashMap.class);
                postRequest.setQueryParams(p);
            }
            if (!StringUtils.isEmpty(orderBy)) {
                final LinkedHashMap o = JSONObject.parseObject(orderBy, LinkedHashMap.class);
                postRequest.setOrderBy(o);
            }

            return postRequest;
        }
    }
}