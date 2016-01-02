# CarrierWave.configure do |config|
#   config.fog_provider = 'fog/aws'                        # required
#   config.fog_credentials = {
#     :provider               => 'AWS',
#     :aws_access_key_id      => 'AKIAJXAS6QC5PAV3OABA',
#     :aws_secret_access_key  => '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',
#     :region                 => 'us-west-2'
#   }
#   config.fog_directory  = 'usebento'
#   config.fog_public = false
#   config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}"}
# end



CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'                        # required
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAINNCYAVGDPU7GZGA',
    :aws_secret_access_key  => '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',
    :region                 => 'us-west-2'
  }
  config.fog_directory  = 'travelog'
  config.fog_public = true
  config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}"}
end