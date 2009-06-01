# By Henrik Nyh <http://henrik.nyh.se> 2007-06-18.
# Free to modify and redistribute with credit.

# Adds a find_all_by_solr method to acts_as_solr models to enable
# will_paginate for acts_as_solr search results.

module ActsAsSolr
  module PaginationExtension

    def wp_count(options, query, method)
      method =~ /_solr$/ ? count_by_solr(query.first, options) : super
    end

    def find_all_by_solr(*args)
      find_by_solr(*args).results
    end

  end
end

ActsAsSolr::ClassMethods.send :include, ActsAsSolr::PaginationExtension