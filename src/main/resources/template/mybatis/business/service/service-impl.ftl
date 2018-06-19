package ${basePackage}.business.service.impl;

import ${basePackage}.business.repository.${modelNameUpperCamel}Mapper;
import ${basePackage}.business.model.${modelNameUpperCamel};
import ${basePackage}.business.service.${modelNameUpperCamel}Service;
import ${basePackage}.core.service.impl.AbstractService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;

@Slf4j
@Service
@Transactional
public class ${modelNameUpperCamel}ServiceImpl extends AbstractService<${modelNameUpperCamel},${IDType}> implements ${modelNameUpperCamel}Service {
    @Resource
    private ${modelNameUpperCamel}Mapper ${modelNameLowerCamel}Mapper;

}
