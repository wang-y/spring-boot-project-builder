package ${confpackage};

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import ${corepackage}.repository.impl.RepositoryImpl;

@Configuration
@EnableJpaRepositories(basePackages = {"**.repository"}, repositoryBaseClass = RepositoryImpl.class)
public class JpaConfigurer {}