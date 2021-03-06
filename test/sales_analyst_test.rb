require 'time'
require_relative 'test_helper'
require_relative '../lib/sales_analyst'

class SalesAnalystTest < MiniTest::Test

  def setup
    @files = {:items         => './test/data/items_test.csv',
              :merchants     => './test/data/merchants_test.csv',
              :invoices      => './test/data/invoices_test.csv',
              :invoice_items => './test/data/invoice_items_test.csv',
              :transactions  => './test/data/transactions_test.csv',
              :customers     => './test/data/customers_test.csv'}

    @files2 = {:items        => './test/data/test_items_2.csv',
              :merchants     => './test/data/merchant_test_2.csv',
              :invoices      => './test/data/invoices_test.csv',
              :invoice_items => './test/data/invoice_items_test.csv',
              :transactions  => './test/data/transactions_test.csv',
              :customers     => './test/data/customers_test.csv'}

    @files3 = {:items        => './test/data/test_items_3.csv',
              :merchants     => './test/data/merchants_test_3.csv',
              :invoices      => './test/data/invoices_test.csv',
              :invoice_items => './test/data/invoice_items_test.csv',
              :transactions  => './test/data/transactions_test.csv',
              :customers     => './test/data/customers_test.csv'}

    @files4 = {:items        => './data/items.csv',
              :merchants     => './data/merchants.csv',
              :invoices      => './data/invoices.csv',
              :invoice_items => './data/invoice_items.csv',
              :transactions  => './data/transactions.csv',
              :customers     => './data/customers.csv'}

  end

  def test_the_sales_analyst_exists
    se = SalesEngine.from_csv(@files)
    sa = SalesAnalyst.new(se)

    assert_instance_of SalesAnalyst, sa
  end

  def test_average_items_per_merchant_works
    se = SalesEngine.from_csv(@files)
    sa = SalesAnalyst.new(se)

    assert_equal 1, sa.average_items_per_merchant
  end

  def test_average_items_per_merchant_standard_deviation_works
    se = SalesEngine.from_csv(@files)
    sa = SalesAnalyst.new(se)

    actual_1 = sa.create_items_length_per_merchant_hash.keys
    actual_2 = sa.create_items_length_per_merchant_hash.values

    assert_equal [12334105, 12334112, 12334113, 12334115, 12334123], actual_1
    assert_equal [1, 0, 0, 0, 0], actual_2
  end

  def test_average_items_per_perchant_standard_dev
    se = SalesEngine.from_csv(@files)
    sa = SalesAnalyst.new(se)

    sa.stubs(:create_items_length_per_merchant_hash).returns({0 => 3, 1 => 4, 2 => 5})

    actual = sa.average_items_per_merchant_standard_deviation

    assert_equal 1, actual
  end

  def test_merchants_with_high_item_count
    se = SalesEngine.from_csv(@files)
    sa = SalesAnalyst.new(se)

    actual = sa.merchants_with_high_item_count.length

    assert_equal 0, actual
  end

  def test_average_item_price_for_merchant
    se = SalesEngine.from_csv(@files)
    sa = SalesAnalyst.new(se)

    actual = sa.average_item_price_for_merchant(12334105)

    assert_equal 0.2999E2, actual
  end

  def test_average_average_price_per_merchant_works
    se = SalesEngine.from_csv(@files2)
    sa = SalesAnalyst.new(se)

    actual = sa.average_average_price_per_merchant

    assert_equal 0.667806E4, actual
  end

  def test_golden_items_works
    se = SalesEngine.from_csv(@files2)
    sa = SalesAnalyst.new(se)

    actual = sa.golden_items.length

    assert_equal 0, actual
  end

  def test_average_invoices_per_merchant_works
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)

    actual = sa.average_invoices_per_merchant

    assert_equal 2.4, actual
  end

  def test_average_invoices_per_merchant_standard_deviation_works
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.average_invoices_per_merchant_standard_deviation

    assert_equal 0.55, actual
  end

  def test_top_merchants_by_invoice_count_works
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.top_merchants_by_invoice_count

    assert_equal [], actual
  end

  def test_bottom_merchants_by_invoice_count_works
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.bottom_merchants_by_invoice_count

    assert_equal 3, actual.length
  end

  def test_invoice_status_returns_correct_percentage
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual_1 = sa.invoice_status(:pending)
    actual_2 = sa.invoice_status(:shipped)
    actual_3 = sa.invoice_status(:returned)

    assert_equal 58.33, actual_1
    assert_equal 33.33, actual_2
    assert_equal 8.33, actual_3
  end

  def test_create_invoices_per_day_hash_works
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.top_days_by_invoice_count

    assert_equal ["Saturday", "Friday", "Wednesday", "Monday"], actual
  end

  def test_returns_revenue_by_date
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)

    actual_1 = sa.total_revenue_by_date(Time.parse('2009-02-07'))
    actual_2 = sa.total_revenue_by_date(Time.parse('2012-02-28'))

    assert_equal 21067.77, actual_1
    assert_equal 0, actual_2
  end

  def test_revenue_by_merchant_returns_dollars
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.revenue_by_merchant(12334753)
    expected = 1872.74

    assert_equal expected, actual
  end

  def test_returns_top_revenue_earners_default_twenty
    se = SalesEngine.from_csv(@files4)
    sa = SalesAnalyst.new(se)
    actual = sa.top_revenue_earners

    assert_equal 20, actual.length
  end

  def test_returns_top_revenue_earners_other_than_default
    se = SalesEngine.from_csv(@files4)
    sa = SalesAnalyst.new(se)
    actual = sa.top_revenue_earners(5)

    assert_equal 5, actual.length
  end

  def test_merchants_with_pending_invoice_returns_correct_number
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.merchants_with_pending_invoices

    assert_equal 8, actual.length
  end

  def test_merchants_with_only_one_item_returns_correct_merchants
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    mr = se.merchants.all
    actual = sa.merchants_with_only_one_item

    assert_equal 4, actual.length
    assert_equal mr[1..4], actual
  end

  def test_merchants_with_only_one_item_in_month_returns_correct_merchants
    se = SalesEngine.from_csv(@files3)
    sa = SalesAnalyst.new(se)
    actual = sa.merchants_with_only_one_item_registered_in_month('February')

    assert_equal 1, actual.length
  end

  def test_if_most_sold_item_returns_item
    se = SalesEngine.from_csv(@files4)
    sa = SalesAnalyst.new(se)
    actual = sa.most_sold_item_for_merchant(12334189)

    assert_equal 1, actual.length
  end

  def test_best_item_for_merchant
    se = SalesEngine.from_csv(@files4)
    sa = SalesAnalyst.new(se)
    actual = sa.best_item_for_merchant(12334189)

    assert_equal Item, actual.class
  end


end
