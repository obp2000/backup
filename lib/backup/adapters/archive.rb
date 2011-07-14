module Backup
  module Adapters
    class Archive < Backup::Adapters::Base
      
      attr_accessor :files, :exclude, :max_part
      
      private

        # Archives and Compresses all files
        def perform
          log system_messages[:archiving]; log system_messages[:compressing]
          _compressed_file = File.join(tmp_path, compressed_file)
          run "tar -cvf #{_compressed_file} #{exclude_files} #{tar_files}"
          if !self.max_part.nil? && File.size(_compressed_file) > self.max_part
            file = File.join(tmp_path, "/", compressed_file)
            Dir.chdir(tmp_path)
            run "split -b #{max_part} #{_compressed_file} -d #{_compressed_file}.part_"
            compressed_part
          else
            puts _compressed_file
            self.final_file = add_archive_file(compressed_file)
          end
        end
        
        def load_settings
          self.files   = procedure.get_adapter_configuration.attributes['files']
          self.exclude = procedure.get_adapter_configuration.attributes['exclude']
          self.max_part = procedure.get_adapter_configuration.attributes['max_part']
        end

        def add_archive_file(file)
          Dir.chdir(tmp_path)
          run "gzip -c #{file} > #{file}.gz"
          "#{file}.gz"
        end

        def performed_file_extension
          ".tar"
        end

        def compressed_part
          files = Dir.entries(tmp_path)
          files = files.delete_if {|x| x !~ /part/ }
          files = files.delete_if {|x| x =~ /\.$/ }
          self.final_file = []
          files.each {|file|
            self.final_file << add_archive_file(file)
          }
        end
        
        def tar_files
          [*files].map{|f| f.gsub(' ', '\ ')}.join(' ')
        end

        def exclude_files
          [*exclude].compact.map{|x| "--exclude=#{x}"}.join(' ')
        end

    end
  end
end
