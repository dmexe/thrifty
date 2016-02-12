module Thrifty::Logger
  class SimpleFormatter < LogfmtFormatter

    private

      def format_hash(attrs)
        level   = attrs.delete(:level)
        message = attrs.delete(:message)
        scope   = attrs.delete(:scope)

        IGNORED_FIELDS.each do |f|
          attrs.delete(f)
        end

        payload = super(attrs)
        payload = payload.empty? ? "" : " [#{payload}]"
        message = message.to_s.empty? ? "" : " #{message}"
        "[%5s]: #{scope} -#{message}#{payload}" % level.upcase
      end
  end
end
