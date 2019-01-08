require 'breezy_template/breezy_template'

class BreezyTemplate
  module DefermentExtension
    ACTIVE_MODES = [:auto, :manual].freeze

    def set!(key, value = BLANK, *args)
      options = args[0]
      if ::Kernel.block_given? && _deferment_options?(options)
        if _deferment_auto?(options)
          @js.push(_breezy_visit_current(@path))
        end
        return _set_value key, ::BreezyTemplate::Var.new('undefined')
      else
        super
      end
    end

    def _breezy_visit_current(path)
      uri = ::URI.parse(@request_path)
      qry = ::URI.decode_www_form(uri.query || '') << ["bzq", path.join('.')]
      uri.query = ::URI.encode_www_form(qry)
      "defers.push({url:'#{uri}'});"
    end

    def _deferment_options?(options)
      options && !!options[:defer] && (@search_path.nil? || @search_path.size == 0)
    end

    def _deferment_options(options)
      options[:defer]
    end

    def _deferment_auto?(options)
      _deferment_options(options) == :auto
    end

    def _set_request_url_once(request_path)
      @request_path ||= request_path
    end

    def _extended_options?(value)
      _deferment_options?(value) || super
    end

    def _mapping_element(element, options)
      if _deferment_options?(options)
        if ::Proc === _deferment_options(options)
           value = _deferment_options(options).call(element)
           options = options.dup.merge({defer: value})
        end
      end

      if _deferment_options?(options)
        if _deferment_auto?(options)
          @js.push(_breezy_visit_current(@path))
        end

        if options.has_key? :key
          id_name = options[:key]
          id_val = element[id_name]
          ::Hash[id_name, id_val]
        else
          ::BreezyTemplate::Var.new('undefined')
        end
      else
        super
      end
    end
  end
end
