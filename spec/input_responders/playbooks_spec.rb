require 'spec_helper'
require 'puppet-debugger/plugin_test_helper'

describe :playbooks do
  include_examples 'plugin_tests'

  describe '#run' do
    context 'when there are no arguments' do
      it 'creates a tree from all playbook directories' do
        allow(plugin.class).to receive(:internal_directories).and_return([playbooks_dir])
        expect(plugin.run).to eq("example_group\n  graph\n  partitions_check\n")
      end
    end

    context 'when the argument is the name of a playbook' do
      it 'creates a tree from the directory' do
        allow(plugin.class).to receive(:playbooks_dir_list).and_return([playbooks_dir])
        dir = Pathname.new(plugin.class.directories.first)
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
        expect(plugin.class.directories).to eq(plugin.class.internal_directories)
      end
    end

    context 'when an external directory is set' do
      it 'returns the internal and external directories' do
        allow(plugin.class).to receive(:external_directory).and_return([playbooks_dir])
        expect(plugin.class.directories).to eq([playbooks_dir])
      end
    end
  end

  describe '#internal_directories' do
    it 'returns the playbooks directory in lib' do
      allow(plugin.class).to receive(:playbooks_dir_list).and_return([playbooks_dir])
      expect(plugin.class.internal_directories).to eq([playbooks_dir])
    end
  end

  describe '#external_directory' do
    context 'when the environment variable is not set' do
      it 'returns nil' do
        ENV['PLAYBOOKS_DIR'] = nil
        expect(plugin.class.external_directory).to eq([])
      end
    end

    context 'when the environment variable is set' do
      it 'returns the path in the environment variable' do
        ENV['PLAYBOOKS_DIR'] = playbooks_dir
        expect(plugin.class.external_directory).to eq([playbooks_dir])
      end
    end
  end

  describe 'playbook file' do
    it 'returns no play file when directory' do
      allow(plugin.class).to receive(:playbooks_dir_list).and_return([playbooks_dir])
      expect(plugin.playbook_file([])).to eq(nil)
    end

    it 'returns no playfile when directory' do
      allow(plugin.class).to receive(:playbooks_dir_list).and_return([playbooks_dir])
      expect(plugin.playbook_file(['example_group'])).to eq(nil)
    end

    it 'returns file' do
      allow(plugin.class).to receive(:playbooks_dir_list).and_return([playbooks_dir])
      expect(plugin.playbook_file(['example_group', 'graph'])).to eq(File.join(playbooks_dir, 'example_group','graph.pp'))
    end
  end

  describe 'command completion' do
    before(:each) do
      allow(plugin.class).to receive(:directories).and_return([playbooks_dir])
      allow(Readline).to receive(:line_buffer).and_return('playbooks')
    end
    it 'not return example group' do
      expect(debugger.command_completion.call('playbooks')).to_not eq(['example_group'])
    end

    it 'return example group' do
      allow(Readline).to receive(:line_buffer).and_return('playbooks ')
      expect(debugger.command_completion.call('playbooks ')).to eq(['example_group'])
    end

    it 'return example group for completion' do
      allow(Readline).to receive(:line_buffer).and_return('playbooks exam')
      expect(debugger.command_completion.call('playbooks exam')).to eq(['example_group'])
    end

    it 'return example group entries' do
      allow(Readline).to receive(:line_buffer).and_return('playbooks example_group ')
      expect(debugger.command_completion.call('playbooks example_group ')).to eq(['graph', 'partitions_check'])
    end
  end
end
