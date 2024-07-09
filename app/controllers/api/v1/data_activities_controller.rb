class Api::V1::DataActivitiesController < ApplicationController
  def index
    data_activities = DataActivity.all
    categories = DataActivity.distinct.pluck(:activite_principale)

    render json: {
      data_activities: data_activities,
      categories: categories
    }
  end
end
