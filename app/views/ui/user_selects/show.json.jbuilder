json.users do
  json.array! @users do |user|
    json.id user.id
    json.name user.name_with_clerk_code
  end
end
