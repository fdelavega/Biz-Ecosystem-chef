#
# Cookbook Name:: business_api_ecosystem
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

node.default[:biz][:version] = 'v5.4.1'

node.default[:nodejs][:version] = '6.10.0'
node.default[:nodejs][:binary][:checksum] = '0f28bef128ef8ce2d9b39b9e46d2ebaeaa8a301f57726f2eba46da194471f224' 

node.default[:biz][:proxy][:conf] = '5.4.1.config.js.erb'

include_recipe "business_api_ecosystem::install"

# Create search indexes

directory '/opt/biz-ecosystem/business-ecosystem-logic-proxy/indexes' do
  recursive true
end

execute 'create_indexes' do
  command 'cd /opt/biz-ecosystem/business-ecosystem-logic-proxy/ && node fill_indexes.js'
end

service "business-proxy" do
  action :restart
end

