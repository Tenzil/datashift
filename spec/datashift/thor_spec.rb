# Copyright:: (c) Autotelik Media Ltd 2015
# Author ::   Tom Statter
#
# License::   MIT - Free, OpenSource
#
# Details::   Specification for Thor tasks supplied with datashift
#
require 'thor'
require 'thor/group'
require 'thor/runner'

require File.dirname(__FILE__) + '/../spec_helper'

describe 'Thor high level command line tasks' do
  before(:all) do
    DataShift.load_commands
  end

  context 'Generate CLI' do
    before(:each) do
      load File.join( datashift_thor_root, 'generate.thor')

      results_clear
    end

    it 'should provide tasks to generate a mapping doc' do

     # datashift:generate:config:import -m Spree::Product -p ~/blah.yaml

      opts = { model: 'Project', path: results_path.to_s }

      run_in(rails_sandbox_path) do
        output = capture_stream(:stdout) { Datashift::Generate::Config.new.invoke(:import, [], opts) }

        puts output

        expect(output).to include('Creating new configuration file ')
      end
    end
  end

  # thor datashift:export:csv -m, --model=MODEL -r, --result=RESULT              ...
  # thor datashift:export:excel -m, --model=MODEL -r, --result=RESULT            ...
  # thor datashift:generate:excel -m, --model=MODEL -r, --result=RESULT          ...
  # thor datashift:import:csv -i, --input=INPUT -m, --model=MODEL                ...
  # thor datashift:import:excel -i, --input=INPUT -m, --model=MODEL              ...
  # thor datashift:paperclip:attach -a, --attachment-klass=ATTACHMENT_KLASS -f, -...                                     ...
  # thor datashift:tools:zip -p, --path=PATH -r, --results=RESULTS               ...

  it 'should list available datashift thor tasks' do
    skip 'better understanding of testign thor'

    # x = capture_stream(:stdout){ Thor::Runner.start(["list"]) }
    # x.should start_with("datashift\n--------")
    # x.should =~ / csv -i/
    # x.should =~ / excel -i/
  end

  # N.B Tasks that fire up Rails application need to be run in own Thread or else get
  #  ...  You cannot have more than one Rails::Application

  it 'should be able to import a model from a complex excel through import CLI' do
    skip 'How to run once rails already initialzed .. error : database configuration does not specify adapter'

    x = Thread.new {
      run_in(rails_sandbox) do
        stdout = capture_stream(:stdout){
          Thor::Runner.start(['datashift:import:excel', '-m', 'Project', '-i', ifixture_file('ProjectsSingleCategories.xls')])
        }
        puts stdout
      end
    }
    x.join
  end

  it 'should attach Images to a specified Class from a directory' do
    skip 'better understanding of testign thor'

    # Owner has_many :digitals of type Digital

    # Owner has a name by which we can id/look it up

    args = [
      '--attachment-klass',        'Digital',
      '--attach-to-klass',         'Owner',
      '--attach-to-find-by-field', 'name',
      '--attach-to-field',         'digitals']

    # which boils down to
    #
    # Digital.find_by_name( abc ).digitals << :Digital.new( File.read('abc_001.jpg') )

    args << '--input' << File.join(fixtures_path, 'images')

    puts "Running attach with: #{args}"

    x = capture_stream(:stdout) { Thor::Runner.start(['datashift:paperclip:attach', [], args]) }

    expect(x).to include "datashift\n--------"
    # x.should =~ / csv -i/
    # x.should =~ / excel -i/
  end
end
