package ${corepackage}.repo.factory;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.TargetSource;
import org.springframework.aop.framework.ProxyFactory;
import org.springframework.aop.interceptor.ExposeInvocationInterceptor;
import org.springframework.beans.factory.BeanClassLoaderAware;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.jpa.repository.support.CrudMethodMetadata;
import org.springframework.data.repository.core.RepositoryInformation;
import org.springframework.data.repository.core.support.RepositoryProxyPostProcessor;
import org.springframework.lang.Nullable;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.util.Assert;
import org.springframework.util.ClassUtils;

import javax.persistence.LockModeType;
import javax.persistence.QueryHint;
import java.lang.reflect.Method;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

public class CrudMethodMetadataPostProcessor implements RepositoryProxyPostProcessor, BeanClassLoaderAware {

    private @Nullable
    ClassLoader classLoader = ClassUtils.getDefaultClassLoader();

    @Override
    public void setBeanClassLoader(ClassLoader classLoader) {
        this.classLoader = classLoader;
    }

    @Override
    public void postProcess(ProxyFactory factory, RepositoryInformation repositoryInformation) {
        factory.addAdvice(CrudMethodMetadataPopulatingMethodInterceptor.INSTANCE);
    }

    public CrudMethodMetadata getCrudMethodMetadata() {

        ProxyFactory factory = new ProxyFactory();

        factory.addInterface(CrudMethodMetadata.class);
        factory.setTargetSource(new ThreadBoundTargetSource());

        return (CrudMethodMetadata) factory.getProxy(this.classLoader);
    }

    enum CrudMethodMetadataPopulatingMethodInterceptor implements MethodInterceptor {

        INSTANCE;

        private final ConcurrentMap<Method, CrudMethodMetadata> metadataCache = new ConcurrentHashMap<Method, CrudMethodMetadata>();

        public Object invoke(MethodInvocation invocation) throws Throwable {

            Method method = invocation.getMethod();
            CrudMethodMetadata metadata = (CrudMethodMetadata) TransactionSynchronizationManager.getResource(method);

            if (metadata != null) {
                return invocation.proceed();
            }

            CrudMethodMetadata methodMetadata = metadataCache.get(method);

            if (methodMetadata == null) {

                methodMetadata = new DefaultCrudMethodMetadata(method);
                CrudMethodMetadata tmp = metadataCache.putIfAbsent(method, methodMetadata);

                if (tmp != null) {
                    methodMetadata = tmp;
                }
            }

            TransactionSynchronizationManager.bindResource(method, methodMetadata);

            try {
                return invocation.proceed();
            } finally {
                TransactionSynchronizationManager.unbindResource(method);
            }
        }
    }

    private static class DefaultCrudMethodMetadata implements CrudMethodMetadata {

        private final @Nullable LockModeType lockModeType;
        private final Map<String, Object> queryHints;
        private final Optional<EntityGraph> entityGraph;
        private final Method method;

        DefaultCrudMethodMetadata(Method method) {

            Assert.notNull(method, "Method must not be null!");

            this.lockModeType = findLockModeType(method);
            this.queryHints = findQueryHints(method);
            this.entityGraph = findEntityGraph(method);
            this.method = method;
        }

        private static Optional<EntityGraph> findEntityGraph(Method method) {
            return Optional.ofNullable(AnnotatedElementUtils.findMergedAnnotation(method, EntityGraph.class));
        }

        @Nullable
        private static LockModeType findLockModeType(Method method) {

            Lock annotation = AnnotatedElementUtils.findMergedAnnotation(method, Lock.class);
            return annotation == null ? null : (LockModeType) AnnotationUtils.getValue(annotation);
        }

        private static Map<String, Object> findQueryHints(Method method) {

            Map<String, Object> queryHints = new HashMap<String, Object>();
            QueryHints queryHintsAnnotation = AnnotatedElementUtils.findMergedAnnotation(method, QueryHints.class);

            if (queryHintsAnnotation != null) {

                for (QueryHint hint : queryHintsAnnotation.value()) {
                    queryHints.put(hint.name(), hint.value());
                }
            }

            QueryHint queryHintAnnotation = AnnotationUtils.findAnnotation(method, QueryHint.class);

            if (queryHintAnnotation != null) {
                queryHints.put(queryHintAnnotation.name(), queryHintAnnotation.value());
            }

            return Collections.unmodifiableMap(queryHints);
        }

        @Nullable
        @Override
        public LockModeType getLockModeType() {
            return lockModeType;
        }

        @Override
        public Map<String, Object> getQueryHints() {
            return queryHints;
        }

        @Override
        public Optional<EntityGraph> getEntityGraph() {
            return entityGraph;
        }

        @Override
        public Method getMethod() {
            return method;
        }
    }

    private static class ThreadBoundTargetSource implements TargetSource {

        @Override
        public Class<?> getTargetClass() {
            return CrudMethodMetadata.class;
        }

        @Override
        public boolean isStatic() {
            return false;
        }

        @Override
        public Object getTarget() throws Exception {

            MethodInvocation invocation = ExposeInvocationInterceptor.currentInvocation();
            return TransactionSynchronizationManager.getResource(invocation.getMethod());
        }

        @Override
        public void releaseTarget(Object target) throws Exception {}
    }
}

