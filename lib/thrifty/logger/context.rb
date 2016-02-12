module Thrifty::Logger
  class Context

    attr_reader :level

    def initialize(app, scope, context = nil)
      @app     = app
      @scope   = scope
      @level   = Thrifty::Logger::DEBUG
      @context = context || {}
    end

    def level=(level)
      @level = level.to_i
    end

    def []=(k,v)
      if v == nil
        @context.delete(k)
      else
        @context[k] = v
      end
    end

    def measure(message, payload = {})
      tm = Time.now.to_f
      re = nil
      re = yield if block_given?
      tm = Time.now.to_f - tm
      payload[:duration] = tm
      self.info message, payload
      re
    end

    Thrifty::Logger::LEVELS.each_with_index do |lv, idx|
      level_id = lv.downcase.to_sym
      define_method level_id do |message = nil, payload = nil, &block|
        return if idx < level
        message = block ? block.call : message
        payload = @context.merge(payload || {})
        entry =
          if message.is_a?(Exception)
            ExceptionEntry.new(
              level_id,
              Time.now,
              @scope,
              message,
              payload
            )
          else
            Entry.new(
              level_id,
              Time.now,
              @scope,
              message,
              payload
            )
          end
        @app.append(entry)
      end
    end
  end
end
