package ${corepackage}.common.body;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

@Data
public class PageRequest extends PostRequest {
    @ApiModelProperty(value = "页码",example = "1")
    private int page;
    @ApiModelProperty(value = "分页条数",example = "20")
    private int size;

}
