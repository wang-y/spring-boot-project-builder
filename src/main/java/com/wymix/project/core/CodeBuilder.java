package com.wymix.project.core;

import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;
import com.wymix.project.core.constant.VersionConstants;
import freemarker.template.TemplateExceptionHandler;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

import static com.wymix.project.core.constant.DataBaseType.*;

public final class CodeBuilder {

    private static final String PROJECT_PATH = System.getProperty("user.dir");//项目在硬盘上的基础路径
    private static final String TEMPLATE_FILE_PATH = PROJECT_PATH + "/src/main/resources/template";//模板位置

    private Map<String ,Object> modelData=new HashMap<>();

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

    private String getRoot() {
        return this.path + "/" + this.projectConfig.project;
    }

    private String getJavaPath() {
        return getRoot() + "/src/main/java/";
    }

    private String getResourcePath() {
        return getRoot() + "/src/main/resources/";
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
        checkConfig();
        String basepackage = projectConfig.type+"." + projectConfig.name + "." + projectConfig.project;
        PACKAGE_CONF = basepackage + ".conf";
        PACKAGE_CORE = basepackage + ".core";
        PACKAGE_BUSINESS = basepackage + ".business";
        BASE_PACKAGE = basepackage;

        PACKAGE_PATH_CONF = packageConvertPath(PACKAGE_CONF);
        PACKAGE_PATH_CORE = packageConvertPath(PACKAGE_CORE);
        BASE_PACKAGE_PATH = packageConvertPath(BASE_PACKAGE);

        buildModelData();

        touchDir();
        createPom();
        createApplication();
        createStarter();

        createCommonCore();
        createCommonConf();

        if(!projectConfig.dataBaseConfig.getDataBaseType().equals(DataBaseType.NONE)) {
            switch (projectConfig.dataBaseConfig.getOrmType()) {
                case MYBATIS:
                    createMyBatisCore();
                    createMyBatisConf();
                    break;
                default:
                    createJPACore();
                    createJPAConf();
                    break;
            }
             createGenertor();
        }
        if (projectConfig.enable_swagger) {
            createSwaggerConf();
        }
        if(projectConfig.enable_docker){
            createDockerfile();
        }
        createGenertor();
        createBanner();
        System.out.println("项目创建完毕！");
    }

    private void buildModelData() {
        modelData.put("basePackage", BASE_PACKAGE);
        modelData.put("confpackage", PACKAGE_CONF);
        modelData.put("corepackage", PACKAGE_CORE);

        modelData.put("enabledSwagger", projectConfig.enable_swagger);
        modelData.put("jdbcurl", this.projectConfig.dataBaseConfig.getJdbc_url());
        modelData.put("username", this.projectConfig.dataBaseConfig.getUser());
        modelData.put("password", this.projectConfig.dataBaseConfig.getPassword());
        modelData.put("artifactId", this.projectConfig.project);
        modelData.put("allowed_cross_domain","${server.allowed-cross-domain}");

        modelData.put("groupId", this.projectConfig.type+"."+this.projectConfig.name);
        modelData.put("enableDocker", this.projectConfig.enable_docker);
        modelData.put("enableDatabase", !this.projectConfig.dataBaseConfig.getDataBaseType().equals(DataBaseType.NONE));
        modelData.put("databaseType", this.projectConfig.dataBaseConfig.getDataBaseType().toString());
        modelData.put("ormType", this.projectConfig.dataBaseConfig.getOrmType().toString());
        modelData.put("databaseConnectPool", this.projectConfig.dataBaseConfig.getDataBaseConnectPool().toString());


        modelData.put("SPRING_BOOT_VERSION", VersionConstants.SPRING_BOOT_VERSION);
        modelData.put("DRUID_VERSION", VersionConstants.DRUID_VERSION);
        modelData.put("MYBATIS_PLUS_VERSION", VersionConstants.MYBATIS_PLUS_VERSION);

        modelData.put("dockerimageprefix","${docker.image.prefix}");
        modelData.put("projectartifactId","${project.artifactId}");
        modelData.put("directory","${project.build.directory}");
        modelData.put("finalName","${project.build.finalName}");


        modelData.put("port", ""+this.projectConfig.port);
        modelData.put("type", ""+this.projectConfig.type);
        modelData.put("name", ""+this.projectConfig.name);
        modelData.put("driverClassName", this.projectConfig.dataBaseConfig.getDataBaseType().getDriverClassName());
        modelData.put("ormType", this.projectConfig.dataBaseConfig.getOrmType().toString());

        if(this.projectConfig.dataBaseConfig.getDataBaseType()!=NONE) {
                    modelData.put("DRIVER_CLASS_NAME",this.projectConfig.dataBaseConfig.getDataBaseType().getDriverClassName());
                    modelData.put("DBTYPE", this.projectConfig.dataBaseConfig.getDataBaseType().toString());
        }
    }

