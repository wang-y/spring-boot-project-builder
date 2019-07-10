FROM java:8
VOLUME /tmp
ADD ${artifactId}.jar application.jar
RUN bash -c 'touch /application.jar'
EXPOSE ${port}
ENTRYPOINT ["exec ","java","$JAVA_OPTS","-Djava.security.egd=file:/dev/./urandom","-jar","/application.jar"]
