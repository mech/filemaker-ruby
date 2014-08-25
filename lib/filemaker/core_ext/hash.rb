class Hash
  def transform_keys
    return enum_for(:transform_keys) unless block_given?
    result = self.class.new
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end

  def stringify_keys
    transform_keys { |key| key.to_s }
  end
end

module Filemaker
  class HashWithIndifferentAndCaseInsensitiveAccess < Hash
    def []=(key, value)
      super(convert_key(key), value)
    end

    def [](key)
      super(convert_key(key))
    end

    protected

    def convert_key(key)
      key.to_s.downcase
    end
  end
end
