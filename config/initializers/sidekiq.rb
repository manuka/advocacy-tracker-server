require "sidekiq"
require "sidekiq/api"

Sidekiq.configure_server do |config|
  config.redis = {url: ENV.fetch("REDIS_URL", "redis://localhost:6379/5"), size: 12}
  config.options[:queues] = %w[default]
end

Sidekiq.configure_client do |config|
  config.redis = {url: ENV.fetch("REDIS_URL", "redis://localhost:6379/5"), size: 1}
end
