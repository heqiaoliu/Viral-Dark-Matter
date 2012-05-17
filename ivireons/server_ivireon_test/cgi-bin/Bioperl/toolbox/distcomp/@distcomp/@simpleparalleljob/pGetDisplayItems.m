function cellargout = pGetDisplayItems(obj,inStruct)
; %#ok undocumented
% gets the common display structure for a job object. outputs at least ONE
% display structure with a header as entries in the output cell array.

% Copyright 2006 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2006/12/27 20:39:45 $

cellargout = cell(4, 1); % initialise number of output arguments
%initialise input structures
mainStruct = inStruct;
dataDependencyStruct = inStruct;
outputTasksStruct = inStruct;
specificStruct = inStruct;

mainStruct.Type = 'paralleljob';
objState = obj.State;
% We dont display ID when ID is invalid 
if strcmp(objState, 'unavailable')
    jID = '';
else
    jID = num2str(obj.ID);
end
mainStruct.Header = ['Parallel Job ID ', jID];

[runningDuration startTime] = distcomp.pGetRunningDuration(obj);

mainStruct.Names = {'UserName', 'State', 'SubmitTime', 'StartTime', 'Running Duration'};
mainStruct.Values = {obj.UserName, objState, obj.SubmitTime, startTime, runningDuration};

% The FileDependencies ( and Path) values are truncated by top level
% pDispArgs. Only 20 lines are currently displayed if they are cell Array.
dataDependencyStruct.Header = 'Data Dependencies';
dataDependencyStruct.Names = {'FileDependencies', 'PathDependencies'};
dataDependencyStruct.Values = {obj.FileDependencies, obj.PathDependencies};

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
        dde = ~cellfun( @isempty, get( f, {'ErrorIdentifier','ErrorMessage'} ) );
        didError = or(dde(:,1), dde(:,2));
        taskIDWithErrorCell = get( f( didError ), {'ID'}  );
        taskIDWithError = [taskIDWithErrorCell{:}];
    end
    % Length of output list of parameters and values must of the same length
    outputTasksStruct.Values = {length( p ), ...
        length( r ),...
        length( f ),...
        iDisplayNothingIfEmpty(taskIDWithError)};
catch
    % DONE - need to display [] here
    outputTasksStruct.Values = {[], ...
        [],...
        [],...
        ''};
end

% THIRD PARTY JOBS SPECIFIC PROPERTIES
%************************************************************************
specificStruct.Header = 'Scheduler Dependent (Parallel Job)';
specificStruct.Names = {'MaximumNumberOfWorkers', 'MinimumNumberOfWorkers'};
specificStruct.Values = {obj.MaximumNumberOfWorkers, obj.MinimumNumberOfWorkers};

% all four categories are sent to top level pSingleObjectDisplay
cellargout{1} = mainStruct;
cellargout{2} = dataDependencyStruct;
cellargout{3} = outputTasksStruct;
cellargout{4} = specificStruct;
end


%--------------------------------------------------------------------------
% internal helper function returns a empty char if item is empty
%--------------------------------------------------------------------------
function val = iDisplayNothingIfEmpty(val)
% Force the output to an empty string if it is empty
if isempty(val)
    val = '';
end
end



