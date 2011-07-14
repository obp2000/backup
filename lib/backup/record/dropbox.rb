require 'backup/connection/dropbox'

module Backup
  module Record
    class Dropbox < Backup::Record::Base
      def load_specific_settings(adapter)
      end

      private

      def self.destroy_backups(procedure, backups)
        dropbox = Backup::Connection::Dropbox.new
        dropbox.static_initialize(procedure)
        session = dropbox.session
        backups.each do |backup|
          files = YAML.load(backup.filename)
          files.each {|file|
            puts "\nDestroying backup \"#{file}\"."
            path_to_file = File.join(dropbox.path, file)
            begin
              session.delete(path_to_file, :mode => :dropbox)
            rescue ::Dropbox::FileNotFoundError => e
              puts "\n Backup with name '#{file}' was not found in '#{dropbox.path}'"
            end
          }
        end
      end
    end
  end
end
