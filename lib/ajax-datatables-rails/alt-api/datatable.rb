# frozen_string_literal: true

require 'ajax-datatables-rails/alt-api/datatable/column_def'
require 'ajax-datatables-rails/alt-api/datatable/view_columns'

module AjaxDatatablesRails
  module AltApi
    # Just include this in your application datatable
    # `include 'ajax-datatables-rails/alt-api/datatable'`
    module Datatable
      def self.included(base)
        base.extend(ClassMethods)

        extend Forwardable

        attr_reader :view, :current_record
        alias_method :record, :current_record
        alias_method :r, :record
      end

      # module class methods
      module ClassMethods
        # This is the primary ActiveRecord model the datatable represents.
        # For example, if you have writing a UserDatatable, and that is
        # a list of User records, 'User' would be the base model.
        def base_model(model_class)
          @base_model = model_class
        end

        # This adds a ColumnDef to the columns. Order in which column is called
        # is important. The column order is the same as they will be returned
        # to the client. To see a full list of options, see the ColumnDef class.
        def column(*new_column_args, &block)
          columns << ColumnDef.new(*new_column_args, &block)
        end

        def columns
          @columns ||= []
        end

        # Use this in the `columns` option in the JS initialization of Datatable.
        # Call this method in the view.
        # There are times that when conditionally showing columns, the column
        # conditionals need access to the datatable instance.
        # Example:
        #   <table data-datatable-columns="<%= UsersDatatable.js_columns %>">
        #     <th>Name</th>
        #     <th>Email</th>
        #   </table>
        #   <script>
        #     var table = $('#my-datatable');
        #     table.DataTable({
        #       columns: JSON.parse(table.data('datatable-columns'))
        #     })
        #   </script>
        def js_columns(only: [], exclude: [])
          cols = if only.present?
                   columns.select { |c| only.include?(c.attr_name) }
                 elsif exclude.present?
                   columns.reject { |c| exclude.include?(c.attr_name) }
                 else
                   columns
                 end
          cols.reject! { |c| c.attr_name.to_s.starts_with?('search_only') }
          cols.map(&:as_json).compact.to_json
        end

        # This is used for tests
        def column_params
          new({}).columns.map(&:as_json).each_with_index.reduce({}) do |accum, (h, i)|
            accum[i] = { **h, search: { value: '', regex: 'false' } }
            accum
          end
        end

        def search_only_attributes(attrs)
          attrs.each do |attr|
            key_name = :"search_only__#{attr.downcase.tr('.', '_')}"
            columns << ColumnDef.new(key_name, source: attr, search_only: true)
          end
        end
      end

      def initialize(params, opts = {})
        @view = opts[:view_context]
        super
      end

      # applies the current datatable instance to the columns
      def columns
        @columns ||= self.class.columns.each { |c| c.datatable = self }
      end

      # There are times that when conditionally showing columns, the column
      # conditionals need access to the datatable instance.
      def js_columns(only: [], exclude: [])
        columns
        self.class.js_columns(only: only, exclude: exclude)
      end

      def base_model
        self.class.instance_variable_get(:@base_model)
      end

      def view_columns
        raise NotImplementedError, 'Columns not defined' if columns.empty?

        @view_columns ||= begin
          columns.each_with_object(ViewColumns.new) do |col, cols|
            cols[col.attr_name] = col.view_column
            cols
          end
        end
      end

      def data
        raise NotImplementedError if columns.empty?

        records_with_error_logging.map do |record|
          @current_record = record
          delegate_to_view_and_record(record)

          columns.each_with_object({}) do |col, row|
            row[col.attr_name] = col.render(record)
            row
          end
        end
      end

      def delegate_to_view_and_record(record) # rubocop:disable Lint/MethodLength,Lint/UnusedMethodArgument
        singleton_class.class_eval do
          def method_missing(meth, *args)
            if record.respond_to?(meth)
              record.send(meth, *args)
            elsif view.respond_to?(meth)
              view.send(meth, *args)
            else
              super
            end
          end

          def respond_to_missing?(meth, _include_all)
            record.respond_to?(meth) || view.respond_to?(meth) || super
          end
        end
      end

      # There are some hard to debug scenarios that come up with ajax-datatables-rails.
      # This helps debug some problems. Usually the bug is caused by some mismatched
      # expectation between what the view_columns are and how it is being used.
      def records_with_error_logging
        @records ||= records
      rescue NoMethodError => e
        if e.name == :fetch && e.receiver.nil?
          Rails.logger.error "#{self.class.name} column problem. view_columns: #{view_columns.pretty_inspect}"
        end
        raise e
      end
    end
  end
end
