function varargout = dctMpiProfHelpers(actionOrPost, varargin)
;%#ok<NOSEM> undocumented
% cache the vector of profile info objects

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2010/02/25 08:02:11 $


persistent sProfileInfoVector;
% The following variable stores any derived aggregate profile information
% for quicker retrival.
persistent sOverAllProfInfos sCachedAllFunctionNames;
% This string and structure are related to user view options
% and can change during each GUI session
persistent sFunctionName sProfViewOptionData;
% all the above fields EXCEPT sProfViewOptionData are empty by default
% unless action newdata (called from mpiprofview) has been called.

nArgOut = nargout;
% Stores the number of additonal arguments after the action command
nArgIn = nargin - 1;
% Ensure at least empty cell is output when required.
if nArgOut >= 1
    varargout = cell(max(nArgOut, 1), 1);
end

% The implicit assumption when user called mpiprofview is that we are
% dealing with a parallel program to prevent confusion and slow dowm this
% should be false for distributed programs that do not have any
% synchronization and are not SPMD. However it should work even when
% messagedetail is off.
autoGenerateOverAllAggregate = 1; % true;

% inititalise the Options which mpiprofview uses to output some
% customized html reflecting user request
if isempty(sProfViewOptionData)
    % Set the default options then allow user options to persist until reset is
    % called via selection of empty field
    sProfViewOptionData = iGetDefaultProfData();
    hasPerLabFields = iHasPerLabFields(sProfileInfoVector);
end
% Because of incompatibility with win32(WebRenderer as opposed to ICE)
% The htmlpost action and arguments are inserted in one string which we will
% separate here. Applies to all platforms.
if strncmp(actionOrPost, 'htmlpost', 8)
    htmlPostStr = actionOrPost(9:end);
    action = 'htmlpost';
else
    action = actionOrPost;
end

switch(action)
    %----------------------------------------------------------------------
    % Data Acess methods
    %----------------------------------------------------------------------
    case 'getEmptyFunctionTable'
        % Get one empty function table entry
        % Currently used only if plot view has not been selected
        hasPerLabFields = iHasPerLabFields(sProfileInfoVector);
        % Getting an empty entry now needs to know how numlabs s the perlab
        % vector fields are of length numlabs.
        hasMPI = iHasMpiData(sProfileInfoVector);
        varargout{1} = iGetSampleEmptyFunctionTableEntry(hasPerLabFields,...
            hasMPI, numel(sProfileInfoVector));
        return;

    case 'getViewOptions'
        varargout{1} = sProfViewOptionData ;
        return;

    case 'resetDispViewOptions'
        % resets basic view options, used from mpiprofview(0);
        sProfViewOptionData.displayTxtMsg = '';
        sFunctionName = '';
        sProfViewOptionData.plotSelectionStr = '';
        if ~iIsLabIndexAnAggregate(sProfViewOptionData.mainLabInd)
            sProfViewOptionData.labSelectionStr = int2str(sProfViewOptionData.mainLabInd) ;
        end
        if isempty(sProfViewOptionData.compLabInd)
            sProfViewOptionData.compSelectionStr = 'None';
        elseif ~iIsLabIndexAnAggregate(sProfViewOptionData.compLabInd)
                sProfViewOptionData.compSelectionStr = int2str(sProfViewOptionData.compLabInd) ;
        else
            % it is an aggregate, no selection string needs to be set
        end
        varargout{1} = sProfViewOptionData ;
        return;

    case 'getFcnName'
        varargout{1} = sFunctionName;
        return;

    case 'setFcnName' % used by mpiprofview only
        sFunctionName = varargin{1};
        return;

        % two part get specifying individual item(s) that need to be
        % obtained
    case 'get'
        if nArgIn < 1
            error('distcomp:mpiprofview:InvalidInputArgs',...
                'a %s GET requires at least 1 additional argument. One argument must specify the item description (maxaggregate or labno)', ...
                inputname);
        elseif nArgIn >= 1 && ~isempty(sProfileInfoVector)
            varargout{1} = nGetThisProfileInfo(varargin{:});
        else % get an get all currently the same
            error('distcomp:mpiprofview:InvalidInputArgs',...
                'Error:  Bad internal state in mpiprofview, please run mpiprofile viewer');
        end
        % always return and dont process further if we have a get command
        return;

    case 'getProfInfoFromAggregate'
        % called before mpiprofvciew starts makefilepage
        aggregateInfo = varargin{1};
        isComparison = varargin{2};
        % This may slow down operation but its necessary to reduce
        % complexity of the logic
        if ~sProfViewOptionData.allLabsHaveAllFunctions
            nEnsureAllLabsHaveAllFunctions();
        end

        if isstruct(aggregateInfo) && ~isempty(sFunctionName)
            fnames = {aggregateInfo.FunctionTable.FunctionName};

            findex = strcmp(sFunctionName, fnames);
            thisLabno = aggregateInfo.FcnTableLabIndex(findex);
            singleProfInfo =  nGetProfileInfoForLab(thisLabno);
            % return the function index for the single profiler info
            fnames = {singleProfInfo.FunctionTable.FunctionName};
            findex = strcmp(sFunctionName, fnames);
            sProfViewOptionData.selectBy = 'labno';
            if isComparison
                % forces comparison to be empty if its empty.
                sProfViewOptionData.compLabInd = thisLabno;
            else
                sProfViewOptionData.mainLabInd = thisLabno;
            end


            varargout{1} = singleProfInfo;
            varargout{2} = find(findex);
        else
            error('distcomp:mpiprofview:AggregateError',...
                ['Cannot find the aggregate information selected.\n'...
                'If the error persists please contact MathWorks.\n'...
                'See also Parallel Computing Toolbox documentation.%s'], '');
        end
        return;
        %------------------------------------------------------------------
        % End Data Acess methods
        %------------------------------------------------------------------

    case 'newdata'
        % This option must be called at least once to start a new view session.
        % Can error here generically since this is called from
        % mpiprofview.
        error(nargchk(3, 3, nArgIn, 'struct'));
        nDealWithNewProfileInfos(varargin{:});


    case 'generatePlot' %CHK remove once tests done
        % only used for test infrastructure
        if ~sProfViewOptionData.allLabsHaveAllFunctions
            nEnsureAllLabsHaveAllFunctions();
        end

        newlabStruct = struct('SelectionStr', 1, 'CurFcnName', [], 'CurLab', 1, 'CurFunIndex',[], 'Type', 'Plot');
        newlabStruct.CurFcnName = varargin{1};
        if nArgIn > 1
            sel = varargin{2};
        else
            sel = 0;
        end
        switch(sel)
            case 0
                newlabStruct.SelectionStr = 'Plot PerLab Communication';
            case 1
                newlabStruct.SelectionStr = 'Plot TotalTime Histogram';
            case 2
                newlabStruct.SelectionStr = 'Plot CommTimePerLab';
            otherwise
                newlabStruct.SelectionStr = 'Plot PerLab Communication';
        end


        [sProfViewOptionData sFunctionName ] = iGetViewerOptionData(newlabStruct, sProfileInfoVector, sProfViewOptionData);

    case 'htmlpost'
        % htmlPostStr  is now defined at the top when it is separated
        % from the combined actionandPost string
        if isempty(sProfileInfoVector) || ~ischar(htmlPostStr)
            error('distcomp:mpiprofview:EmptyProfileInfoVector',...
                ['Profile info structure is empty or htmlpost is not working. '...
                'Please run MPIPROFILE VIEWER again. If this error persists, '...
                'please contact MathWorks.']);
        else
            postStruct = iParseHTMLPost(htmlPostStr);
            
            % CHK The html posts for functionname with strange characters
            % ('>') do not work correctly with get.  However, the function 
            % index should be accurate, so we'll work out the function name
            % from the index instead of relying on the function name.
            funIndex = str2double(postStruct.CurFunIndex);
            curLab = str2double(postStruct.CurLab);
            postStruct.CurFcnName = nGetFunctionNameFromIndex(funIndex, curLab);
            % If we have selected a Plot view (rather than a lab no)
            % ensure all labs have entries for all functions
            % so that BytesPerLab etc all return a matrix of size
            % numberOfLabs.
            if ~sProfViewOptionData.allLabsHaveAllFunctions && strcmp('Plot', postStruct.Type )
                nEnsureAllLabsHaveAllFunctions();
            end
            [sProfViewOptionData sFunctionName ] = iGetViewerOptionData(postStruct, sProfileInfoVector, sProfViewOptionData);
        end

    case {'changelab', 'changeFcn'}
        % can change lab and or function
        % Here we have 2 input args : This is called if we want to just switch the
        % labno or both the lab no and function Currently called by java
        % combobox and also html callbacks in mpiprofview/makesummarypage
        % through pChangeLab
        error(nargchk(1, 2, nArgIn, 'struct'));
        if isempty(sProfileInfoVector)
            error('distcomp:mpiprofview:EmptyProfileVector', 'Error mpiprofview Profile Info is empty. Please run MPIPROFVIEW or MPIPROFILE VIEWER again.');
        end
        nChangeLabFunction(varargin{:});


    otherwise
        % users should not be calling this function under normal circumstances
        iDisplayActionErrorMessage(action);

