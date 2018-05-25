package com.wymix.project;

import com.wymix.project.core.CodeBuilder;
import com.wymix.project.core.ProjectConfig;
import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;

public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("666")
                .company("abcd")
                .disableSwagger()
                .setDataBaseType(DataBaseType.SQLSERVER)
                .JDBCconfigure("jdbc:mysql://10.30.0.10:8066/oricmfuntest", "root", "ori18502800930")
                .setOrmType(OrmType.JPA)
                .setDataBaseConnectPool(DataBaseConnectPool.HIKARICP);

        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces").build(projectConfig);
    }
}
