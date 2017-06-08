class Merchant

  attr_reader :name,
              :id,
              :created_at

  def initialize(params = {}, parent = nil)
    @parent     = parent
    @name       = params['name']
    @id         = params['id'].to_i
    @created_at = Time.parse(params["created_at"])
  end

  def items
    @parent.mid_to_se(self.id)
  end

  def invoices
    @parent.mid_to_se_for_invoices(self.id)
  end

  def customers
    @parent.mid_to_se_for_customer(self.id)
  end
end
