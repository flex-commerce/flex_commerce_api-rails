module ShiftCommerce
  module CacheHelper
    def shift_cache object, *args
      return yield if object.nil? || params[:preview] === 'true'
      cache(shift_cache_key object, *args) { yield }
    end

    def menus_cache(reference, banner_reference = nil, dependent_reference = nil, options = {})
      # Dont fetch from cache if requested for a preview
      return yield if params[:preview] === 'true'

      # Initialize menus variable to an array
      menus = []

      [reference, dependent_reference].each do |key|
        menus.push(all_menus_cache[key] || MissingMenu.new(key)) unless key.nil?
      end

      # If we dont find any in cache, then fetch via api
      return yield if menus.nil?

      # Fetch from cache for normal requests
      if dependent_reference.nil?
        multi_cache(shift_cache_key(menus, banner_reference), options) { yield if block_given? }
      else
        multi_dependent_cache(shift_cache_key(menus), options) { yield if block_given? }
      end
    end

    private
    # Object can be a FlexCommerce::Menu, FlexCommerce::StaticPage or any other resource we wish to cache.
    def shift_cache_key(resource, banner_reference = nil)
      keys = []
      Array(resource).each do |resource|
        resource_id = banner_reference == nil ? resource.id : banner_reference
        keys.push([resource.class, resource_id, resource.updated_at.to_datetime.utc.to_i.to_s].join("/"))
      end
      keys
    end

  end
end
