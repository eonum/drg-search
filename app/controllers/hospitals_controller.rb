class HospitalsController < ApplicationController
  include HospitalHelper

  def show
    @system = System.find(params[:system_id])
    @hospital = Hospital.find(params[:hospital])

    @num_cases = NumCase.where(version: @system.version, year: @system.base_year, hospital_id: @hospital.hospital_id, level: params[:level].upcase).where('n > 0').order('n desc')
  end
end
