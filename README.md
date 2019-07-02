# spring-boot-project-builder

快速构建Spring Boot项目

下载 release 版本：

https://github.com/wang-y/spring-boot-project-builder/releases/latest

下载完成后 解压zip/tar.gz 在 bin/ 目录下 运行命令
```
# windows: create.bat
# linux:   create.sh
```
根据引导一步步输入信息即可快速生成 spring boot 项目代码

**本项目支持 MYSQL、SQL_SERVER、MARIADB、ORACLE、DB2、POSTGRE_SQL、SQLITE、H2 数据库**

**注：Oracle 及 DB2 因商业软件问题，驱动未开源，需要手动设置maven依赖**

**注：使用SQLITE数据库时，如果使用JPA作为ORM，因Hibernater无对应Dialect，需要手动创建SqliteDialect**

在生成的代码中

src/test/java/com/company/project/Generator

```java
public static void main(String[] args) {
        generate("test_table","Long");  //指定 表名(test_table) , 主键类型(Long)    生成对应表的model/repository/service/web代码
    }
```