class CodesController < ApplicationController
  include CodeHelper
  include SystemsHelper

  def show
    @system = System.find(params[:system_id])


    @code_class = {Mdc: Mdc, Partition: Partition, Adrg: Adrg, Drg: Drg}[params[:level].to_sym]
    @code = @code_class.find(params[:code])

    @num_cases = NumCase.where(version: @system.version, year: @system.base_year, code: @code.code, level: params[:level].upcase).where('n > 0').order('n desc')
  end
end
