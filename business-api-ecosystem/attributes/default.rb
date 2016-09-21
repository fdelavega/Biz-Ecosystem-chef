
# Business Ecosystem
default[:biz][:host] = 'localhost'
default[:biz][:port] = 8000

default[:biz][:rss][:database] = 'RSS'
default[:biz][:rss][:root] = 'DSRevenueSharing'

default[:biz][:catalog][:database] = 'Catalog'
default[:biz][:catalog][:root] = 'DSProductCatalog'

default[:biz][:ordering][:database] = 'Ordering'
default[:biz][:ordering][:root] = 'DSProductOrdering'

default[:biz][:inventory][:database] = 'Inventory'
default[:biz][:inventory][:root] = 'DSProductInventory'

default[:biz][:party][:database] = 'Party'
default[:biz][:party][:root] = 'DSPartyManagement'

default[:biz][:customer][:database] = 'Customer'
default[:biz][:customer][:root] = 'DSCustomerManagement'

default[:biz][:billing][:database] = 'Billing'
default[:biz][:billing][:root] = 'DSBillingManagement'

default[:biz][:usage][:database] = 'UsageM'
default[:biz][:usage][:root] = 'DSUsageManagement'

default[:biz][:charging][:port] = 8006
default[:biz][:charging][:email][:user] = 'email_user'
default[:biz][:charging][:email][:email] = 'biz@email.com'
default[:biz][:charging][:email][:passwd] = 'email_passwd'
default[:biz][:charging][:email][:server] = 'email_server'
default[:biz][:charging][:email][:port] = 557

# Java 8
default[:java][:install_flavor] = 'oracle'
default[:java][:jdk_version] = '8'
default[:java][:oracle][:accept_oracle_download_terms] = true

# Glassfish
default[:glassfish][:version] = '4.1.1'
default[:glassfish][:package_url] = 'http://download.java.net/glassfish/4.1.1/release/glassfish-4.1.1.zip'
default[:glassfish][:domains][:domain1][:config][:username] = 'admin'
default[:glassfish][:domains][:domain1][:config][:password] = 'adminpwd'
default[:glassfish][:domains][:domain1][:config][:master_password] = 'masterpwd'

default[:glassfish][:domains][:domain1][:extra_libraries][:jdbcdriver][:type] = 'common'
default[:glassfish][:domains][:domain1][:extra_libraries][:jdbcdriver][:url] = 'file:///tmp/mysql-connector-java-5.1.39-bin.jar'
default[:glassfish][:domains][:domain1][:extra_libraries][:jdbcdriver][:requires_restart] = true

tmf_apis = ['catalog', 'ordering', 'inventory', 'party', 'customer', 'billing', 'usage']

for api in tmf_apis do
  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:driverclassname] = 'com.mysql.jdbc.Driver'
  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:validationmethod] = 'auto-commit'
  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:restype] = 'java.sql.Driver'

  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:properties][:user] = 'root'
  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:properties][:password] = 'root'
  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:properties][:DatabaseName] = default[:biz][api][:database]
  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:config][:properties][:URL] = 'jdbc:mysql://localhost:3306/' + default[:biz][api][:database]

  default[:glassfish][:domains][:domain1][:jdbc_connection_pools][api][:resources]['jdbc/' + api][:description] = 'Catalog JDBC'
end
