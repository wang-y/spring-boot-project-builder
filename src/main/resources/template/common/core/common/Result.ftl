package ${corepackage}.common;

import com.alibaba.fastjson.JSON;
<#if enabledSwagger>
import io.swagger.annotations.ApiModelProperty;
</#if>

/**
 * 统一API响应结果封装
 */
public class Result<T> {

    <#if enabledSwagger>
    @ApiModelProperty(value = "应答码")
    </#if>
    private int code;

    <#if enabledSwagger>
    @ApiModelProperty(value = "应答信息")
    </#if>
    private String message;

    <#if enabledSwagger>
    @ApiModelProperty(value = "请求返回值")
    </#if>
    private T data;

    public Result() {
    }

    public Result(T data) {
        this.data=data;
    }

    public Result(int code, String message) {
        this.message=message;
        this.code = code;
    }

    public Result setCode(ResultCode resultCode) {
        this.code = resultCode.code();
        return this;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public Result setMessage(String message) {
        this.message = message;
        return this;
    }

    public T getData() {
        return data;
    }

    public Result setData(T data) {
        this.data = data;
        return this;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
