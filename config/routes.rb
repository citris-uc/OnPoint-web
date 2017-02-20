Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, :defaults => { :format => :json } do
    namespace :v0 do
      resource :drugs, :only => [:show] do
        get "rxcui"
        get "dailymed"
      end

      resources :images, :only => [] do
        put "parse", :on => :collection
        put "parse_from_mobile", :on => :collection
      end

      resources :cards, :only => [:index] do
        delete :force, :on => :collection
      end

      resources :medications, :only => [:create] do
        put :decide, :on => :collection
      end

      resources :medication_schedule, :only => [:create] do
      end

      resource :medication_history, :only => [:show], :controller => :medication_history
    end
  end


  resource :drugs, :only => [:show] do
    get "dailymed"
  end

  resources :images, :only => [:index]

  root                :to => "drugs#show"


  require 'sidekiq/web'
  mount Sidekiq::Web => '/82af180466c5'

end
