module ApplicationHelper

  def bootstrap_flash_key_for(key)
    { :notice => "success", :alert => "error" }.fetch(key) { |key| key.to_s }
  end

  def messages_link(text, options = {})
    class_names = "unreadMessages label"
    class_names << " important" if unread_messages_count > 0
    link_to "#{text} <span class=\"#{class_names}\">#{unread_messages_count}</span>".html_safe,
            messages_path, options
  end

end
