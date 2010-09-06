module ActiveRecord
  module ConnectionAdapters
    module Sqlserver
      module Quoting
        
        QUOTED_TRUE, QUOTED_FALSE = '1', '0'
        
        def quote(value, column = nil)
          case value
          when String, ActiveSupport::Multibyte::Chars
            if column && column.type == :binary
              column.class.string_to_binary(value)
            elsif quote_value_as_utf8?(value) || column && column.respond_to?(:is_utf8?) && column.is_utf8?
              quoted_utf8_value(value)
            else
              super
            end
          else
            super
          end
        end

        def quote_string(string)
          string.to_s.gsub(/\'/, "''")
        end

        def quote_column_name(name)
          @sqlserver_quoted_column_and_table_names[name] ||= 
            name.to_s.split('.').map{ |n| n =~ /^\[.*\]$/ ? n : "[#{n}]" }.join('.')
        end

        def quote_table_name(name)
          quote_column_name(name)
        end

        def quoted_true
          QUOTED_TRUE
        end

        def quoted_false
          QUOTED_FALSE
        end

        def quoted_date(value)
          if value.acts_like?(:time) && value.respond_to?(:usec)
            "#{super}.#{sprintf("%03d",value.usec/1000)}"
          else
            super
          end
        end

        def quoted_utf8_value(value)
          "N'#{quote_string(value)}'"
        end
        
        def quote_value_as_utf8?(value)
          value.is_utf8? || enable_default_unicode_types
        end
        
      end
    end
  end
end
