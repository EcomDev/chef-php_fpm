name             'php_fpm'
maintainer       ''
maintainer_email ''
license          ''
description      'Installs/Configures php_fpm'
long_description 'Installs/Configures php_fpm'
version          '0.1.3'

depends 'php'
depends 'apt'

%w(ubuntu debian centos).each do |os|
  supports os
end

cookbook = %w(php_fpm::default)

attribute 'php_versions',
          :display_name => 'Version Mapping',
          :description => 'Hash of php major to minor version mapping',
          :type => 'hash',
          :recipes => cookbook

attribute 'php/recompile',
          :display_name => 'Recompile PHP',
          :description => 'Shall we recompile php if the version is changed?',
          :type => 'boolean',
          :recipes => cookbook

attribute 'php/version',
          :display_name => 'PHP major version',
          :description => 'Major version of php to install',
          :type => 'string',
          :required => 'required',
          :choice => %w(5.3 5.4 5.5),
          :recipes => cookbook
