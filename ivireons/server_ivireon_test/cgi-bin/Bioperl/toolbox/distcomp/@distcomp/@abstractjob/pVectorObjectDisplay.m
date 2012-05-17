function pVectorObjectDisplay(jobs)
; %#ok Undocumented
%pDefaultVectorObjDisplay - display for vector output

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.5 $  $Date: 2010/04/21 21:13:53 $

% Allows user configuration of end of output spacing
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

desc(1) = iCreateCol('Job ID',     @(o)num2str(o.ID),            6, false);
desc(2) = iCreateCol('State',      @(o)o.State,                 11, false);
desc(3) = iCreateCol('FinishTime', @iTimeHelper,                15, false);
desc(4) = iCreateCol('UserName',   @(o)char(o.UserName),         8,  true);
desc(5) = iCreateCol('#tasks',     @(o)num2str(numel(o.Tasks)),  6, false);

title = parallel.internal.createDimensionDisplayString(jobs, 'Jobs');
disp(parallel.internal.createVectorObjectDisplayTable(jobs, desc, title));

if LOOSE
    disp(' ');
end
end


function col = iCreateCol(title, func, width, adjust)
col = struct('title', title, 'function', func, ...
             'width', width, 'adjust', adjust);
end

function timeStr = iTimeHelper(obj)
time = char(obj.FinishTime);
if isempty(time)
    timeStr = '-';
else
    timeStr = time(5:end-9);
end
end