end % end switch

% Get the fields we need to use more than once from structure
mainLabIndex = sProfViewOptionData.mainLabInd;
% currently only one comparison lab index is supported
comparisonLabIndexes = sProfViewOptionData.compLabInd;
nworker = sProfViewOptionData.numberOfLabs;
% Main lab can only be max aggregate
if iIsLabIndexAnAggregate(mainLabIndex)
    currentProfInfo = nGetThisProfileInfo( 'maxAggregate' );
    sProfViewOptionData.labSelectionStr = 'maxAggregate';
elseif mainLabIndex <= nworker
    % LabNo for short is the same as labIndex
    sProfileInfoVector(mainLabIndex).LabNo = mainLabIndex;
    currentProfInfo = sProfileInfoVector(mainLabIndex);
else
    error('distcomp:mpiprofview:InvalidArgument', 'Chosen labindex is greater than the number of ProfileInfo objects.');
end

functionIndex = iGetIndexOfFunctionName(currentProfInfo, sFunctionName);

% If function Name cannot be found in the new lab
% this creates empty entry to be displayed by mpiprofview
if isempty(functionIndex)
    % This section will not get executed if
    % nEnsureAllLabsHaveAllFunctions() has been called. Allows labindex
    % to be changed when the new lab does not execute the current
    % function.
    if strcmp(action, 'htmlpost') && ~isempty(sFunctionName)
        % create an empty function table entry and return its index
        % get the prevous function table and source
        if ~sProfViewOptionData.allLabsHaveAllFunctions
            nEnsureAllLabsHaveAllFunctions();
            currentProfInfo = sProfileInfoVector(mainLabIndex);
            functionIndex = iGetIndexOfFunctionName(currentProfInfo, sFunctionName);

        else
            % something went wrong
            error('distcomp:mpiprofview:CouldNotEnsureAllFunctions', 'Could not insert all functions in the profile info array.');
        end
    else
        functionIndex = 0;
    end
end
% if the comparison lab is not be removed and is valid
if iIsValidLabIndex(comparisonLabIndexes, nworker)
    % insert the correct labNo value
    sProfileInfoVector(comparisonLabIndexes).LabNo = comparisonLabIndexes;
end

if nArgOut == 1
    varargout{1} = mpiprofview(functionIndex(1), currentProfInfo , sProfViewOptionData);
else
    mpiprofview(functionIndex(1), currentProfInfo , sProfViewOptionData);
end
% *************************************************************************
%%%%-----------------------------------------------------------------------
% Deal with new profile info
%%%%-----------------------------------------------------------------------
    function nDealWithNewProfileInfos(funcNameOrIndex, mainLabIndex, profInfoV)
    % Gets all the unique function names and the table with the
    % associated max time per function and min time per function in
    % parallel machine.

    if ~( iIsScalarInt(mainLabIndex) && mainLabIndex <= numel(profInfoV) )
        error('distcomp:mpiprofview:NewData',...
            'The initial lab index selected must be a valid integer less than or equal to numlabs. See documentation fo MPIPROFILE.');
    end
    % creates a new temp directory (deletes old one if already created)
    dctProfTempDataManager('newTempDir');
    % reset persistent data
    sProfViewOptionData = iResetMpiProfview;
    sOverAllProfInfos = [];
    sFunctionName = [];
    % root is not being removed because it is needed for total
    % communication field calculation.
    profInfoV = arrayfun(@(x)iFindAndInsertRootIndex(x), profInfoV);
    sProfileInfoVector = profInfoV;

    if autoGenerateOverAllAggregate && iHasMpiData(profInfoV)
        % Generates aggregate info like max, min aggregate.
        % Also returns the names of all functions called in this parallel program
        [sOverAllProfInfos sCachedAllFunctionNames] = iGenerateAggregateMaxMinTimeProfInfos(sProfileInfoVector);
    end
    % store the number of labs available in the option structure
    sProfViewOptionData.numberOfLabs = numel(sProfileInfoVector);
    % com.mathworks.mde.profiler.Profiler.setNumLabsParallel(numel(sProfileInfoVector), mainLabIndex);
    sFunctionName = nGetFunctionNameFromIndex(funcNameOrIndex, mainLabIndex);

    end

%%%%-----------------------------------------------------------------------
%%%%-----------------------------------------------------------------------
    function functionName = nGetFunctionNameFromIndex(funcNameOrIndex, mainLabIndex)
    % default output for idx = 0 is empty function name

    if iIsString(funcNameOrIndex)
        functionName = funcNameOrIndex;
    elseif iIsScalarInt(funcNameOrIndex)
        % it is numeric so get the function name
        if iIsLabIndexAnAggregate(mainLabIndex)
            labDes = iGetLabDescription(mainLabIndex);
            aggregateInfo = nGetThisProfileInfo(labDes);
            functionName = aggregateInfo.FunctionTable(funcNameOrIndex).FunctionName;
        elseif funcNameOrIndex > 0 && mainLabIndex > 0
            functionName = sProfileInfoVector(mainLabIndex).FunctionTable(funcNameOrIndex).FunctionName;
        else % it must be zero
            functionName = '';
        end
    else % error
        error('distcomp:mpiprofview:InvalidFcnNameOrIndex',...
            'The function name or index must be valid (a string or integer less than or equal to numlabs). See documentation for MPIPROFVIEW.');
    end
    end

