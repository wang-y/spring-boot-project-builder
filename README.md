# spring-boot-project-builder
Spring Boot项目快速构建

```java
public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("demo")
                .company("wymix")
                .enableSwagger()
                .setDataBaseType(DataBaseType.MYSQL)
                .configure("jdbc:mysql://192.168.1.11:3306/testf?zeroDateTimeBehavior=convertToNull&autoReconnect=true", "root", "ori18502800930")
                .setOrmType(OrmType.JPA)
                .setDataBaseConnectPool(DataBaseConnectPool.DRUID);

        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces/").build(projectConfig);

    }
}
```

一键生成 spring boot 项目代码
