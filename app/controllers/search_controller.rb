class SearchController < ApplicationController
  include SearchHelper

  def hospitals
    search_and_render Hospital
  end

  def codes
    search_and_render Drg
  end
end