    private void createGenertor() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            if (projectConfig.dataBaseConfig.getOrmType() == OrmType.MYBATIS) {
                File file = new File(getTestJavaPath() + BASE_PACKAGE_PATH+"Generator.java");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("generator/m_Generator.ftl").process(modelData, new FileWriter(file));

                String projectPath = System.getProperty("user.dir")+"/src/main/resources/template/generator/m_vm";
                File source=new File(projectPath);
                File[] files = source.listFiles();
                for (File vm : files) {
                    File temp = new File(getRoot() + "/src/main/resources/templates/" + vm.getName());
                    if(!temp.getParentFile().exists()){
                        temp.getParentFile().mkdir();
                    }
                    try {
                        Files.copy(vm.toPath(), temp.toPath());
                    }catch (FileAlreadyExistsException alreadyExistsException){
                    }

                }
            }else{
                File file = new File(getTestJavaPath() + BASE_PACKAGE_PATH+"Generator.java");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("generator/j_Generator.ftl").process(modelData, new FileWriter(file));

                String projectPath = System.getProperty("user.dir")+"/src/main/resources/template/generator/j_vm";
                File source=new File(projectPath);
                File[] files = source.listFiles();
                for (File vm : files) {
                    File temp = new File(getRoot() + "/src/main/resources/templates/" + vm.getName());
                    if(!temp.getParentFile().exists()){
                        temp.getParentFile().mkdir();
                    }
                    try {
                        Files.copy(vm.toPath(), temp.toPath());
                    }catch (FileAlreadyExistsException alreadyExistsException){
                    }

                }
            }
        } catch (Exception e) {
            System.out.println("Dockerfile生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("Dockerfile生成完毕！");
    }

    private void createDockerfile() {
        String dockerPath = getRoot() + "/src/main/docker";
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            File dockerfile = new File(dockerPath + "/Dockerfile");
            if (!dockerfile.getParentFile().exists()) {
                dockerfile.getParentFile().mkdirs();
            }
            cfg.getTemplate("Dockerfile.ftl").process(modelData, new FileWriter(dockerfile));
        } catch (Exception e) {
            System.out.println("Dockerfile生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("Dockerfile生成完毕！");
    }

    private void checkConfig() {
        if(StringUtils.isBlank(projectConfig.name)){
            throw new NullPointerException("name can not null!");
        }
        if(StringUtils.isBlank(projectConfig.project)){
            throw new NullPointerException("project can not null!");
        }

        if(!projectConfig.dataBaseConfig.getDataBaseType().equals(DataBaseType.NONE)){
            if(StringUtils.isBlank(projectConfig.dataBaseConfig.getJdbc_url())){
                throw new NullPointerException("JDBC URL can not null!");
            }
            if(StringUtils.isBlank(projectConfig.dataBaseConfig.getUser())){
                throw new NullPointerException("JDBC USERNAME can not null!");
            }
            if(StringUtils.isBlank(projectConfig.dataBaseConfig.getPassword())){
                throw new NullPointerException("JDBC PASSWORD can not null!");
            }
        }
    }

    private void createMyBatisConf() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "MybatisConfigurer.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/conf/MybatisConfigurer.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("MyBatis配置类生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("MyBatis配置类生成完毕！");
    }

    private void createMyBatisCore() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/impl/ServiceImpl.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/core/service/impl/ServiceImpl.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/support/SearchQuerySupport.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/core/service/support/SearchQuerySupport.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("MyBatis核心库生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("MyBatis核心库生成完毕！");
    }

    private void createBanner() {
        try {
            File file = new File(getResourcePath() + "banner.txt");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            try {
                Files.copy(new File(TEMPLATE_FILE_PATH + "/banner.txt").toPath(), file.toPath());
            } catch (Exception e) {
                System.out.println("banner已存在！");
            }

        } catch (Exception e) {
            System.out.println("banner生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("banner生成完毕！");
    }

    private void createSwaggerConf() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "SwaggerConf.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/SwaggerConf.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("swagger配置类生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("swagger配置类生成完毕！");
    }

    private void createCommonCore() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            /**
             * request body
             */
            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/body/PageRequest.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/body/PageRequest.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/body/PostRequest.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/body/PostRequest.ftl").process(modelData, new FileWriter(file));

            /**
             * exception
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/BaseGlobalExceptionHandler.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/BaseGlobalExceptionHandler.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/BusinessException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/BusinessException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/ConvertUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/ConvertUtil.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/DataConflictException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/DataConflictException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/DataNotFoundException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/DataNotFoundException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/ExceptionEnum.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/ExceptionEnum.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/GlobalExceptionHandler.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/GlobalExceptionHandler.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/InternalServerException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/InternalServerException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/ParameterInvalidException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/ParameterInvalidException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/PermissionForbiddenException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/PermissionForbiddenException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/RemoteAccessException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/RemoteAccessException.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/UserNotLoginException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/UserNotLoginException.ftl").process(modelData, new FileWriter(file));

            /**
             * interceptor
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/interceptor/ResponseResultInterceptor.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/interceptor/ResponseResultInterceptor.ftl").process(modelData, new FileWriter(file));

            /**
             * result
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/DefaultErrorResult.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/DefaultErrorResult.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ParameterInvalidItem.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ParameterInvalidItem.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/PlatformResult.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/PlatformResult.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ResponseResult.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ResponseResult.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ResponseResultHandler.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ResponseResultHandler.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/Result.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/Result.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ResultCode.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ResultCode.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/RequestContextHolderUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/RequestContextHolderUtil.ftl").process(modelData, new FileWriter(file));

            /**
             * logs
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/annotations/ServiceLog.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/annotations/ServiceLog.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/aspect/RestControllerAspect.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/aspect/RestControllerAspect.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/aspect/ServiceLogAspect.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/aspect/ServiceLogAspect.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/utils/IpUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/utils/IpUtil.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/utils/LogAspectUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/utils/LogAspectUtil.ftl").process(modelData, new FileWriter(file));

            /**
             * page
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "page/PageInfo.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/page/PageInfo.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "page/SimplePage.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/page/SimplePage.ftl").process(modelData, new FileWriter(file));

            /**
             * service
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/IService.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/service/IService.ftl").process(modelData, new FileWriter(file));
            /**
             * service
             */
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "web/CommonController.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/web/CommonController.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("通用核心库生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("通用核心库生成完毕！");
    }

    private void createCommonConf() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "CustomWebMvcConfigurer.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/CustomWebMvcConfigurer.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CONF + "OpenBrowserCommandRunner.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/OpenBrowserCommandRunner.ftl").process(modelData, new FileWriter(file));

            file = new File(getResourcePath()+ "static/home.html");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("home.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("通用配置类生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("通用配置类生成完毕！");
    }

    private void createJPAConf() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "JpaConfigurer.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/conf/JpaConfigurer.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("JPA配置类生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("JPA配置类生成完毕！");
    }

    private void createJPACore() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repository/IRepository.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repository/IRepository.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "repository/impl/RepositoryImpl.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/repository/impl/RepositoryImpl.ftl").process(modelData, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/impl/ServiceImpl.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/service/impl/ServiceImpl.ftl").process(modelData, new FileWriter(file));

        } catch (Exception e) {
            System.out.println("JPA核心包生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("JPA核心包生成完毕！");
    }

    private void createStarter() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            File file = new File(getJavaPath() + BASE_PACKAGE_PATH + "Application.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("Application.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("启动类 Application.java 生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("启动类 Application.java 生成完毕！");
    }

    private void createPom() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            File file = new File(getRoot() + "/pom.xml");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("pom.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("maven配置文件 pom.xml 生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("maven配置文件 pom.xml 生成完毕！");
    }

    private void createApplication() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            File file = new File(getRoot() + "/src/main/resources/application.yml");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("application_yml.ftl").process(modelData, new FileWriter(file));
        } catch (Exception e) {
            System.out.println("配置文件 application.yml 生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("配置文件 application.yml 生成完毕！");
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

    private void deleteProject() {
        File file = new File(getRoot());
        file.deleteOnExit();
        System.exit(0);
    }
}
