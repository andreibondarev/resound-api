require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'

Shrine.plugin :activerecord
Shrine.plugin :logging, logger: Rails.logger
Shrine.plugin :validation_helpers

puts('------------RAILS SECRETS------------')
puts(Rails.application.secrets.aws_secret_access_key)
puts(Rails.application.secrets.aws_region)
puts(Rails.application.secrets.aws_bucket)
puts(Rails.application.secrets.auth0_domain)
puts('------------ENV VARS------------')
puts(ENV['AWS_ACCESS_KEY_ID'])
puts(ENV['AWS_SECRET_ACCESS_KEY'])
puts(ENV['AWS_REGION'])
puts(ENV['AWS_BUCKET'])
puts('--------------------------------')

storage_location = if Rails.env.production? || ENV['UPLOAD_TO_S3']
                     shrine_options = {
                         access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                         secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                         region: ENV['AWS_REGION'],
                         bucket: ENV['AWS_BUCKET'],
                         upload_options: { acl: 'public-read' },
                     }
                     if Rails.application.secrets.s3_signature_version
                       shrine_options.merge!(
                           { signature_version: Rails.application.secrets.s3_signature_version }
                       )
                     end
                     if Rails.application.secrets.s3_endpoint
                       shrine_options.merge!(
                           { endpoint: Rails.application.secrets.s3_endpoint }
                       )
                     end
                     Shrine::Storage::S3.new(
                        shrine_options
                     )
                   else
                     Shrine::Storage::FileSystem.new('public', prefix: 'uploads/store')
                   end

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
  store: storage_location
}
