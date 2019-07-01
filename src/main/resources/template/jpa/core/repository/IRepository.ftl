package ${corepackage}.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.repository.NoRepositoryBean;
import ${corepackage}.page.SimplePage;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@NoRepositoryBean
public interface IRepository<E,ID extends Serializable>  extends JpaRepository<E, ID>, JpaSpecificationExecutor<E> {

    void deleteByIdConllection(Collection<ID> ids);

    List<E> findAll(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby);

    SimplePage<E> findByPage(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderby,
                             Integer pageSize, Integer pageNum);

    SimplePage<E> findByPageWithSql(String sql, HashMap<String, Object> queryParams, Integer pageSize,
                                    Integer pageNum);

    SimplePage<E> findByPageWithHql(String hql, HashMap<String, Object> queryParams, Integer pageSize,
                                    Integer pageNum);

    SimplePage<E> findByPageWithWhereHql(String whereHql, HashMap<String, Object> queryParams, Integer pageSize,
                                         Integer pageNum);

    SimplePage<E> findByPage(HashMap<String, Object> queryParams, String orderby, Integer pageSize,
                             Integer pageNum);

    List<E> findAllBySql(Class<E> entityClass, String sql);

    String getUniqueResultBySql(String sql, HashMap<String, Object> queryParams);

    SimplePage<E> findByPage(HashMap<String, Object> queryParams, Integer pageSize, Integer pageNum);

    boolean isPropertyUnique(String propertyName, Object newValue, Object oldValue);

    E findUniqueByProperty(String propertyName, Object value);

    List<Map<String, Object>> findAllBySql(String sql, Object... value);

    Map<String, Object> findOneBySql(String sql, Object... value);

    int execute(String sql, Object... value);

    E findOne(HashMap<String, Object> queryParams);

}

