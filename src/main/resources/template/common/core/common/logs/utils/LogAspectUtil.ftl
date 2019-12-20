package ${corepackage}.common.logs.utils;

import org.aspectj.lang.ProceedingJoinPoint;
import org.springframework.web.multipart.MultipartFile;
import ${corepackage}.utils.JsonUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Description:
 *  AOP记录日志的一些共用方法
 */
public class LogAspectUtil {

    private LogAspectUtil(){
    }

    /**
     * 获取需要记录日志方法的参数，敏感参数用*代替
     * @param joinPoint 切点
     * @return 去除敏感参数后的Json字符串
     */
    public static String getMethodParams(ProceedingJoinPoint joinPoint){
        Object[] arguments = joinPoint.getArgs();
        StringBuilder sb = new StringBuilder();
        if(arguments ==null || arguments.length <= 0){
            return sb.toString();
        }
        for (Object arg : arguments) {
            <#if enableWeb>
            String paramStr;
            if (arg instanceof HttpServletResponse) {
                paramStr = HttpServletResponse.class.getSimpleName();
            } else if (arg instanceof HttpServletRequest) {
                paramStr = HttpServletRequest.class.getSimpleName();
            } else if (arg instanceof MultipartFile) {
                long size = ((MultipartFile) arg).getSize();
                paramStr = MultipartFile.class.getSimpleName() + " size:" + size;
            } else {
                paramStr = convertObj2Str(arg);
            }
            <#else>
            String paramStr = convertObj2Str(arg);
            </#if>
            sb.append(paramStr).append(",");
        }
        return sb.deleteCharAt(sb.length() - 1).toString();
    }

    /**
     * 对象转换为字符串
     *
     * @param obj 参数对象
     * @return 参数对象
     */
    public static String convertObj2Str(Object obj) {
        if (obj == null || obj instanceof Exception) {
            return "{}";
        }
        String param;
        try {
            param = JsonUtils.object2Json(obj);
        } catch (Exception e) {
            return String.valueOf(obj);
        }
        return param;
    }
}
