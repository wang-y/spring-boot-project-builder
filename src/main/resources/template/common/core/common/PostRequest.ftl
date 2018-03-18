package ${corepackage}.common;

import lombok.Data;

import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedHashMap;

@Data
public class PostRequest implements Serializable {

    private HashMap<String, Object> queryParams;

    private LinkedHashMap<String,String> orderBy;

}
