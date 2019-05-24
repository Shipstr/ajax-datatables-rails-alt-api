# frozen_string_literal: true

module AjaxDatatablesRails
  module AltApi
    module Datatable
      # This is a datatable column definition
      class ColumnDef
        ColumnDefError = Class.new(StandardError)

        attr_reader :attr_name, :source, :sortable, :visible, :searchable,
                    :search_only, :cond, :cell_renderer, :condition
        attr_accessor :datatable

        def initialize(attr_name, # rubocop:disable Metrics/ParameterLists,Metrics/AbcSize
                       source: nil,
                       sortable: true,
                       visible: true,
                       searchable: true,
                       condition: nil,
                       cond: :like,
                       search_only: false,
                       display_only: false,
                       &cell_renderer)
          @attr_name = attr_name
          @source = source
          if display_only
            visible = true
            searchable = false
            sortable = false
          end
          if search_only
            visible = false
            searchable = true
            sortable = false
          end
          @condition = condition
          @visible = visible
          @sortable = visible ? sortable : false
          @cell_renderer = cell_renderer
          @searchable = searchable
          @search_only = search_only
          @cond = cond
          @datatable = nil
        end

        # Used to serialize options passed to the JS datatable initializer columns
        def as_json
          if condition_met?
            {data: attr_name, visible: visible, sortable: sortable}
          end
        end

        def view_column
          {source: search_source,
           orderable: to_bool(sortable),
           searchable: to_bool(searchable),
           cond: cond}
        end

        def render?
          visible && condition_met?
        end

        def render(record) # rubocop:disable Metrics/AbcSize
          return unless render?

          if cell_renderer
            if cell_renderer.arity == 1
              datatable.instance_exec(record, &cell_renderer)
            else
              datatable.instance_exec(&cell_renderer)
            end
          elsif record.respond_to?(attr_name)
            record.send(attr_name)
          else
            raise ColumnDefError, "Unable to render #{attr_name} for datatable: #{datatable.class.name}"
          end
        end

        private

        def search_source
          base_model = datatable.base_model
          src = source
          src ||= "#{base_model}.#{attr_name}" if base_model
          unless src
            raise ColumnDefError, "Unable to infer source for column #{attr_name}"
          end

          src
        end

        def condition_met?
          if condition.present? && condition.is_a?(Proc)
            unless datatable
              raise ColumnDefError, "`datatable` is nil when evaling condition: #{attr_name}"
            end

            datatable.instance_exec(&condition)
          else
            true
          end
        end

        def to_bool(val)
          if val.is_a?(Proc)
            datatable.instance_exec(&val)
          else
            val
          end
        end
      end
    end
  end
end
