package ${corepackage}.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import ${corepackage}.common.exception.DataNotFoundException;
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
    public E findOne(ID id) {
        Optional<E> optional = repository.findById(id);
        if(optional.isPresent()){
           return optional.get();
        }else{
            throw new DataNotFoundException();
        }
    }

    @Override
    public E findOne(HashMap<String, Object> queryParams) {
        return repository.findOne(queryParams);
    }

    @Override
    public SimplePage<E> page(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy, int page, int size) {
        return repository.findByPage(queryParams, orderBy, size, page);
    }

    @Override
    public Collection<E> list(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy) {
        return  repository.findAll(queryParams, orderBy);
    }

    @Override
    public E save(E e) {
        return repository.save(e);
    }

    @Override
    public E update(E e) {
        return repository.save(e);
    }

    @Override
    public void delByID(ID id) {
        repository.deleteById(id);
    }

    @Override
    public void delBatchByID(Collection<ID> ids) {
        repository.deleteByIdConllection(ids);
    }
}
