class AnonymousController < ApplicationController
  def flash
    @flash ||= {}
  end

  def redirect_to(*)
  end

  def session
    @session ||= {}
  end
end
