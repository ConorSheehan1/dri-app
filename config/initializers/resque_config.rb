config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], password: config[:password], thread_safe: true)

Resque.inline = Rails.env.test?

Resque.logger = Logger::Syslog.new
Resque.logger.level = Logger::WARN
