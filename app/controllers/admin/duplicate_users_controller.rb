module Admin
  class DuplicateUsersController < ApplicationController
    def index
      @duplicate_users = policy_scope(User)
        .select("clerk_code, COUNT(id) account_counts")
        .group(:clerk_code)
        .having("count(id) > 1")
        .where.not(clerk_code: nil)
        .order("account_counts DESC, clerk_code DESC")
    end

    def edit
      @clerk_code = params[:id]
      @duplicate_users = User.where(clerk_code: @clerk_code)
      render layout: false
    end

    def update
      main_user = User.find(params[:main_user_id])
      to_remove_user_ids = User.where.not(id: main_user.id)
        .where(clerk_code: main_user.clerk_code).pluck(:id)
      UserMerger.do_merge(main_user.id, to_remove_user_ids)
    end
  end
end
