package ${corepackage}.service.impl;

import ${corepackage}.common.exception.BusinessException;
import ${corepackage}.common.logs.annotations.ServiceLog;
import ${corepackage}.mapper.Mapper;
import ${corepackage}.service.Service;

import org.springframework.beans.factory.annotation.Autowired;
import tk.mybatis.mapper.entity.Condition;

import java.io.Serializable;
import java.lang.reflect.Field;
import java.lang.reflect.ParameterizedType;
import java.util.List;

/**
 * 基于通用MyBatis Mapper插件的Service接口的实现
 */
public abstract class AbstractService<T,ID extends Serializable> implements Service<T,ID> {

    @Autowired
    protected Mapper<T> mapper;

    private Class<T> modelClass;    // 当前泛型真实类型的Class

    public AbstractService() {
        ParameterizedType pt = (ParameterizedType) this.getClass().getGenericSuperclass();
        modelClass = (Class<T>) pt.getActualTypeArguments()[0];
    }

    @ServiceLog(description = "持久化")
    public void save(T model) {
        mapper.insertSelective(model);
    }

    @ServiceLog(description = "批量持久化")
    public void save(List<T> models) {
        mapper.insertList(models);
    }

    @ServiceLog(description = "通过主鍵刪除")
    public void deleteById(ID id) {
        mapper.deleteByPrimaryKey(id);
    }

    @ServiceLog(description = "通过主鍵批量刪除")
    public void deleteByIds(String ids) {
        mapper.deleteByIds(ids);
    }

    @ServiceLog(description = "更新")
    public void update(T model) {
        mapper.updateByPrimaryKeySelective(model);
    }

    @ServiceLog(description = "通过ID查找")
    public T findById(ID id) {
        return mapper.selectByPrimaryKey(id);
    }

    @ServiceLog(description = "根据自定义条件查找")
    @Override
    public T findBy(String fieldName, Object value) throws Exception {
        try {
            T model = modelClass.newInstance();
            Field field = modelClass.getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(model, value);
            return mapper.selectOne(model);
        } catch (ReflectiveOperationException e) {
            throw new BusinessException(e.getMessage(), e);
        }
    }

    @ServiceLog(description = "通过多个ID查找")
    public List<T> findByIds(String ids) {
        return mapper.selectByIds(ids);
    }

    @ServiceLog(description = "根据条件查找")
    public List<T> findByCondition(Condition condition) {
        return mapper.selectByCondition(condition);
    }

    @ServiceLog(description = "获取所有")
    public List<T> findAll() {
        return mapper.selectAll();
    }
}
