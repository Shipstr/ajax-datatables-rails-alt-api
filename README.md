# AjaxDatatablesRails::AltApi

This is an alternative API to the `ajax-datatables-rails gem`. The motivation for this was that we had a lot of datatables written agains an older version of ajax-datatables-rails. The newer version of ajax-datatables-rails was incompatible with our older implementation of datatables, so it required a major refactor effort. There were certain things in the recent ajax-datatables-rails API felt redundant, and if a major refactor was needed, a reimagined API started to be devloped.

This uses ajax-datatables-rails under the hood. Idealy, this or something similar may influence future versions of ajax-datatables-rails.

## Features

There are some additional features this API provides.

* Makes it easy to define the column definitions in the client JS. The column definitions are based on the same definitions that you declare in the datatable.
* Cells rendering automatically can delegate to the record or view. So the cell rendering blocks can easily access method defined on the view or the record.
* Columns are defined once, with the goal of reducing redundancy.
* Debugging mismatch problems with jQuery datatables can be frustrating. There is some code to help debug these tricky situations. There are still many improvements that can be done with this, but it is a start.

## Usage

Inside your application datatable or the individual datatables, include the module.

```Ruby
class ApplicationDatatable < AjaxDatatablesRails::ActiveRecord
  include AjaxDatatablesRails::AltApi
end
```

Example datatable:

```Ruby
class UserDatatable < ApplicationDatatable
  base_model 'User'

  # The default behavior is that the column is searchable, sortable, and renders the value.
  column(:first_name)
  # Column names can be arbitrary. This example references a relationship
  # alternatively, the block can be more explicit { |user| user.company.name } or { record.company.name }
  column(:company_name, source: 'Company.name') { company.name }
  column(:address, display_only: true) { format_address(address) }

  # This example auto uses both the view's `l` method and `updated_at` (from the user record)
  column(:updated_at, searchable: false) { l(updated_at, :short) }
  # In this example, `:links` is not tied to the record. So `display_only` is used so it is not searchable or sortable.
  # You can call `record` in the block to refer to the record passed to the cell renderer.
  column(:links, display_only: true) { link_to("Show", user_path(record)) }


  # assuming there is an address relationship to the user, you could expose searchable attrs this way
  search_only_attributes %w[Address.city
                            Address.state_name
                            Address.country
                            Address.country_name
                            Address.postal_code]

  # some method called by a cell renderer block
  def format_address(address)
    # makes the address pretty
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ajax-datatables-rails-alt-api.
