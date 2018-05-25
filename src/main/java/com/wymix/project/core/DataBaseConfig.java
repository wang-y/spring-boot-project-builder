package com.wymix.project.core;


import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;
import lombok.Data;

@Data
public class DataBaseConfig {
    private ProjectConfig projectConfig;
    private DataBaseType dataBaseType;
    private OrmType ormType;
    private DataBaseConnectPool dataBaseConnectPool;

    private String jdbc_url;
    private String user;
    private String password;

    protected DataBaseConfig(ProjectConfig projectConfig) {
        this.dataBaseType = DataBaseType.NONE;
        this.projectConfig = projectConfig;
        this.ormType = OrmType.NONE;
        this.dataBaseConnectPool = DataBaseConnectPool.NONE;
    }

    public ProjectConfig JDBCconfigure(String url, String username, String password) {
        this.jdbc_url = url;
        this.user = username;
        this.password = password;
        return this.projectConfig;
    }


}
