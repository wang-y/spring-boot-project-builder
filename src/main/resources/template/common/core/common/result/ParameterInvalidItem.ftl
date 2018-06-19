package ${corepackage}.common.result;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Description:
 *  参数无效项
 */
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
public class ParameterInvalidItem {

    /**
     * 无效字段的名称
     */
    private String fieldName;

    /**
     * 错误信息
     */
    private String message;


}