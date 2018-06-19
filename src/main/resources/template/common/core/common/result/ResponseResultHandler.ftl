package ${corepackage}.common.result;

import ${corepackage}.common.RequestContextHolderUtil;
import ${corepackage}.common.interceptor.ResponseResultInterceptor;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

@ControllerAdvice
public class ResponseResultHandler implements ResponseBodyAdvice<Object> {
    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        ResponseResult responseResultAnn = (ResponseResult) RequestContextHolderUtil.getRequest().getAttribute(ResponseResultInterceptor.RESPONSE_RESULT);
        return responseResultAnn == null ? false : true;
    }

    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType, Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request, ServerHttpResponse response) {
        ResponseResult responseResultAnn = (ResponseResult) RequestContextHolderUtil.getRequest().getAttribute(ResponseResultInterceptor.RESPONSE_RESULT);

        Class<? extends Result> resultClazz = responseResultAnn.value();

        if (resultClazz.isAssignableFrom(PlatformResult.class)) {
            if (body instanceof DefaultErrorResult) {
                DefaultErrorResult defaultErrorResult = (DefaultErrorResult) body;
                return PlatformResult.builder()
                        .code(defaultErrorResult.getCode())
                        .message(defaultErrorResult.getMessage())
                        .data(defaultErrorResult.getErrors())
                        .build();
            }

            return PlatformResult.success(body);
        }

        return body;
    }
}
