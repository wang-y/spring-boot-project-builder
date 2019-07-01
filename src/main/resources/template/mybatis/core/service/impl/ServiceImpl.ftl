package ${corepackage}.service.impl;

import com.baomidou.mybatisplus.core.enums.SqlMethod;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.toolkit.GlobalConfigUtils;
import com.baomidou.mybatisplus.core.toolkit.ReflectionKit;
import com.baomidou.mybatisplus.extension.toolkit.SqlHelper;
import org.apache.ibatis.session.SqlSession;
import org.mybatis.spring.SqlSessionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import ${corepackage}.page.SimplePage;
import ${corepackage}.service.IService;
import ${corepackage}.service.support.SearchQuerySupport;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;

public abstract class ServiceImpl<E, ID extends Serializable, REPOSITORY extends BaseMapper<E>> implements IService<E, ID> {

    @Autowired
    protected REPOSITORY repository;

    /**
     * 判断数据库操作是否成功
     *
     * @param result 数据库操作返回影响条数
     * @return boolean
     */
    protected boolean retBool(Integer result) {
        return SqlHelper.retBool(result);
    }

    protected Class<E> currentModelClass() {
        return (Class<E>) ReflectionKit.getSuperClassGenericType(getClass(), 0);
    }

    /**
     * 批量操作 SqlSession
     */
    protected SqlSession sqlSessionBatch() {
        return SqlHelper.sqlSessionBatch(currentModelClass());
    }

    /**
     * 释放sqlSession
     *
     * @param sqlSession session
     */
    protected void closeSqlSession(SqlSession sqlSession) {
        SqlSessionUtils.closeSqlSession(sqlSession, GlobalConfigUtils.currentSessionFactory(currentModelClass()));
    }

    /**
     * 获取 SqlStatement
     *
     * @param sqlMethod ignore
     * @return ignore
     */
    protected String sqlStatement(SqlMethod sqlMethod) {
        return SqlHelper.table(currentModelClass()).getSqlStatement(sqlMethod.getMethod());
    }


    @Override
    public E findOne(ID id) {
        return repository.selectById(id);
    }

    @Override
    public E findOne(HashMap<String, Object> queryParams) {
        return SearchQuerySupport.helperForOne(queryParams,repository,currentModelClass());
    }

    @Override
    public SimplePage<E> page(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy, int page, int size) {
        return SearchQuerySupport.helperForPage(queryParams, orderBy, repository, currentModelClass(), page, size);
    }

    @Override
    public Collection<E> list(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy) {
        return SearchQuerySupport.helperForList(queryParams,orderBy,repository,currentModelClass());
    }

    @Override
    public E save(E e) {
        repository.insert(e);
        return e;
    }

    @Override
    public E update(E e) {
        repository.updateById(e);
        return e;
    }

    @Override
    public void delByID(ID id) {
        repository.deleteById(id);
    }

    @Override
    public void delBatchByID(Collection<ID> ids) {
        repository.deleteBatchIds(ids);
    }
}
