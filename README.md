# AjaxDatatablesRails::AltApi

This is an alternative API to the [ajax-datatables-rails](https://github.com/jbox-web/ajax-datatables-rails) gem. The motivation for this was that we had a lot of datatables written against an older version of ajax-datatables-rails. The newer version of ajax-datatables-rails was incompatible with our older implementation of datatables, so it required a major refactor effort. There were certain things in the recent ajax-datatables-rails API felt redundant, and if a major refactor was needed, a reimagined API started to be developed.

This uses ajax-datatables-rails under the hood. Perhaps, this or something similar may influence future versions of ajax-datatables-rails.

This is compatible with ajax-datatables-rails. This is intended to replace needing to define methods like: `view_columns`, `data`, defining `def_delgators`.

## Features

There are some additional features this API provides.

* Makes it easy to define the column definitions in the client JS. The column definitions are based on the same definitions that you declare in the datatable.
* Cells rendering automatically can delegate to the record or view. So the cell rendering blocks can easily access method defined on the view or the record.
* Columns are defined once, with the goal of reducing redundancy.
* Debugging mismatch problems with jQuery datatables can be frustrating. There is some code to help debug these tricky situations. There are still many improvements that can be done with this, but it is a start.

## Basic Usage

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


  # Assuming there is an address relationship to the user, you can expose searchable attributes this way.
  search_only_attributes %w[Address.city
                            Address.state_name
                            Address.country
                            Address.country_name
                            Address.postal_code]

  # methods not available to the view some method called by a cell renderer block
  module CellMethods
    def format_address(address)
      # makes the address pretty
    end
  end

  private

  def get_raw_records
    User.includes(:address)
  end
end
```

### Front-end usage

Newer versions of jQuery Datatables expects the columns to be defined when the table is initialized. This gem generates that info based on the definition in the datatable.

```Ruby
# users_controller.rb
class UsersController < ApplicationController
  def index
    @users_datatable = UserDatatable.new(params, view_context: view_context)

    respond_to do |fmt|
      fmt.html
      fmt.json do
        render json: @customer_datatable
      end
    end
  end
end
```

```ERB
// users/index.html.erb

<table id="users-datatable"
       data-ajax-url=""
       data-datatable-columns=<%= @users_datatable.js_columns %>>
  <th>Name</th>
  <th>Company</th>
  <th>Address</th>
  <th>Last updated</th>
  <th>links</th>
</table>

<script>
  $table = $('#users-datatable');
  $table.DataTable({
    ajax: $table.data('ajax-url'),
    processing: true,
    serverSide: true,
    columns: $table.data('datatable-columns')
  })
</script>
```

### Column options

The `column` method can take the following arguments:

| option        | type    | required | default value           | meaning                                                                                                       |
|---------------|---------|----------|-------------------------|---------------------------------------------------------------------------------------------------------------|
| attr_name     | String  | yes      | `nil`                   | Name of attr. This can be arbitrary, and not reflective of attributes on a model                              |
| source        | Boolean | no       | same attr on base model | Use this if the attr_name is not on the base_model and the column needs to be searchable or sortable          |
| sortable      | Boolean | no       | `true`                  | Do you want the model to be sortable                                                                          |
| visible       | Boolean | no       | `true`                  | Set to false if this should not be rendered                                                                   |
| searchable    | Boolean | no       | `true`                  | Set to false if you don't want the column to be searched                                                      |
| condition     | Proc    | no       | `true`                  | A truthy result of the proc will render the column. This is useful if you want to conditionally show a column |
| cond          | Symbol  | no       | default of datatables   | This is passed through to ajax-datatables-rails. It is the SQL matcher search will use                        |
| search_only   | Boolean | no       | `true`                  | Shorthand option for do not display but make attr searchable                                                  |
| display_only  | Boolean | no       | `true`                  | Shorthand option for display but exclude from search                                                          |
| cell_renderer | Block   | no       | `nil`                   | This block is what renders cells. More info below                                                             |

Cell rendering

There are two options for this. Let the `attr_name` return the value associated with the `base_model` attribute. Or you can provide a block. The block can take an argument:

`{ |current_record| current_record.name }` or no argument { name } will both behave the same. `method_missing` is used to seamlessly delegate to the `record`, `view`, or CellMethods defined on the datatable.

## Testing

Tests are currently, non-existent 😕. It is something I'd like to change, but I doubt will have time. This was extracted from a rails project that had around 20 complex datatables. I feel that this has been put through its paces by working for the project this was extracted from. Tests were written against that project, but since datatables is closely tied with ActiveRecord. I'd like to write tests, but so far have not had the time.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ajax-datatables-rails-alt-api.
