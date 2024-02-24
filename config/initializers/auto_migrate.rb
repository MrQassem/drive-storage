Rails.application.config.after_initialize do
  ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate')).migrate
end
  