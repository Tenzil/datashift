# Copyright:: (c) Autotelik Media Ltd 2015
# Author ::   Tom Statter
# License::   MIT
#
# Details::   Export a model to Excel '97(-2007) file format.
#
# TOD : Can we switch between .xls and XSSF (POI implementation of Excel 2007 OOXML (.xlsx) file format.)
#
#
require 'excel'
require 'file_generator'

module DataShift

  class ExcelGenerator < FileGenerator

    include DataShift::Logging
    include DataShift::ExcelBase

    attr_accessor :excel

    def initialize
      super
    end

    # Create an Excel file template (header row) representing supplied Model
    # file_name => Filename for generated template
    #
    # See DataShift::Exporters::Configuration for options
    #
    def generate(file_name, klass, options = {})

      @file_name = file_name

      start_excel(klass, options)

      @excel.set_headers( klass_to_headers(klass) )

      logger.info("ExcelGenerator saving generated template #{@file_name}")

      # @excel.autosize if(options[:autosize])

      @excel.write( @file_name )
    end

  end # ExcelGenerator

end # DataShift
