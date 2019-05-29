module AjaxDatatablesRails
  module AltApi
    module Datatable
      # This is used by the column.cell_renderer and seamlessly
      # delegates to the view or the record
      class RowContext
        attr_reader :view, :record

        def initialize(view, record)
          @view = view
          @record = record
        end

        # This allows seamless delegation to @current_record or @view
        def method_missing(meth, *args)
          if @record.respond_to?(meth)
            @record.send(meth, *args)
          elsif @view.respond_to?(meth)
            @view.send(meth, *args)
          else
            super
          end
        end

        def respond_to_missing?(meth, _include_all)
          @record.respond_to?(meth) || @view.respond_to?(meth) || super
        end
      end
    end
  end
end
