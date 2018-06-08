package ${corepackage}.common;

<#if enabledSwagger>
import io.swagger.annotations.ApiModelProperty;
</#if>
import lombok.Data;

@Data
public class PageRequest extends PostRequest {
<#if enabledSwagger>
    @ApiModelProperty(value = "页码",example = "1")
</#if>
    private int page;
<#if enabledSwagger>
    @ApiModelProperty(value = "分页条数",example = "20")
</#if>
    private int size;

}
