# Support whyrun
def whyrun_supported?
  true
end

action :create do
  run_context.include_recipe 'php_fpm::fpm'
  resource = Array.new
  variables = new_resource.hash_fill_default_options(
      new_resource.state,
      node['php']['fpm']['default'],
      :fpm_default
  )

  variables[:listen] = new_resource.php_fpm_listen(new_resource.name, variables)
  variables[:listen_params] = new_resource.generate_php_fpm_listen_params(new_resource.name)

  resource <<= template "#{node['php']['fpm']['conf_dir']}/php-fpm.conf" do
    owner 'root'
    group 'root'
    source 'conf.erb'
    cookbook 'php_fpm'
    if new_resource.any_pools?
      notifies :restart, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    end
    mode 00644
  end

  resource <<= template "#{node['php']['fpm']['pool_dir']}/#{new_resource.name}.conf" do
    owner 'root'
    group 'root'
    mode '755'
    source 'pool.erb'
    cookbook 'php_fpm'
    variables(
        params: variables
    )
    if new_resource.any_pools?
      notifies :reload, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    else
      notifies :start, 'service[' + node['php']['fpm']['service'] + ']', :immediately
    end
  end

  new_resource.update_from_resources(resource)
end

action :delete do
  run_context.include_recipe 'php_fpm::fpm'

  resource = file "#{node['php']['fpm']['pool_dir']}/#{new_resource.name}.conf" do
    action :delete
    # notifies :restart, 'service[php-app-fpm]', :immediate
  end

  new_resource.updated_by_last_action(resource.updated_by_last_action?)
end