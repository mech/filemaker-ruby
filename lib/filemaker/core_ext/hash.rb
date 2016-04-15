module Filemaker
  class HashWithIndifferentAndCaseInsensitiveAccess < Hash
    def []=(key, value)
      super(convert_key(key), value)
    end

    def [](key)
      super(convert_key(key))
    end

    def key?(key)
      super(convert_key(key))
    end

    alias include? key?
    alias member? key?

    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    def values_at(*indices)
      indices.map { |key| self[convert_key(key)] }
    end

    def delete(key)
      super(convert_key(key))
    end

    protected

    def convert_key(key)
      key.to_s.downcase
    end
  end
end
