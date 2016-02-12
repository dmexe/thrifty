module Thrifty::HTTP::Server
  class ErrMiddleware

    def initialize(app, name)
      @log = Thrifty.get_logger(name)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      @log.error(e, clean_env(env))
      body = dump_exception(e)
      [
        500,
        {
          Rack::CONTENT_TYPE   => 'text/plain',
          Rack::CONTENT_LENGTH => Rack::Utils.bytesize(body).to_s,
        },
        [body],
      ]
    end

    private

    def clean_env(env)
      env.inject({}) do |ac, pair|
        case
        when pair[0] =~ /\A(rack|puma)\./
          ac
        else
          ac.merge! pair[0] => pair[1]
        end
      end
    end

    def dump_exception(exception)
      string = "#{exception.class}: #{exception.message}\n"
      string << exception.backtrace.map { |l| "\t#{l}" }.join("\n")
      string
    end

  end
end

