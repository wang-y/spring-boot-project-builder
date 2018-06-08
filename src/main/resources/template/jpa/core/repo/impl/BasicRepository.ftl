package ${corepackage}.repo.impl;

import ${corepackage}.page.PageInfo;
import ${corepackage}.page.SimplePage;
import ${corepackage}.repo.IBasicRepository;
import org.apache.commons.lang3.StringUtils;
import org.hibernate.query.NativeQuery;
import org.hibernate.transform.Transformers;
import org.joda.time.format.DateTimeFormat;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.data.jpa.provider.PersistenceProvider;
import org.springframework.data.jpa.repository.support.CrudMethodMetadata;
import org.springframework.data.jpa.repository.support.JpaEntityInformation;
import org.springframework.data.jpa.repository.support.QuerydslJpaRepository;
import org.springframework.util.Assert;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import java.beans.PropertyDescriptor;
import java.io.Serializable;
import java.sql.Timestamp;
import java.util.*;

import static org.springframework.beans.BeanUtils.getPropertyDescriptor;

public class BasicRepository<T, ID extends Serializable> extends QuerydslJpaRepository<T, ID>
        implements IBasicRepository<T, ID> {

    private final static String TIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
    private final static String DATE_FORMAT = "yyyy-MM-dd";

    private final JpaEntityInformation<T, ?> information;
    private final EntityManager em;
    @SuppressWarnings("unused")
    private final PersistenceProvider persistenceProvider;

    private CrudMethodMetadata metadata;

    /**
     * 构造函数
     */
    public BasicRepository(JpaEntityInformation<T, ID> entityInformation, EntityManager entityManager) {
        super(entityInformation, entityManager);
        this.information = entityInformation;
        this.em = entityManager;
        this.persistenceProvider = PersistenceProvider.fromEntityManager(entityManager);
    }

    private static String replaceAllSuffix(String str) {
        String result = str.replaceAll("_greaterOrEq", "").replaceAll("_lessOrEq", "").replaceAll("_lessThan", "")
                .replaceAll("_greaterThan", "").replaceAll("_start", "")
                .replaceAll("_end", "").replaceAll("_in", "").replaceAll("_notin", "").replaceAll("_null", "")
                .replaceAll("_notnull", "").replaceAll("_eq", "").replaceAll("_noteq", "").replaceAll("_like", "").replaceAll("_notlike", "");
        return result;
    }

    @Override
    protected CrudMethodMetadata getRepositoryMethodMetadata() {
        return metadata;
    }

    @Override
    public void setRepositoryMethodMetadata(CrudMethodMetadata crudMethodMetadata) {
        super.setRepositoryMethodMetadata(crudMethodMetadata);
        this.metadata = crudMethodMetadata;
    }

    @Override
    public void delete(Collection<ID> ids) {
        for (ID id : ids) {
            this.deleteById(id);
        }

    }

    @SuppressWarnings("unchecked")
    @Override
    public List<T> findAll(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby) {

        String whereHql = buildWhereQuery(queryParams);
        String orderHql = buildOrderby(orderby);

        String hql = "select entity from " + information.getEntityName() + " entity where 1=1 ";
        Query query = createQuery(hql + whereHql + orderHql, queryParams);

        List<T> list = (List<T>) query.getResultList();
        return list;
    }

    @Override
    public SimplePage<T> findByPage(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby,
                                    Integer pageSize, Integer pageNum) {

        return findByPage(queryParams, buildOrderby(orderby), pageSize, pageNum);

    }

    @SuppressWarnings("unchecked")
    @Override
    public SimplePage<T> findByPage(HashMap<String, Object> queryParams, String orderby, Integer pageSize,
                                    Integer pageNum) {

        String whereHql = buildWhereQuery(queryParams);
        String orderHql = orderby;

        String hql = "select count(*) from " + information.getEntityName() + " entity where 1=1 ";

        Query query = createQuery(hql + whereHql + orderHql, queryParams);
        PageInfo pageInfo = new PageInfo(((Long) query.getSingleResult()).intValue(), pageSize);
        pageInfo.refresh(pageNum);

        hql = "select entity from " + information.getEntityName() + " entity where 1=1 ";
        query = createQuery(hql + whereHql + orderHql, queryParams);
        query.setFirstResult(pageInfo.getStartRecord()).setMaxResults(pageInfo.getPageSize());

        return new SimplePage<T>(pageInfo, (List<T>) query.getResultList());
    }

    @SuppressWarnings("unchecked")
    @Override
    public SimplePage<T> findByPage(HashMap<String, Object> queryParams, Integer pageSize, Integer pageNum) {
        String whereHql = buildWhereQuery(queryParams);

        String hql = "select count(*) from " + information.getEntityName() + " entity where 1=1 ";
        Query query = createQuery(hql + whereHql, queryParams);
        PageInfo pageInfo = new PageInfo(((Long) query.getSingleResult()).intValue(), pageSize);
        pageInfo.refresh(pageNum);

        hql = "select entity from " + information.getEntityName() + " entity where 1=1 ";
        query = createQuery(hql + whereHql, queryParams);
        query.setFirstResult(pageInfo.getStartRecord()).setMaxResults(pageInfo.getPageSize());

        return new SimplePage<T>(pageInfo, (List<T>) query.getResultList());
    }

    private Query createQuery(String hql, HashMap<String, Object> queryParams) {
        Query query = em.createQuery(hql);
        setQueryParams(query, queryParams);
        return query;
    }

    @SuppressWarnings("unchecked")
    @Override
    public SimplePage<T> findByPageWithWhereHql(String whereHql, HashMap<String, Object> queryParams, Integer pageSize,
                                                Integer pageNum) {

        String hql = "select count(*) from " + information.getEntityName() + " entity where 1=1 ";
        if (whereHql == null) {
            whereHql = "";
        }

        Query query = em.createQuery(hql + whereHql);
        setQueryParams(query, queryParams);
        PageInfo pageInfo = new PageInfo(((Long) query.getSingleResult()).intValue(), pageSize);
        pageInfo.refresh(pageNum);

        hql = "select entity from " + information.getEntityName() + " entity where 1=1 ";
        query = em.createQuery(hql + whereHql);
        setQueryParams(query, queryParams);
        query.setFirstResult(pageInfo.getStartRecord()).setMaxResults(pageInfo.getPageSize());

        return new SimplePage<T>(pageInfo, (List<T>) query.getResultList());
    }

    @SuppressWarnings("unchecked")
    @Override
    public SimplePage<T> findByPageWithHql(String hql, HashMap<String, Object> queryParams, Integer pageSize,
                                           Integer pageNum) {

        Query query = em.createQuery("select count(*) from (" + hql + ")");
        setQueryParams(query, queryParams);

        PageInfo pageInfo = new PageInfo(((Long) query.getSingleResult()).intValue(), pageSize);
        pageInfo.refresh(pageNum);

        query = em.createQuery(hql);
        setQueryParams(query, queryParams);
        query.setFirstResult(pageInfo.getStartRecord()).setMaxResults(pageInfo.getPageSize());

        return new SimplePage<T>(pageInfo, (List<T>) query.getResultList());
    }

    @SuppressWarnings({"unchecked"})
    @Override
    public SimplePage<T> findByPageWithSql(String sql, HashMap<String, Object> queryParams, Integer pageSize,
                                           Integer pageNum) {

        Query query = em.createNativeQuery("select count(1) from (" + sql + ") T");
        setQueryParams(query, queryParams);

        PageInfo pageInfo = new PageInfo(((Long) query.getSingleResult()).intValue(), pageSize);
        pageInfo.refresh(pageNum);

        query = em.createNativeQuery(sql);
        setQueryParams(query, queryParams);
        query.setFirstResult(pageInfo.getStartRecord()).setMaxResults(pageInfo.getPageSize());
        query.unwrap(NativeQuery.class).addEntity(this.getDomainClass());

        return new SimplePage<T>(pageInfo, (List<T>) query.getResultList());
    }

    @SuppressWarnings("unchecked")
     private void setQueryParams(Query query, HashMap<String, Object> queryParams) {
        if (queryParams != null && queryParams.size() > 0) {
            for (String key : queryParams.keySet()) {
                String tempKey = key;
                String[] tempKeys = tempKey.split("\\|");
                Map<String, Object> valueMap = null;
                if (queryParams.get(key) instanceof Map<?, ?>) {
                    valueMap = (Map<String, Object>) queryParams.get(key);
                }

                for (String str : tempKeys) {
                    Class<?> clazz = getFieldType(this.getDomainClass(), replaceAllSuffix(str));
                    if (clazz != null && clazz.equals(String.class) && !StringUtils.endsWithAny(str, "_in", "_notin")
                            && StringUtils.endsWithAny(str, "_like", "_notlike")) {
                        if (valueMap != null) {
                            query.setParameter(str, '%' + valueMap.get(str).toString() + '%');
                        } else {
                            query.setParameter(str, '%' + queryParams.get(key).toString() + '%');
                        }
                    } else if (str.endsWith("_in") || str.endsWith("_notin")) {
                        Object t;
                        if (valueMap != null) {
                            t = valueMap.get(str);
                        } else {
                            t = queryParams.get(key);
                        }

                        if (t instanceof List) {
                            List<Object> list = (List<Object>) t;
                            for (Object object : list) {
                                query.setParameter(str + list.indexOf(object), mapToClazz(object,clazz));
                            }
                        } else if (t.getClass().isArray()) {
                            Object[] array = (Object[]) t;
                            for (int i = 0; i < array.length; i++) {
                                query.setParameter(str + i, mapToClazz(array[i],clazz));
                            }
                        } else {
                            query.setParameter(str, mapToClazz(queryParams.get(key),clazz));
                        }
                    } else {
                        if (StringUtils.endsWithAny(str, "_null", "_notnull")) {
                            continue;
                        }
                        if (valueMap != null) {
                            query.setParameter(str, mapToClazz(queryParams.get(str),clazz));
                        }
                        query.setParameter(str, mapToClazz(queryParams.get(key),clazz));
                    }
                }
            }
        }
    }
    
    private static Object mapToClazz(Object obj, Class<?> clazz) {
        Object result = null;
        if(obj == null){
        } else if (clazz.equals(String.class)) {
            result = obj.toString();
        } else if (clazz.equals(Integer.class)) {
            result = Integer.parseInt(obj.toString());
        } else if (clazz.equals(Float.class)) {
            result = Float.parseFloat(obj.toString());
        } else if (clazz.equals(Double.class)) {
            result = Double.parseDouble(obj.toString());
        } else if (clazz.equals(Short.class)) {
            result = Short.parseShort(obj.toString());
        } else if (clazz.equals(Byte.class)) {
            result = Byte.parseByte(obj.toString());
        } else if (clazz.equals(Boolean.class)) {
            result = Boolean.parseBoolean(obj.toString());
        } else if (clazz.equals(Character.class)) {
            result = obj.toString();
        }else if (clazz.equals(Long.class)) {
            result = Long.parseLong(obj.toString());
        } else if (clazz.equals(Date.class)) {
            String str = obj.toString();
            if (str.length() >= 19) {
                result = DateTimeFormat.forPattern(TIME_FORMAT).parseDateTime(str).toDate();
            } else if (str.length() >= 10) {
                result = DateTimeFormat.forPattern(DATE_FORMAT).parseDateTime(str).toDate();
            }
        } else if (clazz.equals(Timestamp.class)) {
            String str = obj.toString();
            result = Timestamp.valueOf(str);
        }else if (clazz.equals(java.sql.Date.class)) {
            String str = obj.toString();
            result = java.sql.Date.valueOf(str);
        }
        return result;
    }

    private String buildOrderby(LinkedHashMap<String, String> orderby) {
        StringBuffer orderbyql = new StringBuffer("");
        if (orderby != null && orderby.size() > 0) {
            orderbyql.append(" order by ");
            for (String key : orderby.keySet()) {
                orderbyql.append("entity.").append(key).append(" ").append(orderby.get(key)).append(",");
            }
            orderbyql.deleteCharAt(orderbyql.length() - 1);
        }

        return orderbyql.toString();
    }

    @SuppressWarnings("unchecked")
    private String buildWhereQuery(HashMap<String, Object> queryParams) {
        StringBuffer whereQueryHql = new StringBuffer("");
        if (queryParams != null && queryParams.size() > 0) {
            for (String key : queryParams.keySet()) {
                whereQueryHql.append(" and (");
                String operator = " and ";
                if (key.contains("|")) {
                    operator = " or ";
                }
                String tempKey = key;
                String[] tempKeys = tempKey.split("\\|");
                int index = 0;

                Map<String, Object> valueMap = null;
                if (queryParams.get(key) instanceof Map<?, ?>) {
                    valueMap = (Map<String, Object>) queryParams.get(key);
                }

                for (String str : tempKeys) {
                    String andOr = operator;
                    if (index++ == 0) {
                        andOr = "";
                    }
                    if (str.endsWith("_lessThan")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" <:")
                                .append(str);
                    } else if (str.endsWith("_greaterThan")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" >:")
                                .append(str);
                    } else if (str.endsWith("_lessOrEq")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" <=:")
                                .append(str);
                    } else if (str.endsWith("_greaterOrEq")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" >=:")
                                .append(str);
                    } else if (str.endsWith("_start")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" >=:")
                                .append(str);
                    } else if (str.endsWith("_end")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" <=:")
                                .append(str);
                    } else if (str.endsWith("_in")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" in (");

                        Object t = null;
                        if (valueMap != null) {
                            t = valueMap.get(str);
                        } else {
                            t = queryParams.get(key);
                        }

                        if (t instanceof List) {
                            List<Object> list = (List<Object>) t;
                            for (Object object : list) {
                                whereQueryHql.append(":" + str + list.indexOf(object));
                                if (list.indexOf(object) < list.size() - 1) {
                                    whereQueryHql.append(",");
                                }
                            }
                        } else if (t.getClass().isArray()) {
                            Object[] array = (Object[]) t;
                            for (int i = 0; i < array.length; i++) {
                                whereQueryHql.append(":" + str + i);
                                if (i < array.length - 1) {
                                    whereQueryHql.append(",");
                                }
                            }
                        } else {
                            whereQueryHql.append(":" + str);
                        }
                        whereQueryHql.append(")");
                    } else if (str.endsWith("_notin")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" not in (");

                        Object t = null;
                        if (valueMap != null) {
                            t = valueMap.get(str);
                        } else {
                            t = queryParams.get(key);
                        }

                        if (t instanceof List) {
                            List<Object> list = (List<Object>) t;
                            for (Object object : list) {
                                whereQueryHql.append(":" + str + list.indexOf(object));
                                if (list.indexOf(object) < list.size() - 1) {
                                    whereQueryHql.append(",");
                                }
                            }
                        } else if (t.getClass().isArray()) {
                            Object[] array = (Object[]) t;
                            for (int i = 0; i < array.length; i++) {
                                whereQueryHql.append(":" + str + i);
                                if (i < array.length - 1) {
                                    whereQueryHql.append(",");
                                }
                            }
                        } else {
                            whereQueryHql.append(":" + str);
                        }
                        whereQueryHql.append(")");
                    } else if (str.endsWith("_null")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" is null");
                    } else if (str.endsWith("_notnull")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str))
                                .append(" is not null");
                    } else if (str.endsWith("_eq")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" =:")
                                .append(str);
                    } else if (str.endsWith("_noteq")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" <>:")
                                .append(str);
                    } else if (str.endsWith("_like")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" like :")
                                .append(str);
                    } else if (str.endsWith("_notlike")) {
                        whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str))
                                .append(" not like :").append(str);
                    } else {
                        Class<?> clazz = getFieldType(this.getDomainClass(), key);
                        if (clazz != null && clazz.equals(String.class)) {
                            whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str))
                                    .append(" like :").append(str);
                        } else {
                            whereQueryHql.append(andOr).append("entity.").append(replaceAllSuffix(str)).append(" =:")
                                    .append(str);
                        }

                    }
                }
                whereQueryHql.append(")");
            }
        }

        return whereQueryHql.toString();
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<T> findAllBySql(Class<T> entityClass, String sql) {
        // 创建原生SQL查询QUERY实例,指定了返回的实体类型
        Query query = em.createNativeQuery(sql, entityClass);
        // 执行查询，返回的是实体列表,
        List<T> EntityList = (List<T>) query.getResultList();
        return EntityList;
    }

    public String getUniqueResultBySql(String sql, HashMap<String, Object> queryParams) {
        Query query = em.createNativeQuery(sql);
        for (String key : queryParams.keySet()) {
            query.setParameter(key, queryParams.get(key));
        }
        // 执行查询，返回的是实体列表,
        String result = (String) query.getSingleResult();
        return result;
    }

    @Override
    public boolean isPropertyUnique(String propertyName, Object newValue, Object oldValue) {

        if (newValue == null || newValue.equals(oldValue)) {
            return true;
        }

        Object object = findUniqueByProperty(propertyName, newValue);
        return (object == null);

    }

    @SuppressWarnings("unchecked")
    @Override
    public T findUniqueByProperty(String propertyName, Object value) {

        Assert.hasText(propertyName, "[Assertion failed] - this String argument must have text; it must not be null, empty, or blank");

        HashMap<String, Object> queryParams = new HashMap<String, Object>();
        queryParams.put(propertyName + "_eq", value);

        String whereHql = buildWhereQuery(queryParams);

        String hql = "select entity from " + information.getEntityName() + " entity where 1=1 ";
        Query query = createQuery(hql + whereHql, queryParams);

        if (query.getResultList().size() == 0) {
            return null;
        } else {
            return (T) query.getSingleResult();
        }
    }

    @SuppressWarnings({"unchecked"})
    @Override
    public List<Map<String, Object>> dosql(String sql, Object... value) {
        Query query = this.em.createNativeQuery(sql);

        int i = 1;

        if (value != null) {
            for (Object obj : value) {
                query.setParameter(i++, obj);
            }
        }

        query.unwrap(NativeQuery.class).setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);

        return query.getResultList();
    }

    @SuppressWarnings({"unchecked"})
    @Override
    public Map<String, Object> execsql(String sql, Object... value) {
        Query query = this.em.createNativeQuery(sql);

        int i = 1;

        for (Object obj : value) {
            query.setParameter(i++, obj);
        }

        query.unwrap(NativeQuery.class).setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);
        if (query.getResultList().size() == 0) {
            return null;
        } else {
            return (Map<String, Object>) query.getResultList().get(0);
        }
    }

    @Override
    public int ddl(String sql, Object... value) {
        Query query = this.em.createNativeQuery(sql);
        int i = 1;

        for (Object obj : value) {
            query.setParameter(i++, obj);
        }

        return query.executeUpdate();
    }

    @SuppressWarnings("unchecked")
    @Override
    public T findOne(HashMap<String, Object> queryParams) {
        String whereHql = buildWhereQuery(queryParams);
        String hql = "select entity from " + information.getEntityName() + " entity where 1=1 ";
        Query query = createQuery(hql + whereHql, queryParams);

        T t;
        try {
            t= (T) query.getSingleResult();
        }catch (NoResultException | EmptyResultDataAccessException e){
            t = null;
        }

        return t;
    }

    private static Class<?> getFieldType(Class<?> entityClass, String fieldName) {
        Assert.notNull(entityClass, "entityClass must not be null");
        Assert.notNull(fieldName, "fieldName must not be null");
        PropertyDescriptor pd = getPropertyDescriptor(entityClass, fieldName);
        return pd.getPropertyType();
    }

}

