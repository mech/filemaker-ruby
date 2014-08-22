module Filemaker
  module Error
    class CommunicationError < StandardError; end
    class AuthenticationError < StandardError; end
  end
end
