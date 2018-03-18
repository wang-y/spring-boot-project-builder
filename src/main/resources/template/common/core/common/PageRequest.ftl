package ${corepackage}.common;

import lombok.Data;

@Data
public class PageRequest extends PostRequest {

    private int page;

    private int size;

}
