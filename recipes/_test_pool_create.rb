
if node.attribute?('_php_fpm_test')
  php_fpm_pool node['_php_fpm_test']['pool'] do
    node['_php_fpm_test'].each_pair do |key, value|
      if key != 'pool'
        send(key.to_sym, value)
      end
    end
  end
end