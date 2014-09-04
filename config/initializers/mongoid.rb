
# Monkey patch BSON to return string keys in json
# https://github.com/rails-api/active_model_serializers/issues/354
module BSON
  class ObjectId
    def as_json(*args)
      to_s
    end

    alias :to_json :as_json
  end
end
