class HospitalsController < ApplicationController
  include HospitalHelper

  def show
    @system = System.find(params[:system_id])
    @hospital = Hospital.find(params[:hospital])
  end
end
