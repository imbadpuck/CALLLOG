module APIError
  class Base < StandardError
    include ActiveModel::Serialization

    attr_accessor :message

    def initialize *args
      if args.length == 0
        t_key = self.class.name.underscore.gsub(%r{\/}, ".")
        @message = I18n.t(t_key)
      else
        @message = args[0][:message]
      end
    end
  end

  module Common
    class ServerError < APIError::Base
    end

    class ConnectionRefused < APIError::Base
    end

    class Unauthorized < APIError::Base
    end

    class NotFound < APIError::Base
    end

    class BadRequest < APIError::Base
    end

    class UnSaved < APIError::Base
    end
  end
end
