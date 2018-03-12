package com.wymix.project;

import com.wymix.project.core.CodeBuilder;
import com.wymix.project.core.ProjectConfig;
import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;

public class Main {

    public static void main(String[] args) {
        ProjectConfig projectConfig = ProjectConfig.project("demo")
                .company("wymix")
                .enableSwagger()
                .setDataBaseType(DataBaseType.MYSQL)
                .configure("jdbc:mysql://10.30.0.11:3306/testf?zeroDateTimeBehavior=convertToNull&autoReconnect=true", "root", "ori18502800930")
                .setOrmType(OrmType.MYBATIS)
                .setDataBaseConnectPool(DataBaseConnectPool.DRUID);

        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces/").build(projectConfig);

    }
}
