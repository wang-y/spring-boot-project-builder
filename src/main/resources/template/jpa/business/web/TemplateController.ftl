package ${businesspackage}.web;

import ${businesspackage}.model.${modelName};
import ${businesspackage}.service.${modelName}Service;
import ${businesspackage}.vo.${modelName}Vo;
import ${corepackage}.service.IBasicService;
import ${corepackage}.web.BasicController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

@RestController
@RequestMapping("${model}")
public class ${modelName}Controller extends BasicController<${modelName}Vo,${modelName},${PKType}> {

    private static final Logger LOGGER = LoggerFactory.getLogger(${modelName}Controller.class);

    @Resource
    private ${modelName}Service serviceImpl;

    @Override
    protected IBasicService<${modelName}Vo, ${modelName}, ${PKType}> getService() {
        return serviceImpl;
    }
}
