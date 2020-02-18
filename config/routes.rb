# == Route Map
#
# 2020-01-23T23:22:39.668Z pid=19142 tid=gtbrkolne INFO: Cron Jobs - add job with name: update_crypto_prices
# 2020-01-23T23:22:39.670Z pid=19142 tid=gtbrkolne INFO: Cron Jobs - add job with name: expire_chat_members
# 2020-01-23T23:22:39.671Z pid=19142 tid=gtbrkolne INFO: Cron Jobs - add job with name: expire_trades
#                        Prefix Verb   URI Pattern                                                                              Controller#Action
#                          root GET    /                                                                                        pages#home
#                 registrations POST   /registrations(.:format)                                                                 registrations#create
#              new_registration GET    /registrations/new(.:format)                                                             registrations#new
#                      sessions POST   /sessions(.:format)                                                                      sessions#create
#                   new_session GET    /sessions/new(.:format)                                                                  sessions#new
#                        logout GET    /log_out(.:format)                                                                       sessions#log_out
#      two_factor_authorization GET    /2fa(.:format)                                                                           sessions#two_factor_authorization
#                  validate_2fa POST   /validate_2fa(.:format)                                                                  sessions#validate_2fa
#                  pass_captcha PUT    /captcha(.:format)                                                                       sessions#passed_captcha
#                       reviews POST   /reviews(.:format)                                                                       reviews#create
#                     offerings POST   /offerings(.:format)                                                                     offerings#create
#                  new_offering GET    /offerings/new(.:format)                                                                 offerings#new
#                 edit_offering GET    /offerings/:id/edit(.:format)                                                            offerings#edit
#                      offering GET    /offerings/:id(.:format)                                                                 offerings#show
#                               PATCH  /offerings/:id(.:format)                                                                 offerings#update
#                               PUT    /offerings/:id(.:format)                                                                 offerings#update
#                               DELETE /offerings/:id(.:format)                                                                 offerings#destroy
#                      exchange GET    /exchange(.:format)                                                                      offerings#index
#                        trader GET    /trader/:id(.:format)                                                                    trader#show
#               user_paid_trade POST   /trades/:id/user_paid(.:format)                                                          trades#user_paid
#                  expire_trade POST   /trades/:id/expire_trade(.:format)                                                       trades#expire_trade
#          mark_completed_trade POST   /trades/:id/mark_complete(.:format)                                                      trades#mark_complete
#       extend_expiry_for_trade POST   /trades/:id/extend_expiry(.:format)                                                      trades#extend_expiry
#   request_extension_for_trade POST   /trades/:id/request_extension(.:format)                                                  trades#request_expiry_extension
#         destination_for_trade POST   /trades/:id/destination(.:format)                                                        trades#set_destination_address
#                        trades GET    /trades(.:format)                                                                        trades#index
#                               POST   /trades(.:format)                                                                        trades#create
#                         trade GET    /trades/:id(.:format)                                                                    trades#show
#        add_message_trade_chat POST   /trade_chats/:id/add_message(.:format)                                                   trade_chats#add_message
#     add_attachment_trade_chat POST   /trade_chats/:id/add_attachment(.:format)                                                trade_chats#add_attachment
#     report_message_trade_chat POST   /trade_chats/:id/report_msg(.:format)                                                    trade_chats#report_message
#                   trade_chats POST   /trade_chats(.:format)                                                                   trade_chats#create
#                  notification GET    /notifications/:id(.:format)                                                             notifications#show
#                trade_disputes POST   /trade_disputes(.:format)                                                                trade_disputes#create
#             new_trade_dispute GET    /trade_disputes/new(.:format)                                                            trade_disputes#new
#                 trade_dispute GET    /trade_disputes/:id(.:format)                                                            trade_disputes#show
#      global_chat_send_message PATCH  /global_chat/:global_chat_id/send_message(.:format)                                      global_chat#send_message
# global_chat_new_trade_request POST   /global_chat/:global_chat_id/trade_request(.:format)                                     global_chat#enter_trade_request
#             global_chat_index GET    /global_chat(.:format)                                                                   global_chat#index
#            rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#     rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#            rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#     update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#          rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do
  root 'pages#home'

  resources :registrations, only: %i(new create)

  resources :sessions, only: %i(new create)
  get '/log_out', to: 'sessions#log_out', as: 'logout'
  get '/2fa',     to: 'sessions#two_factor_authorization',  as: :two_factor_authorization
  post '/validate_2fa', to: 'sessions#validate_2fa',        as: :validate_2fa
  put '/captcha', to: 'sessions#passed_captcha',            as: :pass_captcha


  resources :reviews, only: %i(create)

  resources :offerings, except: :index
  get '/exchange', to: 'offerings#index', as: :exchange

  resources :trader, only: :show
  resources :trades, only: %i(create show index) do
    member do
      post 'user_paid',     to: 'trades#user_paid', as: :user_paid
      post 'expire_trade',  to: 'trades#expire_trade', as: :expire
      post 'mark_complete', to: 'trades#mark_complete', as: :mark_completed
      post 'extend_expiry', to: 'trades#extend_expiry', as: :extend_expiry_for
      post 'request_extension', to: 'trades#request_expiry_extension', as: :request_extension_for
      post 'destination', to: 'trades#set_destination_address', as: :destination_for
    end
  end

  resources :trade_chats, only: :create do
    member do
      post 'add_message',     to: 'trade_chats#add_message', as: :add_message
      post 'add_attachment',  to: 'trade_chats#add_attachment', as: :add_attachment
      post 'report_msg',      to: 'trade_chats#report_message', as: :report_message
    end
  end

  resources :notifications, only: :show
  resources :trade_disputes, only: %i(new create show)

  resources :global_chat, only: :index do
    patch 'send_message', to: 'global_chat#send_message', as: :send_message
    post 'trade_request', to: 'global_chat#enter_trade_request', as: :new_trade_request
  end
end
