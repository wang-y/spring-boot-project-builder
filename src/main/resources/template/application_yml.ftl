server:
  port: ${port}
  servlet:
    context-path: /${artifactId}
  allowed-cross-domain: true

spring:
  application:
    name: ${artifactId}
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    serialization:
      FAIL_ON_EMPTY_BEANS: false
  aop:
    proxy-target-class: true
  mvc:
    throw-exception-if-no-handler-found: true
  resources:
    add-mappings: false
  profiles:
    active: dev
<#if enableDatabase>
  datasource:
    driver-class-name: ${driverClassName}
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
      <#else>
mybatis-plus:
  mapper-locations: classpath*:/mapper/*.xml
    </#if>
</#if>
logging:
  level:
    root: info
    ${type}.${name}.${artifactId}.*: debug

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
