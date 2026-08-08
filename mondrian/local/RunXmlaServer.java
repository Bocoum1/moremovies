import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;

import mondrian.olap.MondrianServer;
import mondrian.spi.CatalogLocator;
import mondrian.spi.impl.CatalogLocatorImpl;
import mondrian.xmla.XmlaHandler;
import mondrian.xmla.impl.MondrianXmlaServlet;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.olap4j.OlapConnection;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;

public class RunXmlaServer {
  private static final String DATASOURCE_NAME = "MoreMoviesWarehouse";

  private static final class LocalMondrianXmlaServlet extends MondrianXmlaServlet {
    private final String endpointUrl;
    private final String dataSourceInfo;

    private LocalMondrianXmlaServlet(String endpointUrl, String dataSourceInfo) {
      this.endpointUrl = endpointUrl;
      this.dataSourceInfo = dataSourceInfo;
    }

    @Override
    protected CatalogLocator makeCatalogLocator(ServletConfig servletConfig) {
      return CatalogLocatorImpl.INSTANCE;
    }

    @Override
    protected XmlaHandler.ConnectionFactory createConnectionFactory(ServletConfig servletConfig)
        throws ServletException {
      XmlaHandler.ConnectionFactory delegate = super.createConnectionFactory(servletConfig);
      MondrianServer delegateServer = this.server;
      Map<String, Object> discoverResponse = new LinkedHashMap<>();
      discoverResponse.put("DataSourceName", DATASOURCE_NAME);
      discoverResponse.put(
          "DataSourceDescription",
          "Local Mondrian XMLA server for MoreMovies");
      discoverResponse.put("URL", endpointUrl);
      discoverResponse.put("DataSourceInfo", dataSourceInfo);
      discoverResponse.put("ProviderName", "Mondrian");
      discoverResponse.put("ProviderType", new String[] {"MDP"});
      discoverResponse.put("AuthenticationMode", "Unauthenticated");

      return new XmlaHandler.ConnectionFactory() {
        @Override
        public OlapConnection getConnection(
            String catalog,
            String schema,
            String roleName,
            Properties properties) throws SQLException {
          return delegate.getConnection(catalog, schema, roleName, properties);
        }

        @Override
        public Map<String, Object> getPreConfiguredDiscoverDatasourcesResponse() {
          return discoverResponse;
        }
      };
    }
  }

  private static String env(String name, String defaultValue) {
    String value = System.getenv(name);
    return (value == null || value.isBlank()) ? defaultValue : value;
  }

  private static String requiredEnv(String name) {
    String value = System.getenv(name);
    if (value == null || value.isBlank()) {
      throw new IllegalArgumentException("Variable d'environnement manquante: " + name);
    }
    return value;
  }

  private static String xmlEscape(String value) {
    return value
        .replace("&", "&amp;")
        .replace("\"", "&quot;")
        .replace("<", "&lt;")
        .replace(">", "&gt;");
  }

  private static String buildDataSourceInfo(
      String host,
      String port,
      String dbName,
      String dbUser,
      String dbPassword,
      String dbParams,
      String schemaPath) {
    return "Provider=mondrian;"
        + "Jdbc=jdbc:mariadb://" + host + ":" + port + "/" + dbName + "?" + dbParams + ";"
        + "JdbcDrivers=org.mariadb.jdbc.Driver;"
        + "JdbcUser=" + dbUser + ";"
        + "JdbcPassword=" + dbPassword + ";"
        + "Catalog=file:" + schemaPath + ";";
  }

  private static Path writeDataSourcesXml(
      String endpointUrl,
      String schemaPath,
      String dataSourceInfo) throws IOException {
    String xml =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            + "<DataSources>\n"
            + "  <DataSource>\n"
            + "    <DataSourceName>" + DATASOURCE_NAME + "</DataSourceName>\n"
            + "    <DataSourceDescription>Local Mondrian XMLA server for MoreMovies</DataSourceDescription>\n"
            + "    <URL>" + xmlEscape(endpointUrl) + "</URL>\n"
            + "    <DataSourceInfo>" + xmlEscape(dataSourceInfo) + "</DataSourceInfo>\n"
            + "    <ProviderName>Mondrian</ProviderName>\n"
            + "    <ProviderType>MDP</ProviderType>\n"
            + "    <AuthenticationMode>Unauthenticated</AuthenticationMode>\n"
            + "    <Catalogs>\n"
            + "      <Catalog name=\"" + DATASOURCE_NAME + "\">\n"
            + "        <DataSourceInfo>" + xmlEscape(dataSourceInfo) + "</DataSourceInfo>\n"
            + "        <Definition>file:" + xmlEscape(schemaPath) + "</Definition>\n"
            + "      </Catalog>\n"
            + "    </Catalogs>\n"
            + "  </DataSource>\n"
            + "</DataSources>\n";

    Path tmpFile = Files.createTempFile("mondrian-datasources-", ".xml");
    Files.writeString(
        tmpFile,
        xml,
        StandardCharsets.UTF_8,
        StandardOpenOption.TRUNCATE_EXISTING);
    return tmpFile;
  }

  public static void main(String[] args) throws Exception {
    String schemaPath = requiredEnv("MONDRIAN_SCHEMA_PATH");
    String dbHost = env("MONDRIAN_DB_HOST", "localhost");
    String dbPort = env("MONDRIAN_DB_PORT", "3306");
    String dbName = env("MONDRIAN_DB_NAME", "mm_warehouse");
    String dbUser = requiredEnv("MONDRIAN_DB_USER");
    String dbPassword = requiredEnv("MONDRIAN_DB_PASSWORD");
    String dbParams =
        env("MONDRIAN_DB_PARAMS", "useUnicode=true&characterEncoding=UTF-8&serverTimezone=Europe/Paris");
    int xmlaPort = Integer.parseInt(env("MONDRIAN_XMLA_PORT", "8888"));
    String endpointPath = env("MONDRIAN_XMLA_PATH", "/xmla");
    if (!endpointPath.startsWith("/")) {
      endpointPath = "/" + endpointPath;
    }

    String endpointUrl = "http://localhost:" + xmlaPort + endpointPath;
    String dataSourceInfo =
        buildDataSourceInfo(dbHost, dbPort, dbName, dbUser, dbPassword, dbParams, schemaPath);
    Path dataSourcesXml = writeDataSourcesXml(endpointUrl, schemaPath, dataSourceInfo);

    Runtime.getRuntime().addShutdownHook(new Thread(() -> {
      try {
        Files.deleteIfExists(dataSourcesXml);
      } catch (IOException ignored) {
      }
    }));

    Server server = new Server(xmlaPort);
    ServletContextHandler context = new ServletContextHandler(ServletContextHandler.NO_SESSIONS);
    context.setContextPath("/");
    server.setHandler(context);

    ServletHolder holder = new ServletHolder(new LocalMondrianXmlaServlet(endpointUrl, dataSourceInfo));
    holder.setInitOrder(1);
    holder.setInitParameter("DataSourcesConfig", dataSourcesXml.toAbsolutePath().toString());
    context.addServlet(holder, endpointPath);

    server.start();

    System.out.println("Mondrian XML/A local pret.");
    System.out.println("Endpoint : " + endpointUrl);
    System.out.println("Catalog  : " + DATASOURCE_NAME);
    System.out.println("Config   : " + dataSourcesXml.toAbsolutePath());
    System.out.println("Arret    : Ctrl+C");

    server.join();
  }
}
