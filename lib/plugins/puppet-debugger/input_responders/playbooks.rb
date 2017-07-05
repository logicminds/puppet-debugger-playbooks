require 'puppet-debugger/input_responder_plugin'
module PuppetDebugger
  module InputResponders
    class Playbooks < InputResponderPlugin
      COMMAND_WORDS = %w(playbooks)
      SUMMARY = 'Show a list of available playbooks.'
      COMMAND_GROUP = :editing

      def self.command_completion(buffer_words)
        directories.map do |d|
          path = File.join(d, *buffer_words)
          glob_path = File.directory?(path) ? File.join(path, '*') : path + '*'
          files = Dir.glob(glob_path)
          dirs = files.grep(path).map { |f| File.basename(f, File.extname(f)) }
          files.find_all {|d| d.match(path) }.map { |f| File.basename(f, File.extname(f)) } - dirs
        end.flatten.sort
      end

      def self.directories
        (internal_directories + external_directory).uniq
      end

      # @return [String] - the path to the playbooks directory
      def self.internal_directories
        playbooks_dir_list
      end

      # @return [Array[String]] dir of external playbooks dir
      # empty array is returned if no external directory
      def self.external_directory
        [ENV['PLAYBOOKS_DIR']].compact
      end

      # @return [Array[String]] - a list of puppet debugger playbook directories
      def self.playbooks_dir_list
        @playbooks_dir_list ||= begin
          gemspecs.collect do |spec|
            lib_path = File.join(spec.full_gem_path,'lib','puppet-debugger','playbooks')
            lib_path if Dir.exist?(lib_path)
          end.compact
        end
      end

      # Returns an Array of Gem::Specification objects.
      def self.gemspecs
        @gemspecs ||= Gem::Specification.respond_to?(:latest_specs) ?
            Gem::Specification.latest_specs : Gem.searcher.init_gemspecs
      end

      def playbook_file(words)
        path = File.join(*words)
        file = nil
        self.class.directories.find do |dir|
          search_path = File.join(dir, path) + '*'
          file = Dir.glob(search_path).find {|f| File.file?(f)}
        end
        file
      end

      def run(args = [])
        if args.count > 0
          file = playbook_file(args)
          return debugger.handle_input("play #{file}") if file && File.exist?(file)
          self.class.directories.each do |dir|
            walk(dir) do |path|
              if args.first == File.basename(path)
                return create_tree([path])
              end
            end
          end
        else
          create_tree(self.class.directories)
        end
      end

      # @param dirs [Array[String]]
      def create_tree(dirs = [])
        tree = []
        dirs.each do |dir|
          walk(dir) do |path, depth|
            tree << sprintf("%s%s\n", ('  ' * depth), File.basename(path, File.extname(path)) )
          end
        end
        tree.join()
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
