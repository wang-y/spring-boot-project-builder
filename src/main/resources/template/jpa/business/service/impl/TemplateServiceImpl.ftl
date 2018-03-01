package ${businesspackage}.service.impl;

import ${businesspackage}.model.${modelName};
import ${businesspackage}.repository.${modelName}Repository;
import ${businesspackage}.service.${modelName}Service;
import ${businesspackage}.vo.${modelName}Vo;
import ${corepackage}.repo.IBasicRepository;
import ${corepackage}.service.impl.BasicService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Service
public class ${modelName}ServiceImpl extends BasicService<${modelName}Vo,${modelName},${PKType}> implements ${modelName}Service {

    private static final Logger LOGGER = LoggerFactory.getLogger(${modelName}ServiceImpl.class);

    @Resource
    private ${modelName}Repository repository;

    @Override
    protected IBasicRepository<${modelName}, ${PKType}> getRepository() {
        return repository;
    }

}