%%%%-----------------------------------------------------------------------
% function retInfo = nGetThisProfileInfo(profInfoType, labno)
%%%%-----------------------------------------------------------------------
    function retInfo = nGetThisProfileInfo(profInfoType, labno)

    switch profInfoType

        case 'labno'
            if ~iIsLabIndexAnAggregate(labno) && nargin == 2
                retInfo = nGetProfileInfoForLab(labno);
            else
                error('distcomp:mpiprofview:InvalidGetInput',...
                    'mpiprofview ''get labno'' action with invalid lab index. Selected lab index must be a valid integer.');
            end

        case 'allfcnnames'
            retInfo = sCachedAllFunctionNames;

        case 'all'
            retInfo = sProfileInfoVector;
            % get all profile information including aggregate
        case 'viewOptions'
            retInfo = sProfViewOptionData;

        case 'maxAggregate'
            % generate the aggregate information if need be
            if isempty(sOverAllProfInfos)
                [sOverAllProfInfos sCachedAllFunctionNames] = ...
                    iGenerateAggregateMaxMinTimeProfInfos(sProfileInfoVector);
            end
            retInfo = sOverAllProfInfos(1);
            % min executed Aggregate is min time > 0.
        case 'min Executed Aggregate'
            if isempty(sOverAllProfInfos)
                [sOverAllProfInfos sCachedAllFunctionNames] = ...
                    iGenerateAggregateMaxMinTimeProfInfos(sProfileInfoVector);
            end
            retInfo = sOverAllProfInfos(2);

        case 'maxTotalTime'
            labno = iGetLabNoAndFieldVector(@max, 'TotalTime', sProfileInfoVector, sFunctionName);
            retInfo = nGetProfileInfoForLab(labno);

        case 'minTotalTime'
            labno = iGetLabNoAndFieldVector(@min, 'TotalTime', sProfileInfoVector, sFunctionName);
            retInfo = nGetProfileInfoForLab(labno);

        otherwise
            error('distcomp:mpiprofview:InvalidGetInput', 'Error: pCallBackHelpers get . Invalid lab selection type %s', profInfoType);

    end
    end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
    function profinfo = nGetProfileInfoForLab(labno)
    sProfileInfoVector(labno).LabNo = labno;
    profinfo = sProfileInfoVector(labno);
    end

%%%%-----------------------------------------------------------------------
% Ensures all profInfo.FunctionTable entries for all labs have at least an
% empty entry for every function called in the SPMD program. See iGenerateAggregate....
% This function cannot be called before the persistent
% sCachedAllFunctionNames and sOverAllProfInfos are stored.
%%%%-----------------------------------------------------------------------
    function nEnsureAllLabsHaveAllFunctions()
    if isempty(sCachedAllFunctionNames)
        error('distcomp:mpiprofview:InvalidInternalState', ' function EnsureAllLabsHaveAllFunctions cannot be called \n%s\n%s\n', ...
            'if aggregate profile info have not been calculated.',...
            'Please report this error to MathWorks.');
    end

    hasPerLabFields = iHasPerLabFields(sProfileInfoVector);
    hasMPI = iHasMpiData(sProfileInfoVector);

    % takes data from max aggregate
    allFcnTable = sOverAllProfInfos(1).FunctionTable;

    for i=1:numel(sProfileInfoVector)
        fcnNames = { sProfileInfoVector(i).FunctionTable.FunctionName};
        memberIndex = ismember(sCachedAllFunctionNames, fcnNames);
        fcnNamesAdded = sCachedAllFunctionNames(~memberIndex);
        if ~isempty(fcnNamesAdded)
            sProfileInfoVector(i).FunctionTable(end+1:end+numel(fcnNamesAdded)) = iGetEmptyFunctionTables(allFcnTable(~memberIndex), ...
                hasPerLabFields, hasMPI, numel(sProfileInfoVector));
        end
    end
    % change the state so that we do not subsequently call this function
    sProfViewOptionData.allLabsHaveAllFunctions = true;

    end

%%%%-----------------------------------------------------------------------
% Handles changeLab action
% Change the current lab and function name
%%%%-----------------------------------------------------------------------
    function nChangeLabFunction(funcNameOrIndex, labIndexOrStr)
    % if we have a valid function name or index then change the
    % current function. This function is not user visible so no need to
    % test for iIsString.
    if nargin == 1
        nUpdateLabIndexFromJavaProfiler();
        labIndexOrStr = sProfViewOptionData.mainLabInd;

    elseif nargin == 0
        % We might get invalid post because of different html components on
        % different platforms.
        error('distcomp:mpiprofview:ChangeLabFunction',...
            'Invalid arguments to change lab function. Please contact MathWorks with reproduction steps.');
    end

    isLabIndexAString = iIsString(labIndexOrStr);
    % the labno can be greater than the numberOfLabs
    % when we use the java listbox which
    % returns a char index value.
    if  isLabIndexAString && strcmp(labIndexOrStr, int2str(sProfViewOptionData.numberOfLabs + 1))
        sProfViewOptionData.displayTxtMsg = 'max Time Aggregate / Function';
        labIndexOrStr = int2str(iGetDefaultAggregateIndex());
    end

    newlabStruct = struct('SelectionStr', '1', 'CurFcnName', cell(1,1), 'CurLab', 1, 'CurFunIndex', [], 'Type', 'Main');
    if ~isLabIndexAString
        sFunctionName = nGetFunctionNameFromIndex(funcNameOrIndex, labIndexOrStr);
        % update the selection strings
        % this is necessary to keep correct state when user presses the
        % back button
        newlabStruct.SelectionStr = iGetLabDescription(labIndexOrStr);
        % forces comparison to be empty if its empty.
        newlabStruct.CompSelectionStr = iGetLabDescription(sProfViewOptionData.compLabInd);
        newlabStruct.Type = 'AutoSelectComparison';
    else
        % sFunctionName = Not needed
        % only java inputs a string lab and does not need to update the
        % function name
        newlabStruct.SelectionStr = labIndexOrStr;
    end
    newlabStruct.CurFcnName = sFunctionName;

    sProfViewOptionData = iGetViewerOptionData(newlabStruct, sProfileInfoVector, sProfViewOptionData);
    end


%%%%-----------------------------------------------------------------------
%%%%-----------------------------------------------------------------------
    function nUpdateLabIndexFromJavaProfiler
    % get the current labindexes displayed from the html title parse in
    % Java
    labIndexList = com.mathworks.mde.profiler.Profiler.getSelectedLabsFromHtml();

    labIndexList(labIndexList == 0) = [];
    if ~isempty(labIndexList)
        % converts negative to matlab NaN
        sProfViewOptionData.mainLabInd = labIndexList(1);
        sProfViewOptionData.compLabInd = labIndexList(2:end);
    end
    end
end
%--------------------------------------------------------------------------
% function iGetSampleEmptyFunctionTableEntry( hasPerLab, hasMPI, nworker )
%--------------------------------------------------------------------------
function emptyFT = iGetSampleEmptyFunctionTableEntry(hasPerLab, hasMPI, nworker)

% Sub-field definitions
children = struct(...
    'Index',    cell(0,1),...
    'NumCalls',      0,...
    'TotalTime',     0,...
    'BytesSent',     0,...
    'BytesReceived', 0,...
    'TimeWasted',    0,...
    'CommTime',      0 );
parents = struct(...
    'Index',    {},...
    'NumCalls', 0 );

% This is the basic profile function table structure. All FunctionTable
% structures have these fields in this order. We add other fields to the
% end if we need them.
basicStructDefn = {...
    'CompleteName',  cell(1,1),...
    'FunctionName',  '',...
    'FileName',      '',...
    'Type',          'M-not-executed',...
    'Children',      children,...
    'Parents',       parents,...
    'ExecutedLines', ones(0,7),...
    'IsRecursive',   0,...
    'TotalRecursiveTime', 0,...
    'PartialData',   0,...
    'NumCalls',      0,...
    'TotalTime',     0};
% The MPI fields
hasMPIExtraFields = {...
    'BytesSent',     0,...
    'BytesReceived', 0,...
    'TimeWasted',    0,...
    'CommTime',      0};
