package ${corepackage}.service;

import ${corepackage}.page.SimplePage;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;

public interface IService<E, ID extends Serializable> {
    E findOne(ID id);

    E findOne(HashMap<String, Object> queryParams);

    SimplePage<E> page(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy, int page, int size);

    Collection<E> list(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy);

    E save(E e);

    E update(E e);

    void delByID(ID id);

    void delBatchByID(Collection<ID> ids);

}
