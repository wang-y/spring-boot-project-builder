package ${corepackage}.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import ${corepackage}.common.exception.DataNotFoundException;
import ${corepackage}.common.logs.annotations.ServiceLog;
import ${corepackage}.page.SimplePage;
import ${corepackage}.service.IService;
import ${corepackage}.repository.IRepository;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Optional;

@Transactional
public abstract class ServiceImpl<E, ID extends Serializable, REPOSITORY extends IRepository<E, ID>> implements IService<E, ID> {

    @Autowired
    protected REPOSITORY repository;

    @Override
    @ServiceLog(description="通过ID查找详情")
    public E findOne(ID id) {
        Optional<E> optional = repository.findById(id);
        if(optional.isPresent()){
           return optional.get();
        }else{
            throw new DataNotFoundException();
        }
    }

    @Override
    @ServiceLog(description="通过条件查找详情")
    public E findOne(HashMap<String, Object> queryParams) {
        return repository.findOne(queryParams);
    }

    @Override
    @ServiceLog(description="通过条件查找分页列表")
    public SimplePage<E> page(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy, int page, int size) {
        return repository.findByPage(queryParams, orderBy, size, page);
    }

    @Override
    @ServiceLog(description="通过条件查找列表")
    public Collection<E> list(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy) {
        return  repository.findAll(queryParams, orderBy);
    }

    @Override
    @ServiceLog(description="保存实体")
    public E save(E e) {
        return repository.save(e);
    }

    @Override
    @ServiceLog(description="修改实体")
    public E update(E e) {
        return repository.save(e);
    }

    @Override
    @ServiceLog(description="通过ID删除实体")
    public void delByID(ID id) {
        repository.deleteById(id);
    }

    @Override
    @ServiceLog(description="通过ID集合删除实体")
    public void delBatchByID(Collection<ID> ids) {
        repository.deleteByIdConllection(ids);
    }
}
