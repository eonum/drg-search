class CodesController < ApplicationController
  include CodeHelper

  def show
    @system = System.find(params[:system_id])
    @code_class = {Mdc: Mdc, Partition: Partition, Adrg: Adrg, Drg: Drg}[params[:level].to_sym]
    @code = @code_class.find(params[:code])
  end
end
