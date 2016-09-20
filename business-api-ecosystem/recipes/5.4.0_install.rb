#
# Cookbook Name:: business-api-ecosystem
# Recipe:: 5.4.0_install
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

#git_repos = [{
#  'repository' => 'https://github.com/FIWARE-TMForum/business-ecosystem-rss.git'
#  'branch' => node[:rss][:branch]
#}]

rss_data = Hash[
  :url => 'https://github.com/FIWARE-TMForum/business-ecosystem-rss/releases/download/v5.4.0/DSRevenueSharing.war',
  :database => node[:biz][:rss][:database],
  :root => node[:biz][:rss][:root]
]

catalog_data = Hash[
  :url => 'https://github.com/FIWARE-TMForum/DSPRODUCTCATALOG2/releases/download/v5.4.0/DSProductCatalog.war',
  :database => node[:biz][:catalog][:database],
  :root => node[:biz][:catalog][:root]
]

ordering_data = Hash[
  :url => 'https://github.com/FIWARE-TMForum/DSPRODUCTORDERING/releases/download/v5.4.0/DSProductOrdering.war',
  :database => node[:biz][:ordering][:database],
  :root => node[:biz][:ordering][:root]
]

inventory_data = Hash[
  :url => 'https://github.com/FIWARE-TMForum/DSPRODUCTINVENTORY/releases/download/v5.4.0/DSProductInventory.war',
  :database => node[:biz][:inventory][:database],
  :root => node[:biz][:inventory][:root]
]

wars = [rss_data, catalog_data, ordering_data, inventory_data]

# Include java
include_recipe "java"

package 'git' do
  action :install
end

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

# Create databases
#include_recipe 'mysql'

mysql_service 'default' do
  # notifies :run, 'execute[apt-get update]', :immediately
  port '3306'
  version '5.6'
  initial_root_password 'root'
  action [:create, :start]
end

for war in wars do
  execute 'create-databases' do
    command 'mysql -S /var/run/mysql-default/mysqld.sock -u root -proot -e "CREATE DATABASE IF NOT EXISTS ' + war[:database] + ';"'
  end
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

