package ${corepackage}.service;

import ${corepackage}.page.SimplePage;

import java.io.Serializable;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;

public interface IBasicService<VO extends Serializable, ENTITY extends Serializable, ID extends Serializable> {

    VO save(VO vo);

    void delByID(ID id);

    VO update(VO vo);

    Collection<VO> list(HashMap<String, Object> params, LinkedHashMap<String, String> orderBy);

    Collection<VO> list(HashMap<String, Object> params);

    SimplePage<VO> page(HashMap<String, Object> params, LinkedHashMap<String, String> orderBy, int page, int size);

    VO findOne(ID id);

    VO findOne(HashMap<String, Object> params);

    void delBatchByID(Collection<ID> id);

    ENTITY voToEntity(VO vo, String... ignore) throws IllegalAccessException, InstantiationException;

    VO entityToVo(ENTITY entity, String... ignore) throws IllegalAccessException, InstantiationException;
}
