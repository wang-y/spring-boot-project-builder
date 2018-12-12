package com.wymix.project;

import com.wymix.project.core.CodeBuilder;
import com.wymix.project.core.DataBaseConfig;
import com.wymix.project.core.ProjectConfig;
import com.wymix.project.core.constant.DataBaseConnectPool;
import com.wymix.project.core.constant.DataBaseType;
import com.wymix.project.core.constant.OrmType;
import org.apache.commons.lang3.StringUtils;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        System.out.println("               _");
        System.out.println("         __  _(_) ___ __ _ _   ___      __");
        System.out.println("         \\ \\/ / |/ _ ' _` | | | \\ \\ /\\ / /");
        System.out.println("          >  <| | | | | | | |_| |\\ V  V /");
        System.out.println("         /_/\\_\\_|_| |_| |_| .__/  \\_/\\_/");
        System.out.println("                           \\___|");
        System.out.println("-----------------------------------------------------");
        System.out.println("https://github.com/wang-y/spring-boot-project-builder");
        System.out.println("-----------------------------------------------------");
        System.out.println("                                           (欢迎fork)");
//        buildProject();
        build();
    }


    private static void buildProject() {
        ProjectConfig projectConfig = ProjectConfig.project("docker.test")
                .company("wymix")
                .enableSwagger()
                .setDataBaseType(DataBaseType.NONE)
                .JDBCconfigure("jdbc:mysql://10.30.0.11:3306/testf", "root", "ori18502800930")
                .setOrmType(OrmType.JPA)
                .setDataBaseConnectPool(DataBaseConnectPool.HIKARICP).enableDocker();

        CodeBuilder.toFilePath("/home/wymix/workspaces/study_diary_workspaces").build(projectConfig);
    }


    private static void build() {
        System.out.print("请输入项目创建路径：");
        Scanner scanner = new Scanner(System.in);
        String path = scanner.nextLine();
        System.out.println("项目将创建到 [" + path + "] 路径下。\n");
        String company ="wymix";
        System.out.print("请输入个人/企业英文名称或缩写（小写）：");
        while (true){
            company = scanner.nextLine();
            if(company.matches("^[a-z]+$")){
                break;
            }else{
                System.out.println("输入错误，请重新输入");
                System.out.print("请输入个人/企业英文名称或缩写（小写）：");
            }
        }
        System.out.println("项目名称为： [" + company + "] 。\n");

        System.out.print("请输入项目英文名称或缩写：");
        String project = "test";
        while (true){
            project = scanner.nextLine();
            if(project.matches("^[a-z]+$")){
                break;
            }else{
                System.out.println("输入错误，请重新输入");
                System.out.print("请输入项目英文名称或缩写：");
            }
        }
        System.out.println("项目名称为： [" + project + "] 。\n");

        ProjectConfig projectConfig = ProjectConfig.project(project).company(company).enableSwagger();

        System.out.print("请输入项目占用端口(默认:8080)：");
        String port = "";
        while (true){
            port = scanner.nextLine();
            if(StringUtils.isBlank(port)){
                break;
            }
            if(port.matches("^[0-9]\\d*$")){
                if(Integer.parseInt(port)>=0&&Integer.parseInt(port)<=65535){
                    break;
                }else{
                    System.out.println("端口号范围: [ 0 - 65535 ] ");
                    System.out.print("请输入项目占用端口(默认:8080)：");
                }
            }else{
                System.out.println("输入错误，请重新输入");
                System.out.print("请输入项目占用端口(默认:8080)：");
            }
        }
        if(StringUtils.isNotBlank(port)){
            projectConfig.setPort(Integer.parseInt(port));
        }
        System.out.println("项目占用端口为： [" + projectConfig.getPort() + "] 。\n");

        System.out.println("是否启用Swagger2：");
        System.out.println("    0. 禁用");
        System.out.println("    1. 启用");
        System.out.print("请选择(默认启用)：");
        boolean enableSwagger2 = true;
        String enableSwagger2str = scanner.nextLine();
        if (StringUtils.isNotBlank(enableSwagger2str)) {
            if (StringUtils.equals(enableSwagger2str, "0")) {
                projectConfig.disableSwagger();
                enableSwagger2 = false;
            }
        }
        System.out.println("项目 [" + project + "] " + (enableSwagger2 ? "启用" : "禁用") + " Swagger2。\n");

        System.out.println("数据库类型：");
        System.out.println("    0. None");
        System.out.println("    1. MySQL");
        System.out.println("    2. SQL Server");
        System.out.print("请选择数据库类型序号(默认不使用数据库)：");
        String num = scanner.nextLine();
        DataBaseType dataTpe = DataBaseType.NONE;
        if (StringUtils.isNotBlank(num)) {
            if (StringUtils.equals(num, "0")) {
                dataTpe = DataBaseType.NONE;
            } else if (StringUtils.equals(num, "1")) {
                dataTpe = DataBaseType.MYSQL;
            } else if (StringUtils.equals(num, "2")) {
                dataTpe = DataBaseType.SQLSERVER;
            }
        }
        DataBaseConfig dataBaseConfig = projectConfig.setDataBaseType(dataTpe);
        if (dataTpe.equals(DataBaseType.NONE)) {
            System.out.println("项目 [" + project + "] 不使用数据库。\n");
        } else {
            System.out.println("项目 [" + project + "] 数据库采用 [" + dataTpe.toString() + "]。\n");
        }

        if (!dataTpe.equals(DataBaseType.NONE)) {

            System.out.print("请输入数据库JDBC连接地址：");
            String jdbc_url = scanner.nextLine();

            System.out.print("请输入数据库用户名：");
            String username = scanner.nextLine();

            System.out.print("请输入数据库用户名密码：");
            String password = scanner.nextLine();
            System.out.println();
            projectConfig = dataBaseConfig.JDBCconfigure(jdbc_url, username, password);

            System.out.println("持久层框架：");
            System.out.println("    0. JPA");
            System.out.println("    1. MyBatis");
            System.out.print("请选择持久层框架序号(默认JPA)：");
            num = scanner.nextLine();
            OrmType ormType = OrmType.JPA;
            if (StringUtils.isNotBlank(num)) {
                if (StringUtils.equals(num, "0")) {
                    ormType = OrmType.JPA;
                } else {
                    ormType = OrmType.MYBATIS;
                }
            }
            projectConfig.setOrmType(ormType);
            System.out.println("项目 [" + project + "] 持久层框架采用 [" + ormType.toString() + "]。\n");

            System.out.println("数据库连接池：");
            System.out.println("    0. Druid");
            System.out.println("    1. HikariCP");
            System.out.print("请选择数据库连接池序号(默认HikariCP)：");
            num = scanner.nextLine();
            DataBaseConnectPool dataBaseConnectPool = DataBaseConnectPool.HIKARICP;
            if (StringUtils.isNotBlank(num)) {
                if (StringUtils.equals(num, "0")) {
                    dataBaseConnectPool = DataBaseConnectPool.DRUID;
                } else {
                    dataBaseConnectPool = DataBaseConnectPool.HIKARICP;
                }
            }
            projectConfig.setDataBaseConnectPool(dataBaseConnectPool);
            System.out.println("项目 [" + project + "] 数据库连接池采用 [" + dataBaseConnectPool.toString() + "]。\n");
        }

        System.out.println("是否启用Docker：");
        System.out.println("    0. 禁用");
        System.out.println("    1. 启用");
        System.out.print("请选择(默认禁用)：");
        boolean enableDocker = false;
        String enableDockerstr = scanner.nextLine();
        if (StringUtils.isNotBlank(enableDockerstr)) {
            if (StringUtils.equals(enableDockerstr, "1")) {
                projectConfig.enableDocker();
                enableDocker = true;
            }
        }
        System.out.println("项目 [" + project + "] " + (enableDocker ? "启用" : "禁用") + " Docker。\n");


        System.out.println("开始构建 [" + project + "] 项目...");
        CodeBuilder.toFilePath(path).build(projectConfig);
        System.out.println("构建 [" + project + "] 项目完毕！");
        System.out.println("请前往目录 [" + path + "] 下查看项目！");
    }
}
