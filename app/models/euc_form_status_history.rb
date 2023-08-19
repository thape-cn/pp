class EucFormStatusHistory < ApplicationRecord
  belongs_to :evaluation_user_capability
  belongs_to :user
end
