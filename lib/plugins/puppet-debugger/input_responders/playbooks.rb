require 'puppet-debugger/input_responder_plugin'
module PuppetDebugger
  module InputResponders
    class Playbooks < InputResponderPlugin
      COMMAND_WORDS = %w(playbooks)
      SUMMARY = 'Show a list of available playbooks.'
      COMMAND_GROUP = :editing

      def run(args = [])
        if args.count > 0
          directories.each do |dir|
            walk(dir) do |path|
              if args.first == File.basename(path)
                return create_tree([path])
              end
            end
          end
        else
          create_tree(directories)
        end
      end

      # @param dirs [Array[String]]
      def create_tree(dirs = [])
        lines = ''
        dirs.each do |dir|
          walk(dir) do |path, depth|
            lines += ('  ' * depth) + File.basename(path, '.*') + "\n"
          end
        end
        lines
      end

      def directories
        directories = [internal_directory]
        directories << external_directory if external_directory
        directories
      end

      # @return [String] - the path to the playbooks directory
      def internal_directory
        relative_path = File.join('lib', 'playbooks')
        File.expand_path(File.join(PuppetDebugger::ROOTDIR, relative_path))
      end

      def external_directory
        ENV['PLAYBOOKS_DIR'] if File.exist?(ENV['PLAYBOOKS_DIR'].to_s)
      end

      private

      # @param dir [String] - directory path
      # @param depth [Integer] - where you are in the directory tree
      # @param block [block] - passes path and depth to block
      # @return [nil]
      def walk(dir, depth = 0, &block)
        Dir.foreach(dir).sort.each do |name|
          next if name == '.' || name == '..'
          path = File.join(dir, name)
          block.call(path, depth)
          walk(path, depth + 1, &block) if File.directory?(path)
        end
      end
    end
  end
end