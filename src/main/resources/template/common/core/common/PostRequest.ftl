package ${corepackage}.common;

<#if enabledSwagger>
import io.swagger.annotations.ApiModelProperty;
</#if>
import lombok.Data;

import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedHashMap;

@Data
public class PostRequest implements Serializable {
<#if enabledSwagger>
    @ApiModelProperty(value = "请求参数", notes = "请求参数格式为： “key:为 “字段名_判断”，value 为 “值”, 如查询id=5，则应如此写：{\"id_eq\":5}")
</#if>
    private HashMap<String, Object> queryParams;
<#if enabledSwagger>
    @ApiModelProperty(value = "排序参数", notes = "排序参数格式为： “key:为 “字段名”，value 为 “ASC/DESC”, 如以id升序排序，则应如此写：{\"id\":\"ASC\"}")
</#if>
    private LinkedHashMap<String,String> orderBy;

}
