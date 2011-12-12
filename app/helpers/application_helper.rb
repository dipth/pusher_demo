module ApplicationHelper

  def bootstrap_flash_key_for(key)
    { :notice => "success", :alert => "error" }.fetch(key) { |key| key.to_s }
  end

  def messages_link(text, options = {})
    link_to unread_messages_count > 0 ? "#{text} <span class=\"label important\">#{unread_messages_count}</span>".html_safe : text,
            messages_path, options
  end

end
