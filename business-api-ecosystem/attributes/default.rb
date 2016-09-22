
require 'json'

conf_data = {
  'host' => 'localhost',
  'port' => 8000,
  'client_id' => 'client_id',
  'client_secret' => 'client_secret',
  'charging' => {
    'port' => 8006,
    'email_user' => 'email_user',
    'email' => 'biz@email.com',
    'email_passwd' => 'email_passwd',
    'email_server' => 'email_server',
    'email_port' => 587,
    'paypal_id' => 'paypal_id',
    'paypal_secret' => 'paypal_secret',
    'paypal_mode' => 'sandbox'
  }
}

# Override attributes with user configuration
if File.exist? '/opt/biz-ecosystem/biz-conf.json'
  conf = File.read('/opt/biz-ecosystem/biz-conf.json')
  conf_data = JSON.parse(conf)
end

# Business Ecosystem
default[:biz][:host] = conf_data['host']
default[:biz][:port] = conf_data['port']

default[:biz][:client_id] = conf_data['client_id']
default[:biz][:client_secret] = conf_data['client_secret']
default[:biz][:callback_url] = "http://#{default[:biz][:host]}:#{default[:biz][:port]}/auth/fiware/callback"

default[:biz][:charging][:port] = conf_data['charging']['port']
default[:biz][:charging][:email][:user] = conf_data['charging']['email_user']
default[:biz][:charging][:email][:email] = conf_data['charging']['email']
default[:biz][:charging][:email][:passwd] = conf_data['charging']['email_passwd']
default[:biz][:charging][:email][:server] = conf_data['charging']['email_server']
default[:biz][:charging][:email][:port] = conf_data['charging']['email_port']

default[:biz][:charging][:paypal][:id] = conf_data['charging']['paypal_id']
default[:biz][:charging][:paypal][:secret] = conf_data['charging']['paypal_secret']
default[:biz][:charging][:paypal][:mode] = conf_data['charging']['paypal_mode']

# APIs
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

# Java 8
default[:java][:install_flavor] = 'oracle'
default[:java][:jdk_version] = '8'
default[:java][:oracle][:accept_oracle_download_terms] = true

# Glassfish
default[:glassfish][:version] = '4.1'
default[:glassfish][:package_url] = 'http://download.java.net/glassfish/4.1/release/glassfish-4.1.zip'
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

