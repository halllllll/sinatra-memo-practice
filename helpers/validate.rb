# frozen_string_literal: true

module Validate
  def validate_params(params, origin_page)
    status 400
    @error_message = 'required parameter not found'
    halt 400, erb(origin_page) if [params[:title], params[:content]].any?(nil)

    @error_message = 'empty value not acceptable'
    halt 400, erb(origin_page) if [params[:title], params[:content]].map(&:strip).any?(&:empty?)
  end
end
