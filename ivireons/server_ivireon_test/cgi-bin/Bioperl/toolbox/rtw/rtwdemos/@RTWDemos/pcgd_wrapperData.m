function pcgd_wrapperData(pcgDemoData,def)
    % This file defines the function interface for the external code
    % "SimpleTable"

%   Copyright 2007 The MathWorks, Inc.
                        
    def.SrcPaths      = {fullfile(matlabroot,'toolbox','rtw','rtwdemos','EmbeddedCoderOverview','stage_4_files')}; % The current working directory
    def.IncPaths      = {fullfile(matlabroot,'toolbox','rtw','rtwdemos','EmbeddedCoderOverview','stage_4_files')}; % The current working directory
    
    % Defines the function interface, inputs, return values and parameters
    def.OutputFcnSpec = ['double y1 = SimpleTable(double u1,',...
                         'double p1[], double p2[], int16 p3)'];    
    
    % the C and H files where the external code is defined
    def.HeaderFiles   = {'SimpleTable.h'};                     
    def.SourceFiles   = {'SimpleTable.c'};
    % The name of the created S-Function
    def.SFunctionName = 'SimpTableWrap';

    % save it to the base workspace
     assignin('base','def',def);
end

    
