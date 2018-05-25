package com.wymix.project;

import com.wymix.project.core.CodeBuilder;
import com.wymix.project.core.ProjectConfig;
import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;

public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("test")
                .company("wymix")
                .disableSwagger()
                .setDataBaseType(DataBaseType.SQLSERVER)
                .JDBCconfigure("jdbc:mysql://192.168.1.11:3306/testf", "root", "12345678")
                .setOrmType(OrmType.JPA)
                .setDataBaseConnectPool(DataBaseConnectPool.HIKARICP);

        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces").build(projectConfig);
    }
}
