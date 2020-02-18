Rails.application.configure do

  config.cache_classes = false

  config.eager_load = false

  config.consider_all_requests_local = true

  config.action_controller.perform_caching = true
  config.action_controller.enable_fragment_cache_logging = true
  
  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load

  config.active_record.verbose_query_logs = true

  config.assets.debug = true

  config.assets.quiet = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


  config.cache_store = :redis_cache_store, {
    url: Rails.application.credentials.redis_env,
    expires_in: 1.days
  }
  config.session_store :active_record_store, key: '_pangolin_session'

end
