module Companies::FinOperationsHelper
  def debt id, amount, operation_type
    if operation_type == "payment_subscription"
      s = Subscription.find id
      f = FinOperation.where(operation_object_id: s.id, operation_type: "payment_subscription").sum(:amount)
      
      if f <= s.price
        r = s.price - amount
      else
        r = 0.0
      end
    else
      0.0
    end                       
  end
end
