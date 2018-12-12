package com.wymix.project.core;

import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;


public class ProjectConfig {


    protected DataBaseConfig dataBaseConfig;
    protected String company;
    protected String project;
    protected int port = 8080;
    protected String contextPath;
    protected boolean enable_swagger = true;
    protected boolean enable_docker = false;

    private ProjectConfig() {

    }

    public ProjectConfig company(String company) {
        this.company = company;
        return this;
    }

    public static ProjectConfig project(String project) {
        ProjectConfig projectConfig = new ProjectConfig();
        projectConfig.project = project;
        projectConfig.dataBaseConfig = new DataBaseConfig(projectConfig);
        return projectConfig;
    }

    public ProjectConfig enableSwagger() {
        this.enable_swagger = true;
        return this;
    }

    public ProjectConfig disableSwagger() {
        this.enable_swagger = false;
        return this;
    }

    public ProjectConfig enableDocker() {
        this.enable_docker = true;
        return this;
    }

    public ProjectConfig disableDocker() {
        this.enable_docker = false;
        return this;
    }

    public DataBaseConfig setDataBaseType(DataBaseType type) {
        this.dataBaseConfig.setDataBaseType(type);
        return this.dataBaseConfig;
    }

    public ProjectConfig setOrmType(OrmType type) {
        this.dataBaseConfig.setOrmType(type);
        return this;
    }

    public ProjectConfig setDataBaseConnectPool(DataBaseConnectPool pool) {
        this.dataBaseConfig.setDataBaseConnectPool(pool);
        return this;
    }

    public ProjectConfig setPort(int port) {
        this.port = port;
        return this;
    }

    public ProjectConfig setContextPath(String contextPath) {
        this.contextPath = contextPath;
        return this;
    }

    public int getPort() {
        return this.port;
    }
}