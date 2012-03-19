class CongressController < ApplicationController
  skip_before_filter :authorize
  caches_page :query
  include NytCongress

  def index
  end

  def query
    args = params[:args].split("/")
    if args.length < 1
      # error
      return nil
    end
    method_symbol = args[0].tr("-","_").to_sym
    NytCongress.method_defined?(method_symbol)
    render json: self.method(method_symbol).call(args[1], "introduced")
 
  end
end
