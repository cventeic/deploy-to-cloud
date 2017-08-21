require 'ostruct'
require 'recursive_open_struct'


def get_config()


  config = {
    project: {
      name: 'venteicher-org',
        id: 174023,
      keys: {
          rails_master_key: 'MDQxYjg4NjU4Mzg5ZmM4YmMyOWZjNmM3NTQzMWM3ZTk='
        }
    },

    cloud: {
      provider:  'gce', # Google Compute / Container Engine
      #registry_uri: "gcr.io/#{project_name}-#{project_id}"
      registry_uri: "gcr.io/venteicher-org-174023"
    },


=begin
    cloud: {
      provider:  'local', # Local Kubernetes Cluster
      registry_uri: "localhost:5000"
    },
=end

    apps: [
      {
        type: 'node',
        source_url: "/home/chris/venteicher-org-cli/venteicher-org",
        # mode: 'production', # development, production, test
      },
=begin
      {
        type: 'rails',
        source_url: "/home/chris/venteicher-org-cli/venteicher-org-rails"
        # mode: 'production', # development, production, test
      },
=end
    ]
  }

  # Convert data structure (hashes and arrays) into a
  #   dot notation accessable structure (ex. config.project.name)
  #
  return RecursiveOpenStruct.new(config, recurse_over_arrays: true )

end

