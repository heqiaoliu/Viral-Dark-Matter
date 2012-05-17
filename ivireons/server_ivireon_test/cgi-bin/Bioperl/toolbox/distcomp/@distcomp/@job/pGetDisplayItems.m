function cellargout = pGetDisplayItems(obj, inStruct)
; %#ok Undocumented
%   Gets the common display structure for a job object. outputs at least
%   ONE display structure with a header as entries in the output cell array.

% Copyright 2006-2009 The MathWorks, Inc.

% $Revision: 1.1.6.4 $    $Date: 2009/12/22 18:51:33 $

cellargout = cell(4, 1);
% initialise number of output arguments
mainStruct = inStruct;
outputDataDependencyStruct = inStruct;
outputTasksStruct = inStruct;
specificStruct = inStruct;

mainStruct.Type = 'job';
objState = obj.State;

if strcmp(objState, 'unavailable') || strcmp(objState, 'destroyed')
    jID = '';
else
    jID = num2str(obj.ID);
end
mainStruct.Header = [iGetJobType(obj) 'Job ID ' jID];
% gets a generic header so that the subclasses can append their own name
% wihout actually overriting pGetDisplayItems. Used for identifying Parallel Jobs.

% gets the running duration as a string
[runningDuration startTime] = distcomp.pGetRunningDuration(obj);

mainStruct.Names = {'UserName', 'AuthorizedUsers', 'State', 'SubmitTime', 'StartTime', 'Running Duration'};
mainStruct.Values = {obj.UserName, obj.AuthorizedUsers, objState, obj.SubmitTime, startTime, runningDuration};

% pDispArgs will truncate these values if very large (>20 cell items and also per line)
outputDataDependencyStruct.Header = 'Data Dependencies';
outputDataDependencyStruct.Names = {'FileDependencies', 'PathDependencies'};
% the values here will be truncated by top level function in pDispArgs
outputDataDependencyStruct.Values = {obj.FileDependencies, obj.PathDependencies};


outputTasksStruct.Header = 'Associated Task(s)';
outputTasksStruct.Names = {'Number Pending ', ...
    'Number Running ', ...
    'Number Finished', ...
    'TaskID of errors'};

try
    [p, r, f] = obj.findTask;
    taskIDWithError = [];
    if ~isempty( f )
        % based on Narfi feedback ErrorMessage could be empty so need to check both fields
        dde = ~cellfun( @isempty, get( f, {'ErrorIdentifier','ErrorMessage'}) );
        didError = or(dde(:,1), dde(:,2));
        taskIDWithErrorCell = get( f( didError ), {'ID'} );
        taskIDWithError = [taskIDWithErrorCell{:}];
    end
    % Length of output list of parameters and values must of the same length
    outputTasksStruct.Values = {length( p ), ...
        length( r ),...
        length( f ),...
        iDisplayNothingIfEmpty(taskIDWithError)};

catch err %#ok<NASGU>
    % DONE - need to display [] here
    outputTasksStruct.Values = {[], ...
        [],...
        [],...
        ''};
end



% ***********************************************************************
% JOBAMANGER SPECIFIC PROPERTIES
specificStruct.Header = 'Jobmanager Dependent Properties';

specificStruct.Names = {'MaximumNumberOfWorkers', ...
    'MinimumNumberOfWorkers',...
    'Timeout', ...
    'RestartWorker'...
    'QueuedFcn', ...
    'RunningFcn', ...
    'FinishedFcn'};
specificStruct.Values = {obj.MaximumNumberOfWorkers, ...
    obj.MinimumNumberOfWorkers,...
    obj.Timeout, ...
    obj.RestartWorker, ...
    iDisplayNothingIfEmpty(obj.QueuedFcn),...
    iDisplayNothingIfEmpty(obj.RunningFcn), ...
    iDisplayNothingIfEmpty(obj.FinishedFcn)};

cellargout{1} = mainStruct;
% all four categories are sent to top level pDefaultSingleObjDisplay
cellargout{2} = outputDataDependencyStruct;
cellargout{3} = outputTasksStruct;
cellargout{4} = specificStruct;
end


%--------------------------------------------------------------------------
% internal helper function returns a empty space if item is empty
%--------------------------------------------------------------------------
function val = iDisplayNothingIfEmpty(val)
% Force the output to an empty string if it is empty
if isempty(val)
    val = '';
end
end


%--------------------------------------------------------------------------
% iGetJobType(obj) returns a string for Parallel/MatlabPool Jobs
%--------------------------------------------------------------------------
function str = iGetJobType(obj)
if isa(obj, 'distcomp.matlabpooljob')
    str = 'MatlabPool ';
elseif isa(obj, 'distcomp.paralleljob')
    str = 'Parallel ';
else
    str = '';
end

end





