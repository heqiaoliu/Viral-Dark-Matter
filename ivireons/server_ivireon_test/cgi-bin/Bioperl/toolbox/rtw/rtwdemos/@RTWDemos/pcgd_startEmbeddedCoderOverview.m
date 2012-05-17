%--------------------------------------------------------------------------
% function: startEmbeddedCoderOverview
% This function launches the Embedded Coder Overview and provides some utility functions
% while the demo runs.  Additionally it keeps the data for the demo in
% scope
%

%   Copyright 2007 The MathWorks, Inc.

function [pcgDemoData] = pcgd_startEmbeddedCoderOverview
    % at this point see if the demo data exists in the base workspace.
    % If it exists clear it then re-create the data

    if (evalin('base','exist(''pcgDemoData'',''var'')'))
        evalin('base','clear pcgDemoData')
    end

    % Need to know which version of MATLAB
    curVer           = version;
    pcgDemoData.is7a = (isempty(findstr('2007a',curVer))==0);
    


    pcgDemoData.rootDir    = pwd; % the working directory
    [pcgDemoData.Models,...
     pcgDemoData.helper,...
     pcgDemoData.Harness]  = RTWDemos.pcgd_assignModels('auto');
    assignin('base','pcgDemoData',pcgDemoData);

end
