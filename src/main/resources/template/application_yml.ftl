server:
  port: ${port}
  servlet:
    context-path: /${artifactId}

spring:
  application:
    name: ${artifactId}
  mvc:
    throw-exception-if-no-handler-found: true
  resources:
    add-mappings: false
  profiles:
    active: dev
<#if enableDatabase>
  datasource:
    <#switch databaseType>
        <#case "MYSQL">
    driver-class-name: com.mysql.jdbc.Driver
        <#break>
        <#case "SQLSERVER">
    driver-class-name: com.microsoft.sqlserver.jdbc.SQLServerDriver
        <#break>
    </#switch>
    <#switch databaseConnectPool>
        <#case "DRUID">
    type: com.alibaba.druid.pool.DruidDataSource
        <#break>
        <#case "HIKARICP">
    type: com.zaxxer.hikari.HikariDataSource
        <#break>
        <#default>
    type: com.alibaba.druid.pool.DruidDataSource
        <#break>
    </#switch>
    <#if ormType == "JPA">
  jpa:
    show-sql: true
    open-in-view: true
    hibernate:
      ddl-auto: none
      naming:
        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
    properties:
      hibernate:
        <#switch databaseType>
            <#case "MYSQL">
        dialect: org.hibernate.dialect.MySQLDialect
            <#break>
            <#case "SQLSERVER">
        dialect: org.hibernate.dialect.SQLServer2012Dialect
            <#break>
        </#switch>
    </#if>
</#if>

---
spring:
  profiles: dev
<#if enableDatabase>
  datasource:
    url: ${jdbcurl}
    username: ${username}
    password: ${password}
</#if>
---
spring:
  profiles: test
<#if enableDatabase>
  datasource:
    url: ${jdbcurl}
    username: ${username}
    password: ${password}
</#if>

---
spring:
  profiles: prod
<#if enableDatabase>
  datasource:
    url: ${jdbcurl}
    username: ${username}
    password: ${password}
</#if>
