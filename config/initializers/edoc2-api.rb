Edoc2.loginName = Rails.application.credentials[Rails.env.to_sym][:edoc2_login_name]
Edoc2.ipAddress = Socket.ip_address_list.detect(&:ipv4_private?)&.ip_address || Socket.ip_address_list.detect(&:ipv4?)&.ip_address
Edoc2.integrationKey = Rails.application.credentials[Rails.env.to_sym][:edoc2_integration_key]
Edoc2.base_url = Rails.application.credentials[Rails.env.to_sym][:edoc2_base_url] # notice no / at end
