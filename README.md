# spring-boot-project-builder
Spring Boot项目快速构建

```java
public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("demo")  //项目名
                .company("wymix")  //公司名
                .enableSwagger()  //启用swagger
                .setDataBaseType(DataBaseType.MYSQL)  //指定数据库类型（目前仅支持mysql）
                .configure("jdbc:mysql://192.168.1.11:3306/testf?zeroDateTimeBehavior=convertToNull&autoReconnect=true", "root", "ori18502800930") //配置数据库
                .setOrmType(OrmType.JPA) //指定持久层框架(目前仅JPA)
                .setDataBaseConnectPool(DataBaseConnectPool.DRUID);//指定数据库连接池(目前仅支持DRUID)

        //向"/home/wymix/workspaces/study_diary_workspaces/"输出项目文件
        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces/").build(projectConfig);

    }
}
```

一键生成 spring boot 项目代码

在生成的代码中

src/test/java/com/company/project/CodeGenerator

```java
public static void main(String[] args) {
        genCode("test_table","Long");  //指定 表名(test_table) , 主键类型(Long)    生成对应表的model/vo/repository/service/web代码
//      genCode("test_table","Tt","Long");  //指定 表名(test_table),自定义类名(tt), 主键类型(Long);
    }
```
