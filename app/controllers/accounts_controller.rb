class AccountsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
    render :template => "users/new"
  end

    def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = t("flash.accounts.create.notice")
      redirect_back_or_default root_url
    else
      render :template => "users/new"
    end
  end

  
  def show
    find_user
    render :template => "users/show"
  end

  def edit
    find_user
    render :template => "users/edit"
  end
  
  def update
    find_user
    if @user.update_attributes(params[:user])
      flash[:notice] = t('flash.accounts.update.notice')
      redirect_to account_url
    else
      render :template => "users/edit"
    end
  end

private

  def find_user
    @user = @current_user
  end
  
end
