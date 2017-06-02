require 'pry'

require_relative 'test_helper'
require_relative '../lib/merchant'
require_relative '../lib/sales_engine'

class MerchantTest < MiniTest::Test

  def setup
    @files = {:items => './test/data/items_test.csv',
              :merchants => './test/data/merchants_test.csv'}
  end

  def test_if_create_class
    m = Merchant.new

    assert_instance_of Merchant, m
  end

  def test_default_attributes
    m = Merchant.new({'name'  =>  "Turing School",
                      'id'    =>  201})

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


end
