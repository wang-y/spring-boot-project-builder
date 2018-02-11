package ${corepackage}.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedHashMap;

public class PostRequest implements Serializable {

    private HashMap<String, Object> queryParams;

    private LinkedHashMap<String,String> orderBy;

    public HashMap<String, Object> getQueryParams() {
        return queryParams;
    }

    public void setQueryParams(HashMap<String, Object> queryParams) {
        this.queryParams = queryParams;
    }

    public LinkedHashMap<String, String> getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(LinkedHashMap<String, String> orderBy) {
        this.orderBy = orderBy;
    }
}
