module AjaxDatatablesRails
  module AltApi
    module Datatable
      # DataTables can be really tricky to debug when attributes don't align.
      # I added this to help a little
      class ViewColumns < Hash
        def [](key)
          super(key).tap do |r|
            if r.nil?
              Rails.logger.warn "-- Datatable view column key missing: #{key}"
            end
          end
        end
      end
    end
  end
end
