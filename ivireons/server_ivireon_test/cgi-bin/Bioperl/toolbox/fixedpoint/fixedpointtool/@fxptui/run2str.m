function str = run2str(run)
%STR2RUN   returns the run number for Active (0) or Reference (1)

%   Author(s): V.Srinivasan
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/11/19 16:36:52 $

% Make active and reference variables persistent to improve performance.
persistent active;
persistent reference;
if isempty(active)
    active = DAStudio.message('FixedPoint:fixedPointTool:labelActive');
end
if isempty(reference)
    reference = DAStudio.message('FixedPoint:fixedPointTool:labelReference');
end
if run > 1
    %initialize the array
    additional_run(1:run-2) = {''};
    for i = 2:run 
        additional_run{i-1} = sprintf('%s %d',DAStudio.message('FixedPoint:fixedPointTool:labelRun'),run);
    end
    runs = {active, reference,additional_run{1:end}};
else
    runs = {active, reference};
end
% return the string for the run.
str = runs{run+1};

% [EOF]