% The per lab fields
perLabExtraFields = {...
    'BytesReceivedPerLab', zeros(1,nworker),...
    'TimeWastedPerLab',    zeros(1,nworker),...
    'CommTimePerLab',      zeros(1,nworker)};

if hasPerLab
    emptyFT = struct( basicStructDefn{:}, hasMPIExtraFields{:}, perLabExtraFields{:} );
elseif hasMPI
    emptyFT = struct( basicStructDefn{:}, hasMPIExtraFields{:} );
else
    emptyFT = struct( basicStructDefn{:} );
end
end

%--------------------------------------------------------------------------
% iGetDefaultProfData
%--------------------------------------------------------------------------
function sProfViewOptionData = iGetDefaultProfData()
% allLabsHaveALlfunctions initially false. Used to identify that a call has
% been made to nEnsureAllLabsHaveAllFunctions() once per session.
% initially it is not guaranteed that every function has an entry on
% every lab. see nEnsureAllLabsHaveAllFunctions().
% Field reset and savedImageFiles only exists to prevent the need for additonal argument to
% mpiprofview. They do not need to persist.
sProfViewOptionData = struct(   'reset',false,...
    'numberOfLabs', 1,...
    'allLabsHaveAllFunctions', false, ...
    'selectBy', 'labno',...
    'mainLabInd', 1,...
    'compLabInd', [],...
    'displayTxtMsg','',...
    'labSelectionStr', '1',...
    'compSelectionStr', 'None',...
    'plotSelectionStr', '',...
    'savedImageFiles',cell(1,1));
% Note: cell values need to be set separately
% as cells in struct specify the size of the struct array.
sProfViewOptionData.savedImageFiles = {};
end

