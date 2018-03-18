package com.wymix.project;

import com.wymix.project.core.CodeBuilder;
import com.wymix.project.core.ProjectConfig;
import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;

public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("dataservice1")
                .company("orieange")
                .enableSwagger()
                .setDataBaseType(DataBaseType.SQLSERVER)
                .configure("jdbc:sqlserver://localhost:1433;database=dataservice", "sa", "12345678")
                .setOrmType(OrmType.JPA)
                .setDataBaseConnectPool(DataBaseConnectPool.DRUID);

        CodeBuilder.toFilePath("E:\\study_diary_workspaces").build(projectConfig);
    }
}
