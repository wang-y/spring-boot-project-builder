package ${basepackage};

import com.google.common.base.CaseFormat;
import freemarker.template.TemplateExceptionHandler;
import lombok.Data;
import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
                
                con = DriverManager.getConnection("jdbc:mysql://"+host+":"+port+"/INFORMATION_SCHEMA?zeroDateTimeBehavior=convertToNull&autoReconnect=true&useUnicode=true&characterEncoding=utf-8",
                      JDBC_USERNAME, JDBC_PASSWORD);

                String database=uri.getPath().replaceFirst("/", "");
                sql += "select COLUMN_NAME,DATA_TYPE,COLUMN_COMMENT,COLUMN_KEY,EXTRA,NUMERIC_PRECISION,NUMERIC_SCALE from COLUMNS where TABLE_SCHEMA='" + database + "' and TABLE_NAME=?";
            } else if (StringUtils.equalsIgnoreCase(DATABASETYPE, "sqlserver")) {
                con = DriverManager.getConnection(JDBC_URL, JDBC_USERNAME, JDBC_PASSWORD);

                sql += "SELECT CAST(col.name AS NVARCHAR(1000)) AS COLUMN_NAME ,\n" +
                        "CAST(ISNULL(ep.[value], '') AS NVARCHAR(1000)) AS COLUMN_COMMENT ,\n" +
                        "CAST(t.name AS NVARCHAR(128)) AS DATA_TYPE ,\n" +
                        "ISNULL(COLUMNPROPERTY(col.id, col.name, 'Precision'), 0) AS NUMERIC_PRECISION ,\n" +
                        "ISNULL(COLUMNPROPERTY(col.id, col.name, 'Scale'), 0) AS NUMERIC_SCALE ,\n" +
                        "CASE WHEN EXISTS ( SELECT   1\n" +
                        "    FROM dbo.sysindexes si \n" +
                        "    INNER JOIN dbo.sysindexkeys sik ON si.id = sik.id AND si.indid = sik.indid\n" +
                        "    INNER JOIN dbo.syscolumns sc ON sc.id = sik.id AND sc.colid = sik.colid\n" +
                        "    INNER JOIN dbo.sysobjects so ON so.name = si.name AND so.xtype = 'PK'\n" +
                        "    WHERE sc.id = col.id AND sc.colid = col.colid ) \n" +
                        "THEN 'PRI' ELSE 'FALSE' END AS COLUMN_KEY ,\n" +
                        "CASE WHEN COLUMNPROPERTY(col.id, col.name, 'IsIdentity') = 1 THEN 'auto_increment' ELSE 'FALSE'  END AS EXTRA\n" +
                        "FROM dbo.syscolumns col\n" +
                        "LEFT  JOIN dbo.systypes t ON col.xtype = t.xusertype\n" +
                        "INNER JOIN dbo.sysobjects obj ON col.id = obj.id AND obj.xtype = 'U' AND obj.status >= 0\n" +
                        "LEFT  JOIN dbo.syscomments comm ON col.cdefault = comm.id\n" +
                        "LEFT  JOIN sys.extended_properties ep ON col.id = ep.major_id AND col.colid = ep.minor_id AND ep.name = 'MS_Description'\n" +
                        "LEFT  JOIN sys.extended_properties epTwo ON obj.id = epTwo.major_id AND epTwo.minor_id = 0 AND epTwo.name = 'MS_Description'\n" +
                        "WHERE obj.name = ? \n";
            }

            pStemt = con.prepareStatement(sql);
            pStemt.setString(1, tableName);
            rs = pStemt.executeQuery();

            List<ColumnInfo> columnInfos = new ArrayList<>();

            boolean f_util = false; // 是否需要导入包java.util.*
            boolean f_sql = false;
            while (rs.next()) {
                String column_name = rs.getString("COLUMN_NAME");
                String data_type = rs.getString("DATA_TYPE");
                String column_comment = rs.getString("COLUMN_COMMENT");
                String column_key = rs.getString("COLUMN_KEY");
                String extra = rs.getString("EXTRA");
                Integer precision = rs.getInt("NUMERIC_PRECISION");
                Integer scale = rs.getInt("NUMERIC_SCALE");

                ColumnInfo columnInfo = new ColumnInfo();
                columnInfo.setName(column_name);
                columnInfo.setType(data_type);
                columnInfo.setPrecision(precision);
                columnInfo.setScale(scale);
                columnInfo.setComment(column_comment);
                columnInfo.setColKey(column_key);
                columnInfo.setExtra(extra);

                columnInfos.add(columnInfo);

                if (data_type.equalsIgnoreCase("datetime") || data_type.equalsIgnoreCase("date")) {
                    f_util = true;
                }
                if (data_type.equalsIgnoreCase("image") || data_type.equalsIgnoreCase("text")) {
                    f_sql = true;
                }
            }
            String entitycontent = buildEntity(columnInfos, tableName, modelName, f_util, f_sql);
            String vocontent = buildVo(columnInfos, StringUtils.isNotBlank(modelName) ? modelName : tableName, f_util);

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


    private static String buildEntity(List<ColumnInfo> columnInfos, String tableName, String modelname, boolean f_util, boolean f_sql) {
        StringBuffer sb = new StringBuffer();
        sb.append("package ${basepackage}.business.model;\r\n\r\n");
        sb.append("import lombok.Getter;\r\n");
        sb.append("import lombok.Setter;\r\n\n");
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
        sb.append("\r\n@Getter");
        sb.append("\r\n@Setter");
        sb.append("\r\n@Entity");
        sb.append("\r\n@Table(name = \"" + tableName + "\")");
        sb.append("\r\npublic class " + tableNameConvertUpperCamel(StringUtils.isNotBlank(modelname) ? modelname : tableName) + " implements Serializable {\r\n\r\n");
        processAllAttrs(sb, columnInfos);// 属性
        //processAllMethod(sb, colnames, colTypes);// get set方法
        sb.append("}\r\n");

        // System.out.println(sb.toString());
        return sb.toString();
    }

    private static String buildVo(List<ColumnInfo> columnInfos, String tableName, boolean f_util) {
        StringBuffer sb = new StringBuffer();
        sb.append("package ${basepackage}.business.vo;\r\n\r\n");
        if (ENABLED_SWAGGER) {
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
        processAllAttrs2(sb, columnInfos);// 属性
        //processAllMethod(sb, colnames, colTypes);// get set方法
        sb.append("}\r\n");

        // System.out.println(sb.toString());
        return sb.toString();
    }

    private static void processAllAttrs2(StringBuffer sb, List<ColumnInfo> columnInfos) {

        for (ColumnInfo info : columnInfos) {
            String javaType = sqlType2JavaType(info);
            if (ENABLED_SWAGGER && StringUtils.isNotBlank(info.getComment())) {
                sb.append("    @ApiModelProperty(value = \"" + info.getComment() + "\")\r\n");
            }
            sb.append("    private " + javaType + " " + columnNameConvertUpperCamel(info.getName()) + ";\r\n\r\n");
        }

    }

    private static void processAllAttrs(StringBuffer sb, List<ColumnInfo> columnInfos) {

        for (ColumnInfo info : columnInfos) {

            if (StringUtils.isNotBlank(info.getColKey())) {
                if (StringUtils.equalsIgnoreCase(info.getColKey(), "PRI")) {
                    sb.append("    @Id\r\n");
                }
            }

            if (StringUtils.isNotBlank(info.getExtra())) {
                if (StringUtils.equalsIgnoreCase(info.getExtra(), "auto_increment")) {
                    sb.append("    @GeneratedValue(strategy = GenerationType.IDENTITY)\r\n");
                }
            }

            sb.append("    @Column(name = \"" + info.getName() + "\")\r\n");

            String javaType = sqlType2JavaType(info);
            if (StringUtils.equalsIgnoreCase(javaType, "Date")) {
                sb.append("    @Temporal(value = TemporalType.TIMESTAMP)\r\n");
            }
            sb.append("    private " + javaType + " " + columnNameConvertUpperCamel(info.getName()) + ";");
            if (StringUtils.isNotBlank(info.getComment())) {
                sb.append("  // " + info.getComment());
            }
            sb.append("\r\n\r\n");
        }

    }

    /**
     * 功能：获得列的数据类型
     *
     * @param info
     * @return
     */
    private static String sqlType2JavaType(ColumnInfo info) {
        String sqlType = info.getType();
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
        } else if (sqlType.equalsIgnoreCase("decimal")
                || sqlType.equalsIgnoreCase("numeric")) {
            if(info.getScale()>0){
                return "Double";
            }else{
                return "Long";
            }
        } else if (sqlType.equalsIgnoreCase("double") || sqlType.equalsIgnoreCase("real")
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

    @Data
    private static class ColumnInfo {

        private String name;
        private String type;
        private Integer precision;
        private Integer scale;
        private String comment;
        private String colKey;
        private String extra;

    }
}