%--------------------------------------------------------------------------
% function iGetEmptyFunctionTable( funcTableEntries
%--------------------------------------------------------------------------
function eft = iGetEmptyFunctionTables( funcTableEntries, hasPerLabFields, hasMPI, nworker)

emptyFT = iGetSampleEmptyFunctionTableEntry(hasPerLabFields, hasMPI, nworker);

if isempty(funcTableEntries)
    eft(1) = emptyFT;
    return;
else
    eft(numel(funcTableEntries)) = emptyFT;

    for i = 1: numel(funcTableEntries)
        % copy the function name and related fields to new empty version of
        % that function's FunctionTable entry.
        eft(i) = emptyFT;
        eft(i).CompleteName = funcTableEntries(i).CompleteName;
        eft(i).FunctionName = funcTableEntries(i).FunctionName;
        eft(i).FileName = funcTableEntries(i).FileName;
%         eft(i).ExecutedLines = zeros(size(funcTableEntries(i).ExecutedLines));
%         % ensure the line numbers are the same in the executed lines field.
%         if ~isempty(eft.ExecutedLines)
%             eft(1).ExecutedLines(:,1) = funcTableEntries(i).ExecutedLines(:,1);
%         end

    end
    eft = eft.';
end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function functionIndex = iGetIndexOfFunctionName(profInfo, sFunctionName)

if isempty(sFunctionName)
    functionIndex = 0;
else
    funcNames = {profInfo.FunctionTable.FunctionName};
    logicalFunIndex = strcmp(sFunctionName, funcNames);
    indexvalue = 1:numel(logicalFunIndex);
    % shows empty page if function Name cannot be found
    functionIndex = indexvalue(logicalFunIndex);
end
end

%--------------------------------------------------------------------------
%------------------------------------------------------------------------
function savedFileName = iGetFullImageFileName(imageName, functionName, fieldName)
profilertempdir = dctProfTempDataManager( 'getTempDir' );
a = java.lang.String(functionName);
fcnhash = a.hashCode();
% hashed functionName
functionName = sprintf('%d%08x', sign(fcnhash)+1, abs(fcnhash) );
savedFileName = [profilertempdir imageName fieldName functionName '.png'];
end

%--------------------------------------------------------------------------
% Gets the labno with the user specified statistic on total time
% by default this is the lab with max value .
%--------------------------------------------------------------------------
function [savedFileName labno] = iSaveHistPlotForAllTimes(profInfoVector, thisFunctionName, plotoption)
% The valid form of the plotoption structure is
% plotoption = struct('Type', 'hist', 'FieldName', 'TotalTime');
curFig = dctProfTempDataManager('getEmptyFig');
mAxis = gca(curFig);
fieldName = plotoption.FieldName;
savedFileName = iGetFullImageFileName('histOfMax', thisFunctionName, fieldName);

% Checks to see if this image has been already created
if exist(savedFileName,'file') == 2
    labno  = 1;
    % images are already generate so we do not need to generate anything
    return;
end

[labno ~, allTimes] = iGetLabNoAndFieldVector(@max, fieldName, profInfoVector, thisFunctionName);
hist(allTimes, 'Parent', mAxis);

xlabel(mAxis, [iGetDisplayNameOfField(fieldName) ' (seconds)  ' ], 'Interpreter', 'None');
ylabel(mAxis, 'Number labs (cumulative)', 'Interpreter', 'None');
nworker = numel(profInfoVector);
% change the axis tick to show correctly
set(mAxis, 'ytick', ((1:nworker)'));
% set the title correctly
if isempty(thisFunctionName)
    title(mAxis, sprintf('Max %s for all functions', iGetDisplayNameOfField(fieldName)), 'Interpreter', 'None' );
else
    title(mAxis, sprintf('%s for \nfunction %s', iGetDisplayNameOfField(fieldName), thisFunctionName), 'Interpreter', 'None' );
end

switch plotoption.Type
    % only one option exists currently and that is to change the color to red through colormap
    case 'histred'
        set(curFig,'Colormap',flag(64));
end

set(mAxis,...
    'Position', [0.15 0.15 0.65 0.70], ...
    'PlotBoxAspectRatio',[1 1 1],...
    'DataAspectRatioMode','auto');
% Axis tight is more complex and so we call into the MATLAB function
% as its not a setable property.
axis(mAxis, 'tight');

iPrintToFile(curFig, savedFileName, '125');
set(curFig,'Colormap','default');
end


%--------------------------------------------------------------------------
% This is the only function that plots and saves vector communication fields
% (CommTimePerLab etc).
%--------------------------------------------------------------------------
function [savedFileName labno] = iSaveInterlabCommDiag(profInfoVector, thisFunctionName, plotoption)
%     This is the expected form of plotoption = struct('Type', 'bar3',
%     'FieldName', 'BytesReceivedPerLab')

% initialise the lab no to return to after plot
labno = 1;
perLabFieldName = plotoption.FieldName;
basicFileNameString = [perLabFieldName plotoption.Type];

% generate the unique image file name and check to see if it is already
% created.
savedFileName = iGetFullImageFileName(basicFileNameString, thisFunctionName, '');
if exist(savedFileName,'file') == 2
    labno  = 1;
    % images are already generate so we do not need to generate anything
    return;
end

% get the current figure from temp file manager.
curFig = dctProfTempDataManager('getEmptyFig');
% Hist doesn't display each value that is Nan and if we want to display just
% one bar on same graph this is the easier way.
mAxis = gca(curFig);
% the default labels for the x y axis
ylabelString = 'destination lab index';
xlabelString = 'source lab index';
nworker = numel(profInfoVector);

switch(plotoption.Type)

        case 'imagedefault'
        commDataMatrixPerFunction = iGetCommDataPerLab(profInfoVector, perLabFieldName, thisFunctionName );
        if ~isempty(thisFunctionName)
            explanationStr = ['for function ' thisFunctionName];
        else
            explanationStr = 'for all functions';
        end
        imagesc(commDataMatrixPerFunction,'Parent', mAxis);
        % Same as axis square
        set(mAxis,...
            'Position', [0.1 0.1 0.65 0.75], ...
            'PlotBoxAspectRatio',[1 1 1],...
            'DataAspectRatioMode','auto');
        % Axis tight is more complex and so we call into the MATLAB function
        % as its not a setable property.
        axis(mAxis, 'tight');
        colorbarAxis = colorbar('peer', mAxis);
        if strcmp(perLabFieldName, 'BytesReceivedPerLab')
            maxvalue = max(commDataMatrixPerFunction(:));
            maxunits = toKb(maxvalue);

        else
            maxvalue = max(commDataMatrixPerFunction(:));
            maxunits = sprintf('%4.2fs', maxvalue);
        end
        text(1.4, 0.95,  sprintf('%12s\n%12s', maxunits, '(max)'), 'Units', 'norm',...
            'Color', [0.9 0.2 0], 'Parent', colorbarAxis);
        set(mAxis, 'xtick', ((1:nworker)'));
        set(mAxis, 'ytick', ((1:nworker)'));

    case 'imagetotal'
        [~, totalCommDataPerLab] = iGetCommDataPerLab(profInfoVector, perLabFieldName, thisFunctionName );

        imagesc(totalCommDataPerLab, 'Parent', mAxis);
        set(mAxis, 'xtick', ((1:nworker)'));
        set(mAxis, 'ytick', ((1:nworker)'));
        set(curFig,'Colormap', summer(64));
        hold(mAxis,'on');
        colorbarAxis = colorbar('peer', mAxis);
        % text relative to above axis
        text(1.1,0.95,[num2str(max(totalCommDataPerLab(:))) ' max val'], 'Units', 'norm', 'Parent', colorbarAxis);
        hold(mAxis,'off');
        explanationStr = '(for all fcns)';


    otherwise
        error('distcomp:mpiprofview:UnknownPlotOption',...
            'Invalid plot type ''%s''.', plotoption.Type);
end

xlabel(mAxis, xlabelString, 'Interpreter', 'None');
ylabel(mAxis, ylabelString, 'Interpreter', 'None');

titleStr = sprintf('All Labs %s\n %s', iGetDisplayNameOfField(perLabFieldName), explanationStr);
title(mAxis, titleStr, 'Interpreter', 'None');

% Adjust the image resolution based on number of workers
if nworker > 31
    dpiRes = '175';
elseif nworker > 8
    dpiRes = '150';
elseif nworker > 2
    dpiRes = '125';
else
    dpiRes = '100';
end

iPrintToFile(curFig, savedFileName, dpiRes);
set(curFig,'Colormap','default');

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function str = iGetDisplayNameOfField(fieldName)

switch(fieldName)
    case 'BytesReceivedPerLab'
        str = 'Data Received Per Lab';
    case 'CommTimePerLab'
        str = 'Receive Comm Time Per Lab';
    case 'TimeWastedPerLab'
        str = 'Comm Waiting Time Per Lab';
    case 'TotalTime'
        str = 'Total Time';
    case 'TimeWasted'
        str = 'Comm Waiting Time';
    case 'CommTime'
        str = 'Comm Time (Waiting + Active)';

    otherwise
        str = error('distcomp:mpiprofview:InvalidFieldName', 'Not a valid fieldname');
end
end
%--------------------------------------------------------------------------
% Simplified function from mpiprofview
%--------------------------------------------------------------------------
function x = toKb(y)
values = {1 1024 1024 1024 1024 };

suffixes = { 'b' 'Kb' 'Mb' 'Gb' 'Tb' };

suff = suffixes{1};

for i = 1:length(values)
    if abs(y) >= values{i}
        suff = suffixes{i};
        y = y ./ values{i};
    else
        break;
    end
end

if strcmp(suff, suffixes{1})
    fmt = '%4.0f';
else
    fmt = '%4.2f';
end
x = sprintf([fmt suff], y);
end
%--------------------------------------------------------------------------
% This is the default method of generating images
%--------------------------------------------------------------------------
function iPrintToFile(curFig, savedFileName, dpiRes)
set(curFig, 'PaperPositionMode', 'auto');
print(curFig, '-dpng', ['-r' dpiRes], savedFileName);

end

%--------------------------------------------------------------------------
% This should be the default access function for iGetLabNoWithTotalTime
%--------------------------------------------------------------------------
function labno = iGetLabIndexWithTimeField(profInfoVector, selectedString, thisFunctionName)

switch(selectedString)
    case 'max TotalTime'
        labno = iGetLabNoAndFieldVector(@max, 'TotalTime', profInfoVector, thisFunctionName);
    case 'min TotalTime'
        labno = iGetLabNoAndFieldVector(@min, 'TotalTime', profInfoVector, thisFunctionName);
    case 'max CommTime'
        labno = iGetLabNoAndFieldVector(@max,'CommTime', profInfoVector, thisFunctionName);
    case 'min CommTime'
        labno = iGetLabNoAndFieldVector(@min, 'CommTime', profInfoVector, thisFunctionName);
    case 'max TimeWasted'
        labno = iGetLabNoAndFieldVector(@max,'TimeWasted', profInfoVector, thisFunctionName);
    case 'min TimeWasted'
        labno = iGetLabNoAndFieldVector(@min, 'TimeWasted', profInfoVector, thisFunctionName);

    otherwise
        % there was an error in the selection String from html post or java
        % source
        error('distcomp:mpiprofview:InvalidHtmlPost',...
            'Error the option %s selected is invalid. Please report this error and your environment to MathWorks.', selectedString);
end
end
%--------------------------------------------------------------------------
% Gets the labno with the user specified statistic(max min or mode at the
% moment) on total time by default this is the lab with max value . The
% statistic can be min max or meadian.
%--------------------------------------------------------------------------
function [maxlabno maxField fieldNameVector]  = iGetLabNoAndFieldVector(statFcn, fieldName, profInfoVector, thisFunctionName)
% usually this is max or min, can be extended with custom functions
% that return 2 arrays like max or min for future releases.
functionTableCell = {profInfoVector.FunctionTable};
if (nargin == 3 || isempty(thisFunctionName))
    % if we do not have root or we are looking for TotalTIme find the
    % function table entry with maxField / lab
    if strcmp(fieldName, 'TotalTime')  || isempty(profInfoVector(1).RootIndex)
        % Total time is a special  case where the root data is not valid
        % and so we have to search all of the function
        fieldNameVector = cellfun(@(x) iGetMaxField(fieldName, x), functionTableCell);
        [maxField maxlabno] = statFcn( fieldNameVector);
    else % use the root index if no functionname is specified

        fieldNameVector = cellfun(@(x, y) x(y).(fieldName), functionTableCell, {profInfoVector.RootIndex});
        [maxField maxlabno] = statFcn( fieldNameVector);
    end

    % if we only want to find the max for a particular function
else
    combinedFunctionTables = cell2mat(functionTableCell');
    fnames = {combinedFunctionTables.FunctionName};
    findex = strcmp(thisFunctionName, fnames);
    combinedFunctionTables = combinedFunctionTables(findex);
    % find the number of functions on each lab so that we can compare the
    % combined function tables
    fieldNameVector = [combinedFunctionTables.(fieldName)];
    [maxField maxIndex] = statFcn( fieldNameVector );
    % The following three lines is needed to make sure the correct lab index is returned
    % Because currently not all labs have a functiontable
    % entry for every function in the SPMD program (i.e. no entry for function where numCalls=0).
    indexRange = find(findex);
    maxIndex = indexRange(maxIndex);
    numFTEntriesPerLab = cellfun(@numel, functionTableCell);
    fTableBorderIndexPerLab = iGetBorderIndex(numFTEntriesPerLab);
    maxlabno = find(fTableBorderIndexPerLab >= maxIndex, 1);
end
end

%--------------------------------------------------------------------------
% Gets (aggregates) interlab communication data into one matrix.
% currently
% BytesReceivedPerLab
% TimeWastedPerLab
% CommTimePerLab
%--------------------------------------------------------------------------
function [commDataMatrixPerFunction totalCommDataMatrix]  = iGetCommDataPerLab(profInfoVector, vectorFieldName, thisFunctionName )
functionTableCell = {profInfoVector.FunctionTable};
fcnGetThisPerLabVector =  @(x) (x.(vectorFieldName));

totalCommDataMatrix = [];
isEmptyFcn = isempty(thisFunctionName);
% Optimisation so that we don't calculate the overall total communication
% matrix (for all functions)
if nargout == 2 || isEmptyFcn
    % Get data from root index if function name is empty or we want total Data.
    % TotalTime is the only field that is ignored in root, because it includes
    % idle time.
    fcnGetTotalPerLabDataVector = @(x, ind) (x(ind).(vectorFieldName));
    totalCommDataMatrix = cell2mat(...
        cellfun(fcnGetTotalPerLabDataVector, functionTableCell,{profInfoVector.RootIndex}, ...
        'UniformOutput', false)'...
        );
    commDataMatrixPerFunction = totalCommDataMatrix;
end
% no need to calculate the commDataMatrix if the function name is empty
if ~isEmptyFcn
    % lookup this field for this function name and return a array of
    % function table entries from all the labs in profInfoVector
    combinedFunctionTables = cell2mat(functionTableCell');
    fnames = {combinedFunctionTables.FunctionName};
    findex = strcmp(thisFunctionName, fnames);
    combinedFunctionTables = combinedFunctionTables(findex);
    % malab does like vectors in arrayfun so requires UniformOutput to be
    % false.
    commDataMatrixPerFunction = cell2mat(arrayfun(fcnGetThisPerLabVector,...
        combinedFunctionTables, 'UniformOutput', false)) ;
end
end


%--------------------------------------------------------------------------
% Gets the labno with the user specified statistic on total time
% by default this is the lab with max value .
% this is not currently accurate because of the way we calculate Total
% CommTIme and TimeWasted in mwmpi.
% %--------------------------------------------------------------------------

% function totalActiveBandwidth  = iGetActiveBandWidth(profInfoVector, thisFunctionName )
% % usually this is max or min, can be extended with custom functions
% % that return 2 arrays like max or min for future releases.
% totalBytesMatrix = iGetCommDataPerLab(profInfoVector, 'BytesReceivedPerLab', thisFunctionName );
% totalCommTimeMatrix = iGetCommDataPerLab(profInfoVector, 'CommTimePerLab', thisFunctionName );
% totalTimeWastedWaitingMatrix = iGetCommDataPerLab(profInfoVector, 'TimeWastedPerLab', thisFunctionName );
% totalActiveBandwidth = totalBytesMatrix./(totalCommTimeMatrix - totalTimeWastedWaitingMatrix);
%
% end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function profileInfo = iFindAndInsertRootIndex(profileInfo)
allFunctionTypes = { profileInfo.FunctionTable.Type };
indexOfRoot = find(strcmp(allFunctionTypes, 'Root'));
profileInfo.RootIndex = indexOfRoot;
% ensure root doesn't show up in max time calculations
% which are used for the inline image bar charts in profview
if ~isempty(indexOfRoot)
    % store the roots total time in case we wish to use it at some point
    profileInfo.TicTocTime = profileInfo.FunctionTable(indexOfRoot).TotalTime;
    profileInfo.FunctionTable(indexOfRoot).TotalTime = 0;

end

end

%--------------------------------------------------------------------------
% iGenerateAggregateMaxMinTimeProfInfos
% returns a vector of profiler info structs each with a functiontable that
% could have a mixture of entries from all labs based on max time and min
% time.
%--------------------------------------------------------------------------
function [aggregateProfInfos fcnNames]  = iGenerateAggregateMaxMinTimeProfInfos(profInfoVector)
% combine the function tables into one function table
combinedFunctionTables = vertcat(profInfoVector.FunctionTable);
rootidx = strcmp('Root', {combinedFunctionTables.Type});
combinedFunctionTables(rootidx) = [];
nworker = numel(profInfoVector);
labIndexList = cell(nworker,1);
for ilabno = 1:nworker
    n = numel(profInfoVector(ilabno).FunctionTable) - any(rootidx);
    labIndexList{ilabno} = ones(n, 1)*ilabno;
end
% concatenate the lablist
labIndexList = cell2mat(labIndexList);
% sort ascending by total time
[~, sortIndex] = sort([combinedFunctionTables.TotalTime]);
% store sorted functiontable
combinedFunctionTables = combinedFunctionTables(sortIndex);
labIndexList = labIndexList(sortIndex);
% unique by default always picks out the last occurrence so in a sorted table it will
% be the ones with the greatest amount of time;
[~, fcnIndex] = unique({combinedFunctionTables.FunctionName}, 'last');
[fcnNames minExecutedFcnIndex] = unique({combinedFunctionTables.FunctionName}, 'first');
maxFcnTable = combinedFunctionTables(fcnIndex);
minExecutedFcnTable = combinedFunctionTables(minExecutedFcnIndex);
maxLabIndex = labIndexList(fcnIndex);
minLabIndex = labIndexList(minExecutedFcnIndex);
% store the max and min fcnTables in an array of profile info objects
AGGREGATE = iGetDefaultAggregateIndex();

i = 1;
aggregateProfInfos(i) = profInfoVector(1);
aggregateProfInfos(i).RootIndex = [];
aggregateProfInfos(i).FunctionTable = maxFcnTable;
aggregateProfInfos(i).FcnTableLabIndex = maxLabIndex;
% for aggregate statistic profile infos the labno is undefined
aggregateProfInfos(i).LabNo = AGGREGATE;

i = i+1;
aggregateProfInfos(i) = aggregateProfInfos(1);
% showing the function with min time and not zero (i.e. fcns that were
% actually executed so NumCalls>0)
aggregateProfInfos(i).FunctionTable = minExecutedFcnTable;
aggregateProfInfos(i).FcnTableLabIndex = minLabIndex;
aggregateProfInfos(i).LabNo = AGGREGATE - 1;

end

%--------------------------------------------------------------------------
% Calculate the cumulative index of array of numbers
%--------------------------------------------------------------------------
function total = iGetMaxField(fieldName, functionTable)
% remove / ignore the rootInd not currently needed since TotalTime is set
% to zero. Comm Fields in root are valid for the whole profiling session.
% functionTable(rootInd) = [];
if ~isempty(functionTable)
    total = max([functionTable.(fieldName)]);
else
    total = 0;
end

end

%--------------------------------------------------------------------------
% Calculate the cumulative index of array of numbers
%--------------------------------------------------------------------------
function numIndex = iGetBorderIndex(numIndex)
% numIndex = zeros(numel(numArray),1);
for k = 2 : numel(numIndex)
    numIndex(k) = numIndex(k) + numIndex(k-1);
end

end

%--------------------------------------------------------------------------
% iResetMpiProfview- Reset the cached internal state of mpiprofview and
% return default profilerdata
%--------------------------------------------------------------------------
function profData = iResetMpiProfview()
% reset the html and create a parallel profiler viewer
% (setHmlTextP creates a Parallel customized instance of
% singleton Profiler following the pattern of setHtmlText in profview).'
%mpiHTML = [ makeheadhtml '<title>1, Reset</title> </html>'];
%com.mathworks.mde.profiler.Profiler.setHtmlTextParallel(mpiHTML);
% com.mathworks.mde.profiler.Profiler.getParallelProfilerP(true);
% call mpi profview with fifth parameter being true;
% because at functional design we decided against using UDD this or a
% nested is the only way of accessing the persistent data in mpiprofview.
profData = iGetDefaultProfData();
% notify profview to reset
profData.reset = true;
mpiprofview([], [], profData);
% turn off reset
profData.reset = false;
end


%--------------------------------------------------------------------------
%strc = iParseHTMLPost( inStr ) generates a matlab structure from html post data
% keeping the original html variable names
%--------------------------------------------------------------------------
function strc = iParseHTMLPost( inStr )
strc = [];
% replace the unique fieldname ending with qxqType with Type. Workaround
% for web browser bug 377435.
inStr = regexprep(inStr, '\w{4}qxqType=', 'Type=');
% replace the initial ? from html post
inStr(1) = '&';
% convert the post data into a matlab structure
match1 = regexp(inStr,'&([^&]*)','tokens');
for n = 1:length(match1)
    match2 = regexp(match1{n}{1},'([^=]*)=([^=]*)','tokens');
    for m = 1:length(match2)
        prop = urldecode(match2{m}{1});
        val  = urldecode(match2{m}{2});
        strc.(prop) = val;
    end
end
end

%--------------------------------------------------------------------------
% function iGetViewerOptionData()
%--------------------------------------------------------------------------
function [profViewOptionData functionName prevlab previndx] = iGetViewerOptionData(postStruct, profileInfoVector, profViewOptionData)
% This function takes the input structure and generates the necessary
% ViewOptions so that mpriprofview can display the current selected view.
% THe input postStruct must be of the form.
% struct ('TYPE','REQUIRED',...
% 'CurFcnName', 'REQUIRED', ...
% 'SelectionStr', 'REQUIRED',...
% 'CurLab','REQUIRED can be null',...
% 'CurFunIndex','REQUIRED can be null', ...
% 'CompSelectionStr', 'OPTIONAL')
% Only SelectionStr and CompSelectionStr can be labIndex or a description of
% the lab (e.g. lab with max TotalTime).

hasMPI = iHasMpiData(profileInfoVector(1));


% ***************DEAL WITH LAB (LIST BOX) DATA********
functionName = postStruct.CurFcnName;
% Check to see where the postdata is coming from
% (currently there is two listboxes and
% autoselection button).
listBoxType = postStruct.Type;

% reset any previously stored images and text associated with this view

% this string is for mpiprofview to be able to show additional
% txt information about each lab (e.g. max, min, problem)
profViewOptionData.displayTxtMsg = '';
profViewOptionData.savedImageFiles = {};
switch(listBoxType)

    case 'Plot'
        selectionString = postStruct.SelectionStr;
        profViewOptionData = nSetOptionsFromPlotListBox(selectionString, profViewOptionData);
        prevlab = 1;
        previndx = 1;
        return;

    case 'AutoSelectComparison'
        % If the labno is a txt string description or number deal with it here
        % If the labno comes from the Profile.java gui everything will be numerical
        selectionString = postStruct.SelectionStr;
        profViewOptionData = nSetOptionsFromLabSelectionListBoxes(selectionString, profViewOptionData, 'Main');
        selectionString =  postStruct.CompSelectionStr;
        % store get and set the options based on the current seconday
        % listbox(s) selection
        profViewOptionData = nSetOptionsFromLabSelectionListBoxes(selectionString, profViewOptionData, 'Comparison');

        if ~isempty(profViewOptionData.compLabInd) && (profViewOptionData.mainLabInd(1) == profViewOptionData.compLabInd(1))
            % if both labs are the same then just select the next lab
            profViewOptionData.compLabInd(1) = mod(profViewOptionData.compLabInd(1), numel(profileInfoVector)) + 1;
        end

    case 'Main'
        selectionString = postStruct.SelectionStr;
        profViewOptionData = nSetOptionsFromLabSelectionListBoxes(selectionString, profViewOptionData, 'Main');

    case 'Comparison'
        selectionString = postStruct.CompSelectionStr;
        profViewOptionData = nSetOptionsFromLabSelectionListBoxes(selectionString, profViewOptionData, listBoxType);

    otherwise
        error('distcomp:mpiprofview:invalidHtmlPostType',...
            'There was an error in the htmlPost Type: %s. Please report this error to MathWorks.',...
            listBoxType);

end

try
    prevlab = str2double(postStruct.CurLab);
    previndx = str2double(postStruct.CurFunIndex);
catch err  %#ok<NASGU>
    prevlab = 1;
    previndx = 1;
end
% ***********End of List Box Comparisons*****

% selectionString stores the lab index or description of the lab index

%% ------------------------------------------------------------------------
%   nested function for iGetViewerOptionData which does the right thing to
%   setup the proViewOptionData
%% ------------------------------------------------------------------------
    function profViewOptionData = nSetOptionsFromLabSelectionListBoxes(selectionString, profViewOptionData, listBoxType)

    % The cell of strings in txtStringsInListBox must be the same as the one in mpiprofview.m
    % iMakeLabSelectionListBox and iMakeLabComparisonListBox

    % currently there is only one comparison but in future this can be
    % increased by calling this function with a third argument specifying which
    % comparison field we are selecting;
    comparisonIndex = 1;
    isComparison = strcmp(listBoxType, 'Comparison');
    % if the compSelectionStr is None reset the lab selection in mpiprofview
    if isComparison && strcmp(selectionString, 'None')
        profViewOptionData.compLabInd = [];
        profViewOptionData.compSelectionStr = 'None';
        return;
    end

    txtStringsInListBox = {'maxAggregate',...
        'min Executed Aggregate',...
        'min TotalTime',...
        'max TotalTime',...
        'min CommTime',...
        'max CommTime'};

    displayTxtMsg = '';
    savedImageFiles ={};
    % tells us how the comparison is selected by;
    comparisonSelectByString = 'labno';

    switch(selectionString)
        case {txtStringsInListBox{1}, '-1'}
            % selects an aggregated generated profile info
            comparisonSelectByString = 'maxAggregate';
            labno = iGetDefaultAggregateIndex();
            selectionString = txtStringsInListBox{1};

        case {txtStringsInListBox{2}, '-2'}
            % selects an aggregated generated profile info
            comparisonSelectByString = 'min Executed Aggregate';
            labno = iGetDefaultAggregateIndex() - 1;
             selectionString = txtStringsInListBox{2};

        case txtStringsInListBox(3:end)
            % deal with cases which start with max or min

            maxOrMinLabno = iGetLabIndexWithTimeField(profileInfoVector, ...
                selectionString, ...
                functionName);

            if ischar(functionName)
                displayTxtMsg = sprintf(' lab %d has %s %s ',...
                    maxOrMinLabno, selectionString, functionName);
            end

            if ~isempty(functionName)
                listBoxString = '%d (with %s time for %s.m)';
                displayTxtMsg = sprintf(listBoxString, maxOrMinLabno, selectionString, iHsTruncateName(functionName));

            end

            labno = maxOrMinLabno;
        case ''
            labno = [];
            displayTxtMsg = '';

        otherwise
            % Deal with case the selection string is a labno
            % Can also be integer.
            if iIsString(selectionString)
                % if it doesn't have a descriptive text
                % assume its a number stored as text
                labno =  str2double(selectionString);
                if isnan(labno)
                    error('distcomp:mpiprofview:InvalidHtmlPost',...
                        'Error the option selected is invalid. Please report this error and your environment to MathWorks');
                end
            else
                    error('distcomp:mpiprofview:InvalidHtmlPost',...
                        'Error the option selected is invalid. Please report this error and your environment to MathWorks');

            end


    end % end of switch

    % Modifies profViewOptionData to indicate plot images are ready
    profViewOptionData.savedImageFiles = savedImageFiles;
    % needed to make sure we ignore the selection
    % of aggregate in the java listbox. Aggregates are not defined for non spmd
    if ~hasMPI && ~isempty(labno) && iIsLabIndexAnAggregate(labno)
        % reset to default labno
        labno = 1;
        selectionString = '1';
    end
    if ~isComparison
        profViewOptionData.labSelectionStr =  selectionString;
        profViewOptionData.mainLabInd = labno;
        profViewOptionData.displayTxtMsg = displayTxtMsg;
    else
        profViewOptionData.compSelectionStr = selectionString;
        if isempty(labno)
            profViewOptionData.compLabInd = [];
        else
            profViewOptionData.compLabInd(comparisonIndex) = labno;
        end
        profViewOptionData.selectBy = comparisonSelectByString;
        % add to the selection txt comment field
        if ~isempty(displayTxtMsg)
            profViewOptionData.displayTxtMsg =  ['(' displayTxtMsg ')'];
        end
    end
    end
%% ------------------------------------------------------------------------
%% ------------------------------------------------------------------------
    function profViewOptionData = nSetOptionsFromPlotListBox(selectionString, profViewOptionData)
    % This cell of strings must be the same as the one in mpiprofview.m
    % defined in plotViewListBoxStruct
    % The actual list box is generated by iMakeGenericSelectionListBox
    % remove Plot All
    txtStringsInListBox = {...
        'Plot TotalTime Histogram',...
        'Plot PerLab Communication',...
        'Plot CommTimePerLab', ...
        };
    savedImageFiles ={};

    if ~hasMPI
        error('distcomp:mpiprofview:NoCommInfoForPlot',...
            ['No communication information found. You may have used the standard profiler.\n'...
            ' Plots can only be generated for programs that are profiled with MPIPROFILE.\n'...
            ' See documentation for MPIPROFILE VIEWER.']);
    end

    if ~isempty(functionName)
        dispTxtFunctionName = ['for ' iHsTruncateName(functionName)];
    else
        dispTxtFunctionName = '';
    end

    switch(selectionString)

        case txtStringsInListBox{1} % HISTOGRAM OF TIME FIELDS
            plotoption = struct('Type', 'hist', 'FieldName', 'TotalTime');
            savedImageFiles{1}  = iSaveHistPlotForAllTimes(profileInfoVector,...
                functionName, plotoption);

            plotoption = struct('Type', 'hist', 'FieldName', 'CommTime');
            savedImageFiles{end+1} = iSaveHistPlotForAllTimes(profileInfoVector,...
                functionName, plotoption);
            %TIME WASTED HISTOGRAM
            plotoption = struct('Type', 'histred', 'FieldName', 'TimeWasted');
            savedImageFiles{end+1} = iSaveHistPlotForAllTimes(profileInfoVector,...
                functionName, plotoption);
            displayTxtMsg = sprintf( 'Histograms %s', dispTxtFunctionName);

        case txtStringsInListBox{2} % INTERLAB COMMUNICATION

            plotoption = struct('Type', 'imagedefault', 'FieldName', 'BytesReceivedPerLab');
            savedImageFiles{end+1} =  iSaveInterlabCommDiag(profileInfoVector, functionName, plotoption);

            plotoption = struct('Type', 'imagedefault', 'FieldName', 'CommTimePerLab');
            savedImageFiles{end+1}  =  iSaveInterlabCommDiag(profileInfoVector, functionName, plotoption);

            plotoption = struct('Type', 'imagedefault', 'FieldName', 'TimeWastedPerLab');
            savedImageFiles{end+1} =  iSaveInterlabCommDiag(profileInfoVector, functionName, plotoption);
            displayTxtMsg = sprintf( 'PerLab Communication Images %s', dispTxtFunctionName);

        case txtStringsInListBox{3}
            plotoption = struct('Type', 'imagedefault', 'FieldName', 'CommTimePerLab');
            savedImageFiles{end+1}  =  iSaveInterlabCommDiag(profileInfoVector, functionName, plotoption);
            displayTxtMsg = sprintf( 'Comm Time Per Lab Image %s', dispTxtFunctionName);

        case ''
            % remove the plots
            savedImageFiles  = {};
            displayTxtMsg = '';
        otherwise
            error('distcomp:mpiprofview:InvalidHtmlPost',...
                'Error the Plot option selected is invalid. Please report this error to MathWorks');

    end % end of switch

    % Modifies profViewOptionData to indicate plot images are ready
    profViewOptionData.savedImageFiles = savedImageFiles;
    profViewOptionData.plotSelectionStr =  selectionString;
    %     profViewOptionData.mainLabInd = 1;
    profViewOptionData.displayTxtMsg = displayTxtMsg;

    end % end of nested function


end
%%

%--------------------------------------------------------------------------
% H indicates its helper to an i function thus not used by main function directly
%--------------------------------------------------------------------------
function selectionStr = iHsTruncateName(selectionStr)
if numel(selectionStr)>10
    selectionStr = [selectionStr(1:8) '..'];
end;
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function b = iHasMpiData(profileInfo)
% Does this profiler data structure have profiling information in it?
b = (isfield(profileInfo, 'BytesSent') || ...
    (isfield(profileInfo, 'FunctionTable') && isfield(profileInfo(1).FunctionTable, 'TimeWasted')));
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function hasfields = iHasPerLabFields(profileInfoVector)
hasfields = ~isempty(profileInfoVector) && isfield(profileInfoVector(1).FunctionTable(1), 'BytesReceivedPerLab');
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function ist = iIsLabIndexAnAggregate(labIndex)
ist = labIndex<0;
end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function valid = iIsValidLabIndex(labIndex, nworker)
% zero is used to indicated that nothing should not be displayed
valid =  ~isempty(labIndex) && labIndex~=0 && (labIndex>0) && labIndex <= nworker ;
end
% -------------------------------------------------------------------------
% returns the special index that indicates selected profiler data is an
% Aggregate
% -------------------------------------------------------------------------
function labIndex = iGetDefaultAggregateIndex()
labIndex = -1;

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function valid = iIsString(value)
valid = ischar(value) && (size(value, 2) == numel(value));
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function isn = iIsScalarInt(value)
isn = isnumeric(value) && isreal(value) && isscalar(value);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function iDisplayActionErrorMessage(action)
if ~iIsString(action)
    error('distcomp:mpiprofview:InvalidActionCommand',...
        'Error Invalid action argument to pCallBackHelpers');
else
    error ('distcomp:mpiprofview:UnKnownActionCommand',...
        'Unknown action command passed to pCallBackHelpers. Please use mpiprofview as direct usage of this function is not recommended.');
end
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function str = iGetLabDescription(labIndex)
if iIsLabIndexAnAggregate(labIndex)
    switch(labIndex)
        case -1
            str = 'maxAggregate';
        case -2
            str = 'min Executed Aggregate';
        otherwise
            str = 'max TotalTime';

    end
elseif ~isempty(labIndex)
    str = sprintf('%d', labIndex);
else
    str = '';
end
end
