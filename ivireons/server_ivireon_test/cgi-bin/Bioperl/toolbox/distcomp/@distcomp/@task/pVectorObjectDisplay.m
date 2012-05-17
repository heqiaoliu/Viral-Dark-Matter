function pVectorObjectDisplay(tasks)
; %#ok Undocumented
%pDefaultVectorObjDisplay - display for vector output

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.9 $  $Date: 2010/04/21 21:14:07 $

% Allows user configuration of end of output spacing.
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

persistent Strings Values
if isempty(Values)
    types = findtype('distcomp.taskexecutionstate');
    Values = types.Values;
    Strings = types.Strings;
end

desc(1) = iCreateCol('Task ID',       @(o)num2str(o.getNum()),            7, false);
desc(2) = iCreateCol('State',         @(o)Strings{o.getState()==Values}, 11, false);
desc(3) = iCreateCol('FinishTime',    @iTimeHelper,                      15, false);
desc(4) = iCreateCol('Worker',        @iWorkerHelper,                    15,  true);
desc(5) = iCreateCol('Function Name', @iFunctionHelper,                  15,  true);
desc(6) = iCreateCol('Error',         @iErrorHelper,                      6, false);

title = parallel.internal.createDimensionDisplayString(tasks, 'Tasks');
disp(parallel.internal.createVectorObjectDisplayTable(iGetWorkUnitInfos(tasks), desc, title));

if LOOSE
    disp(' ');
end
end


function col = iCreateCol(title, func, width, adjust)
col = struct('title', title, 'function', func, ...
             'width', width, 'adjust', adjust);
end

function workUnitInfos = iGetWorkUnitInfos(workUnits)
% Retrieve the workUnitInfo (with only part of the large data items)
% for all workUnits (one at a time as some of them might fail).
infoCell = cell(numel(workUnits), 1);
for i = 1:numel(workUnits)
    try 
        id = workUnits(i).pReturnUUID;
        %TODO: get WorkUnitInfo without the large data items (or only the MLFunction)
        infos = workUnits(i).pReturnProxyObject.getWorkUnitInfo(id);
        infoCell{i} = infos(1);
    catch err %#ok<NASGU>
    end
end
workUnitInfos = [infoCell{:}];
end

function timeStr = iTimeHelper(obj)
date = obj.getFinishTime();
if date.equals(java.util.Date(-1))
    timeStr = '-';
else
    formatStr = 'MMM dd HH:mm:ss';
    timeStr = java.text.SimpleDateFormat(formatStr).format(date);
end
end

function workerStr = iWorkerHelper(obj)
workerStr = '';
if ~isempty(obj.getWorker())
    workerStr = char(obj.getWorker().getName());
end
end

function funcStr = iFunctionHelper(obj)
funcStr = char(distcompdeserialize(obj.getMLFunction().getData()));
if ~isempty(funcStr) && funcStr(1) ~= '@'
    funcStr = ['@' funcStr];
end
end

function errorStr = iErrorHelper(obj)
if ~isempty(obj.getErrorMessage()) || ~isempty(obj.getErrorIdentifier())
    errorStr = 'Error';
else
    errorStr = '';
end
end
