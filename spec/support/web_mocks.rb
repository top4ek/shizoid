# frozen_string_literal: true

module WebMocks
  def webmocks(group, stub, *args)
    klass = "WebMocks::#{group.to_s.camelize}".constantize
    klass.send(stub, *args)
  end

  def self.filter_body(item, args = {})
    if args[:include_fields].present? && args[:include_fields] != :anything
      include_fields = args[:include_fields]
      include_fields = include_fields.split(',') if include_fields.is_a? String
      item.slice!(*include_fields.map(&:to_sym))
    end

    if args[:exclude_fields].present? && args[:exclude_fields] != :anything
      exclude_fields = args[:exclude_fields]
      exclude_fields = exclude_fields.split(',') if exclude_fields.is_a? String
      item.except!(*exclude_fields.map(&:to_sym))
    end
    item
  end

  def self.prepare_params(args, available_params)
    anything_params = args.select { |k, v| v == :anything && k.in?(available_params) }.keys
    exact_params = args.slice(*available_params).except(*anything_params).compact.transform_values(&:to_s)
    query_params = [anything_params, exact_params].flatten
    return nil if query_params == [{}]

    ::WebMock.hash_including(*query_params)
  end
end
