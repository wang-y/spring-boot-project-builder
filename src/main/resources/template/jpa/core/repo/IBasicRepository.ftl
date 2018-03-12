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

    void delete(Collection<ID> ids);

    List<T> findAll(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby);

    SimplePage<T> findByPage(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby,
                                    Integer pageSize, Integer pageNum);

    SimplePage<T> findByPageWithSql(String sql, HashMap<String, Object> queryParams, Integer pageSize,
                                           Integer pageNum);

    SimplePage<T> findByPageWithHql(String hql, HashMap<String, Object> queryParams, Integer pageSize,
                                           Integer pageNum);

    SimplePage<T> findByPageWithWhereHql(String whereHql, HashMap<String, Object> queryParams, Integer pageSize,
                                                Integer pageNum);

    SimplePage<T> findByPage(HashMap<String, Object> queryParams, String orderby, Integer pageSize,
                                    Integer pageNum);

    List<T> findAllBySql(Class<T> entityClass, String sql);

    String getUniqueResultBySql(String sql, HashMap<String, Object> queryParams);

    SimplePage<T> findByPage(HashMap<String, Object> queryParams, Integer pageSize, Integer pageNum);

    boolean isPropertyUnique(String propertyName, Object newValue, Object oldValue);

    T findUniqueByProperty(String propertyName, Object value);

    List<Map<String, Object>> dosql(String sql, Object... value);

    Map<String, Object> execsql(String sql, Object... value);

    int ddl(String sql, Object... value);

    T findOne(HashMap<String, Object> queryParams);

}

