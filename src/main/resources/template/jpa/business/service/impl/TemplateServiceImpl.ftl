package ${businesspackage}.service.impl;

import ${businesspackage}.model.${modelName};
import ${businesspackage}.repository.${modelName}Repository;
import ${businesspackage}.service.${modelName}Service;
import ${businesspackage}.vo.${modelName}Vo;
import ${corepackage}.repo.IBasicRepository;
import ${corepackage}.service.impl.BasicService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Slf4j
@Service
public class ${modelName}ServiceImpl extends BasicService<${modelName}Vo,${modelName},${PKType}> implements ${modelName}Service {

    @Resource
    private ${modelName}Repository repository;

    @Override
    protected IBasicRepository<${modelName}, ${PKType}> getRepository() {
        return repository;
    }

}
