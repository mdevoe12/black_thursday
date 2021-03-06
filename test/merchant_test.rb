require_relative 'test_helper'
require_relative '../lib/merchant'
require_relative '../lib/sales_engine'

class MerchantTest < MiniTest::Test

  def setup
    @files = {:items         => './test/data/items_test.csv',
              :merchants     => './test/data/merchants_test.csv',
              :invoices      => './test/data/invoices_test.csv',
              :invoice_items => './test/data/invoice_items_test.csv',
              :transactions  => './test/data/transactions_test.csv',
              :customers     => './test/data/customers_test.csv'}
    @files_2 = {:items       => './test/data/test_items_3.csv',
              :merchants     => './test/data/merchants_test_3.csv',
              :invoices      => './test/data/invoices_test.csv',
              :invoice_items => './test/data/invoice_items_test.csv',
              :transactions  => './test/data/transactions_test.csv',
              :customers     => './test/data/customers_test.csv'}
  end

  def test_if_create_class
    m = Merchant.new({'name'       =>  "Turing School",
                      'id'         =>  '201',
                      'created_at' => '2010-07-15'})

    assert_instance_of Merchant, m
  end

  def test_default_attributes
    m = Merchant.new({'name'       =>  "Turing School",
                      'id'         =>  '201',
                      'created_at' => '2010-07-15'})

    assert m.name
    assert_equal "Turing School", m.name
    assert m.id
    assert_equal 201, m.id
  end

  def test_if_items_method_returns_items
    se = SalesEngine.from_csv(@files)
    merchant = se.merchants.find_by_id(12334105)
    actual = merchant.items.length

    assert_equal 1, actual
  end

  def test_if_invoices_method_returns_invoices
    se = SalesEngine.from_csv(@files_2)
    merchant = se.merchants.find_by_id(12335938)
    actual = merchant.items.length

    assert_equal 2, actual
  end

  def test_if_customers_method_returns_customers
    se = SalesEngine.from_csv(@files_2)
    merchant = se. merchants.find_by_id(12335938)
    actual = merchant.customers
    expected = [se.customers.all[0]]

    assert_equal expected, actual
  end


end
