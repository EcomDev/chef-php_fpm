if defined?(ChefSpec)
  ChefSpec::Runner.define_runner_method(:php_fpm_pool)

  def create_php_fpm_pool(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:php_fpm_pool, :create, resource)
  end

  def delete_php_fpm_pool(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:php_fpm_pool, :delete, resource)
  end
end