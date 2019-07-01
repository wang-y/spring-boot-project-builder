package com.wymix.project.core.constant;

public enum DataBaseType {
    NONE(null),
    MYSQL("com.mysql.cj.jdbc.Driver"),
    SQL_SERVER("com.microsoft.jdbc.sqlserver.SQLServerDriver"),
    MARIADB("com.mariadb.jdbc.Driver"),
    ORACLE("oracle.jdbc.OracleDriver"),
    DB2("com.ibm.db2.jcc.DB2Driver"),
    H2("org.h2.Driver"),
    SQLITE("org.sqlite.JDBC"),
    POSTGRE_SQL("org.postgresql.Driver");

    private String driverClassName;

    DataBaseType(String driverClassName) {
        this.driverClassName = driverClassName;
    }

    public String getDriverClassName() {
        return this.driverClassName;
    }
}
