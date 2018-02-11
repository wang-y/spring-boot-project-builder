package ${corepackage}.utils;

import org.springframework.util.Assert;

import java.beans.PropertyDescriptor;

public abstract class ReflectUtil extends org.springframework.beans.BeanUtils {

    public static Class<?> getFieldType(Class<?> entityClass, String fieldName) {
        Assert.notNull(entityClass, "entityClass must not be null");
        Assert.notNull(fieldName, "fieldName must not be null");
        PropertyDescriptor pd = getPropertyDescriptor(entityClass, fieldName);
        return pd.getPropertyType();
    }

}
