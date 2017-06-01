require 'csv'
require_relative 'merchant'
class MerchantRepository

  attr_reader :all

  def initialize(file_path)
    @all = []
    populate_merchants(file_path)
  end

  def populate_merchants(file_path)
    i = 0
    CSV.foreach(file_path, row_sep: :auto) do |line|
      i += 1
      next if i == 1
      id = line[0]
      name = line[1]
      self.all << Merchant.new({ :name => name, :id => id })
    end
  end

  def find_by_id(id)
    @all.find do |merchant|
      if merchant.id == id
        return merchant
      end
      nil
    end
  end

  def find_by_name(name)
    @all.find do |merchant|
      if merchant.name.downcase == name.downcase
        return merchant
      end
      nil
    end
  end

  def find_all_by_name(name)
    result = []
    @all.find_all do |merchant|
      if merchant.name.downcase.include? name.downcase
        result << merchant
      end
    end
    result
  end
end