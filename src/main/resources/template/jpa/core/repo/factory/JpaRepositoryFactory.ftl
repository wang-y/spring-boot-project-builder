package ${corepackage}.repo.factory;

import ${corepackage}.repo.impl.BasicRepository;
import org.springframework.data.jpa.provider.PersistenceProvider;
import org.springframework.data.jpa.provider.QueryExtractor;
import org.springframework.data.jpa.repository.query.JpaQueryLookupStrategy;
import org.springframework.data.jpa.repository.support.JpaEntityInformation;
import org.springframework.data.jpa.repository.support.JpaEntityInformationSupport;
import org.springframework.data.repository.core.EntityInformation;
import org.springframework.data.repository.core.RepositoryInformation;
import org.springframework.data.repository.core.RepositoryMetadata;
import org.springframework.data.repository.core.support.RepositoryFactorySupport;
import org.springframework.data.jpa.repository.query.EscapeCharacter;
import org.springframework.data.repository.query.QueryMethodEvaluationContextProvider;
import org.springframework.data.repository.query.QueryLookupStrategy;
import org.springframework.lang.Nullable;
import org.springframework.util.Assert;

import javax.persistence.EntityManager;
import java.io.Serializable;
import java.util.Optional;

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
public <T, ID> EntityInformation<T, ID> getEntityInformation(Class<T> domainClass) {
    return (JpaEntityInformation<T, ID>) JpaEntityInformationSupport.getEntityInformation(domainClass, entityManager);
    }

    @Override
    protected Object getTargetRepository(RepositoryInformation information) {

    BasicRepository<?, ?> repository = getTargetRepository(information, entityManager);
    repository.setRepositoryMethodMetadata(crudMethodMetadataPostProcessor.getCrudMethodMetadata());

    return repository;
    }

    protected <T, ID extends Serializable> BasicRepository<T, ID> getTargetRepository(
    RepositoryInformation information, EntityManager entityManager) {

    EntityInformation<?, Serializable> entityInformation = getEntityInformation(information.getDomainType());

    return getTargetRepositoryViaReflection(information, entityInformation, entityManager);
    }

    @Override
    protected Class<?> getRepositoryBaseClass(RepositoryMetadata metadata) {
    return BasicRepository.class;
    }

    @Override
    protected Optional<QueryLookupStrategy> getQueryLookupStrategy(@Nullable QueryLookupStrategy.Key key,
        QueryMethodEvaluationContextProvider evaluationContextProvider) {
        return Optional.of(JpaQueryLookupStrategy.create(entityManager, key, extractor, evaluationContextProvider, EscapeCharacter.DEFAULT));
    }

}
