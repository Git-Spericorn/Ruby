module CrudConcern
  extend ActiveSupport::Concern

  ##################################################################
  #      This module take cares the CRUD controller methods        #
  #                                                                #
  # Note: add skip_before_action if you want to ignore any of the  #
  # above action to be loaded from module                          #
  ##################################################################

  included do
    before_action :init_resource
    before_action :load_resources, only: [:index]
    before_action :load_resource, only: [:new, :edit, :update, :destroy, :create, :show]
  end

  def index
    authorize @resources.classify.constantize
  end

  def new
  end

  def show
  end

  def create
    instance_variable_get("@#{@resource}").save!(send("#{@resource}_params"))
  end

  def edit
  end

  def update
    instance_variable_get("@#{@resource}").update!(send("#{@resource}_params"))
  end

  def destroy
    respond_to do |format|
      format.html {
        if current_user.valid_password?(authenticate_params[:password])
          instance_variable_get("@#{@resource}").destroy
        else
          flash[:error] = 'Invalid Password'
        end
        redirect_to send("#{@resources}_path")
      }
      format.js {
        @path = send("#{@resource}_path", instance_variable_get("@#{@resource}"))
        render 'shared/delete'
      }
    end
  end

  private

  def init_resource
    @resources = controller_name
    @resource = @resources.singularize
  end

  def load_resource
    if params[:action] == "create"
      instance_variable_set "@#{@resource}", @resources.classify.constantize.new(send("#{@resource}_params"))
    else
      instance_variable_set "@#{@resource}", @resources.classify.constantize.find_or_initialize_by(id: params[:id])
    end
    authorize  instance_variable_get("@#{@resource}")
  end

  def load_resources
    instance_variable_set "@#{@resources}", @resources.classify.constantize.all.order(created_at: :desc).page(params[:page]).per(10)
  end

  def authenticate_params
    params.require(:authenticate).permit(:password)
  end

end