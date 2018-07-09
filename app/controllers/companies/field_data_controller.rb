class Companies::FieldDataController < ApplicationController
  before_action :confirm_actions, only: [:create, :update, :destroy]
end
