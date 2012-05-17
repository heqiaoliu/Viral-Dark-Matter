function pVectorObjectDisplay(jobs)
; %#ok Undocumented
%pDefaultVectorObjDisplay - display for vector output

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:14:05 $

% Allows user configuration of end of output spacing.
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

persistent Strings Values
if isempty(Values)
    types = findtype('distcomp.jobexecutionstate');
    Values = types.Values;
    Strings = types.Strings;
end

desc(1) = iCreateCol('Job ID',     @(o)num2str(o.getNum()),            6, false);
desc(2) = iCreateCol('Type',       @iTypeHelper,                      12, false);
desc(3) = iCreateCol('State',      @(o)Strings{o.getState()==Values}, 10, false);
desc(4) = iCreateCol('FinishTime', @iTimeHelper,                      15, false);
desc(5) = iCreateCol('UserName',   @(o)char(o.getUserName()),          8, false);
desc(6) = iCreateCol('#tasks',     @(o)num2str(numel(o.getTasks())),   6, false);

title = parallel.internal.createDimensionDisplayString(jobs, 'Jobs');
disp(parallel.internal.createVectorObjectDisplayTable(iGetWorkUnitInfos(jobs), desc, title));

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

function typeStr = iTypeHelper(obj)
types = {'distributed', 'parallel', 'matlabpool'};
typeStr = types{obj.getJobMLType()+1};
end