module ApplicationHelper
  
  def bootstrap_flash_key_for(key)
    { :notice => "success", :alert => "error" }.fetch(key) { |key| key.to_s }
  end

end
