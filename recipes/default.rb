php_version = node['php']['version']

raise 'PHP version is unknown' unless node['php_versions'].attribute?(php_version)

node.set['php']['install_method'] = 'source'
node.set['php']['version'] = node['php_versions'][php_version]['version']
node.set['php']['checksum'] = node['php_versions'][php_version]['checksum']

if node['php']['recompile']
  php_binary = node['php']['prefix_dir'] + '/bin/' + node['php']['bin']
  php_version_match = 'test -f ' + php_binary + ' && ('+ php_binary +' -v | grep "PHP ' + node['php']['version'] +'")'
  file php_binary do
    action :delete
    not_if php_version_match
  end
end

include_recipe 'php::default'



