package ${confpackage};

import ${corepackage}.repo.factory.JpaRepositoryFactoryBean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(basePackages = {"**.repository"}, repositoryFactoryBeanClass = JpaRepositoryFactoryBean.class)
public class JPAConfig {}