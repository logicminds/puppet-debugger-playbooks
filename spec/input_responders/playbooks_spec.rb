require 'spec_helper'
require 'puppet-debugger/plugin_test_helper'

def playbooks_dir
  File.join(fixtures_dir, 'playbooks')
end

describe :playbooks do
  include_examples 'plugin_tests'

  describe '#run' do
    context 'when there are no arguments' do
      it 'creates a tree from all playbook directories' do
        expect(plugin.run).to eq(plugin.create_tree(plugin.directories))
      end
    end

    context 'when the argument is the name of a playbook' do
      it 'creates a tree from the directory' do
        dir = Pathname.new(plugin.directories.first)
        subdir = dir.children.select { |c| File.directory?(c) }.first
        subdir_name = File.basename(subdir)
        expect(plugin.run([subdir_name])).to eq(plugin.create_tree([subdir]))
      end
    end
  end

  describe '#create_tree' do
    let(:dir) { playbooks_dir }
    let(:dir_entries) { Dir[File.join(dir, '**', '*')].map { |e| File.basename(e, '.*') } }

    it 'lists the contents of a directory and all its subdirectories' do
      expect(dir_entries).not_to be_empty
      tree = plugin.create_tree([dir])
      dir_entries.each { |e| expect(tree).to match(e) }
    end
  end

  describe '#directories' do
    context 'when an external directory is not set' do
      it 'returns the internal directory' do
        expect(plugin.directories).to eq([plugin.internal_directory])
      end
    end

    context 'when an external directory is set' do
      it 'returns the internal and external directories' do
        allow(plugin).to receive(:external_directory) { playbooks_dir }
        expect(plugin.directories).to eq([plugin.internal_directory, plugin.external_directory])
      end
    end
  end

  describe '#internal_directory' do
    it 'returns the playbooks directory in lib' do
      expect(plugin.internal_directory).to eq(File.join(PuppetDebugger::ROOTDIR, 'lib', 'playbooks'))
    end
  end

  describe '#external_directory' do
    context 'when the environment variable is not set' do
      it 'returns nil' do
        ENV['PLAYBOOKS_DIR'] = nil
        expect(plugin.external_directory).to be_nil
      end
    end

    context 'when the environment variable is set' do
      it 'returns the path in the environment variable' do
        ENV['PLAYBOOKS_DIR'] = playbooks_dir
        expect(plugin.external_directory).to eq(playbooks_dir)
      end
    end
  end
end