import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.DriverManager;
import java.util.Properties;

import org.olap4j.CellSet;
import org.olap4j.OlapConnection;
import org.olap4j.OlapStatement;
import org.olap4j.layout.RectangularCellSetFormatter;

public class RunMdx {
  public static void main(String[] args) throws Exception {
    if (args.length != 1) {
      System.err.println("Usage: RunMdx <query.mdx>");
      System.exit(1);
    }

    String schemaPath = requireEnv("MONDRIAN_SCHEMA_PATH");
    String dbHost = envOrDefault("MONDRIAN_DB_HOST", "localhost");
    String dbPort = envOrDefault("MONDRIAN_DB_PORT", "3306");
    String dbName = envOrDefault("MONDRIAN_DB_NAME", "mm_warehouse");
    String dbUser = requireEnv("MONDRIAN_DB_USER");
    String dbPassword = requireEnv("MONDRIAN_DB_PASSWORD");
    String dbParams = envOrDefault(
        "MONDRIAN_DB_PARAMS",
        "useUnicode=true&characterEncoding=UTF-8&serverTimezone=Europe/Paris");

    String mdx = readFile(args[0]);

    String jdbcUrl = String.format(
        "jdbc:mondrian:"
            + "Jdbc=jdbc:mariadb://%s:%s/%s?%s;"
            + "Catalog=file:%s;"
            + "JdbcDrivers=org.mariadb.jdbc.Driver;"
            + "JdbcUser=%s;"
            + "JdbcPassword=%s;",
        dbHost,
        dbPort,
        dbName,
        dbParams,
        schemaPath,
        dbUser,
        dbPassword);

    Class.forName("mondrian.olap4j.MondrianOlap4jDriver");

    Properties props = new Properties();
    try (OlapConnection connection =
            (OlapConnection) DriverManager.getConnection(jdbcUrl, props);
        OlapStatement statement = connection.createStatement()) {
      CellSet cellSet = statement.executeOlapQuery(mdx);
      RectangularCellSetFormatter formatter = new RectangularCellSetFormatter(false);
      PrintWriter out = new PrintWriter(System.out, true);
      formatter.format(cellSet, out);
      out.flush();
    }
  }

  private static String requireEnv(String name) {
    String value = System.getenv(name);
    if (value == null || value.isBlank()) {
      System.err.println("Missing required environment variable: " + name);
      System.exit(2);
    }
    return value;
  }

  private static String envOrDefault(String name, String fallback) {
    String value = System.getenv(name);
    return (value == null || value.isBlank()) ? fallback : value;
  }

  private static String readFile(String path) throws IOException {
    return Files.readString(Path.of(path), StandardCharsets.UTF_8);
  }
}
