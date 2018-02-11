package ${corepackage}.repo.factory;

import org.springframework.data.mapping.context.MappingContext;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.core.support.RepositoryFactorySupport;
import org.springframework.data.repository.core.support.TransactionalRepositoryFactoryBeanSupport;
import org.springframework.util.Assert;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.io.Serializable;

public class JpaRepositoryFactoryBean<T extends Repository<S, ID>, S, ID extends Serializable>
        extends TransactionalRepositoryFactoryBeanSupport<T, S, ID> {

    private EntityManager entityManager;

    /**
     * Creates a new {@link TransactionalRepositoryFactoryBeanSupport} for the given repository interface.
     *
     * @param repositoryInterface must not be {@literal null}.
     */
    protected JpaRepositoryFactoryBean(Class<? extends T> repositoryInterface) {
        super(repositoryInterface);
    }

    @PersistenceContext
    public void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Override
    public void setMappingContext(MappingContext<?, ?> mappingContext) {
        super.setMappingContext(mappingContext);
    }

    @Override
    protected RepositoryFactorySupport doCreateRepositoryFactory() {
        return createRepositoryFactory(entityManager);
    }

    protected RepositoryFactorySupport createRepositoryFactory(EntityManager entityManager) {
        return new JpaRepositoryFactory(entityManager);
    }

    @Override
    public void afterPropertiesSet() {

        Assert.notNull(entityManager, "EntityManager must not be null!");
        super.afterPropertiesSet();
    }
}
