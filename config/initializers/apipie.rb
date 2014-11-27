Apipie.configure do |config|
  config.app_name                = "Tunesheap"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/apipie" 
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/**/*.rb"
  config.app_info = "This is the reference for Tunesheap API. There are three main objects  Artist, Album and Song. Artist has many albums. Album belongs to artist and has many songs. Song belongs to album. All objects allow CRUD operations and there are additional endpoints that allow estabishing and removing relationships between objects. Have fun."
  config.namespaced_resources = true
  config.validate = false
end
