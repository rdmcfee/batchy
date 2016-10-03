module Batchy
  module Routing
    module MapperExtensions
      def batchify(path, options = {})
        options.merge!(:to => "batchy/batch#index")
        post path, options
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Batchy::Routing::MapperExtensions
