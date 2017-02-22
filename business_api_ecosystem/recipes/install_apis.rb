#
# Cookbook Name:: business_api_ecosystem
# Recipe:: install_apis
#
# Copyright 2016, CoNWeT Lab., Universidad PolitÃ©cnica de Madrid
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'

rss_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/business-ecosystem-rss/releases/download/#{node[:biz][:version]}/DSRevenueSharing.war",
  :database => node[:biz][:rss][:database],
  :root => node[:biz][:rss][:root]
]

catalog_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSPRODUCTCATALOG2/releases/download/#{node[:biz][:version]}/DSProductCatalog.war",
  :database => node[:biz][:catalog][:database],
  :root => node[:biz][:catalog][:root]
]

ordering_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSPRODUCTORDERING/releases/download/#{node[:biz][:version]}/DSProductOrdering.war",
  :database => node[:biz][:ordering][:database],
  :root => node[:biz][:ordering][:root]
]

inventory_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSPRODUCTINVENTORY/releases/download/#{node[:biz][:version]}/DSProductInventory.war",
  :database => node[:biz][:inventory][:database],
  :root => node[:biz][:inventory][:root]
]

party_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSPARTYMANAGEMENT/releases/download/#{node[:biz][:version]}/DSPartyManagement.war",
  :database => node[:biz][:party][:database],
  :root => node[:biz][:party][:root]
]

customer_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSCUSTOMER/releases/download/#{node[:biz][:version]}/DSCustomerManagement.war",
  :database => node[:biz][:customer][:database],
  :root => node[:biz][:customer][:root]
]

billing_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSBILLINGMANAGEMENT/releases/download/#{node[:biz][:version]}/DSBillingManagement.war",
  :database => node[:biz][:billing][:database],
  :root => node[:biz][:billing][:root]
]

usage_data = Hash[
  :url => "https://github.com/FIWARE-TMForum/DSUSAGEMANAGEMENT/releases/download/#{node[:biz][:version]}/DSUsageManagement.war",
  :database => node[:biz][:usage][:database],
  :root => node[:biz][:usage][:root]
]

wars = [rss_data, catalog_data, ordering_data, inventory_data, party_data, customer_data, billing_data, usage_data]

# Create properties files for the RSS
directory '/etc/default/rss' do
  recursive true
end

template '/etc/default/rss/database.properties' do
  source 'database.properties.erb'
  mode '0755'
end

template '/etc/default/rss/oauth.properties' do
  source 'oauth.properties.erb'
  mode '0755'
end

include_recipe 'apt'

if node[:platform_family] == "rhel" then
  mysql_service 'default' do
    port '3306'
    version '5.6'
    initial_root_password 'root'
    action [:create, :start]
  end
else
  mysql_service 'default' do
    package_version '5.6.33-0ubuntu0.14.04.1'
    notifies :run, 'execute[apt-get update]', :immediately
    port '3306'
    version '5.6'
    initial_root_password 'root'
    action [:create, :start]
  end
end

for war in wars do
  execute 'create-databases' do
    command 'mysql -S /var/run/mysql-default/mysqld.sock -u root -proot -e "CREATE DATABASE IF NOT EXISTS ' + war[:database] + ';"'
  end
end

cookbook_file "/tmp/mysql-connector-java-5.1.39-bin.jar" do
  source "mysql-connector-java-5.1.39-bin.jar"
  mode "0755"
end

# Include Glassfish
include_recipe "glassfish::attribute_driven_domain"

glassfish_secure_admin "Remote access" do
  action :enable 
  domain_name 'domain1'
  username node[:glassfish][:domains][:domain1][:config][:username]
  password_file '/srv/glassfish/domain1_admin_passwd'
end

# Deploy war files
for war in wars do
  glassfish_deployable war[:root] do
    url war[:url]
    action :deploy
    context_root war[:root]
    domain_name 'domain1'
    username node[:glassfish][:domains][:domain1][:config][:username]
    password_file '/srv/glassfish/domain1_admin_passwd'
  end
end

