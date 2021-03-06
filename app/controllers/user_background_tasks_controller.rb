class UserBackgroundTasksController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!

  def index
    @tasks = UserBackgroundTask.where(user_id: current_user.id).page(params[:page]).available
  end

  def destroy
    UserBackgroundTask.where(user_id: current_user.id).where(status: ['completed', 'failed', 'killed']).delete_all

    respond_to do |format|
      format.html { redirect_to(user_tasks_url) }
    end
  end
end
