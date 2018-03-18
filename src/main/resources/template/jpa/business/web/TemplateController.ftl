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

@Slf4j
@RestController
@RequestMapping("${model}")
public class ${modelName}Controller extends BasicController<${modelName}Vo,${modelName},${PKType}> {

    @Resource
    private ${modelName}Service serviceImpl;

    @Override
    protected IBasicService<${modelName}Vo, ${modelName}, ${PKType}> getService() {
        return serviceImpl;
    }
}
