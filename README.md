# spring-boot-project-builder

快速构建Spring Boot项目

```java
public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("demo")  //项目名
                .company("wymix")  //公司名
                .enableSwagger()  //启用swagger
                .setDataBaseType(DataBaseType.MYSQL)  //指定数据库类型（目前支持mysql/sqlserver）
                .JDBCconfigure("jdbc:mysql://192.168.1.11:3306/testf?zeroDateTimeBehavior=convertToNull&autoReconnect=true", "root", "12345678") //配置数据库
                .setOrmType(OrmType.JPA) //指定持久层框架(目前支持JPA/MyBatis)
                .setDataBaseConnectPool(DataBaseConnectPool.DRUID);//指定数据库连接池(目前支持DRUID/HIKARICP)

        //向"/home/wymix/workspaces/study_diary_workspaces/"输出项目文件
        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces/").build(projectConfig);

    }
}
```

一键生成 spring boot 项目代码

**本项目在mysql/sqlserver环境下测试均通过！**


# 使用JPA

在生成的代码中

src/test/java/com/company/project/CodeGenerator

```java
public static void main(String[] args) {
        genCode("test_table","Long");  //指定 表名(test_table) , 主键类型(Long)    生成对应表的model/vo/repository/service/web代码
//      genCode("test_table","Tt","Long");  //指定 表名(test_table),自定义类名(tt), 主键类型(Long);
    }
```

因该项目引入了QueryDSL，所以在生成代码后 执行 _mvn clean compile_  生成Q结构查询实体

# 使用MyBatis

**本模块代码复制自 https://github.com/lihengming/spring-boot-api-project-seed 版权归他 ^_^**

在生成的代码中

src/test/java/com/company/project/CodeGenerator

```java
public static void main(String[] args) {
        genCode("test_table");  //生成对应表的model/repository/service/web代码
//        genCodeByCustomModelName("输入表名","输入自定义Model名称");  
    }
```
