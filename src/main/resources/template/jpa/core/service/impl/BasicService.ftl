package ${corepackage}.service.impl;

import ${corepackage}.page.SimplePage;
import ${corepackage}.repo.IBasicRepository;
import ${corepackage}.service.IBasicService;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.*;
import org.springframework.transaction.annotation.Transactional;

@Transactional
public abstract class BasicService<V extends Serializable, E extends Serializable, ID extends Serializable> implements IBasicService<V, E, ID> {

    private Class<E> entityClass;

    private Class<V> voClass;

    private Class<ID> idClass;

    public BasicService() {
        Type genType = getClass().getGenericSuperclass();
        Type[] params = ((ParameterizedType) genType).getActualTypeArguments();
        voClass = (Class) params[0];
        entityClass = (Class) params[1];
        idClass = (Class) params[2];
    }

    protected abstract IBasicRepository<E, ID> getRepository();

    @Override

    public V save(V v) {
        E e=getRepository().save(voToEntity(v));
        v = entityToVo(e);
        return v;
    }

    @Override
    public void delByID(ID id) {
        getRepository().delete(id);
    }

    @Override
    public V update(V v) {
        getRepository().save(voToEntity(v));
        return v;
    }

    @Override
    public Collection<V> list(HashMap<String, Object> params, LinkedHashMap<String, String> orderBy) {
        List<E> eList = getRepository().findAll(params, orderBy);
        List<V> vList = new ArrayList<>();
        eList.stream().forEach(e -> vList.add(entityToVo(e)));
        return vList ;
    }

    @Override
    public Collection<V> list(HashMap<String, Object> params) {
        return list(params,null);
    }

    @Override
    public SimplePage<V> page(HashMap<String, Object> params, LinkedHashMap<String, String> orderBy, int page, int size) {
        SimplePage<E> epage = getRepository().findByPage(params, orderBy, size, page);
        SimplePage<V> vpage = new SimplePage<>(epage.getPageInfo());
        epage.stream().forEach(e -> vpage.addResult(entityToVo(e)));
        return vpage;
    }

    @Override
    public V findOne(ID id) {
        return entityToVo(getRepository().findOne(id));
    }

    @Override
    public V findOne(HashMap<String, Object> params) {
        return entityToVo(getRepository().findOne(params));
    }

    @Override
    public void delBatchByID(Collection<ID> id) {
        getRepository().delete(id);
    }

    @Override
    public E voToEntity(V v, String... ignore) {
        E e = null;
        try {
            e = entityClass.newInstance();
            BeanUtils.copyProperties(v, e, ignore);
        } catch (InstantiationException | IllegalAccessException | IllegalArgumentException e1) {
            e1.printStackTrace();
        }
        return e;
    }

    @Override
    public V entityToVo(E e, String... ignore) {
        V v = null;
        try {
            v = voClass.newInstance();
            BeanUtils.copyProperties(e, v, ignore);
        } catch (InstantiationException | IllegalAccessException | IllegalArgumentException e1) {
            e1.printStackTrace();
        }
        return v;
    }
}
