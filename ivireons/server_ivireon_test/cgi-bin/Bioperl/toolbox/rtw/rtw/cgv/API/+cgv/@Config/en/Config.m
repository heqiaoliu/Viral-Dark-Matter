classdef Config
%cgv.Config
%
% Syntax: 
%   cgv.Config( Model Name, optional args)
%
% Description:
%   Returns a handle to a Config object that supports evaluation and optional modification 
%   of the model for compatibility with various modes of execution (e.g. SIL, PIL, etc.).
%   This object uses one of the following approaches regarding changing the model:
%   default, SaveModel or ReportOnly.  In default mode, the object executes 
%   set_param commands for parameters which need to change, but the object 
%   does not save the model.  In SaveModel, the object saves any model it 
%   changes.  In ReportOnly, the object lists the changes, and no changes are 
%   made to the model.
%   Note: The configuration set or the model might still need modifications to execute
%   successfully in the target environment.
% 
% Parameters:
%   Model Name - top model
%   optional args: - optional comma separated parameter and value pairs that modify the
%   operation of the Config object.
%       Default values are listed in parentheses.  Valid pairs are:
%       o 'ComponentType': ('topmodel') | 'modelblock'
%       o 'connectivity': ('sim') | 'sil' | 'tasking' | 'custom'
%           o If 'tasking', an additional parameter and value pair defines the processor
%           type:
%               'processor': 'ARM' | 'TriCore' | 'C166' | '8051' | 'M16C' | DSP563xx'.
%       o 'LogMode': ('SignalLogging') | 'SaveOutput'
%       o 'SaveModel': ('off') | 'on' 
%       o 'ReportOnly': ('off') | 'on' 
%
% Methods
%   configModel(): Update the configuration set.
%   getReportData(): Compares the original and updated configuration sets. 
%       Returns an array of strings with the model name, parameter, previous 
%       parameter value, and recommended or new parameter value.
%   displayReport(): Prints the results of getReportData() to the Command Window.
% 
% Example:
%   c = cgv.Config('vdp', 'componentType', 'modelblock');
%   c.configModel();
%   c.displayReport
%   bdclose vdp

 
%   Copyright 2009 The MathWorks, Inc.

    methods
        function out=Config
            % Class constructor
            %
        end

        function IsConfigForCGV(in) %#ok<MANU>
        end

        function configModel(in) %#ok<MANU>
        end

    end
    properties
        %DeviceType -  Named similar to the set_param parameter
        DeviceType;

    end
end
