class HealthCheckController < ApplicationController
  def live
    render json: { status: 'Working great!' }, status: :ok
  end
end
