package ${confpackage};

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInterceptor;
import org.apache.ibatis.plugin.Interceptor;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.util.ObjectUtils;
import tk.mybatis.spring.mapper.MapperScannerConfigurer;

import javax.sql.DataSource;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Properties;

import static ${corepackage}.constant.ProjectConstant.*;

/**
 * Mybatis & Mapper & PageHelper 配置
 */
@Configuration
public class MybatisConfigurer {

    private static final String DATABASETYPE="${databasetype}";

    @Bean
    public SqlSessionFactory sqlSessionFactoryBean(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(dataSource);
        factory.setTypeAliasesPackage(MODEL_PACKAGE);

        //配置分页插件，详情请查阅官方文档
        PageHelper pageHelper = new PageHelper();
        Properties properties = new Properties();
        properties.setProperty("pageSizeZero", "true");  //分页尺寸为0时查询所有纪录不再执行分页
        properties.setProperty("reasonable", "true");  //页码<=0 查询第一页，页码>=总页数查询最后一页
        properties.setProperty("supportMethodsArguments", "true");  //支持通过 Mapper 接口参数来传递分页参数
        pageHelper.setProperties(properties);

        PageInterceptor interceptor = new PageInterceptor();
        interceptor.setProperties(properties);
        //添加插件
        factory.setPlugins(new Interceptor[]{interceptor});

        //添加XML目录
        org.springframework.core.io.Resource[] resources = null;
        if (!ObjectUtils.isEmpty(resources = resolveMapperLocations("classpath:mapper/**/*.xml"))) {
            factory.setMapperLocations(resources);
        }
        return factory.getObject();
    }

    public org.springframework.core.io.Resource[] resolveMapperLocations(String... mapperLocations) {
        PathMatchingResourcePatternResolver resourceResolver = new PathMatchingResourcePatternResolver();
        ArrayList resources = new ArrayList();
        if(mapperLocations != null) {
            int total = mapperLocations.length;
            for(int i = 0; i < total; ++i) {
                String mapperLocation = mapperLocations[i];
                try {
                    org.springframework.core.io.Resource[] mappers = resourceResolver.getResources(mapperLocation);
                    resources.addAll(Arrays.asList(mappers));
                } catch (IOException ex) {
                }
            }
        }
        return (org.springframework.core.io.Resource[])resources.toArray(new org.springframework.core.io.Resource[resources.size()]);
    }

    @Bean
    public MapperScannerConfigurer mapperScannerConfigurer() {
        MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
        mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactoryBean");
        mapperScannerConfigurer.setBasePackage(MAPPER_PACKAGE);

        //配置通用Mapper，详情请查阅官方文档
        Properties properties = new Properties();
        //properties.setProperty("mappers", MAPPER_INTERFACE_REFERENCE);  //4.0之后版本不需要，除非自定义mapper
        properties.setProperty("notEmpty", "false");  //insert、update是否判断字符串类型!='' 即 test="str != null"表达式内是否追加 and str != ''
        properties.setProperty("IDENTITY", DATABASETYPE);
        mapperScannerConfigurer.setProperties(properties);

        return mapperScannerConfigurer;
    }

}