function pVectorObjectDisplay(tasks)
; %#ok Undocumented
% pDefaultVectorObjDisplay - display override for vectors of Tasks

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.9 $  $Date: 2010/04/21 21:13:55 $

LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

desc(1) = iCreateCol('Task ID',       @(o)num2str(o.ID),  7, false);
desc(2) = iCreateCol('State',         @(o)o.State,       11, false);
desc(3) = iCreateCol('FinishTime',    @iTimeHelper,      15, false);
desc(4) = iCreateCol('Function Name', @iFunctionHelper,  15,  true);
desc(5) = iCreateCol('Error',         @iErrorHelper,      6, false);

title = parallel.internal.createDimensionDisplayString(tasks, 'Tasks');
disp(parallel.internal.createVectorObjectDisplayTable(tasks, desc, title));

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

function taskFunctionName = iFunctionHelper(obj)
taskFunctionName = obj.Function;
if ~isempty(taskFunctionName) && ~ischar(taskFunctionName)
    taskFunctionName = func2str(taskFunctionName);
    % Add a @ if the function name isn't an inline function which
    % already has the @.
    if ~isempty(taskFunctionName) && taskFunctionName(1) ~= '@'
        taskFunctionName = ['@' taskFunctionName];
    end
end
end

function errorStr = iErrorHelper(obj)
if ~isempty(obj.ErrorMessage) || ~isempty(obj.ErrorIdentifier)
    errorStr = 'Error';
else
    errorStr = '';
end
end
