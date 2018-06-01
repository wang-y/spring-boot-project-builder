# spring-boot-project-builder

快速构建Spring Boot项目

下载 release 版本：

https://github.com/wang-y/spring-boot-project-builder/releases/download/1.0.0/spring-boot-project-builder.jar

下载完成后 运行命令
```
# java -jar spring-boot-project-builder.jar
```
根据引导一步步输入信息即可快速生成 spring boot 项目代码

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
