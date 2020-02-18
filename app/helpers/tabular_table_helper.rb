module TabularTableHelper
  def user_tr_styles(user)
    [
      :default_currency, :last_login_at, :last_logout_at, :last_activity_at
    ].inject('') do |sum, attribute|
      value = user.send(attribute)
      value = value.bytes.inject(&:+) if value.class == String
      value = value.to_i if value.class == ActiveSupport::TimeWithZone

      sum += "--order-by-#{attribute}: #{value}; "
    end
  end

  def product_tr_styles(product)
    [
      :category, :product_type, :default_price, :times_purchased, :featured
    ].inject('') do |sum, attribute|
      unless attribute == :default_price
        value = product.send(attribute)
        value = value.title.bytes.inject(&:+) if attribute == :category
        value = value.bytes.inject(&:+) if value.class == String
        value = value.to_s.bytes.inject(&:+) if boolean?(value)
      else
        value = product.default_price(current_user.default_currency)
      end

      sum += "--order-by-#{attribute}: #{value}; "
    end
  end

  def order_tr_styles(order)
    [
      :status, :product_count, :coin_amount, :coin_type, :fiat_price_paid,
      :fiat_currency
    ].inject('') do |sum, attribute|
      unless attribute == :product_count
        value = order.send(attribute)
        value = value.bytes.inject(&:+) if value.class == String
        value = value.to_s.bytes.inject(&:+) if boolean?(value)
        value = value.to_s.delete('.').to_i if attribute == :coin_amount
      else
        value = order.order_items.count if attribute == :product_count
      end

      sum +=  "--order-by-#{attribute}: #{value};"
    end
  end

  def cart_tr_styles(cart)
    [
      :cart_count, :miners_fee, :nibiru_fee, :subtotal, :grand_total
    ].inject('') do |sum, attribute|
      unless attribute == :cart_count
        value = value.to_s.delete('.').to_i
      else
        value = cart.cart_products.size
      end

      sum +=  "--order-by-#{attribute}: #{value};"
    end
  end

  def category_tr_styles(category)
    [:products_count, :parent].inject('') do |sum, attribute|
      if attribute == :products_count
        sum += "--order-by-products_count: #{category.products.size};"
      else
        sum += "--order-by-parent: #{category.parent.title.bytes.inject(&:+)};"
      end
    end
  end

  def dispute_tr_styles(dispute)
    %i(
      user_id total_coin_price price_at_time shipping_at_time
      quantity_purchased tracking_number shipped_at received_at left_review
      placed_at product_title
    ).inject('') do |sum, attribute|
      if attribute == :placed_at
        value = dispute.order.created_at.to_i
      elsif attribute == :product_title
        value = dispute.order_item.product.title.bytes.inject(&:+)
      elsif attribute == :user_id
        value = dispute.user_id
      else
        value = dispute.order_item.send(attribute)
        value = value.bytes.inject(&:+) if value.class == String
        value = value.to_s.bytes.inject(&:+) if boolean?(value)
        value = value.to_i if value.class == ActiveSupport::TimeWithZone
        value = value.to_s.delete('.').to_i if attribute == :total_coin_price
      end

      sum += "--order-by-#{attribute}: #{value};"
    end
  end

  def payment_tr_styles(payment_request)
    %i(
      status coin_amount coin_type user_id expires_at
    ).inject('') do |sum, attribute|
      value = payment_request.send(attribute)
      value = value.bytes.inject(&:+) if value.class == String
      value = value.to_i if value.class == ActiveSupport::TimeWithZone
      value = value.to_s.delete('.').to_i if attribute == :coin_amount

      sum += "--order-by-#{attribute}: #{value};"
    end
  end

  def log_tr_styles(log)
    "--order-by-posted_at: #{log.created_at.to_i};"
  end

  def boolean?(value)
    [TrueClass, FalseClass].include? value.class
  end
end
