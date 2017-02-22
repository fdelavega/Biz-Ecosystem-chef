name             "business_api_ecosystem"
maintainer       "CoNWeT"
maintainer_email "wstore@conwet.com"
license          "Apache 2.0"
description      "Installs and configures the Business API Ecosystem"
version          "5.4.0"

depends          "glassfish"
depends          "apt"
depends          "mysql", "~> 8.0"
depends          "poise-python"
depends          "java"
depends          "mongodb"
depends          "nodejs"
depends          "yum-epel"
depends          "yum-mysql-community"

%w{ debian ubuntu centos redhat fedora }.each do |os|
    supports os
end
