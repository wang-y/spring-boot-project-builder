package com.wymix.project.core;

import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;
import com.wymix.project.core.constant.VersionConstants;
import freemarker.template.TemplateExceptionHandler;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
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
        String basepackage = "com." + projectConfig.company + "." + projectConfig.project;

        PACKAGE_CONF = basepackage + ".conf";
        PACKAGE_CORE = basepackage + ".core";
        PACKAGE_BUSINESS = basepackage + ".business";
        BASE_PACKAGE = basepackage;

        PACKAGE_PATH_CONF = packageConvertPath(PACKAGE_CONF);
        PACKAGE_PATH_CORE = packageConvertPath(PACKAGE_CORE);
        BASE_PACKAGE_PATH = packageConvertPath(BASE_PACKAGE);

        touchDir();
        createPom();
        createApplication();
        createStarter();

        if(!projectConfig.dataBaseConfig.getDataBaseType().equals(DataBaseType.NONE)) {
            switch (projectConfig.dataBaseConfig.getOrmType()) {
                case JPA:
                    createJPACore();
                    createJPAConf();
                    genJPABusinessLogicCode();
                    break;
                case MYBATIS:
                    createMyBatisCore();
                    createMyBatisConf();
                    break;
                default:
                    createJPACore();
                    createJPAConf();
                    genJPABusinessLogicCode();
                    break;
            }
            createTemplateCode();
        }
        createCommonCore();
        createCommonConf();
        if (projectConfig.enable_swagger) {
            createSwaggerConf();
        }
        if(projectConfig.enable_docker){
            createDockerfile();
        }
        createBanner();
        System.out.println("项目创建完毕！");
    }

    private void createDockerfile() {
        String dockerPath = getRoot() + "/src/main/docker";
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("artifactId", this.projectConfig.project);

            File dockerfile = new File(dockerPath + "/Dockerfile");
            if (!dockerfile.getParentFile().exists()) {
                dockerfile.getParentFile().mkdirs();
            }
            cfg.getTemplate("Dockerfile.ftl").process(data, new FileWriter(dockerfile));
        } catch (Exception e) {
            System.out.println("Dockerfile生成失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("Dockerfile生成完毕！");
    }

    private void checkConfig() {
        if(StringUtils.isBlank(projectConfig.company)){
            throw new NullPointerException("company can not null!");
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

            Map<String, Object> data = new HashMap<>();
            data.put("confpackage", PACKAGE_CONF);
            data.put("corepackage", PACKAGE_CORE);
            data.put("databasetype", projectConfig.dataBaseConfig.getDataBaseType().toString());

            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "MybatisConfigurer.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/conf/MybatisConfigurer.ftl").process(data, new FileWriter(file));
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

            Map<String, Object> data = new HashMap<>();
            data.put("corepackage", PACKAGE_CORE);

            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "mapper/Mapper.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/core/mapper/Mapper.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/Service.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/core/service/Service.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "service/impl/AbstractService.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/core/service/impl/AbstractService.ftl").process(data, new FileWriter(file));

            data.put("basepackage", BASE_PACKAGE);
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "constant/ProjectConstant.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("mybatis/core/constant/ProjectConstant.ftl").process(data, new FileWriter(file));
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

    private void createTemplateCode() {
        String jdbc_driver = "";
        if (projectConfig.dataBaseConfig != null && projectConfig.dataBaseConfig.getDataBaseType() != DataBaseType.NONE) {
            switch (projectConfig.dataBaseConfig.getDataBaseType()) {
                case MYSQL:
                    jdbc_driver += "com.mysql.jdbc.Driver";
                    break;
                case SQLSERVER:
                    jdbc_driver += "com.microsoft.sqlserver.jdbc.SQLServerDriver";
                    break;
            }
        }

        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();

            if (projectConfig.dataBaseConfig.getOrmType() == OrmType.JPA) {
                data.put("businesspackage", PACKAGE_BUSINESS);
                data.put("corepackage", PACKAGE_CORE);

                data.put("modelName", "${modelName}");
                data.put("PKType", "${PKType}");

                File file = new File(getTestResourcesPath() + "generator/template/repository/TemplateRepository.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("jpa/business/repository/TemplateRepository.ftl").process(data, new FileWriter(file));

                file = new File(getTestResourcesPath() + "generator/template/service/TemplateService.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("jpa/business/service/TemplateService.ftl").process(data, new FileWriter(file));

                file = new File(getTestResourcesPath() + "generator/template/service/impl/TemplateServiceImpl.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("jpa/business/service/impl/TemplateServiceImpl.ftl").process(data, new FileWriter(file));

                data.put("baseRequestMapping", "${baseRequestMapping?lower_case}");
                file = new File(getTestResourcesPath() + "generator/template/web/TemplateController.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("jpa/business/web/TemplateController.ftl").process(data, new FileWriter(file));

                data = new HashMap<>();
                data.put("basepackage", BASE_PACKAGE);
                data.put("database_user", projectConfig.dataBaseConfig.getUser());
                data.put("database_passowrd", projectConfig.dataBaseConfig.getPassword());
                data.put("database_url", projectConfig.dataBaseConfig.getJdbc_url());
                data.put("businesspackage", PACKAGE_BUSINESS);
                data.put("enabled_swagger", projectConfig.enable_swagger ? "yes" : "no");
                data.put("databasetype", projectConfig.dataBaseConfig.getDataBaseType().toString());
                data.put("jdbc_diver_class_name", jdbc_driver);

                file = new File(getTestJavaPath() + BASE_PACKAGE_PATH + "CodeGenerator.java");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("gen/JPA_CodeGenerator.ftl").process(data, new FileWriter(file));
            } else if (projectConfig.dataBaseConfig.getOrmType() == OrmType.MYBATIS) {
                data.put("basePackage", BASE_PACKAGE);
                data.put("modelNameUpperCamel", "${modelNameUpperCamel}");
                data.put("modelNameLowerCamel", "${modelNameLowerCamel}");
                data.put("IDType", "${IDType}");
                data.put("enabledSwagger", projectConfig.enable_swagger);
                data.put("baseRequestMapping", "${baseRequestMapping}");

                File file = new File(getTestResourcesPath() + "generator/template/service/service.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("mybatis/business/service/service.ftl").process(data, new FileWriter(file));

                file = new File(getTestResourcesPath() + "generator/template/service/impl/service-impl.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("mybatis/business/service/service-impl.ftl").process(data, new FileWriter(file));

                file = new File(getTestResourcesPath() + "generator/template/web/controller.ftl");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("mybatis/business/web/controller.ftl").process(data, new FileWriter(file));

                data = new HashMap<>();
                data.put("basepackage", BASE_PACKAGE);
                data.put("corepackage", PACKAGE_CORE);

                data.put("database_url", projectConfig.dataBaseConfig.getJdbc_url());
                data.put("database_user", projectConfig.dataBaseConfig.getUser());
                data.put("database_passowrd", projectConfig.dataBaseConfig.getPassword());

                data.put("enabled_swagger", projectConfig.enable_swagger ? "yes" : "no");
                data.put("databasetype", projectConfig.dataBaseConfig.getDataBaseType().toString());
                data.put("jdbc_diver_class_name", jdbc_driver);

                file = new File(getTestJavaPath() + BASE_PACKAGE_PATH + "CodeGenerator.java");
                if (!file.getParentFile().exists()) {
                    file.getParentFile().mkdirs();
                }
                cfg.getTemplate("gen/MYBATIS_CodeGenerator.ftl").process(data, new FileWriter(file));
            }
        } catch (Exception e) {
            System.out.println("代码生成器类创建失败！");
            e.printStackTrace();
            deleteProject();
        }
        System.out.println("代码生成器类创建完毕！");
    }

    private void createSwaggerConf() {
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
        } catch (Exception e) {
            System.out.println("swagger配置类生成失败！");
            e.printStackTrace();
            deleteProject();
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

    private void createCommonCore() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("corepackage", PACKAGE_CORE);
            data.put("enabledSwagger", projectConfig.enable_swagger);

            File file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/body/PageRequest.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/body/PageRequest.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/body/PostRequest.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/body/PostRequest.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/BaseGlobalExceptionHandler.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/BaseGlobalExceptionHandler.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/BusinessException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/BusinessException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/ConvertUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/ConvertUtil.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/DataConflictException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/DataConflictException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/DataNotFoundException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/DataNotFoundException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/ExceptionEnum.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/ExceptionEnum.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/GlobalExceptionHandler.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/GlobalExceptionHandler.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/InternalServerException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/InternalServerException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/ParameterInvalidException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/ParameterInvalidException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/PermissionForbiddenException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/PermissionForbiddenException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/RemoteAccessException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/RemoteAccessException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/exception/UserNotLoginException.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/exception/UserNotLoginException.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/interceptor/ResponseResultInterceptor.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/interceptor/ResponseResultInterceptor.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/DefaultErrorResult.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/DefaultErrorResult.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ParameterInvalidItem.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ParameterInvalidItem.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/PlatformResult.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/PlatformResult.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ResponseResult.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ResponseResult.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ResponseResultHandler.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ResponseResultHandler.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/Result.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/Result.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/result/ResultCode.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/result/ResultCode.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/RequestContextHolderUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/RequestContextHolderUtil.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/annotations/ServiceLog.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/annotations/ServiceLog.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/aspect/RestControllerAspect.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/aspect/RestControllerAspect.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/aspect/ServiceLogAspect.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/aspect/ServiceLogAspect.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/utils/IpUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/utils/IpUtil.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "common/logs/utils/LogAspectUtil.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/core/common/logs/utils/LogAspectUtil.ftl").process(data, new FileWriter(file));

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
            Map<String, Object> data = new HashMap<>();
            data.put("confpackage", PACKAGE_CONF);
            data.put("corepackage", PACKAGE_CORE);
            data.put("enabledSwagger", projectConfig.enable_swagger);
            data.put("allowed_cross_domain","${server.allowed-cross-domain}");
            File file = new File(getJavaPath() + PACKAGE_PATH_CONF + "CustomWebMvcConfigurer.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/CustomWebMvcConfigurer.ftl").process(data, new FileWriter(file));

            file = new File(getJavaPath() + PACKAGE_PATH_CONF + "OpenBrowserCommandRunner.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("common/conf/OpenBrowserCommandRunner.ftl").process(data, new FileWriter(file));

            file = new File(getResourcePath()+ "static/home.html");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("home.ftl").process(data, new FileWriter(file));
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
            deleteProject();
        }
        System.out.println("JPA配置类生成完毕！");
    }

    private void createJPACore() {
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
            data.put("enabledSwagger", projectConfig.enable_swagger);
            file = new File(getJavaPath() + PACKAGE_PATH_CORE + "web/BasicController.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("jpa/core/web/BasicController.ftl").process(data, new FileWriter(file));
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
            deleteProject();
        }
        System.out.println("启动类 Application.java 生成完毕！");
    }

    private void createPom() {
        try {
            freemarker.template.Configuration cfg = getConfiguration();
            Map<String, Object> data = new HashMap<>();

            data.put("groupId", this.projectConfig.company);
            data.put("artifactId", this.projectConfig.project);
            data.put("enabledSwagger", this.projectConfig.enable_swagger);
            data.put("enableDocker", this.projectConfig.enable_docker);
            data.put("enableDatabase", !this.projectConfig.dataBaseConfig.getDataBaseType().equals(DataBaseType.NONE));
            data.put("databaseType", this.projectConfig.dataBaseConfig.getDataBaseType().toString());
            data.put("ormType", this.projectConfig.dataBaseConfig.getOrmType().toString());
            data.put("databaseConnectPool", this.projectConfig.dataBaseConfig.getDataBaseConnectPool().toString());


            data.put("SPRING_BOOT_VERSION", VersionConstants.SPRING_BOOT_VERSION);
            data.put("DRUID_VERSION", VersionConstants.DRUID_VERSION);

            data.put("dockerimageprefix","${docker.image.prefix}");
            data.put("projectartifactId","${project.artifactId}");
            data.put("directory","${project.build.directory}");
            data.put("finalName","${project.build.finalName}");

            File file = new File(getRoot() + "/pom.xml");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("pom.ftl").process(data, new FileWriter(file));
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
            Map<String, Object> data = new HashMap<>();

            data.put("port", ""+this.projectConfig.port);
            data.put("company", ""+this.projectConfig.company);
            data.put("artifactId", this.projectConfig.project);
            data.put("enableDatabase", !this.projectConfig.dataBaseConfig.getDataBaseType().equals(DataBaseType.NONE));
            data.put("databaseType", this.projectConfig.dataBaseConfig.getDataBaseType().toString());
            data.put("ormType", this.projectConfig.dataBaseConfig.getOrmType().toString());
            data.put("databaseConnectPool", this.projectConfig.dataBaseConfig.getDataBaseConnectPool().toString());

            data.put("jdbcurl", this.projectConfig.dataBaseConfig.getJdbc_url());
            data.put("username", this.projectConfig.dataBaseConfig.getUser());
            data.put("password", this.projectConfig.dataBaseConfig.getPassword());

            File file = new File(getRoot() + "/src/main/resources/application.yml");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("application_yml.ftl").process(data, new FileWriter(file));
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
