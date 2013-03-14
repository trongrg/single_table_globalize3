Dir[File.expand_path('../models/**/*.rb', __FILE__)].sort.each do |model|
  require model
end
