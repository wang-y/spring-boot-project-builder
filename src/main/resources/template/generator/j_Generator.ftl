package ${basePackage};

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.generator.AutoGenerator;
import com.baomidou.mybatisplus.generator.InjectionConfig;
import com.baomidou.mybatisplus.generator.config.*;
import com.baomidou.mybatisplus.generator.config.rules.NamingStrategy;

import java.util.HashMap;
import java.util.Map;

public class Generator {

    private final static String JDBC_URL="${JDBC_URL}";
    private final static String JDBC_USERNAME="${JDBC_USERNAME}";
    private final static String JDBC_PASSWORD="${JDBC_PASSWORD}";
    private final static String DRIVER_CLASS_NAME="${DRIVER_CLASS_NAME}";

    public static void main(String[] args) {
        generate("testmodel","Long");
    }

    private static void generate(String table,String idType){
        AutoGenerator mpg = new AutoGenerator();

        DataSourceConfig dataSourceConfig = new DataSourceConfig();
        dataSourceConfig.setDbType(DbType.${DBTYPE});
        dataSourceConfig.setUrl(JDBC_URL);
        dataSourceConfig.setUsername(JDBC_USERNAME);
        dataSourceConfig.setPassword(JDBC_PASSWORD);
        dataSourceConfig.setDriverName(DRIVER_CLASS_NAME);
        mpg.setDataSource(dataSourceConfig);

        GlobalConfig gc = new GlobalConfig();
        String projectPath = System.getProperty("user.dir");
        gc.setOutputDir(projectPath + "/src/main/java");
        gc.setOpen(false);
        gc.setFileOverride(false);
<#if enabledSwagger>
        gc.setSwagger2(true);
</#if>
        gc.setEntityName("%s");
        gc.setMapperName("I%sRepository");
        gc.setServiceName("I%sService");
        gc.setServiceImplName("%sServiceImpl");
        gc.setControllerName("%sController");
        mpg.setGlobalConfig(gc);

        PackageConfig packageConfig = new PackageConfig();
        packageConfig.setParent("${basePackage}.business");
        packageConfig.setEntity("model");
        packageConfig.setService("service");
        packageConfig.setServiceImpl("service.impl");
        packageConfig.setMapper("repository");
        packageConfig.setController("web");
        packageConfig.setXml(null);
        mpg.setPackageInfo(packageConfig);


        StrategyConfig strategy = new StrategyConfig();

        strategy.setNaming(NamingStrategy.underline_to_camel);
        strategy.setColumnNaming(NamingStrategy.underline_to_camel);
        strategy.setEntityLombokModel(true);
        strategy.setSuperMapperClass("${basePackage}.core.repository.IRepository");
        strategy.setSuperServiceClass("${basePackage}.core.service.IService");
        strategy.setSuperServiceImplClass("${basePackage}.core.service.impl.ServiceImpl");
        strategy.setSuperControllerClass("${basePackage}.core.web.CommonController");
        strategy.setRestControllerStyle(true);
        strategy.setControllerMappingHyphenStyle(true);
        strategy.setInclude(table);

        InjectionConfig cfg = new InjectionConfig() {
            @Override
            public void initMap() {
                Map<String, Object> map = new HashMap<>();
                map.put("idType", idType);
                this.setMap(map);
            }
        };
        mpg.setCfg(cfg);

        TemplateConfig templateConfig = new TemplateConfig();
        templateConfig.setXml(null);
        templateConfig.setEntity("templates/entity.java");
        templateConfig.setMapper("templates/mapper.java");
        templateConfig.setService("templates/service.java");
        templateConfig.setServiceImpl("templates/serviceImpl.java");
        templateConfig.setController("templates/controller.java");
        mpg.setTemplate(templateConfig);
        mpg.setStrategy(strategy);
        mpg.execute();
    }
}
