package ${corepackage}.mapper;

public interface Mapper<T>
        extends
        InsertMapper<T>,
        DeleteMapper<T>,
        UpdateMapper<T>,
        SelectMapper<T> {
}
