module Filemaker
  module Error
    class CommunicationError < StandardError; end
    class AuthenticationError < StandardError; end
    class ParameterError < StandardError; end
  end
end
