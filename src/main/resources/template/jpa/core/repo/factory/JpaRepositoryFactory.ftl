package ${corepackage}.repo.factory;

import ${corepackage}.repo.impl.BasicRepository;
import org.springframework.data.jpa.provider.PersistenceProvider;
import org.springframework.data.jpa.provider.QueryExtractor;
import org.springframework.data.jpa.repository.query.JpaQueryLookupStrategy;
import org.springframework.data.jpa.repository.support.JpaEntityInformation;
import org.springframework.data.jpa.repository.support.JpaEntityInformationSupport;
import org.springframework.data.jpa.repository.support.QueryDslJpaRepository;
import org.springframework.data.querydsl.QueryDslPredicateExecutor;
import org.springframework.data.repository.core.RepositoryInformation;
import org.springframework.data.repository.core.RepositoryMetadata;
import org.springframework.data.repository.core.support.RepositoryFactorySupport;
import org.springframework.data.repository.query.EvaluationContextProvider;
import org.springframework.data.repository.query.QueryLookupStrategy;
import org.springframework.util.Assert;

import javax.persistence.EntityManager;
import java.io.Serializable;

import static org.springframework.data.querydsl.QueryDslUtils.QUERY_DSL_PRESENT;

public class JpaRepositoryFactory extends RepositoryFactorySupport {

    private final EntityManager entityManager;
    private final QueryExtractor extractor;
    private final CrudMethodMetadataPostProcessor crudMethodMetadataPostProcessor;

    public JpaRepositoryFactory(EntityManager entityManager) {

        Assert.notNull(entityManager, "EntityManager must not be null!");

        this.entityManager = entityManager;
        this.extractor = PersistenceProvider.fromEntityManager(entityManager);
        this.crudMethodMetadataPostProcessor = new CrudMethodMetadataPostProcessor();

        addRepositoryProxyPostProcessor(crudMethodMetadataPostProcessor);
    }

    @Override
    public void setBeanClassLoader(ClassLoader classLoader) {
        super.setBeanClassLoader(classLoader);
        this.crudMethodMetadataPostProcessor.setBeanClassLoader(classLoader);
    }

    @Override
    protected Object getTargetRepository(RepositoryInformation information) {

        BasicRepository<?, ?> repository = getTargetRepository(information, entityManager);
        repository.setRepositoryMethodMetadata(crudMethodMetadataPostProcessor.getCrudMethodMetadata());

        return repository;
    }

    protected <T, ID extends Serializable> BasicRepository<T, ID> getTargetRepository(
            RepositoryInformation information, EntityManager entityManager) {

        JpaEntityInformation<?, Serializable> entityInformation = getEntityInformation(information.getDomainType());

        return getTargetRepositoryViaReflection(information, entityInformation, entityManager);
    }

    @Override
    protected Class<?> getRepositoryBaseClass(RepositoryMetadata metadata) {
        return BasicRepository.class;
    }

    @Override
    protected QueryLookupStrategy getQueryLookupStrategy(QueryLookupStrategy.Key key, EvaluationContextProvider evaluationContextProvider) {
        return JpaQueryLookupStrategy.create(entityManager, key, extractor, evaluationContextProvider);
    }

    @Override
    @SuppressWarnings("unchecked")
    public <T, ID extends Serializable> JpaEntityInformation<T, ID> getEntityInformation(Class<T> domainClass) {
        return (JpaEntityInformation<T, ID>) JpaEntityInformationSupport.getEntityInformation(domainClass, entityManager);
    }
}
