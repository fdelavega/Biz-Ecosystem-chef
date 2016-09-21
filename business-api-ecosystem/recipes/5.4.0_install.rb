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

# Include java
include_recipe "java"

package 'git' do
  action :install
end

include_recipe "business-api-ecosystem::install_apis"

directory "/opt/biz-ecosystem" do
  recursive true
end

include_recipe "mongodb::default"

mongodb_instance "mongodb" do
  smallfiles true
end

include_recipe "business-api-ecosystem::install_charging"

# Run the charging backend
service 'business-charging' do
  supports :restart => true, :start => true, :stop =>true
  action [:enable, :start]
end

# execute 'sleeep' do
#  command 'exec 9<>/dev/tcp/127.0.0.1/4848 >> /tmp/hola.txt 2>&1; exec 9>&-; exec 9<&-; exec 9>&'
# end

# execute 'start-charging' do
#  command 'service business-charging restart >> /tmp/hola.txt 2>&1'
# end
