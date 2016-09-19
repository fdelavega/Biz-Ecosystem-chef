
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

#default[:glassfish][:domain1][:extra_libraries][:jdbcdriver][:type] = 'common'
#default[:glassfish][:domain1][:extra_libraries][:jdbcdriver][:url] = ''



# Business Ecosystem
default[:biz][:apis][:port] = '8080'
default[:biz][:rss][:database] = 'RSS'
default[:biz][:rss][:root] = 'DSRevenueSharing'

