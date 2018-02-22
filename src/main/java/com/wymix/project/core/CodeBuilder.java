package com.wymix.project.core;

import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;
import freemarker.template.TemplateExceptionHandler;

import java.io.*;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

public final class CodeBuilder {

    private static final String PROJECT_PATH = System.getProperty("user.dir");//项目在硬盘上的基础路径
    private static final String TEMPLATE_FILE_PATH = PROJECT_PATH + "/src/main/resources/template";//模板位置

    private String path;
    private ProjectConfig projectConfig;

    private String PACKAGE_PATH_CONF;
    private String PACKAGE_PATH_CORE;

    private String BASE_PACKAGE_PATH;

    private String PACKAGE_CONF;
    private String PACKAGE_CORE;
    private String PACKAGE_BUSINESS;
    private String BASE_PACKAGE;

    private static freemarker.template.Configuration getConfiguration() throws IOException {
        freemarker.template.Configuration cfg = new freemarker.template.Configuration(freemarker.template.Configuration.VERSION_2_3_23);
        cfg.setDirectoryForTemplateLoading(new File(TEMPLATE_FILE_PATH));
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.IGNORE_HANDLER);
        return cfg;
    }

    private static String packageConvertPath(String packageName) {
        return String.format("/%s/", packageName.contains(".") ? packageName.replaceAll("\\.", "/") : packageName);
    }

    private final static String POM_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<project xmlns=\"http://maven.apache.org/POM/4.0.0\"\n" +
            "         xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n" +
            "         xsi:schemaLocation=\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\">\n" +
            "    <modelVersion>4.0.0</modelVersion>\n\n";

    private final static String POM_FOOTER = "\n\n</project>";

    private String getRoot() {
        return this.path + "/" + this.projectConfig.project;
    }

    private String getJavaPath() {
        return getRoot() + "/src/main/java/";
    }

    private String getTestJavaPath() {
        return getRoot() + "/src/test/java/";
    }

    private String getTestResourcesPath() {
        return getRoot() + "/src/test/resources/";
    }

    public static CodeBuilder toFilePath(String path) {
        CodeBuilder codeBuilder = new CodeBuilder();
        codeBuilder.path = path;
        return codeBuilder;
    }

    public void build(ProjectConfig projectConfig) {
        this.projectConfig = projectConfig;
        String basepackage = "com." + projectConfig.company + "." + projectConfig.project;

        PACKAGE_CONF = basepackage + ".conf";
        PACKAGE_CORE = basepackage + ".core";
        PACKAGE_BUSINESS=basepackage+ ".business";
        BASE_PACKAGE = basepackage;

        PACKAGE_PATH_CONF = packageConvertPath(PACKAGE_CONF);
        PACKAGE_PATH_CORE = packageConvertPath(PACKAGE_CORE);
        BASE_PACKAGE_PATH = packageConvertPath(BASE_PACKAGE);

        touchDir();
        touchConfigFile();
        modifyPom();
        modifyApplication();
        createStarter();

        switch (projectConfig.dataBaseConfig.getOrmType()) {
            case JPA:
                copyCoreJPAJava();
                copyConfJPAJava();
                genJPABusinessLogicCode();
                break;
//            case MYBATIS:
//                copyCoreMYBATISJava();
//                break;
            default:
                copyCoreJPAJava();
                copyConfJPAJava();
                genJPABusinessLogicCode();
                break;
        }
        copyCoreCommonJava();
        copyConfCommonJava();
        if(projectConfig.enable_swagger){
            copyConfSwaggerJava();
        }
        ///
        copyCodeTemplate();
        System.out.println("项目创建完毕！");
    }

    private void copyCodeTemplate() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("businesspackage", PACKAGE_BUSINESS);
            data.put("corepackage", PACKAGE_CORE);

            data.put("modelName", "${modelName}");
            data.put("PKType", "${PKType}");

            File file = new File(getTestResourcesPath()  + "generator/template/repository/TemplateRepository.ftl");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/business/repository/TemplateRepository.ftl").process(data, new FileWriter(file));

            file = new File(getTestResourcesPath()  + "generator/template/service/TemplateService.ftl");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/business/service/TemplateService.ftl").process(data, new FileWriter(file));

            file = new File(getTestResourcesPath()  + "generator/template/service/impl/TemplateServiceImpl.ftl");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/business/service/impl/TemplateServiceImpl.ftl").process(data, new FileWriter(file));

            file = new File(getTestResourcesPath()  + "generator/template/web/TemplateController.ftl");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/business/web/TemplateController.ftl").process(data, new FileWriter(file));

            String url = projectConfig.dataBaseConfig.getJdbc_url();
            String cleanURI = url.substring(5);

            URI uri = URI.create(cleanURI);

            data = new HashMap<>();
            data.put("basepackage", BASE_PACKAGE);
            data.put("database_user", projectConfig.dataBaseConfig.getUser());
            data.put("database_passowrd", projectConfig.dataBaseConfig.getPassword());
            data.put("host", uri.getHost());
            data.put("port", String.valueOf(uri.getPort()));
            data.put("database", uri.getPath().replaceFirst("/",""));
            data.put("businesspackage", PACKAGE_BUSINESS);

            file = new File(getTestJavaPath() +BASE_PACKAGE_PATH + "CodeGenerator.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("gen/CodeGenerator.ftl").process(data, new FileWriter(file));
        }catch (Exception e){
            System.out.println("代码生成器类创建失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("代码生成器类创建完毕！");
    }

    private void copyConfSwaggerJava() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("confpackage", PACKAGE_CONF);
            data.put("basepackage", BASE_PACKAGE);

            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "SwaggerConf.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/SwaggerConf.ftl").process(data, new FileWriter(file));
        }catch (Exception e){
            System.out.println("swagger配置类生成失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("swagger配置类生成完毕！");
    }

    private void genJPABusinessLogicCode() {
        File file = new File(getJavaPath() + BASE_PACKAGE_PATH + "business/repository");
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(getJavaPath() + BASE_PACKAGE_PATH + "business/service/impl");
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(getJavaPath() + BASE_PACKAGE_PATH + "business/web");
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(getJavaPath() + BASE_PACKAGE_PATH + "business/model");
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(getJavaPath() + BASE_PACKAGE_PATH + "business/vo");
        if (!file.exists()) {
            file.mkdirs();
        }
        System.out.println("JPA业务包创建完毕！");
    }

    private void copyCoreCommonJava() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("corepackage", PACKAGE_CORE);

            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/Result.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/Result.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/ResultCode.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/ResultCode.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/PostRequest.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/PostRequest.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/PageRequest.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/PageRequest.ftl").process(data, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("通用核心库生成失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("通用核心库生成完毕！");
    }

    private void copyConfCommonJava() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            Map<String, Object> data = new HashMap<>();
            data.put("confpackage", PACKAGE_CONF);
            data.put("corepackage", PACKAGE_CORE);
            data.put("enabledSwagger",projectConfig.enable_swagger);
            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "WebMvcConfigurer.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/WebMvcConfigurer.ftl").process(data, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("通用配置类生成失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("通用配置类生成完毕！");
    }

    private void copyConfJPAJava() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            Map<String, Object> data = new HashMap<>();
            data.put("confpackage", PACKAGE_CONF);
            data.put("corepackage", PACKAGE_CORE);
            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "JPAConfig.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/conf/JPAConfig.ftl").process(data, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("JPA配置类生成失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("JPA配置类生成完毕！");
    }

    private void copyCoreJPAJava() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("corepackage", PACKAGE_CORE);

            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repo/IBasicRepository.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repo/IBasicRepository.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repo/impl/BasicRepository.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repo/impl/BasicRepository.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repo/factory/CrudMethodMetadataPostProcessor.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repo/factory/CrudMethodMetadataPostProcessor.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repo/factory/JpaRepositoryFactory.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repo/factory/JpaRepositoryFactory.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repo/factory/JpaRepositoryFactoryBean.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repo/factory/JpaRepositoryFactoryBean.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "utils/ReflectUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/utils/ReflectUtil.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "page/PageInfo.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/page/PageInfo.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "page/SimplePage.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/page/SimplePage.ftl").process(data, new FileWriter(file));

            //

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/impl/BasicService.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/service/impl/BasicService.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/IBasicService.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/service/IBasicService.ftl").process(data, new FileWriter(file));
            //
            //
            //
            data.put("enabledSwagger",projectConfig.enable_swagger);
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "web/BasicController.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/web/BasicController.ftl").process(data, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("JPA核心包生成失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("JPA核心包生成完毕！");
    }

    private void createStarter() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            Map<String, Object> data = new HashMap<>();
            data.put("basepackage", BASE_PACKAGE);
            File file = new File(getJavaPath() + BASE_PACKAGE_PATH + "Application.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("Application.ftl").process(data, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("启动类 Application.java 生成失败！");
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("启动类 Application.java 生成完毕！");
    }

    private void modifyPom() {
        FileOutputStream outputStream = null;
        PrintWriter writer = null;
        try {
            String pom = getRoot() + "/pom.xml";
            File file = new File(pom);
            outputStream = new FileOutputStream(file);
            writer = new PrintWriter(outputStream);
            writer.write(POM_HEADER);
            writer.write("    <parent>\n");
            writer.write("        <groupId>org.springframework.boot</groupId>\n");
            writer.write("        <artifactId>spring-boot-starter-parent</artifactId>\n");
            writer.write("        <version>1.5.10.RELEASE</version>\n");
            writer.write("    </parent>\n\n");

            writer.write("    <groupId>com." + this.projectConfig.company + "</groupId>\n");
            writer.write("    <artifactId>" + this.projectConfig.project + "</artifactId>\n");
            writer.write("    <version>0.0.1-SNAPSHOT</version>\n");
            writer.write("    <packaging>jar</packaging>\n\n");

            writer.write("    <properties>\n");
            writer.write("        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>\n");
            writer.write("        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>\n");
            writer.write("        <java.version>1.8</java.version>\n");
            writer.write("    </properties>\n\n");

            writer.write("    <dependencies>\n");
            writer.write("        <dependency>\n");
            writer.write("            <groupId>org.springframework.boot</groupId>\n");
            writer.write("            <artifactId>spring-boot-starter-web</artifactId>\n");
            writer.write("            <exclusions>\n");
            writer.write("                <exclusion>\n");
            writer.write("                    <groupId>org.springframework.boot</groupId>\n");
            writer.write("                    <artifactId>spring-boot-starter-tomcat</artifactId>\n");
            writer.write("                </exclusion>\n");
            writer.write("            </exclusions>\n");
            writer.write("        </dependency>\n");
            writer.write("        <dependency>\n");
            writer.write("            <groupId>org.springframework.boot</groupId>\n");
            writer.write("            <artifactId>spring-boot-starter-undertow</artifactId>\n");
            writer.write("        </dependency>\n");

            if (projectConfig.enable_swagger) {
                writer.write("        <dependency>\n");
                writer.write("            <groupId>io.springfox</groupId>\n");
                writer.write("            <artifactId>springfox-swagger2</artifactId>\n");
                writer.write("            <version>2.7.0</version>\n");
                writer.write("        </dependency>\n");
                writer.write("        <dependency>\n");
                writer.write("            <groupId>io.springfox</groupId>\n");
                writer.write("            <artifactId>springfox-swagger-ui</artifactId>\n");
                writer.write("            <version>2.7.0</version>\n");
                writer.write("        </dependency>\n");
                writer.write("        <dependency>\n");
                writer.write("            <groupId>io.springfox</groupId>\n");
                writer.write("            <artifactId>springfox-staticdocs</artifactId>\n");
                writer.write("            <version>2.6.1</version>\n");
                writer.write("        </dependency>\n");
            }

            if (projectConfig.dataBaseConfig.getDataBaseType() != DataBaseType.NONE) {
                switch (projectConfig.dataBaseConfig.getDataBaseType()) {
                    case MYSQL:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>mysql</groupId>\n");
                        writer.write("            <artifactId>mysql-connector-java</artifactId>\n");
                        writer.write("        </dependency>\n");
                        break;
                    case ORACLE:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>com.oracle.jdbc</groupId>\n");
                        writer.write("            <artifactId>ojdbc8</artifactId>\n");
                        writer.write("            <version>12.2.0.1</version>\n");
                        writer.write("        </dependency>\n");
                        break;
                    case DB2:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>com.oracle.jdbc</groupId>\n");
                        writer.write("            <artifactId>ojdbc8</artifactId>\n");
                        writer.write("            <version>12.2.0.1</version>\n");
                        writer.write("        </dependency>\n");
                        break;
                    case SQLSERVER:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>com.oracle.jdbc</groupId>\n");
                        writer.write("            <artifactId>ojdbc8</artifactId>\n");
                        writer.write("            <version>12.2.0.1</version>\n");
                        writer.write("        </dependency>\n");
                        break;
                }

                switch (projectConfig.dataBaseConfig.getOrmType()) {
                    case JPA:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>org.springframework.boot</groupId>\n");
                        writer.write("            <artifactId>spring-boot-starter-data-jpa</artifactId>\n");
                        writer.write("        </dependency>\n");
                        break;
//                    case MYBATIS:
//                        writer.write("        <dependency>\n");
//                        writer.write("            <groupId>org.mybatis</groupId>\n");
//                        writer.write("            <artifactId>mybatis-spring</artifactId>\n");
//                        writer.write("            <version>1.3.1</version>\n");
//                        writer.write("        </dependency>\n");
//                        writer.write("        <dependency>\n");
//                        writer.write("            <groupId>org.mybatis</groupId>\n");
//                        writer.write("            <artifactId>mybatis</artifactId>\n");
//                        writer.write("            <version>3.4.5</version>\n");
//                        writer.write("        </dependency>\n");
//                        writer.write("        <dependency>\n");
//                        writer.write("            <groupId>tk.mybatis</groupId>\n");
//                        writer.write("            <artifactId>mapper</artifactId>\n");
//                        writer.write("            <version>3.4.2</version>\n");
//                        writer.write("        </dependency>\n");
//                        writer.write("        <dependency>\n");
//                        writer.write("            <groupId>com.github.pagehelper</groupId>\n");
//                        writer.write("            <artifactId>pagehelper</artifactId>\n");
//                        writer.write("            <version>4.2.1</version>\n");
//                        writer.write("        </dependency>\n");
//                        break;
                    default:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>org.springframework.boot</groupId>\n");
                        writer.write("            <artifactId>spring-boot-starter-data-jpa</artifactId>\n");
                        writer.write("        </dependency>\n");
                        break;
                }

                switch (projectConfig.dataBaseConfig.getDataBaseConnectPool()) {
                    case DRUID:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>com.alibaba</groupId>\n");
                        writer.write("            <artifactId>druid-spring-boot-starter</artifactId>\n");
                        writer.write("            <version>1.1.6</version>\n");
                        writer.write("        </dependency>\n");
                        break;
                    case C3P0:
                        break;
                    case HIKARICP:
                        break;
                    default:
                        writer.write("        <dependency>\n");
                        writer.write("            <groupId>com.alibaba</groupId>\n");
                        writer.write("            <artifactId>druid-spring-boot-starter</artifactId>\n");
                        writer.write("            <version>1.1.6</version>\n");
                        writer.write("        </dependency>\n");
                        break;
                }
            }

            writer.write("        <dependency>\n");
            writer.write("            <groupId>com.alibaba</groupId>\n");
            writer.write("            <artifactId>fastjson</artifactId>\n");
            writer.write("            <version>1.2.44</version>\n");
            writer.write("        </dependency>\n");

            writer.write("        <dependency>\n");
            writer.write("            <groupId>org.projectlombok</groupId>\n");
            writer.write("            <artifactId>lombok</artifactId>\n");
            writer.write("            <version>1.16.20</version>\n");
            writer.write("            <scope>provided</scope>\n");
            writer.write("        </dependency>\n");

            writer.write("        <dependency>\n");
            writer.write("            <groupId>commons-codec</groupId>\n");
            writer.write("            <artifactId>commons-codec</artifactId>\n");
            writer.write("        </dependency>\n");

            writer.write("        <dependency>\n");
            writer.write("            <groupId>org.apache.commons</groupId>\n");
            writer.write("            <artifactId>commons-lang3</artifactId>\n");
            writer.write("            <version>3.7</version>\n");
            writer.write("        </dependency>\n");

            writer.write("        <dependency>\n");
            writer.write("            <groupId>org.freemarker</groupId>\n");
            writer.write("            <artifactId>freemarker</artifactId>\n");
            writer.write("            <version>2.3.23</version>\n");
            writer.write("            <scope>test</scope>\n");
            writer.write("        </dependency>\n");

            writer.write("        <dependency>\n");
            writer.write("            <groupId>com.google.guava</groupId>\n");
            writer.write("            <artifactId>guava</artifactId>\n");
            writer.write("            <version>24.0-jre</version>\n");
            writer.write("        </dependency>\n");

            writer.write("    </dependencies>\n\n");

            writer.write("    <build>\n");
            writer.write("        <finalName>" + this.projectConfig.project + "</finalName>\n");
            writer.write("        <plugins>\n");
            writer.write("            <plugin>\n");
            writer.write("                <groupId>org.springframework.boot</groupId>\n");
            writer.write("                <artifactId>spring-boot-maven-plugin</artifactId>\n");
            writer.write("                <configuration>\n");
            writer.write("                    <fork>true</fork>\n");
            writer.write("                    <mainClass>com." + this.projectConfig.company + "." + this.projectConfig.project + ".Application</mainClass>\n");
            writer.write("                    <executable>true</executable>\n");
            writer.write("                </configuration>\n");
            writer.write("                <executions>\n");
            writer.write("                    <execution>\n");
            writer.write("                        <goals>\n");
            writer.write("                            <goal>repackage</goal>\n");
            writer.write("                        </goals>\n");
            writer.write("                    </execution>\n");
            writer.write("                </executions>\n");
            writer.write("                <dependencies>\n");
            writer.write("                    <dependency>\n");
            writer.write("                        <groupId>org.springframework</groupId>\n");
            writer.write("                        <artifactId>springloaded</artifactId>\n");
            writer.write("                        <version>1.2.6.RELEASE</version>\n");
            writer.write("                    </dependency>\n");
            writer.write("                </dependencies>\n");
            writer.write("            </plugin>\n");
            writer.write("            <plugin>\n");
            writer.write("                <groupId>org.apache.maven.plugins</groupId>\n");
            writer.write("                <artifactId>maven-compiler-plugin</artifactId>\n");
            writer.write("                <configuration>\n");
            writer.write("                    <source>${java.version}</source>\n");
            writer.write("                    <target>${java.version}</target>\n");
            writer.write("                </configuration>\n");
            writer.write("            </plugin>\n");
            writer.write("        </plugins>\n");
            writer.write("    </build>");

            writer.write(POM_FOOTER);
            writer.flush();

            System.out.println("pom.xml 依赖引入完毕！");
        } catch (Exception e) {
            System.out.println("pom.xml 依赖引入失败！");
            e.printStackTrace();
            System.exit(0);
        } finally {
            if (writer != null) {
                writer.close();
            }
            if (outputStream != null) {
                try {
                    outputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void modifyApplication() {
        FileOutputStream outputStream = null;
        PrintWriter writer = null;
        try {
            String yml = getRoot() + "/src/main/resources/application.yml";
            File file = new File(yml);
            outputStream = new FileOutputStream(file);
            writer = new PrintWriter(outputStream);
            writer.write("server: \n");
            writer.write("  port: " + projectConfig.port + "\n");
            writer.write("  context-path: /" + projectConfig.project + "\n\n");

            writer.write("spring: \n");
            writer.write("  application: \n");
            writer.write("    name: " + projectConfig.project + "\n");
            writer.write("  mvc: \n");
            writer.write("    throw-exception-if-no-handler-found: true\n");
            writer.write("  resources: \n");
            writer.write("    add-mappings: false\n");
            writer.write("  profiles: \n");
            writer.write("    active: dev\n");

            if (projectConfig.dataBaseConfig.getDataBaseType() != DataBaseType.NONE) {
                writer.write("  datasource: \n");
                switch (projectConfig.dataBaseConfig.getDataBaseType()) {
                    case MYSQL:
                        writer.write("    driver-class-name: com.mysql.jdbc.Driver\n");
                        break;
                    case ORACLE:
                        writer.write("    driver-class-name: oracle.jdbc.OracleDriver\n");
                        break;
                    case DB2:
                        writer.write("    driver-class-name: \n");
                        break;
                    case SQLSERVER:
                        writer.write("    driver-class-name: \n");
                        break;

                }
                switch (projectConfig.dataBaseConfig.getDataBaseConnectPool()) {
                    case DRUID:
                        writer.write("    type: com.alibaba.druid.pool.DruidDataSource\n");
                        break;
                    case C3P0:
                        writer.write("    type: oracle.jdbc.OracleDriver\n");
                        break;
                    case HIKARICP:
                        writer.write("    type: \n");
                        break;
                    default:
                        writer.write("    type: com.alibaba.druid.pool.DruidDataSource\n");
                        break;

                }

                if (projectConfig.dataBaseConfig.getOrmType() == OrmType.JPA) {
                    writer.write("  jpa: \n");
                    writer.write("    show-sql: true\n");
                    writer.write("    open-in-view: true\n");
                    writer.write("    hibernate: \n");
                    writer.write("      ddl-auto: none\n");
                }
            }

            writer.write("\n---\n");
            writer.write("spring: \n");
            writer.write("  profiles: dev\n");
            if (projectConfig.dataBaseConfig.getDataBaseType() != DataBaseType.NONE) {
                writer.write("  datasource: \n");
                writer.write("    url: " + projectConfig.dataBaseConfig.getJdbc_url() + "\n");
                writer.write("    username: " + projectConfig.dataBaseConfig.getUser() + "\n");
                writer.write("    password: " + projectConfig.dataBaseConfig.getPassword() + "\n");
            }
            writer.write("\n---\n");
            writer.write("spring: \n");
            writer.write("  profiles: test\n");
            if (projectConfig.dataBaseConfig.getDataBaseType() != DataBaseType.NONE) {
                writer.write("  datasource: \n");
                writer.write("    url: " + projectConfig.dataBaseConfig.getJdbc_url() + "\n");
                writer.write("    username: " + projectConfig.dataBaseConfig.getUser() + "\n");
                writer.write("    password: " + projectConfig.dataBaseConfig.getPassword() + "\n");
            }
            writer.write("\n---\n");
            writer.write("spring: \n");
            writer.write("  profiles: prod\n");
            if (projectConfig.dataBaseConfig.getDataBaseType() != DataBaseType.NONE) {
                writer.write("  datasource: \n");
                writer.write("    url: " + projectConfig.dataBaseConfig.getJdbc_url() + "\n");
                writer.write("    username: " + projectConfig.dataBaseConfig.getUser() + "\n");
                writer.write("    password: " + projectConfig.dataBaseConfig.getPassword() + "\n");
            }
            writer.flush();
            System.out.println("application.yml 配置完毕！");
        } catch (Exception e) {
            System.out.println("application.yml 配置失败！");
            e.printStackTrace();
            System.exit(0);
        } finally {
            if (writer != null) {
                writer.close();
            }
            if (outputStream != null) {
                try {
                    outputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void touchConfigFile() {
        try {
            String pom = getRoot() + "/pom.xml";
            File file = new File(pom);
            if (!file.exists()) {
                file.createNewFile();
            }
            String yml = getRoot() + "/src/main/resources/application.yml";
            file = new File(yml);
            if (!file.exists()) {
                file.createNewFile();
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(0);
        }
        System.out.println("项目配置文件创建完毕！");
    }

    private void touchDir() {
        String mainjava = getJavaPath();
        String mainresource = getRoot() + "/src/main/resources";
        String testjava = getRoot() + "/src/test/java";
        String testresource = getRoot() + "/src/test/java";

        File file = new File(getRoot());
        if (!file.exists()) {
            file.mkdir();
        }
        file = new File(mainjava);
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(mainresource);
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(testjava);
        if (!file.exists()) {
            file.mkdirs();
        }
        file = new File(testresource);
        if (!file.exists()) {
            file.mkdirs();
        }
        System.out.println("项目目录创建完毕！");

    }
}
