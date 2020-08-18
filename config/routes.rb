Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'                 # 基本情報編集
      patch 'update_basic_info'             # 基本情報編集更新
      get 'attendances/edit_one_month'      # 勤怠編集
      patch 'attendances/update_one_month'  # 勤怠編集更新
    end
    resources :attendances, only: :update
  end
end