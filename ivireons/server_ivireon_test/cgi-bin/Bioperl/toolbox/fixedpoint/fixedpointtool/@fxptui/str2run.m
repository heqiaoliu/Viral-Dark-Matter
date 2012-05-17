function run = str2run(str)
%STR2RUN   returns the run number for Active (1) or Reference (2)

%   Author(s): V. Srinivasan
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/13 17:56:58 $

persistent active; 
persistent reference;
if isempty(active); active = DAStudio.message('FixedPoint:fixedPointTool:labelActive'); end
if isempty(reference);reference = DAStudio.message('FixedPoint:fixedPointTool:labelReference'); end
if strcmpi(active,str)
    run = 0;
elseif strcmpi(reference,str)
    run = 1;
else
    runstr = DAStudio.message('FixedPoint:fixedPointTool:labelRun');
    % for runs > 1, the string will be of the form "Run #"
    run = regexprep(str,runstr,'');
    run = str2double(run);
end

        
        

% [EOF]
