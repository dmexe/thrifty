module Thrifty::Logger
  class LogfmtFormatter

    UNESCAPED_STRING = /\A[\w\.\-\+\%\,\:\;\/]*\z/i

    IGNORED_FIELDS = [:time]

    def call(entry)
      case entry
      when ExceptionEntry
        format_exception(entry)
      when Entry
        format_entry(entry)
      else
        [entry_or_ex.to_s]
      end
    end

    private

      def format_entry(entry)
        [format_hash(entry.to_h)]
      end

      def format_exception(entry)
        values = []
        values << format_hash(entry.to_h)
        if entry.exception && entry.exception.backtrace.is_a?(Array)
          values <<
            "#{entry.exception.class}: #{entry.exception.message}\n" +
            entry.exception.backtrace.map{|l| "\t#{l}" }.join("\n")
        end
        values
      end

      def format_hash(attrs)
        attrs.inject([]) do |ac, (k,v)|
          if !IGNORED_FIELDS.include?(k) && !(v == nil || v == "")
            new_value = sanitize(v)
            ac << "#{k}=#{new_value}"
          end
          ac
        end.join(" ")
      end

      def sanitize(v)
        case v
        when ::Array
          may_quote v.join(",")
        when ::Integer, ::Symbol
          v.to_s
        when ::Float
          "%0.4f" % v
        when ::TrueClass, ::FalseClass
          v ? "t" : "f"
        when Time
          quote v.utc.to_s
        else
          may_quote(v.to_s)
        end
      end

      def quote(s)
        s.inspect
      end

      def may_quote(s)
        s =~ UNESCAPED_STRING ? s : quote(s)
      end
  end
end
