package ${basepackage};

import com.google.common.base.CaseFormat;
import freemarker.template.TemplateExceptionHandler;
import org.apache.commons.lang3.StringUtils;

import java.net.URI;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class CodeGenerator {

    //JDBC配置，请修改为你项目的实际配置
    private static final String JDBC_URL = "${database_url}";
    private static final String JDBC_USERNAME = "${database_user}";
    private static final String JDBC_PASSWORD = "${database_passowrd}";
    private static final String JDBC_DIVER_CLASS_NAME = "${jdbc_diver_class_name}";

    private static final String PROJECT_PATH = System.getProperty("user.dir");//项目在硬盘上的基础路径
    private static final String TEMPLATE_FILE_PATH = PROJECT_PATH + "/src/test/resources/generator/template";//模板位置

    private static final String JAVA_PATH = "/src/main/java/"; //java文件路径
    private static final String RESOURCES_PATH = "/src/main/resources";//资源文件路径

    private static final boolean ENABLED_SWAGGER="${enabled_swagger}" == "yes";

    private static final String DATABASETYPE="${databasetype}";

    public static void main(String[] args) {
        genCode("test_table","Long");
    }


    public static String genModelAndVo(String tableName, String modelName) {
        Connection con = null;
        PreparedStatement pStemt = null;
        ResultSet rs = null;
        try {
            try {
                Class.forName(JDBC_DIVER_CLASS_NAME);
            } catch (ClassNotFoundException e1) {
                e1.printStackTrace();
            }

            String sql="";

            if (StringUtils.equalsIgnoreCase(DATABASETYPE, "mysql")) {
                String cleanURI = JDBC_URL.substring(5);
                URI uri = URI.create(cleanURI);
                String host=uri.getHost();
                String port=String.valueOf(uri.getPort());
                String database=uri.getPath().replaceFirst("/", "");
                con = DriverManager.getConnection("jdbc:mysql://"+host+":"+port+"/INFORMATION_SCHEMA?zeroDateTimeBehavior=convertToNull&autoReconnect=true&useUnicode=true&characterEncoding=utf-8",
                      JDBC_USERNAME, JDBC_PASSWORD);
                sql += "select COLUMN_NAME,DATA_TYPE,COLUMN_COMMENT,COLUMN_KEY,EXTRA from COLUMNS where TABLE_SCHEMA='"+database+"' and TABLE_NAME=?";
            } else if (StringUtils.equalsIgnoreCase(DATABASETYPE, "oracle")) {
                //无oracle环境，暂不编辑
            } else if (StringUtils.equalsIgnoreCase(DATABASETYPE, "sqlserver")) {
                //无sqlserver环境，暂不编辑
            }


            pStemt = con.prepareStatement(sql);
            pStemt.setString(1, tableName);
            rs = pStemt.executeQuery();

            rs.last();
            int size = rs.getRow(); // 统计列
            rs.beforeFirst();
            String[] colnames = new String[size];
            String[] colTypes = new String[size];
            String[] colComments = new String[size];
            String[] colKeys = new String[size];
            String[] extras = new String[size];

            boolean f_util = false; // 是否需要导入包java.util.*
            boolean f_sql = false;
            int index = 0;
            while (rs.next()) {
                colnames[index] = rs.getString("COLUMN_NAME");
                colTypes[index] = rs.getString("DATA_TYPE");
                colComments[index] = rs.getString("COLUMN_COMMENT");
                colKeys[index] = rs.getString("COLUMN_KEY");
                extras[index] = rs.getString("EXTRA");
                if (colTypes[index].equalsIgnoreCase("datetime") || colTypes[index].equalsIgnoreCase("date")) {
                    f_util = true;
                }
                if (colTypes[index].equalsIgnoreCase("image") || colTypes[index].equalsIgnoreCase("text")) {
                    f_sql = true;
                }
                index++;
            }
            String entitycontent = buildEntity(colnames, colTypes, colKeys, extras, tableName, modelName, f_util, f_sql,colComments);
            String vocontent = buildVo(colnames, colTypes, colKeys, extras, StringUtils.isNotBlank(modelName) ? modelName : tableName, f_util,colComments);

            String modelPackage = "${businesspackage}.model";
            String voPackage = "${businesspackage}.vo";

            try {
                String outputPath = PROJECT_PATH + JAVA_PATH + modelPackage.replace(".", "/") + "/" + tableNameConvertUpperCamel(StringUtils.isNotBlank(modelName) ? modelName : tableName) + ".java";
                File f = new File(PROJECT_PATH + JAVA_PATH + modelPackage.replace(".", "/") + "/");
                if (!f.exists()) {
                    f.mkdirs();
                }
                FileWriter fw = new FileWriter(outputPath);
                PrintWriter pw = new PrintWriter(fw);
                pw.println(entitycontent);
                pw.flush();
                pw.close();
                fw.close();

                outputPath = PROJECT_PATH + JAVA_PATH + voPackage.replace(".", "/") + "/" + tableNameConvertUpperCamel(StringUtils.isNotBlank(modelName) ? modelName : tableName) + "Vo.java";
                f = new File(PROJECT_PATH + JAVA_PATH + voPackage.replace(".", "/") + "/");
                if (!f.exists()) {
                    f.mkdirs();
                }
                fw = new FileWriter(outputPath);
                pw = new PrintWriter(fw);
                pw.println(vocontent);
                pw.flush();
                pw.close();
                fw.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            return tableNameConvertUpperCamel(StringUtils.isNotBlank(modelName) ? modelName : tableName);
        }
    }

    private static void processAllMethod(StringBuffer sb, String[] colnames, String[] colTypes) {
        for (int i = 0; i < colnames.length; i++) {
            sb.append("    public " + sqlType2JavaType(colTypes[i]) + " get" + tableNameConvertUpperCamel(colnames[i]) + "(){\r\n");
            sb.append("        return " + colnames[i] + ";\r\n");
            sb.append("    }\r\n\n");

            sb.append("    public void set" + tableNameConvertUpperCamel(colnames[i]) + "(" + sqlType2JavaType(colTypes[i]) + " "
                    + colnames[i] + "){\r\n");
            sb.append("        this." + colnames[i] + "=" + colnames[i] + ";\r\n");
            sb.append("    }\r\n\n");
        }
    }

    private static String buildEntity(String[] colnames, String[] colTypes, String[] colKeys, String[] extras, String tableName, String modelname, boolean f_util, boolean f_sql,String[] colComments) {
        StringBuffer sb = new StringBuffer();
        sb.append("package ${businesspackage}.model;\r\n\r\n");
        sb.append("import lombok.Data;\r\n\n");
        sb.append("import java.io.Serializable;\r\n");
        sb.append("import javax.persistence.*;\r\n");
        // 判断是否导入工具包
        if (f_util) {
            sb.append("import java.util.Date;\r\n");
        }
        if (f_sql) {
            sb.append("import java.sql.*;\r\n");
        }
        sb.append("\r\n");
        // 注释部分
        sb.append("/**\r\n");
        sb.append(" * " + tableName + " 实体类\r\n");

        sb.append(" */\r\n");
        // 实体部分
        sb.append("\r\n@Data");
        sb.append("\r\n@Entity");
        sb.append("\r\n@Table(name = \"" + tableName + "\")");
        sb.append("\r\npublic class " + tableNameConvertUpperCamel(StringUtils.isNotBlank(modelname) ? modelname : tableName) + " implements Serializable {\r\n\r\n");
        processAllAttrs(sb, colnames, colTypes, colKeys, extras,colComments);// 属性
        //processAllMethod(sb, colnames, colTypes);// get set方法
        sb.append("}\r\n");

        // System.out.println(sb.toString());
        return sb.toString();
    }

    private static String buildVo(String[] colnames, String[] colTypes, String[] colKeys, String[] extras, String tableName, boolean f_util,String[] colComments) {
        StringBuffer sb = new StringBuffer();
        sb.append("package ${businesspackage}.vo;\r\n\r\n");
        if(ENABLED_SWAGGER) {
            sb.append("import io.swagger.annotations.ApiModelProperty;\r\n");
        }
        sb.append("import lombok.Data;\r\n\n");
        sb.append("import java.io.Serializable;\r\n");
        // 判断是否导入工具包
        if (f_util) {
            sb.append("import java.util.Date;\r\n");
        }

        sb.append("\r\n");
        // 注释部分
        sb.append("/**\r\n");
        sb.append(" * " + tableName + " Vo类\r\n");

        sb.append(" */\r\n");
        // 实体部分
        sb.append("\r\n@Data");
        sb.append("\r\npublic class " + tableNameConvertUpperCamel(tableName) + "Vo implements Serializable {\r\n\r\n");
        processAllAttrs2(sb, colnames, colTypes,colComments);// 属性
        //processAllMethod(sb, colnames, colTypes);// get set方法
        sb.append("}\r\n");

        // System.out.println(sb.toString());
        return sb.toString();
    }

    private static void processAllAttrs2(StringBuffer sb, String[] colnames, String[] colTypes,String[] colComments) {

        for (int i = 0; i < colnames.length; i++) {
            String javaType = sqlType2JavaType(colTypes[i]);
            if(ENABLED_SWAGGER&&StringUtils.isNotBlank(colComments[i])){
                sb.append("    @ApiModelProperty(value = \"" + colComments[i] + "\")\r\n");
            }
            sb.append("    private " + javaType + " " + columnNameConvertUpperCamel(colnames[i]) + ";\r\n\r\n");
        }

    }

    private static void processAllAttrs(StringBuffer sb, String[] colnames, String[] colTypes, String[] colKeys, String[] extras,String[] colComments) {

        for (int i = 0; i < colnames.length; i++) {

            if (StringUtils.isNotBlank(colKeys[i])) {
                if (StringUtils.equalsIgnoreCase(colKeys[i], "PRI")) {
                    sb.append("    @Id\r\n");
                }
            }

            if (StringUtils.isNotBlank(extras[i])) {
                if (StringUtils.equalsIgnoreCase(extras[i], "auto_increment")) {
                    if (StringUtils.equalsIgnoreCase(DATABASETYPE, "mysql")||StringUtils.equalsIgnoreCase(DATABASETYPE, "sql_server")) {
                        sb.append("    @GeneratedValue(strategy = GenerationType.IDENTITY)\r\n");
                    } else if(StringUtils.equalsIgnoreCase(DATABASETYPE, "oracle")) {
                        sb.append("    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = \"CUST_SEQ\")\r\n");
                        sb.append("    @SequenceGenerator(sequenceName = \"customer_seq\", allocationSize = 1, name = \"CUST_SEQ\")\r\n");
                    }
                }
            }

            sb.append("    @Column(name = \"" + colnames[i] + "\")\r\n");

            String javaType = sqlType2JavaType(colTypes[i]);
            if (StringUtils.equalsIgnoreCase(javaType, "Date")) {
                sb.append("    @Temporal(value = TemporalType.TIMESTAMP)\r\n");
            }
            sb.append("    private " + javaType + " " + columnNameConvertUpperCamel(colnames[i]) + ";");
            if (StringUtils.isNotBlank(colComments[i])){
                sb.append("  // "+colComments[i]);
            }
            sb.append("\r\n\r\n");
        }

    }

    /**
     * 功能：获得列的数据类型
     *
     * @param sqlType
     * @return
     */
    private static String sqlType2JavaType(String sqlType) {

        if (sqlType.equalsIgnoreCase("bit")) {
            return "Boolean";
        } else if (sqlType.equalsIgnoreCase("tinyint")) {
            return "Byte";
        } else if (sqlType.equalsIgnoreCase("smallint")) {
            return "Short";
        } else if (sqlType.equalsIgnoreCase("int")) {
            return "Integer";
        } else if (sqlType.equalsIgnoreCase("bigint")) {
            return "Long";
        } else if (sqlType.equalsIgnoreCase("float")) {
            return "Float";
        } else if (sqlType.equalsIgnoreCase("double") || sqlType.equalsIgnoreCase("decimal")
                || sqlType.equalsIgnoreCase("numeric") || sqlType.equalsIgnoreCase("real")
                || sqlType.equalsIgnoreCase("money") || sqlType.equalsIgnoreCase("smallmoney")) {
            return "Double";
        } else if (sqlType.equalsIgnoreCase("varchar") || sqlType.equalsIgnoreCase("char")
                || sqlType.equalsIgnoreCase("nvarchar") || sqlType.equalsIgnoreCase("nchar")
                || sqlType.equalsIgnoreCase("text")) {
            return "String";
        } else if (sqlType.equalsIgnoreCase("datetime") || sqlType.equalsIgnoreCase("date")) {
            return "Date";
        } else if (sqlType.equalsIgnoreCase("image")) {
            return "Blod";
        }
        return null;
    }

    private static String tableNameConvertUpperCamel(String tableName) {
        return CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL, tableName.toLowerCase());
    }

    private static String columnNameConvertUpperCamel(String columnName) {
        return CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, columnName.toLowerCase());
    }

    private static freemarker.template.Configuration getConfiguration() throws IOException {
        freemarker.template.Configuration cfg = new freemarker.template.Configuration(freemarker.template.Configuration.VERSION_2_3_23);
        cfg.setDirectoryForTemplateLoading(new File(TEMPLATE_FILE_PATH));
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.IGNORE_HANDLER);
        return cfg;
    }

    private static void genWeb(String modelName,String pkType) {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("modelName", modelName);
            data.put("PKType", pkType);

            File file = new File(PROJECT_PATH+ "/src/main/java"+ packageConvertPath("${basepackage}.business.web")+modelName+"Controller.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("web/TemplateController.ftl").process(data, new FileWriter(file));
        }catch (Exception e){

        }
    }

    private static void genService(String modelName,String pkType) {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("modelName", modelName);
            data.put("PKType", pkType);

            File file = new File(PROJECT_PATH+ "/src/main/java"+ packageConvertPath("${basepackage}.business.service")+modelName+"Service.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("service/TemplateService.ftl").process(data, new FileWriter(file));

            file = new File(PROJECT_PATH+ "/src/main/java"+ packageConvertPath("${basepackage}.business.service.impl")+modelName+"ServiceImpl.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("service/impl/TemplateServiceImpl.ftl").process(data, new FileWriter(file));
        }catch (Exception e){

        }
    }

    private static void genRepository(String modelName,String pkType) {
        try {
            freemarker.template.Configuration cfg = getConfiguration();

            Map<String, Object> data = new HashMap<>();
            data.put("modelName", modelName);
            data.put("PKType", pkType);

            File file = new File(PROJECT_PATH+ "/src/main/java"+ packageConvertPath("${basepackage}.business.repository")+modelName+"Repository.java");
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            cfg.getTemplate("repository/TemplateRepository.ftl").process(data, new FileWriter(file));
        }catch (Exception e){

        }
    }

    private static String packageConvertPath(String packageName) {
        return String.format("/%s/", packageName.contains(".") ? packageName.replaceAll("\\.", "/") : packageName);
    }

    public static void genCode(String tablename,String modelname,String pkType){
        String name=genModelAndVo(tablename, modelname);
        genRepository(name,pkType);
        genService(name,pkType);
        genWeb(name,pkType);
    }

    public static void genCode(String tablename,String pkType){
        String name=genModelAndVo(tablename, null);
        genRepository(name,pkType);
        genService(name,pkType);
        genWeb(name,pkType);
    }
}
