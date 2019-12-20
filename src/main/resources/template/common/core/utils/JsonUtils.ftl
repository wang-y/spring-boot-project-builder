package ${corepackage}.utils;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

public final class JsonUtils {

    private final static ObjectMapper JSON_MAPPER = new ObjectMapper();

    private JsonUtils() {
    }

    public static <T> T json2Object(String value, Class<T> clz) throws IOException {
        return JSON_MAPPER.readValue(value, clz);
    }

    public static <T> String object2Json(T t) throws IOException {
        return JSON_MAPPER.writeValueAsString(t);
    }
}
