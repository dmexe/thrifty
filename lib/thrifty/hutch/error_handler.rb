module Thrifty::Hutch
  class ErrorHandler
    def handle(message_id, payload, consumer, ex)
      Thrifty::Logger::App.handle_exception(
        ex,
        "Hutch",
        payload:    payload,
        consumer:   consumer,
        message_id: message_id
      )
    end
  end
end
