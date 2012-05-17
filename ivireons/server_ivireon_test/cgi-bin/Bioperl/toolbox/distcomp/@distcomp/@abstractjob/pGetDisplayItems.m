function cellargout = pGetDisplayItems(obj, inStruct)
; %#ok Undocumented
% gets the common display structure for a job object. outputs at least ONE
% display structure with a header as entries in the output cell array.

% Copyright 2006 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2007/02/11 05:44:40 $

cellargout = cell(3, 1); % initialise number of output arguments
mainStruct = inStruct;
outputDataDependencyStruct = inStruct;
outputTasksStruct = inStruct;

mainStruct.Type = 'job';
% Note : simpleparalleljobs have their own pGetDisplayItems method.
% We dont display ID when ID is invalid 

objState = obj.State;
if strcmp(objState, 'unavailable') ||  strcmp(objState, 'destroyed')
    jID = '';
else
    jID = num2str(obj.ID);
end
mainStruct.Header = ['Job ID ' jID];

[runningDuration startTime] = distcomp.pGetRunningDuration(obj);
mainStruct.Names = {'UserName', 'State', 'SubmitTime', 'StartTime', 'Running Duration'};
mainStruct.Values = {obj.UserName, objState, obj.SubmitTime, startTime, runningDuration};

outputDataDependencyStruct.Header = 'Data Dependencies';
outputDataDependencyStruct.Names = {'FileDependencies', 'PathDependencies'};
outputDataDependencyStruct.Values = {obj.FileDependencies, obj.PathDependencies};
% DONE renamed variable for finding if error occurs
outputTasksStruct.Header = 'Associated Task(s)';
outputTasksStruct.Names = {'Number Pending ', ...
    'Number Running ', ...
    'Number Finished', ...
    'TaskID of errors'};
% prevent findTask from causing error when job object has become
% unexpectedly unavailable.
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

% all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{1} = mainStruct;
cellargout{2} = outputDataDependencyStruct;
cellargout{3} = outputTasksStruct;

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



%--------------------------------------------------------------------------
% %
%--------------------------------------------------------------------------
% function str = iGetJobType(obj)
%
% if isa(obj, 'distcomp.paralleljob')
%     str = 'Parallel';
% else
%     str = '';
% end
%
% end
