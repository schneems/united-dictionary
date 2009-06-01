class Test::Unit::TestCase
  begin
    Net::HTTP.get_response(URI.parse('http://localhost:8981/solr/'))
  rescue Errno::ECONNREFUSED
    raise "You forgot to 'rake solr:start RAILS_ENV=test', foo!"
  end 

  def self.fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit:: TestCase.fixture_path, table_names)
    end
    table_names.each do |table_name|
      clear_from_solr(table_name)
      klass = instance_eval table_name.to_s.capitalize.singularize.camelize
      klass.find (:all).each{|content| content.solr_save}
    end
  end

  private
  def self.clear_from_solr(table_name)
    ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => "type_t:#{table_name.to_s.capitalize.singularize.camelize}")
  end
end