package ${corepackage}.service.impl;

import com.querydsl.jpa.impl.JPAQueryFactory;
import ${corepackage}.page.SimplePage;
import ${corepackage}.repo.IBasicRepository;
import ${corepackage}.service.IBasicService;
import ${corepackage}.common.logs.annotations.ServiceLog;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.*;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;

@Transactional
public abstract class BasicService<V extends Serializable, E extends Serializable, ID extends Serializable> implements IBasicService<V, E, ID> {

    private Class<E> entityClass;

    private Class<V> voClass;

    private Class<ID> idClass;

    @Autowired
    private EntityManager entityManager;
    
    private JPAQueryFactory queryFactory;

    @PostConstruct
    public void initFactory() {
        queryFactory = new JPAQueryFactory(entityManager);
    }

    protected JPAQueryFactory queryFactory(){
    	return queryFactory;
    }

    public BasicService() {
        Type genType = getClass().getGenericSuperclass();
        Type[] params = ((ParameterizedType) genType).getActualTypeArguments();
        voClass = (Class) params[0];
        entityClass = (Class) params[1];
        idClass = (Class) params[2];
    }

    protected abstract IBasicRepository<E, ID> getRepository();

    @Override
    @ServiceLog(description = "持久化")
    public V save(V v) {
        E e=getRepository().save(voToEntity(v));
        v = entityToVo(e);
        return v;
    }

    @Override
    @ServiceLog(description = "通过主键删除")
    public void delByID(ID id) {
        getRepository().deleteById(id);
    }

    @Override
    @ServiceLog(description = "更新")
    public V update(V v) {
        getRepository().save(voToEntity(v));
        return v;
    }

    @Override
    @ServiceLog(description = "通过条件查找并排序")
    public Collection<V> list(HashMap<String, Object> params, LinkedHashMap<String, String> orderBy) {
        List<E> eList = getRepository().findAll(params, orderBy);
        List<V> vList = new ArrayList<>();
        eList.stream().forEach(e -> vList.add(entityToVo(e)));
        return vList ;
    }

    @Override
    @ServiceLog(description = "通过条件查找")
    public Collection<V> list(HashMap<String, Object> params) {
        return list(params,null);
    }

    @Override
    @ServiceLog(description = "获取所有")
    public Collection<V> listAll() {
        return getRepository().findAll().stream().map(e -> entityToVo(e)).collect(Collectors.toList());
    }

    @Override
    @ServiceLog(description = "分页查询")
    public SimplePage<V> page(HashMap<String, Object> params, LinkedHashMap<String, String> orderBy, int page, int size) {
        SimplePage<E> epage = getRepository().findByPage(params, orderBy, size, page);
        SimplePage<V> vpage = new SimplePage<>(epage.getPageInfo());
        epage.stream().forEach(e -> vpage.addResult(entityToVo(e)));
        return vpage;
    }

    @Override
    @ServiceLog(description = "通过逐渐查找")
    public V findOne(ID id) {
        return entityToVo(getRepository().findById(id).orElseGet(null));
    }

    @Override
    @ServiceLog(description = "通过主键查找")
    public E searchOne(ID id) {
        return getRepository().findById(id).orElseGet(null);
    }

    @Override
    @ServiceLog(description = "通过条件查找唯一对象")
    public V findOne(HashMap<String, Object> params) {
        return entityToVo(getRepository().findOne(params));
    }

    @Override
    @ServiceLog(description = "通过主键集合删除")
    public void delBatchByID(Collection<ID> id) {
        getRepository().delete(id);
    }

    @Override
    public E voToEntity(V v, String... ignore) {
        E e;
        try {
            e = entityClass.newInstance();
            BeanUtils.copyProperties(v, e, ignore);
        } catch (InstantiationException | IllegalAccessException | IllegalArgumentException e1) {
            e = null;
        }
        return e;
    }

    @Override
    public V entityToVo(E e, String... ignore) {
        V v;
        try {
            v = voClass.newInstance();
            BeanUtils.copyProperties(e, v, ignore);
        } catch (InstantiationException | IllegalAccessException | IllegalArgumentException e1) {
            v = null;
        }
        return v;
    }
}
