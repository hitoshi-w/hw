class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to task_url(@task) and return
    else
      render :new
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    @task.attributes = task_params
    if @task.save
      redirect_to task_url(@task) and return
    else
      render :edit
    end
  end

  private

  def task_params
    params.require(:task).permit(:content)
  end
end
