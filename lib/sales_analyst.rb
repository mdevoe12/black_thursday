require_relative './sales_engine'

class SalesAnalyst

  attr_reader :se
  def initialize(se)
    @se = se
  end

  def average_items_per_merchant
    mr = se.merchants.all
    ir = se.items.all
    average = (ir.length.to_f)/(mr.length)
    average.round(2)
  end

  def average_items_per_merchant_standard_deviation
    values = create_items_per_merchant_hash.values
    standard_deviation(values)
  end

  def create_items_per_merchant_hash
    merchant_items = {}
    mr = se.merchants.all
    mr.each do |merchant|
      items = se.items_by_merchant_id(merchant.id)
      merchant_items[merchant.id] = items.length
    end
    merchant_items
  end

  def merchants_with_high_item_count
    mr = se.merchants.all
    mr.find_all do |merchant|
      merchant.items.length >= self.one_deviation
    end
  end

  def one_deviation
    average_items_per_merchant + average_items_per_merchant_standard_deviation
  end

  def average_item_price_for_merchant(merchant_id)
    items = se.items_by_merchant_id(merchant_id)
    sum = items.reduce(0) { |acc, item| acc += item.unit_price }
    price_average = sum/items.length
    BigDecimal.new(price_average).round(2)
  end

  def average_average_price_per_merchant
    mr = se.merchants.all
    averages = mr.reduce(0) do |acc, merchant|
      acc += average_item_price_for_merchant(merchant.id)
    end
    average_average = averages/mr.length
    BigDecimal.new(average_average).round(2)
  end

  def golden_items
    ir = se.items.all
    unit_prices = ir.map {|item| item.unit_price}
    ir.find_all do |item|
      item.unit_price >= self.two_price_deviations(unit_prices)
    end
  end

  def two_price_deviations(unit_prices)
    average_average_price_per_merchant + (standard_deviation(unit_prices) * 2)
  end

  def average_invoices_per_merchant
    mr = se.merchants.all
    invr = se.invoices.all

    average = (invr.length.to_f)/(mr.length)
    average.round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    values = create_invoices_per_merchant_hash.values
    standard_deviation(values)
  end

  def create_invoices_per_merchant_hash
    merchant_invoices = {}
    mr = se.merchants.all
    mr.each do |merchant|
      invoices = se.invoices_by_merchant_id(merchant.id)
      merchant_invoices[merchant.id] = invoices.length
    end
    merchant_invoices
  end

  def top_merchants_by_invoice_count
    merch_inv = create_invoices_per_merchant_hash
    mr = se.merchants.all
    mr.select {|merchant| merch_inv[merchant.id] >= two_invoice_deviations}
  end

  def two_invoice_deviations
    (average_invoices_per_merchant +
    (average_invoices_per_merchant_standard_deviation * 2))
  end

  def bottom_merchants_by_invoice_count
    merchant_invoices = create_invoices_per_merchant_hash
    mr = se.merchants.all
    two_deviations = ((average_invoices_per_merchant) -
                      (average_invoices_per_merchant_standard_deviation * 2))
    mr.select {|merchant| merchant_invoices[merchant.id] <= two_deviations}
  end

  def top_days_by_invoice_count
    invoices_per_day = create_invoices_per_day_hash
    values = invoices_per_day.values
    days = invoices_per_day.keys
    days.select { |day| invoices_per_day[day] > one_invoice_deviation(values) }
  end

  def average_invoices_per_day
    (se.invoices.all.length)/7
  end

  def average_invoices_per_day_standard_deviation(values)
    standard_deviation(values)
  end

  def one_invoice_deviation(values)
    (average_invoices_per_day +
    average_invoices_per_day_standard_deviation(values))
  end

  def create_invoices_per_day_hash
    days = {"Monday" => 0,
            "Tuesday" => 0,
            "Wednesday" => 0,
            "Thursday" => 0,
            "Friday" => 0,
            "Saturday" => 0,
            "Sunday" => 0}
    invr = se.invoices.all
    invr.each do |invoice|
      if days.keys.include? invoice.created_at.strftime("%A")
      days[invoice.created_at.strftime("%A")] += 1
      end
    end
    days
  end

  def invoice_status(status)
    invr = se.invoices.all
    status_matches = invr.select {|invoice| invoice.status == status}
    percentage = (status_matches.length.to_f)/(invr.length) * 100
    percentage.round(2)
  end

  def total_revenue_by_date(date)
    stripped = date.strftime('%Y%m%d')
    all_inv = se.invoices_by_date(stripped)
    invoice_ids = all_inv.map  {|invoice| invoice.id }
    all_items = invoice_ids.flat_map {|id| se.invoice_items_by_invoice_id(id)}
    all_items.reduce(0) {|acc, item| acc+= item.quantity * item.unit_price}
  end

  def top_revenue_earners(x = 20)
    revenue_per_merchant = creates_revenue_per_merchant_hash
    ascending_revenue = revenue_per_merchant.sort_by {|_k,v| v}.flatten
    merchants = ascending_revenue.select.with_index {|item, idx| idx.even? }
    descending_revenue = merchants.reverse
    descending_revenue[0..(x - 1)]
  end

  def creates_revenue_per_merchant_hash
    mr = se.merchants.all
    revenue_per_merchant = {}
    mr.each do |merchant|
      revenue_per_merchant[merchant] = revenue_by_merchant(merchant.id)
    end
    revenue_per_merchant
  end

  def revenue_by_merchant(merchant_id)
    invoices = se.invoices_by_merchant_id(merchant_id)
    totals = invoices.map {|invoice| se.total_by_invoice_id(invoice.id)}
    paid_totals = totals.reject {|invoice| invoice.nil?}
    paid_totals.reduce(0) {|acc, amount| acc += amount}
  end

  def merchants_ranked_by_revenue 
    mr = se.merchants.all
    top_revenue_earners(mr.length)
  end

  def merchants_with_pending_invoices
    invr = se.invoices
    invoices = invr.all
    pending = invoices.reject {|invoice| invoice.is_paid_in_full?}
    mids = pending.map {|invoice| invoice.merchant_id}.uniq
      # binding.pry
    mids.map {|id| se.merchant_by_merchant_id(id)}
  end

  def standard_deviation(values)
    mean = values.reduce(:+)/values.length.to_f
    mean_squared = values.reduce(0) { |acc, num| acc += ((num - mean)**2) }
    Math.sqrt(mean_squared / (values.length - 1)).round(2)
  end
end
