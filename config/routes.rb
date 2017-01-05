Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, :defaults => { :format => :json } do
    namespace :v0 do
      resources :cards, :only => [:index] do
        delete :force, :on => :collection
      end
    end
  end


  require 'sidekiq/web'
  mount Sidekiq::Web => '/82af180466c5'

end
