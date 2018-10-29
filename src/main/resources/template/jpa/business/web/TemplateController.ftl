package ${businesspackage}.web;

import ${businesspackage}.model.${modelName};
import ${businesspackage}.service.${modelName}Service;
import ${businesspackage}.vo.${modelName}Vo;
import ${corepackage}.service.IBasicService;
import ${corepackage}.web.BasicController;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * 当方法返回值为 String 类型时，须指定返回的内容类型为MediaType.APPLICATION_JSON_VALUE，否则会报出强制类型转换异常
 * 示例：
 *    @GetMapping(name = "test",produces = MediaType.APPLICATION_JSON_VALUE)
 *    public String getString() {
 *        return "Hello,World!";
 *    }
 */

@Slf4j
@RestController
@RequestMapping("${baseRequestMapping}")
public class ${modelName}Controller extends BasicController<${modelName}Vo,${modelName},${PKType}> {

    @Resource
    private ${modelName}Service serviceImpl;

    @Override
    protected IBasicService<${modelName}Vo, ${modelName}, ${PKType}> getService() {
        return serviceImpl;
    }
}
