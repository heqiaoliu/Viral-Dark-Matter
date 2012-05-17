function cellargout = pGetDisplayItems(obj, inStruct)
; %#ok Undocumented
% gets the common display structure. outputs a cell arrays of inStructs

% Copyright 2006-2008 The MathWorks, Inc.

% $Revision: 1.1.6.6 $  $Date: 2008/05/19 22:45:23 $

% initialise number of output arguments
cellargout = cell(3, 1);
% initialise output structures based on same format
mainStruct = inStruct;
taskResultStruct = inStruct;
specificStruct = inStruct;

objectState = obj.State;

if strcmp(objectState, 'unavailable') || strcmp(objectState, 'destroyed')
    mainStruct.Header = 'Task ID';
else
    mainStruct.Header = ['Task ID ' num2str(obj.ID) ' from Job ID ' num2str(obj.Parent.ID)];
end

mainStruct.Type = 'task';
mainStruct.Names = {'State', 'Function', 'StartTime', 'Running Duration'};
% startTime is optionally returned to prevent two rmi calls
[runningDuration startTime] = distcomp.pGetRunningDuration(obj);
mainStruct.Values = {objectState, obj.Function, startTime, runningDuration};

% Length of output list of parameters and values must of the same length
% Need to know how long the error message is to define the
% taskResultsStruct
errorID  = obj.ErrorIdentifier;
errorMsg = obj.ErrorMessage;
splitErrorMessage = iGetStringCell(errorMsg);
nerrorlines = numel(splitErrorMessage);

taskResultStruct.Header = 'Task Result Properties';
% preallocate additional store if errormessage is large
taskResultStruct.Names  = cell(nerrorlines+1, 1);
taskResultStruct.Values = cell(nerrorlines+1, 1);
taskResultStruct.Names(1:2) = {'ErrorIdentifier','ErrorMessage'};


taskResultStruct.Values{1}  = errorID;
% errormessage is broken up before it is output
taskResultStruct.Values(2:end) = splitErrorMessage;
errorStruct = obj.Error;
if ~isempty(errorStruct)
    numStackItems = numel(errorStruct.stack);
else
    numStackItems = 0;
end
% ignores first stackFramesToIgnore as they are DCT functions not user code
stackFramesToIgnore = 6;
% only show the Error Stack if there is a error message or
% ErrorIdentifier
if ~isempty(errorMsg) || ~isempty(errorID)
    taskResultStruct.Names{end+1} = 'Error Stack';
    taskResultStruct.Values{end+1} = '';
    startIndex = numel(taskResultStruct.Values)-1;

    % currently (Nov 2006) the default error stack has 6 items relating to dct code which we do not want to output.
    numStackItems = max(0, numStackItems - stackFramesToIgnore);
    % numStackItems returns zero if errorStruct is empty or invalid (see
    % above)
    if numStackItems > 0
        % allocate number of lines required
        taskResultStruct.Names{end+numStackItems-1} = [];
        taskResultStruct.Values{end+numStackItems-1} = [];

        for ii = 1:numStackItems
            thisItem = errorStruct.stack(ii);
            % Get filename from full path
            [c, displayFile] = fileparts(thisItem.file);
            % Is it a subfunction, nested function etc.
            if ~strcmp(displayFile, thisItem.name)
                displayFileItem = [displayFile '>' thisItem.name];
            else
                displayFileItem = [displayFile '.m'];
            end
            taskResultStruct.Values{startIndex+ii} = [displayFileItem ' at ' num2str(thisItem.line)];
        end
    end
end


workername = '';

if ~isempty(obj.Worker)
    workername = obj.Worker.Name;
    nTruncate = 20;
    if numel(workername) < nTruncate
        nTruncate = numel(workername);
        workername = [workername(1:nTruncate) ' on ' obj.Worker.Hostname];
    else
        workername = [workername(1:nTruncate) '.. on ' obj.Worker.Hostname];

    end
end

specificStruct.Header = 'Jobmanager Dependent Properties';
specificStruct.Names = {'Worker Location', 'RunningFcn', 'FinishedFcn', ...
                    'Timeout', 'MaximumNumberOfRetries', 'AttemptedNumberOfRetries'};
specificStruct.Values = {workername, obj.RunningFcn, obj.FinishedFcn, ...
                    obj.Timeout, obj.MaximumNumberOfRetries, ...
                    obj.AttemptedNumberOfRetries};


cellargout{1} = mainStruct;   % all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{2} = taskResultStruct;
cellargout{3} = specificStruct;
end

%--------------------------------------------------------------------------
% internal helper function returns a empty space if item is empty
% and breaks up very long character strings into cell arrays
%--------------------------------------------------------------------------
function y = iGetStringCell(str)  

% Number of characters before a break up ( for wrap around) of error message
% string - because we want the total line to wrap at the command window
% length provided by external mex function
N = iGetTruncationLength();

if isempty(str)
    y = {''};
    return;
end
% break up based on linefeed (returns original if none found)
y = strread(str, '%s', 'delimiter', '\n');

% otherwise if there is no linefeed then break up based on the number of characters
if (numel(y) == 1) && numel(str) > N
    divisible = ceil(numel(str)/N); % guaranteed to be 1 or greater
    y{divisible} = [];%preallocate
    startI = 0;
    for ic = 1:divisible-1
        startI = (ic-1)*N;
        y{ic} = str(startI+1:startI+N);
    end
    y{divisible} = str(startI+N+1:end);  % last bit of item
end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function STR_LEN_THRESH = iGetTruncationLength()
% STR_LEN_THRESH defines the cut off  threshold for truncating string values of properties
% call c mex function to get command window size
STR_LEN_THRESH = 46;
headerSize = 25;
try
    cmdWSize = distcomp.dctCmdWindowSize();
    % make sure cmdWSize is something sensible
    if cmdWSize > (STR_LEN_THRESH + headerSize) && cmdWSize < 5000
        STR_LEN_THRESH = cmdWSize - headerSize;
    end
catch
end
end
