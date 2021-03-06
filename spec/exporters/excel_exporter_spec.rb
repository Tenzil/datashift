# Copyright:: (c) Autotelik Media Ltd 2015
# Author ::   Tom Statter
# License::   MIT
#
# Details::   Specs for Excel aspect of Active Record Loader
#
require File.dirname(__FILE__) + '/../spec_helper'

require 'erb'
require 'excel_exporter'

module  DataShift

  describe 'Excel Exporter' do
    include_context 'ClearThenManageProject'

    before(:all) do
      results_clear( '*.xls' )
    end

    before(:each) do
      DataShift::Exporters::Configuration.reset
    end

    let(:exporter) { ExcelExporter.new }

    it 'should be able to create a new excel exporter' do
      expect(exporter).to_not be_nil
    end

    it 'should handle bad params to export' do
      expect = result_file('project_first_export_spec.csv')

      expect { exporter.export(expect, nil) }.not_to raise_error

      expect { exporter.export(expect, []) }.not_to raise_error

      puts "Can manually check file @ #{expect}"
    end

    context 'export model only' do
      let(:expected_projects)   { 7 }

      before(:each) do
        create_list(:project, expected_projects)
      end

      it 'should export model object to .xls file' do
        expected = result_file('exp_project_first_export.xls')

        exporter.export(expected, Project.all.first)

        expect(File.exist?(expected)).to eq true

        puts "Can manually check file @ #{expected}"
      end

      it 'should export collection of model objects to .xls file' do
        expected = result_file('exp_project_export.xls')

        exporter.export(expected, Project.all)

        expect( File.exist?(expected)).to eq true

        excel = Excel.new
        excel.open(expected)

        expect(excel.num_rows).to eq expected_projects + 1
      end
    end

    context 'project with associations' do
      let(:expected_projects) { 7 }

      before(:each) do
        create_list(:project, expected_projects)
        create( :project_with_user )
        create( :project_with_milestones, milestones_count: 4 )

        DataShift::Exporters::Configuration.configure do |config|
          config.with = :all
        end
      end

      it 'should include associations in headers' do
        expected = result_file('exp_project_assoc_headers.xls')

        exporter.export_with_associations(expected, Project, Project.all)

        expect(File.exist?(expected)).to eq true

        excel = Excel.new
        excel.open(expected)

        expect(excel.row(0)).to include 'owner'
        expect(excel.row(0)).to include 'user'
      end

      it 'should export a model and associations to .xls file' do
        expected = result_file('exp_project_plus_assoc.xls')

        exporter.export_with_associations(expected, Project, Project.all)

        expect(File.exist?(expected)).to eq true

        excel = Excel.new
        excel.open(expected)

        expected_rows = Project.count + 1
        last_idx = Project.count

        expect(excel.num_rows).to eq expected_rows

        user_inx = excel.row(0).index 'user'

        expect(user_inx).to be > -1

        expect( excel[1, user_inx] ).to be_nil

        # project_with_user has real associated user data
        expect( excel[last_idx, user_inx] ).to include 'mr'

        owner_idx = excel.row(0).index 'owner'

        expect(owner_idx).to be > -1

        expect( excel[last_idx, owner_idx] ).to include '10000.23'
      end

      it 'should export associations in hash format by default to .xls file', duff: true do

        expected = result_file('project_and_assoc_in_hash_export.xls')

        exporter.export_with_associations(expected, Project, Project.all)

        expect(File.exist?(expected)).to eq true

        excel = Excel.new
        excel.open(expected)

        milestone_inx = excel.row(0).index 'milestones'

        # project_with_milestones has real associated user data
        last_row_idx = Project.count

        expect( excel[last_row_idx, milestone_inx].to_s ).to include ColumnPacker.multi_assoc_delim
        expect( excel[last_row_idx, milestone_inx].to_s ).to include '{'
        expect( excel[last_row_idx, milestone_inx].to_s ).to match(/name: milestone/)
        expect( excel[last_row_idx, milestone_inx].to_s ).to match(/project_id: \d+/)
      end

      it 'should export a model and  assocs in json to .xls file', duff:true do

        expected = result_file('project_and_assoc_in_json_export.xls')

        DataShift::Exporters::Configuration.configure do |config|
          config.json = true
        end

        exporter.export_with_associations(expected, Project, Project.all)

        expect(File.exist?(expected)).to eq true

        excel = Excel.new
        excel.open(expected)

        milestone_inx = excel.row(0).index 'milestones'

        last_row_idx = Project.count

        expect( excel[last_row_idx, milestone_inx].to_s ).to include '['
        expect( excel[last_row_idx, milestone_inx].to_s ).to match(/name\":\"milestone/)
        expect( excel[last_row_idx, milestone_inx].to_s ).to match(/"project_id":\d+/)
      end
    end
  end
end
