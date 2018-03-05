package ${corepackage}.repo;

import ${corepackage}.page.SimplePage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.NoRepositoryBean;

import java.io.Serializable;
import java.util.*;

@NoRepositoryBean
public interface IBasicRepository<T, ID extends Serializable>
        extends JpaRepository<T, ID>, JpaSpecificationExecutor<T>, QuerydslPredicateExecutor<T> {

    public void delete(Collection<ID> ids);

    public List<T> findAll(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby);

    public SimplePage<T> findByPage(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby,
                                    Integer pageSize, Integer pageNum);

    public SimplePage<T> findByPageWithSql(String sql, HashMap<String, Object> queryParams, Integer pageSize,
                                           Integer pageNum);

    public SimplePage<T> findByPageWithHql(String hql, HashMap<String, Object> queryParams, Integer pageSize,
                                           Integer pageNum);

    public SimplePage<T> findByPageWithWhereHql(String whereHql, HashMap<String, Object> queryParams, Integer pageSize,
                                                Integer pageNum);

    public SimplePage<T> findByPage(HashMap<String, Object> queryParams, String orderby, Integer pageSize,
                                    Integer pageNum);

    public List<T> findAllBySql(Class<T> entityClass, String sql);

    public String getUniqueResultBySql(String sql, HashMap<String, Object> queryParams);

    public SimplePage<T> findByPage(HashMap<String, Object> queryParams, Integer pageSize, Integer pageNum);

    public boolean isPropertyUnique(String propertyName, Object newValue, Object oldValue);

    public T findUniqueByProperty(String propertyName, Object value);

    public List<Map<String, Object>> dosql(String sql, Object... value);

    public Map<String, Object> execsql(String sql, Object... value);

    public int ddl(String sql, Object... value);

    public T findOne(HashMap<String, Object> queryParams);

}

