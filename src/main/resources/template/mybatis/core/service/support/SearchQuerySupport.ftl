package ${corepackage}.service.support;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import ${corepackage}.page.PageInfo;
import ${corepackage}.page.SimplePage;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

public final class SearchQuerySupport {

    private static String replaceAllSuffix(String str) {
        String result = str.replaceAll("_greaterOrEq", "").replaceAll("_lessOrEq", "").replaceAll("_lessThan", "")
                .replaceAll("_greaterThan", "").replaceAll("_start", "")
                .replaceAll("_end", "").replaceAll("_in", "").replaceAll("_notin", "").replaceAll("_null", "")
                .replaceAll("_notnull", "").replaceAll("_eq", "").replaceAll("_noteq", "").replaceAll("_like", "").replaceAll("_notlike", "");
        return result;
    }

    public static <T> List<T> helperForList(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy, BaseMapper<T> baseMapper, Class<T> tClass) {
        QueryWrapper<T> wrapper = builderQueryWrapper(queryParams, tClass);
        wrapper = buildOrderWrapper(orderBy, wrapper, tClass);
        List<T> list = baseMapper.selectList(wrapper);
        return list;
    }

    public static <T> T helperForOne(HashMap<String, Object> queryParams, BaseMapper<T> baseMapper, Class<T> tClass) {
        QueryWrapper<T> wrapper = builderQueryWrapper(queryParams, tClass);
        T t = baseMapper.selectOne(wrapper);
        return t;
    }

    public static <T> SimplePage<T> helperForPage(HashMap<String, Object> queryParams, LinkedHashMap<String, String> orderBy, BaseMapper<T> baseMapper, Class<T> tClass, int page, int size) {
        QueryWrapper<T> wrapper = builderQueryWrapper(queryParams, tClass);
        wrapper = buildOrderWrapper(orderBy, wrapper, tClass);
        IPage<T> iPage = baseMapper.selectPage(new Page<>(page, size), wrapper);
        PageInfo pageInfo = new PageInfo(iPage.getTotal(), size, page);
        SimplePage<T> simplePage = new SimplePage<>(pageInfo);
        simplePage.setResult(iPage.getRecords());
        return simplePage;
    }

    static <T> QueryWrapper<T> buildOrderWrapper(LinkedHashMap<String, String> orderBy, QueryWrapper<T> wrapper, Class<T> tClass) {
        List<String> ascList = new ArrayList<>();
        List<String> descList = new ArrayList<>();
        if(orderBy!=null) {
            orderBy.forEach((k, v) -> {
                try {
                    String fieldName = k;
                    Field field = tClass.getDeclaredField(k);
                    if (field != null) {
                        TableId tableId = field.getDeclaredAnnotation(TableId.class);
                        if (tableId != null) {
                            fieldName = tableId.value();
                        }
                        TableField tableField = field.getDeclaredAnnotation(TableField.class);
                        if (tableField != null) {
                            fieldName = tableField.value();
                        }
                        if ("ASC".equalsIgnoreCase(v)) {
                            ascList.add(fieldName);
                        } else {
                            descList.add(fieldName);
                        }
                    }
                } catch (NoSuchFieldException e) {
                    e.printStackTrace();
                }
            });
            if (!ascList.isEmpty()) {
                wrapper.orderByAsc(ascList.toArray(new String[]{}));
            }
            if (!descList.isEmpty()) {
                wrapper.orderByDesc(descList.toArray(new String[]{}));
            }
        }
        return wrapper;
    }

    static <T> QueryWrapper<T> builderQueryWrapper(HashMap<String, Object> queryParams, Class<T> tClass) {
        QueryWrapper<T> wrapper = new QueryWrapper<>();
        if (queryParams != null) {
            queryParams.forEach((k, v) -> {
                String fieldName = replaceAllSuffix(k);
                try {
                    Field field = tClass.getDeclaredField(fieldName);
                    if (field != null) {
                        TableId tableId = field.getDeclaredAnnotation(TableId.class);
                        if (tableId != null) {
                            fieldName = tableId.value();
                        }
                        TableField tableField = field.getDeclaredAnnotation(TableField.class);
                        if (tableField != null) {
                            fieldName = tableField.value();
                        }
                        if (k.endsWith("_lessThan")) {
                            wrapper.lt(fieldName, v);
                        } else if (k.endsWith("_greaterThan")) {
                            wrapper.gt(fieldName, v);
                        } else if (k.endsWith("_lessOrEq")) {
                            wrapper.le(fieldName, v);
                        } else if (k.endsWith("_greaterOrEq")) {
                            wrapper.ge(fieldName, v);
                        } else if (k.endsWith("_start")) {
                            wrapper.ge(fieldName, v);
                        } else if (k.endsWith("_end")) {
                            wrapper.le(fieldName, v);
                        } else if (k.endsWith("_in")) {
                            if (v instanceof String) {
                                Object[] array = ((String) v).split(",");
                                wrapper.in(fieldName, array);
                            } else if (v instanceof List) {
                                List<Object> list = (List<Object>) v;
                                wrapper.in(fieldName, list);
                            } else if (v.getClass().isArray()) {
                                Object[] array = (Object[]) v;
                                wrapper.in(fieldName, array);
                            }
                        } else if (k.endsWith("_notin")) {
                            if (v instanceof String) {
                                Object[] array = ((String) v).split(",");
                                wrapper.notIn(fieldName, array);
                            } else if (v instanceof List) {
                                List<Object> list = (List<Object>) v;
                                wrapper.notIn(fieldName, list);
                            } else if (v.getClass().isArray()) {
                                Object[] array = (Object[]) v;
                                wrapper.notIn(fieldName, array);
                            }
                        } else if (k.endsWith("_null")) {
                            wrapper.isNull(fieldName);
                        } else if (k.endsWith("_notnull")) {
                            wrapper.isNotNull(fieldName);
                        } else if (k.endsWith("_eq")) {
                            wrapper.eq(fieldName, v);
                        } else if (k.endsWith("_noteq")) {
                            wrapper.ne(fieldName, v);
                        } else if (k.endsWith("_like")) {
                            wrapper.like(fieldName, v);
                        } else if (k.endsWith("_notlike")) {
                            wrapper.notLike(fieldName, v);
                        } else {
                            Class<?> clazz = field.getType();
                            if (clazz != null && clazz.equals(String.class)) {
                                wrapper.like(fieldName, v);
                            } else {
                                wrapper.eq(fieldName, v);
                            }
                        }
                    }
                } catch (NoSuchFieldException e) {
                    e.printStackTrace();
                }
            });
        }
        return wrapper;
    }

}
