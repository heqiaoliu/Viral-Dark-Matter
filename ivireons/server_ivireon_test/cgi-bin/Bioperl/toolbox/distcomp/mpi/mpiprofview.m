function htmlOut = mpiprofview(functionNameOrIndex, profInfo, profOptionData)
% MPIPROFVIEW   Displays the html profiler interface or returns the html
% string. This command function should be run  via MPIPROFILE VIEWER in PMODE.
% On a MATLAB client MPIPROFVIEW can be used directly in functional form.
% MPIPROFVIEW (<functionname>, <PROFILEINFOARRAY>)
%   <functionname> can be either a name or an index number into the profile.
%   <PROFILEINFOARRAY> is a concatenated array of  <PROFILEINFO> structures where
%   <PROFILEINFO> = MPIPROFILE('INFO') when run on the worker MATLAB(s).
%   The index into <PROFILEINFOARRAY> should correspond to the labindex of the worker.
%   If the <functionname> argument passed in is zero, then profview displays
%   the profile summary page for the first lab in the <PROFILEINFOARRAY> array.
%
%   MPIPROFVIEW returns an HTML string only if an output argument is
%   specified.
%
% To obtain profiler information outside of pmode see MPIPROFILE.
%
%   See also MPIPROFILE, PMODE, PROFVIEW.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2010/03/22 03:42:26 $
%   Ned Gulley, Nov 2001
%   parallel extensions
%   S Marvasti 2007
% Color of comparisons is #AA5501
nArg = nargin;
% errors with correct message if user runs command on worker
iVerifyOnClient(nArg);

% This should be called  sProfInfo;
% however to keep it consistent with profview the name has not been
% changed.
persistent profileInfo;

if nargin < 1,
    % If there's no input argument, just provide the summary
    functionNameOrIndex = 0;
end

import com.mathworks.mde.profiler.Profiler; % Profiler java GUI

% Parallel Profiler Argument Processing
% We use nargin not string commands to keep compatibility with 2 argument
% profview in case of future integration
switch(nArg)
    % Undocumented
    case 3
        if ~isstruct(profOptionData)
            % make sure we error if user tries to use 3 arg mpiprofview
            error('distcomp:mpiprofview:TooManyArguments', ...
                'MPIPROFVIEW only takes 2 arguments. See documentation for MPIPROFILE VIEWER.');
        end
        % call is from pCallbackHelpers
        if profOptionData.reset
            %    reset all persistent internal states and return
            iGetEmptyFunctionTable( [] , true);
            profileInfo = [];
            htmlOut = '';
            return;
        else
            comparisonLabNo = profOptionData.compLabInd;
            % copy the entire new profiler options
            callbackViewOptionStruct = profOptionData;

            % If the input argument (functionNameOrIndex) is empty
            % the cached previously selected function name is used.
            if ~isempty(functionNameOrIndex)
                % for backward compatibilty we assign the same variable
                % used in profview to be either the input variable or
                % previously stored functioNameStr
                functionName = functionNameOrIndex;
            else
                % load the previously stored function name
                functioNameStr = dctMpiProfHelpers('getFcnName');
                functionName = functioNameStr;
            end

        end
        % Note to change just the selected function in current lab
        % 1 argument mpiprofview is called.
    case 2 % PUBLIC API
        % Call our intitialise function to correctly store the vector of profInfo objects when no
        % additonal arguments are passed in
        Profiler.stop;
        theLabIndex = 1;
        if nargout == 1
            htmlOut = dctMpiProfHelpers('newdata', functionNameOrIndex, theLabIndex, profInfo);
        else
            Profiler.start;
            dctMpiProfHelpers('newdata', functionNameOrIndex, theLabIndex, profInfo);
        end
        return;

        % if there is only one input assume it is a function index
    case {1, 0} % PUBLIC USABLE API

        % if function is selected resets the stored Viewoptions data to clear
        % any descriptive text that appears which is not valid in filepage
        % view.
            if nArg == 1
                callbackViewOptionStruct = dctMpiProfHelpers('resetDispViewOptions');
            else
                callbackViewOptionStruct = dctMpiProfHelpers('getViewOptions');
            end

            % don't display help page if user is getting the html output
            % (i.e. nargout == 1)
            if nargout == 0
                curLabHtmlState =  com.mathworks.mde.profiler.Profiler.getSelectedLabsFromHtml();
                if (isempty(curLabHtmlState) || (curLabHtmlState(1) == 0) || isempty(profileInfo))
                    com.mathworks.mde.profiler.Profiler.setCurrentLocationParallel(which([filesep 'private/mpiprofiler.html']));
                    return;
                end
            end


        % ensure we remove any image files that were added.
        callbackViewOptionStruct.savedImageFiles = {};

        % Note that we have already set functionNameOrIndex to be zero if
        % nargin==0.
        functionName = functionNameOrIndex;
        % we dont know at this point what the functionNameStr. It is
        % determined after we set the function index idx.
        % If persistent fields are not empty get the numberofLabs.
        if ~isempty(callbackViewOptionStruct)
            comparisonLabNo = callbackViewOptionStruct.compLabInd;
            % The default values are loaded from the OptionData structure at the top
            % ensure the java listbox is setup correctly
        end

    otherwise
        error('distcomp:mpiprofview:InvalidNumArgs',...
            'Invalid number of arguments in MPIPROFVIEW. See the documentation for MPIPROFILE.');

end
% future comparison can include more than one lab by using
% profInfoVector = dctMpiProfHelpers('get, 'all');
if ~isempty(comparisonLabNo) && ~ischar(comparisonLabNo)
    % store one profile info as profview expects
    comparisonProfInfo = dctMpiProfHelpers('get',...
        callbackViewOptionStruct.selectBy, comparisonLabNo);
else
    comparisonProfInfo = [];
end

% end Parallel Profiler processing

% original profview argument processing
% Three possibilities:
% 1) profile info wasn't passed and hasn't been created yet
% 2) profile info wasn't passed in but is persistent
% 3) profile info was passed in



if (nargin < 2) || isempty(profInfo),
    if isempty(profileInfo),
        % 1) profile info wasn't passed and hasn't been created yet
        error('distcomp:mpiprofview:InvalidInternalState', ...
            'A valid Profile info was not passed in. You can use MPIPROFILE more readily in PMODE.');

    else
        % 2) profile info wasn't passed in but is persistent
        % No action. profileInfo was created in a previous call to this function
    end
else
    % 3) profile info was passed in
    profileInfo = profInfo;
    Profiler.stop;
end

if nargin < 1,
    % If there's no input argument, just provide the summary
    functionName = 0;
end

% Find the function in the supplied data structure
% functionName can be either a name or an index number
if ischar(functionName)
    % Parallel Profview:
    % Added to insure no error is thrown when function is empty
    if isempty(functionName)
        idx = 0;
    else
        functionNameList = {profileInfo.FunctionTable.FunctionName};
        idx = find(strcmp(functionNameList,functionName));

        if isempty(idx)
            error('distcomp:mpiprofview:FunctionNotFound', ...
                'MPIPROFVIEW Error: Function %s not found in profiler Function Table', functionName)
        end
    end
else
    idx = functionName;
end

inaccurateText =  ['<br/>** Communication statistics are not available for ScaLAPACK functions'...
    ', so data marked with <i>**</i> might be inaccurate. <br/>'];
% only display the auto selection button when in SPMD mpi mode and has entries
hasMPI = hasMpiData(profileInfo) && ( numel(profileInfo.FunctionTable) > numel(profileInfo.RootIndex) );
hasPerLab = iHasPerLabFields(profileInfo);

thisMFileName = '';
% store the selected function name for future recall
if idx~=0
    functioNameStr = profileInfo.FunctionTable(idx).FunctionName;
    dctMpiProfHelpers('setFcnName', functioNameStr);
    thisMFileName = functioNameStr;
end
% does the profile info have a plot image
hasPlotImage = ~isempty(callbackViewOptionStruct.savedImageFiles);

if hasPlotImage
    % options for the plot selection listbox
    % these options are shared among the three different views
    % makesummarypage, makefilepage, iMakePlotPage.
    pageType = 'Plot';
    plotListBoxHtml = iGenHtmlListBoxAndButtonMenu(thisMFileName, idx, hasMPI, hasPerLab, pageType, callbackViewOptionStruct);
    s = iMakePlotPage(profileInfo, ['<p align="right">' plotListBoxHtml '</p>'], callbackViewOptionStruct);
else
    if idx == 0
        pageType = 'Summary';
    else
        pageType = 'General';
    end% includes summary or file page
    headerstr = iGenHtmlListBoxAndButtonMenu(thisMFileName, idx, hasMPI, hasPerLab, pageType, callbackViewOptionStruct);
    headerstr = {headerstr inaccurateText};
    if idx == 0
        % lab selection functions expect empty function name if idx is zero

        s = makesummarypage(profileInfo, headerstr, callbackViewOptionStruct, comparisonProfInfo);

    else
        % we are showing only data for a particular function
        % In function detail view there is no concept of Aggregate so we
        % must choose the profile info from the lab that had the maximum
        % value for this function.

        if iIsLabIndexAnAggregate(profileInfo.LabNo)
            iscomparisonInd = 0;
            [profileInfo idx] = dctMpiProfHelpers('getProfInfoFromAggregate', profileInfo, iscomparisonInd);
            % need to get the viewOptionStruct as well to ensure we have the
            % latest copy
            callbackViewOptionStruct = dctMpiProfHelpers('getViewOptions');

        end
        % the preferences are now stored under mpiprofiler not
        % profiler
        busyLineSortKey = getpref('mpiprofiler','busyLineSortKey','time');

        if ~isempty(comparisonProfInfo)% hasComparison (s)
            if iIsLabIndexAnAggregate(comparisonProfInfo.LabNo)
                iscomparisonInd = 1;
                [comparisonProfInfo cidx] = dctMpiProfHelpers('getProfInfoFromAggregate', comparisonProfInfo, iscomparisonInd);
                callbackViewOptionStruct = dctMpiProfHelpers('getViewOptions');
            else

                compNameList = {comparisonProfInfo.FunctionTable.FunctionName};
                cidx = strcmp(functioNameStr, compNameList);
            end
            % Set the pComparisonItem to the corresponding function table
            % entry
            pComparisonItem = comparisonProfInfo.FunctionTable(cidx);

            if ~isempty(pComparisonItem)
                pComparisonItem.LabNo = comparisonProfInfo.LabNo;
            end

            s = makefilepage(profileInfo, idx,...
                busyLineSortKeyStr2Num(busyLineSortKey), headerstr, callbackViewOptionStruct, pComparisonItem );

        else


            s = makefilepage(profileInfo, idx,...
                busyLineSortKeyStr2Num(busyLineSortKey), headerstr, callbackViewOptionStruct );
        end
    end

end

sOut = [s{:}];

if nargout==0
    % This call will create the parallel profiler options if not already setup.
    Profiler.setHtmlTextParallel(sOut);

else
    htmlOut = sOut;
end


% -------------------------------------------------------------------------
% Show the main summary page - modified original profview function
% -------------------------------------------------------------------------
function s = makesummarypage(profileInfo, labSelectionAndFooterCell , viewSelectedOptions, comparisonInfo)
% number of workers for which we would like to display profile info

hasComparison = false;
compLabInd = [];
if nargin > 3 && ~isempty(comparisonInfo)
    hasComparison = true;
    % get the names of the function to comapre on the two labs
    fnames = {profileInfo.FunctionTable.FunctionName};
    fcomparisonnames = {comparisonInfo.FunctionTable.FunctionName};
    [~, fcnIndexInComparison] = ismember(fnames, fcomparisonnames);
    compLabInd = viewSelectedOptions.compLabInd;
end
% pixel gif location
fs = filesep;
% lookup location of mpiprofview
mpiprofviewpath = fileparts(mfilename('fullpath'));
pixelPath = ['file:///' mpiprofviewpath fs 'private' fs];
cyanPixelGif = [pixelPath 'one-pixel-cyan.gif'];
bluePixelGif = [pixelPath 'one-pixel.gif'];
redPixelGif = [pixelPath 'one-pixel-red.gif'];
orangePixelGif = [pixelPath 'one-pixel-orange.gif'];

% Read in preferences
sortMode = getpref('mpiprofiler', 'sortMode', 'totaltime');

allTimes = [profileInfo.FunctionTable.TotalTime];
maxTime = max(allTimes);

if hasComparison
    % calculate maxTime for comparison lab's profile Info
    allComparisonTimes = [comparisonInfo.FunctionTable.TotalTime];
    % this is attached to the profile info
    % to be used for the inline bar images in iGenerateComparisonRow
    maxTime = max(maxTime, max(allComparisonTimes));
end

hasMem = hasMemoryData(profileInfo);
hasMPI = hasMpiData(profileInfo);

% if the sort mode is set to a memory field but we don't have
% any memory data, we need to switch back to time.
if ~hasMem && (strcmp(sortMode, 'allocmem') || ...
        strcmp(sortMode, 'freedmem') || ...
        strcmp(sortMode, 'peakmem')  || ...
        strcmp(sortMode, 'selfmem'))
    sortMode = 'totaltime';
end
% hasMPI and hasMem is assumed cannot both be true
if ~hasMPI && ~hasMem && ~(strcmp(sortMode, 'totaltime') && strcmp(sortMode, 'selftime'))

    sortMode = 'totaltime';
end



s = {};
s{1} = makeheadhtml;

% *********
% Stores the state of mpiprofview in the html title for parsing by
% Profiler.java
% iLabInt2Str allows us to deal with labno which do not correspond to
% labindex. Currently this is only special tag for aggregate.
% adds the comparison labno to the title string
if hasComparison
    % numComparisons = 1;
    mpiComparisonTitle = sprintf('%d, %s', 1, iLabInt2Str(compLabInd));
else
    % by default we havbe no comparisons
    mpiComparisonTitle = '0, 0';
end


if hasMPI
    mpiHTML = 'Parallel';
else
    mpiHTML = '';
end
% format <title > selectedLabIndex, numlabs, numcomparisons, comparisonLabIndex .... </title>
s{end+1} = sprintf('<title>%s, %s, %s, %s Profile Summary</title>', iLabInt2Str(profileInfo.LabNo), iLabInt2Str(viewSelectedOptions.numberOfLabs), mpiComparisonTitle, mpiHTML);
% **********

cssfile = which('matlab-report-styles.css');
s{end+1} = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
s{end+1} = '</head>';

s{end+1} = '<body>';

% Summary info
status = mpiprofile('status');
s{end+1} = '<span style="font-size: 14pt; background: #FFE4B0">Parallel Profile Summary</span>';
s{end+1} = sprintf('  <i>Generated %s using %s time.</i><br/>',datestr(now), status.Timer);

if length(profileInfo.FunctionTable)==0 || (hasMPI && numel(profileInfo.FunctionTable) <= 1) %#ok<ISMT>
    s{end+1} = '<p><span style="color:#F00">No profile information to display.</span><br/>';
    s{end+1} = 'Note that built-in functions do not appear in this report.<p>';
end

% Create the text heading which shows which labs data is being shown
if hasComparison
    mpiHTML = sprintf('compared with lab <b>%s</b>', iGetLabDescription(comparisonInfo.LabNo) );
else
    mpiHTML = '';
end

if hasMPI
    s{end+1} = sprintf(['<br/><span style="font-size: 14pt; padding: 0;background: #FFBB00">'...
        'Showing <b>all functions</b> called in lab <b> %s </b>%s</span> %s<br/>'],...
        iGetLabDescription(profileInfo.LabNo),...
        mpiHTML,...
        viewSelectedOptions.displayTxtMsg);
end
% insert the lab selection html listboxes provided by top level mpiprofview
s{end+1} = [labSelectionAndFooterCell{:}];

if hasComparison
    % reduce the cell padding space
    cellpadding = '4';
    labDesc = iGetLabDescription(compLabInd);

else
    labDesc = '';
    cellpadding = '6';
end

s{end+1} = sprintf('<table frame="void" border="0" cellspacing=0 cellpadding="%s">', cellpadding);
% group the columns according to html 4 specifications
% w3.org/tr/html3/struct/tables.html
s{end+1} = '<colgroup align="left" span="2">';
s{end+1} = '<colgroup align="left">';
s{end+1} = '<colgroup align="left">';
s{end+1} = '<colgroup align="left">';
s{end+1} = '<colgroup align="left">';
s{end+1} = '<colgroup align="left">';
s{end+1} = '<colgroup align="left">';
s{end+1} = '<colgroup align="left">';

% used to highlight a single function Name when there is a comparison item
% to display
switchHighLight = false;

% functions to filter out just from mpiprofview
% (used by makesummarypage and makefilepage)
allFunctionNames = {profileInfo.FunctionTable.FunctionName};
[~, functionShouldNotDisplay] =  iFindIndexOfFcnsToFilterOut(profileInfo);
% generates table heading and bolds column if that is the select by field
[tableHeadingStr sortIndex] = iMakeSummaryPageTableHeadingAndSortIndex(profileInfo,...
    sortMode, labDesc);

lightGreyHtmlColor = '"#E9E9E9"';

for i = 1:length(profileInfo.FunctionTable),
    n = sortIndex(i);
    if mod(i,24)==1
        s{end+1} = tableHeadingStr; 
    end

    if functionShouldNotDisplay(n)
        continue;
    end

    % do not display the Root node which is only used for Aggregate
    % Per Lab Field (e.g. CommTimePerLab for entire program on all labs)

    if hasComparison
        % alternatively highlight the comparison rows for better visuals
        % delimination

        if switchHighLight
            highLightStr = [' bgcolor=' lightGreyHtmlColor];
        else
            highLightStr = '';
        end
        switchHighLight = ~switchHighLight;
    else
        % keep the default background color
        % if no comparison is being shown
        highLightStr = '';
    end

    comparisonGifFiles = {bluePixelGif; cyanPixelGif; orangePixelGif};
    s{end+1} = iMakeSummaryPageTableRow(profileInfo, 0, maxTime, allFunctionNames{n},...
        n, highLightStr, comparisonGifFiles);

    % *********************************************************************
    % call to generate comparison row
    if hasComparison
        % the pixel images that will be used by the comparison lab.
        % its the same as the current lab except that we use red and light red for
        % selftime and total time. Currently self waste time is indicated by the
        % same color (orange).
        comparisonGifFiles = {redPixelGif; cyanPixelGif; orangePixelGif};
        s{end+1} = iMakeSummaryPageTableRow(comparisonInfo, n, maxTime, allFunctionNames{n},...
            fcnIndexInComparison(n), highLightStr, comparisonGifFiles); 
    end
    % *********************************************************************

end
s{end+1} = '</table>';
s{end+1} = '<p><a name="selftimedef"></a><strong>Self time</strong> is the time spent in a function excluding the ';
s{end+1} = 'time spent in its child functions. Self time also includes ';
s{end+1} = 'overhead resulting from the process of profiling.';
if hasMPI
    s{end+1} = labSelectionAndFooterCell{end};
end
s{end+1} = '</body>';

s{end+1} = '</html>';


% -------------------------------------------------------------------------
% Show the function details page
% -------------------------------------------------------------------------
function s = makefilepage(profileInfo, idx, key_data_field, labSelectionAndFooterCell, viewSelectedOptions, compareItem)
% profileInfo - the profiling data structure from callstats
% idx - index of the function to generate details for
% key_data_field - an integer representing which type of
%                  collected data to sort the details by.
%                  this controls what lines are displayed
%                  as the top 5 busy lines.
%   1 - sort by time
%   2 - sort by allocated memory
%   3 - sort by freed memory
%   4 - sort by peak memory
%   5 = OR sort by 1 and MPI strings returned by iGetOptionStringsMPI()
% ADDITONAL NOTES FOR MPIPROFVIEW
% Please note that the MATLAB file is assumed to not have changed unless
% shown otherwise by checking the ExecutedLines fields against number of
% lines in the MATLAB code. Reusing variable name from profview except not
% calling callstats('has_changed')

% things to assume not be true unless proven otherwise
hasComparison = false;
didChange = false;

% start with header of html output
s{1} = makeheadhtml;
ftItem = profileInfo.FunctionTable(idx);

IsNotAccurateStr = '';
hasMem = hasMemoryData(ftItem);
hasMPI = hasMpiData(ftItem);
% labno is guaranteed to exist in dctMpiProfHelpers which is the only
% function that calls mpiprofview. Anything else calls back to
% dctMpiProfHelpers.
mainLabInd = profileInfo.LabNo;
% ComparisonItem can only be empty when the function is not executed on this.
% In this case we Add a field to the ExecutedLines in the
% busyLineDisplay section. Do not test for empty as empty compareItem is
% valid and will result in a comparison (filled with zeros).
if nargin > 5
    % currently file page does not support comparison with non mpi data
    hasComparison = hasMPI;
    compExecutedLinesNotEmpty = true;
    % if the compared Item doesn't call this function empty then give notice.
    % and create a zero values entry for the executedlines
    if isempty(compareItem) || isempty(compareItem.ExecutedLines)
        compareItem = iGetEmptyFunctionTable(ftItem);
        compExecutedLinesNotEmpty = false;
        compLabInd = viewSelectedOptions.compLabInd;
    else
        % The comparison also has some executed lines
        compLabInd = viewSelectedOptions.compLabInd;
    end

end

if hasMPI
    if iHasInaccurateMPITimings(ftItem.FunctionName)
        IsNotAccurateStr = '**';
    end
end

% Select the column order and unit strings depending on the
% sort type.
%
% The field_order controls how the columns of time and memory
% are laid out left to right.  Each entry in the field order
% vector corresponds to the key_data_field for that item.
% The first entry in the field order is always the item we are
% currently sorting on.
%
% The key_unit and key_unit_up variables are used to parameterize
% the values of some strings depending on what we a
%
if ~hasMem
    % if we have no memory data, default to time
    if ~hasMPI
        key_data_field = 1;
        field_order = 1;
        key_unit = 'time';
        key_unit_up = 'Time';
    end
else
    switch key_data_field
        case 1
            field_order = [1 2 3 4];
            key_unit = 'time';
            key_unit_up = 'Time';
        case 2
            field_order = [2 3 4 1];
            key_unit = 'allocated memory';
            key_unit_up = 'Allocated Memory';
        case 3
            field_order = [3 4 2 1];
            key_unit = 'freed memory';
            key_unit_up = 'Freed Memory';
        case 4
            field_order = [4 2 3 1];
            key_unit = 'peak memory';
            key_unit_up = 'Peak Memory';
        otherwise
            error('distcomp:mpiprofiler:BadSortKey','Bad sort key %d', key_data_field);
    end
end

if ~hasMPI
    % if we have no mpi data, default to time
    if ~hasMem
        key_data_field = 1;
        field_order = 1;
        key_unit = 'time';
        key_unit_up = 'Time';
    end
else
    switch key_data_field
        case 1
            field_order = [1 2 3 4 5];
            key_unit = 'time';
            key_unit_up = 'Time';
        case 2
            field_order = [2 3 4 5 1];
            key_unit = 'Data Sent';
            key_unit_up = key_unit;
        case 3
            field_order = [3 4 5 2 1];
            key_unit = 'Data Received';
            key_unit_up = key_unit;
        case 4
            field_order = [4 5 2 3 1];
            key_unit = 'Comm Waiting Time';
            key_unit_up = key_unit;
        case 5
            field_order = [5 4 2 3 1];
            key_unit = 'Total Comm Time';
            key_unit_up = key_unit;
        otherwise
            error('distcomp:mpiprofiler:BadSortKey','Bad sort key %d', key_data_field);
    end
end
% pixel gif location
bluePixelGif = ['file:///' which('one-pixel.gif')];
redPixelGif = ['file:///' which('one-pixel-red.gif')];
% used to produce any color font using sprintf and suitable colorstr
genericFontColorHtml = '<span style="color: %s">';

% totalData holds all the totals for each type of data (time & memory)
% for the current function.  It is indexed by key_data_field or entries
% in field_order.
totalData(1) = ftItem.TotalTime;
if hasMem
    totalData(2) = ftItem.TotalMemAllocated;
    totalData(3) = ftItem.TotalMemFreed;
    totalData(4) = ftItem.PeakMem;
end

% hasMPI will always overwrite hasMem
if hasMPI
    totalData(2) = ftItem.BytesSent;
    totalData(3) = ftItem.BytesReceived;
    totalData(4) = ftItem.TimeWasted;
    totalData(5) = ftItem.CommTime - ftItem.TimeWasted;
    % calculate percentage of time spent in computation
    if ftItem.TotalTime ~= 0
        calcOverTotalTime =  (ftItem.TotalTime - ftItem.CommTime) / ftItem.TotalTime;
    else
        calcOverTotalTime = 0;
    end

    if hasComparison
        ctotalData(1) = compareItem.TotalTime;
        ctotalData(2) = compareItem.BytesSent;
        ctotalData(3) = compareItem.BytesReceived;
        ctotalData(4) = compareItem.TimeWasted;
        ctotalData(5) = compareItem.CommTime - compareItem.TimeWasted;
        if compareItem.TotalTime ~= 0
            cCalcOverTotalTime =  (compareItem.TotalTime - compareItem.CommTime) / compareItem.TotalTime;
        else
            cCalcOverTotalTime = 0;
        end
    end
end

% Build up function name target list from the children table
targetHash = [];
for n = 1:length(ftItem.Children)
    targetName = profileInfo.FunctionTable(ftItem.Children(n).Index).FunctionName;
    % Don't link to Opaque-functions with dots in the name
    if ~any(targetName=='.') && ~any(targetName=='@')
        % Build a hashtable for the target strings
        % Ensure that targetName is a legal MATLAB identifier.
        targetName = regexprep(targetName,'^([a-z_A-Z0-9]*[^a-z_A-Z0-9])+','');
        if ~isempty(targetName) && targetName(1) ~= '_'
            targetHash.(targetName) = ftItem.Children(n).Index;
        end
    end
end

% MATLAB functions, scripts, and subfunctions are the only file types we can
% list. If the file is mlocked, we can't display it.
mlockedFlag = mislocked(ftItem.FileName);
mFileFlag = 1;
pFileFlag = 0;
filteredFileFlag = false;
% Here we separate a variable that allows us to trap problems that could
% occur otherwise if the executedlines field is empty [] rather than 0x3
% double. This is work around for profiler data structure change in 2007b
% prerelease
indexOfFcnRoot = iFindIndexOfFcnsToFilterOut(profileInfo);
shouldIgnoreDisplayForAnonymous = (any(strcmp(ftItem.Type,{'M-anonymous-function', 'M-not-executed'}))|| isempty(regexp(ftItem.Type,'^M-','once'))) || mlockedFlag;

if ( shouldIgnoreDisplayForAnonymous|| ...
        isempty(ftItem.FileName))
    mFileFlag = 0;
else
    % Make sure it's not a P-file
    if ~isempty(regexp(ftItem.FileName,'\.p$','once'))
        pFileFlag = 1;
        % Replace ".p" string with ".m" string.
        fullName = regexprep(ftItem.FileName,'\.p$','.m');
        % Make sure the MATLAB file corresponding to the P-file exists
        if ~exist(fullName,'file')
            mFileFlag = 0;
        end
    else
        fullName = ftItem.FileName;
    end
end

badListingDisplayMode = false;
didChangePath = false;
mFileFlagError = '';
if mFileFlag
    [f err] =  pGetMcode(fullName);
    if ~isempty(err)

        clusterName = fullName;
        [fullName finderr] = iFindFileOnClient(ftItem, fullName);
        if isempty(finderr)
            [f err] = pGetMcode(fullName);
        else
            err = finderr;
        end

        if ~isempty(err)
            if isempty(fullName)
                mFileFlagError = sprintf('Could not find %s on the client. %s Make sure the profiled MATLAB file is accessible from the MATLAB client.', clusterName, err);
            else
                mFileFlagError = sprintf('Found file %s on the client, but could not read it. Make sure the file is up-to-date and that this account has read permission from the MATLAB client.', fullName);
            end
            % turn off display of MATLAB code if it was not found
            mFileFlag = false;

        else
            didChangePath = true;
        end

    end
    if isempty(ftItem.ExecutedLines) && ftItem.NumCalls > 0
        % If the executed lines array is empty but the number of calls
        % is not 0 then the body of this function must have been filtered
        % for some reason.  We do not want to display the MATLAB code in
        % this case.
        % This may occur for Abstract MCOS class constructors.
        f = [];
        filteredFileFlag = true;
    elseif length(f) < ftItem.ExecutedLines(end,1)
        % This is a simple (non-comprehensive) test to see if the file has been
        % altered since it was profiled. The variable f contains every line of the
        % file, and ExecutedLines points to those line numbers. If
        % ExecutedLines points to lines outside that range, something is wrong.
        badListingDisplayMode = true;
        didChange = true;
    end
end

if hasComparison
    numComparisons = 1;
    mpiComparisonTitle = sprintf(' %d, %s,', numComparisons, iLabInt2Str(compLabInd));
else
    mpiComparisonTitle = ' 0, 0,';
end
% assume always there is a labNo(labIndex) even for distributed profInfo or single
% profile info. iLabInt2Str ensures the labno is converted correctly .
% The title needs to include state information about the generated html
% page so that the Java Profiler can keep consistency when back button is
% used.
s{end+1} = sprintf('<title>%s, %d,%s Function details for %s</title>',...
    iLabInt2Str(mainLabInd), viewSelectedOptions.numberOfLabs, mpiComparisonTitle,  ftItem.FunctionName);

cssfile = which('matlab-report-styles.css');
s{end+1} = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
s{end+1} = '</head>';
s{end+1} = '<body>';

% Summary info
% displayName = truncateDisplayName(ftItem.FunctionName,40);

displayName = ftItem.FunctionName;
if hasMPI
    colorString = iGetColorStrIndicatorForDecimal(calcOverTotalTime);
else
    colorString ='#FFE4B0';
end
s{end+1} = sprintf('<span style="font-size: 14pt; background: %s">%s', ...
    colorString, displayName);

if ftItem.NumCalls==1,
    callStr = 'call';
else
    callStr = 'calls';
end
status = mpiprofile('status');


% if we do not have any additonal fields dipslay the same as normal
% profiler.  Intentional decision was not to display mpi communication and
% memory fields
if ~hasMem && ~hasMPI
    s{end+1} = sprintf(' (%d %s, %4.3f sec)</span><br/>', ...
        ftItem.NumCalls, callStr, totalData(1));
    s{end+1} = sprintf('<i>Generated %s using %s time.</i><br/>', datestr(now), status.Timer);
else
    if hasMPI
        %     no explicit hasMPI string formating needed since formatData()
        %     deals with this
        s{end+1} = sprintf('(%d %s, %4.3f sec, %s sent, %s rec, %s wait, %s act comm )%s <br/> </span>', ...
            ftItem.NumCalls,...
            callStr,...
            ftItem.TotalTime,...
            formatData(2, totalData(2), hasMPI),...
            formatData(3, totalData(3), hasMPI),...
            formatData(4, totalData(4), hasMPI),...
            formatData(5, totalData(5), hasMPI), IsNotAccurateStr...
            );
    else
        % assume it is memory fields
        s{end+1} = sprintf('(%d %s, %4.3f , %s , %s , %s ) <br/> </span>', ...
            ftItem.NumCalls,...
            callStr,...
            ftItem.TotalTime,...
            formatData(2, totalData(2), hasMPI),...
            formatData(3, totalData(3), hasMPI),...
            formatData(4, totalData(4), hasMPI)...
            );

    end

    % dark blue color
    fontColorSpan = sprintf(genericFontColorHtml, '#0000BB');
    calculationPercentString = sprintf('Total computation took %s <b>%2.2f</b>', fontColorSpan, calcOverTotalTime*100);
    calculationPercentString =[calculationPercentString   '% </span> '];

    if hasComparison
        % comparison font color selection
        colorStringRelectingComputationTime = iGetColorStrIndicatorForDecimal(cCalcOverTotalTime);
        comparisonHighlightSpan = sprintf('<span style="font-size: 14pt; color: #AA5501; font-weight: normal; text-decoration: none; background: %s">',...
            colorStringRelectingComputationTime);
        s{end+1} = comparisonHighlightSpan;
        s{end+1} = sprintf('%s(%d %s, %4.3f sec, %s sent, %s rec, %s wait, %s act comm )%s <br/> </span>', ...
            displayName,...
            compareItem.NumCalls,...
            callStr,...
            compareItem.TotalTime,...
            formatData(2, ctotalData(2),hasMPI),...
            formatData(3, ctotalData(3), hasMPI),...
            formatData(4, ctotalData(4), hasMPI),...
            formatData(5, ctotalData(5), hasMPI),  IsNotAccurateStr);
        timeDiffString = sprintf('with time difference of <b> %8.3f </b> s. ', abs(ftItem.TotalTime - compareItem.TotalTime));
        % turn background of comparison white and font color to red and reduces
        % font size slightly.
        % COMPARISON COLOR font-size: 10pt
        comparisonFontSpan = '<span style="color: #AA5501; font-style: italic; text-decoration: none">';
        s{end+1} = timeDiffString;
        % if we have a comparison
        % red color
        fontColorSpan = sprintf(genericFontColorHtml, '#BB0000');
        calculationPercentString = [calculationPercentString ...
            sprintf(' compared to %s %2.2f', fontColorSpan, cCalcOverTotalTime*100)];
        calculationPercentString = [calculationPercentString '%</span> '];

    end
    s{end+1} = calculationPercentString;
    s{end+1} = 'of total time. <br/>';
    s{end+1} = sprintf('<br/><i> Generated %s using %s time.</i><br/>', datestr(now), status.Timer);

end

if hasMPI
    % lab selection display
    if hasComparison
        mpiComparisonHTML = sprintf('compared with <b> %s </b>', iGetLabDescription(compLabInd));
    else
        mpiComparisonHTML = '';
    end
    s{end+1} = sprintf(...
        ['<span style="font-size: 14pt; padding: 0; background: #FFBB00">'...
        'Showing <b>this function''s</b> statistics on lab <b> %s </b>%s</span> <br/>'], iGetLabDescription(profileInfo.LabNo), mpiComparisonHTML);
end
s{end+1} = labSelectionAndFooterCell{1};


if mFileFlag
    s{end+1} = sprintf('%s in file <a href="matlab: edit(urldecode(''%s''))">%s</a><br/>', ...
        ftItem.Type, urlencode(fullName), fullName);
elseif isequal(ftItem.Type,'M-subfunction')
    s{end+1} = 'anonymous function from prompt or eval''ed string<br/>';
else
    s{end+1} = sprintf('%s in file %s. %s<br/>', ...
        ftItem.Type, ftItem.FileName, mFileFlagError);
end

s{end+1} = '[<a href="matlab: dctProfStripAnchors">Copy to new window for comparing multiple runs</a>]';

if pFileFlag && ~mFileFlag
    s{end+1} = '<p><span class="warning">This is a P-file for which there is no corresponding MATLAB file</span></p>';
end

if mlockedFlag
    s{end+1} = sprintf(['<p><span class="warning">This function has been mlocked. Results may be incomplete ' ...
        'or inaccurate.</span></p>']);
end
% didChange = callstats('has_changed',ftItem.CompleteName);
% This will not work for parallel profiler as callstats on the client does
% not have this info.

if didChange
    s{end+1} = sprintf(['<p><span class="warning">This function changed during profiling ' ...
        'or before generation of this report.  Profile results might be incomplete ' ...
        'or inaccurate.</span></p>']);

elseif didChangePath
    s{end+1} = sprintf(['<p><span class="warning">WARNING: The MATLAB file was not found in the original path %s run on cluster. '...
        'This function could have changed during profiling ' ...
        'or before generation of this report.  Profile results might be incomplete ' ...
        'or inaccurate.'], ftItem.FileName);
else
    s{end+1} = sprintf(['<p><span class="warning">' ...
        ' Please note that the code displayed is taken from the client, and might have '...
        'changed since execution on the cluster. Only valid MATLAB functions will be shown. </span></p>']);
end

s{end+1} = '<div class="grayline"/>';


% --------------------------------------------------
% Manage all the checkboxes
% Read in preferences
parentDisplayMode = getpref('mpiprofiler','parentDisplayMode',1);
busylineDisplayMode = getpref('mpiprofiler','busylineDisplayMode',1);
childrenDisplayMode = getpref('mpiprofiler','childrenDisplayMode',1);

mlintDisplayMode = getpref('mpiprofiler','mlintDisplayMode',1);
coverageDisplayMode = getpref('mpiprofiler','coverageDisplayMode',1);
listingDisplayMode = getpref('mpiprofiler','listingDisplayMode',1);
% disable the source listing if the file has changed in a major way
oldListingDisplayMode = listingDisplayMode;
if badListingDisplayMode
    listingDisplayMode = false;
end


s{end+1} = '<form method="POST" action="matlab:mpiprofviewgateway">';
s{end+1} = sprintf('<input type="submit" value="Refresh" />');
s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);

s{end+1} = '<table>';
s{end+1} = '<tr><td>';


checkOptions = {'','checked'};

s{end+1} = sprintf('<input type="checkbox" name="parentDisplayMode" %s />', ...
    checkOptions{parentDisplayMode+1});
s{end+1} = 'Show parent functions</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="busylineDisplayMode" %s />', ...
    checkOptions{busylineDisplayMode+1});
s{end+1} = 'Show busy lines</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="childrenDisplayMode" %s />', ...
    checkOptions{childrenDisplayMode+1});
s{end+1} = 'Show child functions</td></tr><tr><td>';

s{end+1} = sprintf('<input type="checkbox" name="mlintDisplayMode" %s />', ...
    checkOptions{mlintDisplayMode+1});
s{end+1} = 'Show M-Lint results</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="coverageDisplayMode" %s />', ...
    checkOptions{coverageDisplayMode+1});
s{end+1} = 'Show file coverage</td><td>';

s{end+1} = sprintf('<input type="checkbox" name="listingDisplayMode" %s />', ...
    checkOptions{listingDisplayMode+1});
s{end+1} = 'Show function listing</td>';

s{end+1} = '</tr></table>';

s{end+1} = '</form>';

if hasMem
    %
    % if we have more than just time data, insert a callback tied to a pulldown
    % menu which allows the user to select between data sorting methods
    % XXXXXX this menu needs to be moved somewhere nicer
    %
    s{end+1} = '<form method="POST" action="matlab:mpiprofviewgateway">';
    s{end+1} = 'Sort busy lines and graph according to ';
    s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
    s{end+1} = '<select name="busyLineSortKey" onChange="this.form.submit()">';
    optionsList = { };
    optionsList{end+1} = 'time';
    optionsList{end+1} = 'allocated memory';
    optionsList{end+1} = 'freed memory';
    optionsList{end+1} = 'peak memory';

    for n = 1:length(optionsList)
        if strcmp(busyLineSortKeyNum2Str(key_data_field), optionsList{n})
            selectStr='selected';
        else
            selectStr = '';
        end
        s{end+1} = sprintf('<option %s>%s</option>', selectStr, optionsList{n});
    end

    s{end+1} = '</select>';
    s{end+1} = '</form>';
end


if hasMPI
    %
    %
    s{end+1} = '<form method="POST" action="matlab:mpiprofviewgateway">';
    s{end+1} = 'Sort busy lines and graph according to ';
    s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
    s{end+1} = '<select name="busyLineSortKey" onChange="this.form.submit()">';
    optionsList = iGetOptionStringsMPI();

    for n = 1:length(optionsList)
        if strcmp(busyLineSortKeyNum2StrMPI(key_data_field), optionsList{n})
            selectStr='selected';
        else
            selectStr = '';
        end
        s{end+1} = sprintf('<option %s>%s</option>', selectStr, optionsList{n});
    end
    s{end+1} = '</select>';
    s{end+1} = '</form>';
end

s{end+1} = '<div class="grayline"/>';
% --------------------------------------------------

% --------------------------------------------------
% Parent list
% --------------------------------------------------
if parentDisplayMode
    parents = ftItem.Parents;
    s{end+1} = '<strong>Parents</strong> (calling functions)<br/>';
    % Don't show parents if this is a child function of Root
    if isempty(parents) || ~isempty(indexOfFcnRoot) && all([parents.Index] == indexOfFcnRoot)
        s{end+1} = ' No parent ';
    else
        s{end+1} = '<p><table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Function Name</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Function Type</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Calls</td>';
        s{end+1} = '</tr>';
        % does not show root
        for n = 1:length(parents),
            parentIndex = parents(n).Index;
            % ignore the root display
            if parentIndex(1) == indexOfFcnRoot
                continue;
            end
            s{end+1} = '<tr>';

            displayName = truncateDisplayName(profileInfo.FunctionTable(parents(n).Index).FunctionName,40);
            s{end+1} = sprintf('<td class="td-linebottomrt"><a href="matlab: mpiprofview(%d);">%s</a></td>', ...
                parents(n).Index, displayName);

            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                profileInfo.FunctionTable(parentIndex).Type);

            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                parents(n).NumCalls);

            s{end+1} = '</tr>';
        end

        s{end+1} = '</table>';
    end
    s{end+1} = '<div class="grayline"/>';

end
% --------------------------------------------------
% End parent list section
% --------------------------------------------------

% -------------------------------------------------------------------------
% Busy line list section
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% The index into ExecutedLines is always key_data_field + 2
% (i.e. 3 is time, 4 is allocated memory, 5 is freed memory, 6 is peak)
% and similarly for MPI 4 is Data sent 5 is Data rec 6 is Comm Waiting Time
% 7 is total communication time
ln_index = key_data_field + 2;
if hasMPI
    % calculate Active Communication Time Instead of Total Communication Time for the executed lines
    ftItem.ExecutedLines(:,7) = ftItem.ExecutedLines(:,7)-ftItem.ExecutedLines(:,6);
    if hasComparison
        compareItem.ExecutedLines(:,7) = compareItem.ExecutedLines(:,7)-compareItem.ExecutedLines(:,6);
        % Our sort function sorts in descending order and also calls
        % flipud.
        comparisonSortedExecutedLines = iSortExecutedLinesByField(compareItem, ln_index);

    end

end

% sort the data by the selected data kind.
[sortedDataList(:,key_data_field), sortedDataIndex] = sort(ftItem.ExecutedLines(:,ln_index));
sortedDataList = flipud(sortedDataList);

maxDataLineList = flipud(ftItem.ExecutedLines(sortedDataIndex,1));
% only shows the top 5 lines
numtoplines = 5;
maxDataLineList = maxDataLineList(1:min(numtoplines,length(maxDataLineList)));

maxNumCalls = max(ftItem.ExecutedLines(:,2));

dataSortedNumCallsList = flipud(ftItem.ExecutedLines(sortedDataIndex,2));

if hasComparison
    maxComparisonDataLineList = (comparisonSortedExecutedLines(:, 1));
    numcomptoplines = min(numtoplines, length(maxComparisonDataLineList));
    % pick the top five lines
    maxComparisonDataLineList = maxComparisonDataLineList(1:numcomptoplines);
    % The following variables are only needed if we want the allOtherLines list
    % to show up for comparisons. This is currently disabled
    % maxComparisonNumCalls = max(comparisonSortedExecutedLines(:, 1) );
    % sortedComparisonNumCallsList = flipud(comparisonSortedExecutedLines(:, 2));
    % get everything except Line Number and Num Calls to make it equivalent to
    % the sortedDataList generated below by original profview
    % sortedComparisonDataList = (comparisonSortedExecutedLines(:, 3:end));
end

% sort all the rest of the line data based on the indices of the original
% sort.

numberOfFields = length(field_order);

for i=1:numberOfFields
    fi = field_order(i);
    if fi == key_data_field, continue; end
    % check to make sure it is a valid field
    if ~isempty(ftItem.ExecutedLines) && size(ftItem.ExecutedLines,2) >= (fi+2)
        sortedDataList(:,fi) = flipud(ftItem.ExecutedLines(sortedDataIndex,fi+2));
    end
end

% Combines the maxdata line number list from both labs only for lines
% which were not executed by current lab get rid of special case where
% the other lab does not execute any line
% number and is recorded as zero
numelOrigMaxDataLineList = numel(maxDataLineList);
if hasComparison && compExecutedLinesNotEmpty
    linesNotExecutedByCurLab = ~ismember(maxComparisonDataLineList, maxDataLineList);
    linesNotExecutedByCompLab = ~ismember(maxDataLineList, maxComparisonDataLineList);
    % add zero vaulues for these lines that were executed by other lab but not
    % this lab for most pure SPMD we expect numOfLinesNotExecutedByThisLab to be zero
    numOfLinesNotExecutedByThisLab = sum(linesNotExecutedByCurLab);
    % get this labs data for lines executed on comparison lab
    [sortedDataNotInMaxDataLineList numCallsForLinesNotInMaxDataLineList ] = iGetExecutedDataForLines(ftItem, maxComparisonDataLineList(linesNotExecutedByCurLab));
    [sortedDataNotInMaxDataLineList numCallsForLinesNotInMaxDataLineList] = iSortTableAndVectorByField(sortedDataNotInMaxDataLineList, numCallsForLinesNotInMaxDataLineList, key_data_field);
    maxDataLineList = [maxDataLineList ; maxComparisonDataLineList(linesNotExecutedByCurLab)];

    % add the lines not executed by this lab to the sortedDataList for
    % display as usual
    sortedDataList(numtoplines+1:numtoplines+numOfLinesNotExecutedByThisLab , :) =  sortedDataNotInMaxDataLineList;
    dataSortedNumCallsList( numtoplines+1:numtoplines+numOfLinesNotExecutedByThisLab ) = numCallsForLinesNotInMaxDataLineList;
end

% Link directly to the busiest lines
% ----------------------------------------------

% The column names
data_fields = { 'Total Time' 'Allocated Memory' 'Freed Memory' 'Peak Memory' };
if hasMPI % Todo Alan
    data_fields = { 'Total Time' 'Data Sent' 'Data Rec' 'Comm Waiting Time' 'Active Comm Time' };
end


if busylineDisplayMode
    if hasComparison
        s{end+1} = sprintf('<strong>Lines where the most %s was spent including the top 5 code lines from the comparison lab(maroon) </strong><br/> ', key_unit);
    else
        s{end+1} = sprintf('<strong>Lines where the most %s was spent. </strong><br/> ', key_unit);
    end

    if ~mFileFlag || filteredFileFlag
        s{end+1} = 'No MATLAB code to display or function not called';
    else
        if totalData(key_data_field) == 0
            s{end+1} = sprintf('No measurable %s spent in this function', key_unit);
        end

        s{end+1} = '<p><table border=0 cellspacing=0 cellpadding=6>';

        s{end+1} = '<tr>';

        if ~hasComparison
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Line Number</td>';
        else
            s{end+1} = sprintf(['<td class="td-linebottomrt" bgcolor="#FFF0F0">Line Number <br/>'...
                '(for lab %d and %s %d </span>)</td>'],  mainLabInd, comparisonFontSpan, compLabInd);
            % if hascomparison get the data for the lines in
            % maxDataLineList and insert zeros if not executed by
            % comparison
            [sortedDataForComparison numCallsForComparison ] = iGetExecutedDataForLines(compareItem, maxDataLineList);

        end
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Code</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Calls</td>';

        % output the additional column names in the right order
        for fi=1:length(field_order)
            fidx = field_order(fi);
            s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' data_fields{fidx} '</td>'];
        end

        % the percentage and histogram bar always come last.
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">% ' key_unit_up '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' key_unit_up ' Plot</td>'];
        s{end+1} = '</tr>';

        % display the top 5 (or upto 10 for two labs comparison) that were
        % executed
        for n = 1:length(maxDataLineList),
            % string used to highlight the display of top executed lines from
            % the comparison lab (only when current lab does not call these
            % lines in its top 5 executed lines)
            tableCellOptionForOtherLab = '';
            % Dont color rows if comparison executed lines are empty.
            if hasComparison && compExecutedLinesNotEmpty
                % the length of this is the same as the madataline list in the main without the merge with a comparison.
                % min (numtoplines or )
                if n > numelOrigMaxDataLineList
                    % lines that arent there in comparison are
                    % highlighted redish tint color
                    tableCellOptionForOtherLab = 'bgcolor="#FFF0F0"';
                elseif linesNotExecutedByCompLab(n)
                    % blueish tint
                    tableCellOptionForOtherLab = 'bgcolor="#F0F0FF"';
                end
            end

            s{end+1} = ['<tr ' tableCellOptionForOtherLab '>'] ;
            if listingDisplayMode % shows the MATLAB code then link to the m
                s{end+1} = sprintf('<td class="td-linebottomrt" %s> <a href="#Line%d">%d</a></td>', ...
                    tableCellOptionForOtherLab,  maxDataLineList(n), maxDataLineList(n));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt" %s>  %d</td>', ...
                    tableCellOptionForOtherLab, maxDataLineList(n));
            end


            if maxDataLineList(n) > length(f)   % insurance
                codeLine = '';                    % file must have changed
            else
                codeLine = f{maxDataLineList(n)};
            end

            % Squeeze out the leading spaces
            codeLine(cumsum(1-isspace(codeLine))==0)=[];
            % Replace angle brackets
            codeLine = code2html(codeLine);

            maxLineLen = 30;
            if length(codeLine) > maxLineLen
                s{end+1} = sprintf('<td class="td-linebottomrt"><pre>%s...</pre></td>',codeLine(1:maxLineLen));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt"><pre>%s</pre></td>',codeLine);
            end

            if ~hasComparison
                s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>',dataSortedNumCallsList(n));
            else
                s{end+1} = sprintf('<td class="td-linebottomrt">%d <br/> %s%d%s</td>',dataSortedNumCallsList(n), comparisonFontSpan, numCallsForComparison(n), '</span>');
            end
            % output each column of data in the proper order
            for fi=1:length(field_order)
                fidx = field_order(fi);
                % Total time and numcalls are not effected by the
                % Scalapack timing inaccuracies so are not indicated as such
                if hasMPI && fidx>2
                    NOTACCURATETEMP = IsNotAccurateStr;
                else
                    NOTACCURATETEMP = '';
                end
                t = sortedDataList(n,fidx);

                if ~hasComparison
                    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', [formatData(fidx,t, hasMPI) NOTACCURATETEMP] );
                else
                    s{end+1} = sprintf(['<td class="td-linebottomrt">%s<br>' comparisonFontSpan '%s </span></td>'],...
                        [formatData(fidx,t, hasMPI) NOTACCURATETEMP], [formatData(fidx,sortedDataForComparison(n,fidx), hasMPI), NOTACCURATETEMP] );
                end
            end
            % initialise string field to dipslay nothin gif we dont
            % have a lab that we want to compare with.
            comparisonLabPercentField = '';
            if hasComparison
                comparisonLabPercentField = [comparisonFontSpan formatNicePercent(sortedDataForComparison(n,key_data_field), ctotalData(key_data_field)) '</span>'];
                maxDataRatio = max(ctotalData(key_data_field), totalData(key_data_field) );
            else
                maxDataRatio = totalData(key_data_field);

            end

            % output the percentage based on the key sort type.
            s{end+1} = sprintf('<td class="td-linebottomrt" class="td-linebottomrt">%s <br/> %s</td>',...
                formatNicePercent(sortedDataList(n,key_data_field), totalData(key_data_field)),...
                comparisonLabPercentField );

            compareBarChartImageHTML = '';
            if totalData(key_data_field) > 0
                dataRatio = sortedDataList(n,key_data_field)/maxDataRatio;
                if hasComparison
                    compareDataRatio = sortedDataForComparison(n,key_data_field)/maxDataRatio;
                    % html generated here to remove the need for additional if
                    % statements below in the table cell .
                    compareBarChartImageHTML = sprintf('<br/><img src="%s" width=%d height=10></img>', redPixelGif, round(100*compareDataRatio));
                end
            else
                dataRatio = 0;
            end

            % generate histogram bar based on the key sort type.
            s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10>%s</td>', ...
                bluePixelGif, round(100*dataRatio),  compareBarChartImageHTML);

            s{end+1} = '</tr>';
        end

        % Now add a row for everything else
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt">All other lines</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';

        % compute totals for remaining time & memory
        try
            for fi=1:length(field_order)
                fidx = field_order(fi);
                if (fidx ~=4) || hasMPI
                    % this doesn't work for peaks
                    % subtract the total time for all the top 5
                    % (numtoplines)lines executed on this lab from
                    % total
                    % For now don't include lines shaded in red( when in comparison mode)
                    
                    numLines = min(numtoplines, numelOrigMaxDataLineList);
                    
                    %
                    allOtherLineData(fidx) = totalData(fidx) - sum(sortedDataList(1:numLines, fidx));
                    
                else
                    % peak memory needs max.
                    allOtherLineData(fidx) = max(sortedDataList(1:length(maxDataLineList), fidx));
                end
                s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(fidx, allOtherLineData(fidx), hasMPI) );
            end
        catch err %#ok<NASGU>
       end
        % output percentage of "all other lines" by key sort type.
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatNicePercent(allOtherLineData(key_data_field),totalData(key_data_field)));

        if totalData(key_data_field) > 0,
            dataRatio = allOtherLineData(key_data_field)/totalData(key_data_field);
        else
            dataRatio= 0;
        end

        % generate histogram bar for "all other lines" by key sort type.
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*dataRatio));
        s{end+1} = '</tr>';

        % Totals line
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Totals</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';


        mpiComparisonHTML = '';


        for fi=1:length(field_order)
            fidx = field_order(fi);
            % output totals for each column
            if hasComparison
                mpiComparisonHTML =[ comparisonFontSpan '<br/>' formatData(fidx,ctotalData(fidx), hasMPI) '</span>'];
            end
            s{end+1} = sprintf('<td class="td-linebottomrt" bgcolor="#F0F0F0">%s %s</td>', formatData(fidx,totalData(fidx), hasMPI), mpiComparisonHTML );

        end
        if totalData(key_data_field) > 0,
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">100%</td>';
        else
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">0%</td>';
        end

        % no histogram bar here
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';

        s{end+1} = '</tr>';

        s{end+1} = '</table>';
        if hasMPI % only show extra message footer when there is communication
            s{end+1} = labSelectionAndFooterCell{end};
        end
    end
    s{end+1} = '<div class="grayline"/>';

end

% --------------------------------------------------
% End line list section
% --------------------------------------------------

% -------------------------------------------------------------------------
% Children list
% -------------------------------------------------------------------------
if childrenDisplayMode
    % Sort children by key data field (i.e. time, allocated mem, freed mem or peak mem)

    children = ftItem.Children;
    s{end+1} = '<b>Children</b> (called functions)<br/>';

    if isempty(children)
        s{end+1} = 'No children';
    else
        % Children are sorted by total time
        childrenData(:,1)   = [ftItem.Children.TotalTime];
        if hasMem
            childrenData(:,2) = [ftItem.Children.TotalMemAllocated];
            childrenData(:,3) = [ftItem.Children.TotalMemFreed];
            childrenData(:,4) = [ftItem.Children.PeakMem];
        end
        if hasMPI
            %  The fields that are calculated for filepage mode:
            %             BytesSent: 0
            %             BytesReceived: 0
            %             TimeWasted: 0
            childrenData(:,2) = [ftItem.Children.BytesSent];
            childrenData(:,3) = [ftItem.Children.BytesReceived];
            childrenData(:,4) = [ftItem.Children.TimeWasted];
            childrenData(:,5) = [ftItem.Children.CommTime] - [ftItem.Children.TimeWasted];
        end
        [~, dataSortIndex] = sort(childrenData(:,key_data_field));

        s{end+1} = '<p><table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Function Name</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Function Type</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Calls</td>';

        % output column headers for children
        for fi=1:length(field_order)
            fidx = field_order(fi);
            s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' data_fields{fidx} '</td>'];
        end

        % percentage and histogram always go last
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">% ' key_unit_up '</td>'];
        s{end+1} = ['<td class="td-linebottomrt" bgcolor="#F0F0F0">' key_unit_up ' Plot</td>'];
        s{end+1} = '</tr>';

        for i = length(children):-1:1,
            n = dataSortIndex(i);
            s{end+1} = '<tr>';

            % Truncate the name if it gets too long
            displayFunctionName = truncateDisplayName(profileInfo.FunctionTable(children(n).Index).FunctionName,40);

            s{end+1} = sprintf('<td class="td-linebottomrt"><a href="matlab: mpiprofview(%d);">%s</a></td>', ...
                children(n).Index, displayFunctionName);

            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                profileInfo.FunctionTable(children(n).Index).Type);

            s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', ...
                children(n).NumCalls);

            % output data for each column in the correct order
            for fi=1:length(field_order)
                fidx = field_order(fi);
                t = childrenData(n,fidx);
                s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', formatData(fidx, t, hasMPI) );
            end

            % output percentage based on key sort type.
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
                formatNicePercent(childrenData(n,key_data_field), totalData(key_data_field)));

            if totalData(key_data_field) > 0,
                dataRatio = childrenData(n,key_data_field)/totalData(key_data_field);
            else
                dataRatio= 0;
            end

            % generate histogram based on key sort type
            s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
                bluePixelGif, round(100*dataRatio));
            s{end+1} = '</tr>';
        end

        % Now add a row with self-timing information
        s{end+1} = '<tr>';
        s{end+1} = sprintf('<td class="td-linebottomrt">Self %s (built-ins, overhead, etc.)</td>', key_unit);
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt">&nbsp;</td>';

        % output self information for each type of data (time, memory)
        for fi=1:length(field_order)
            fidx = field_order(fi);
            if fidx ~= 4 || hasMPI
                % not for peak
                selfData(fidx) = totalData(fidx) - sum(childrenData(:,fidx));
            else
                % peaks need something different.  (is this meaningless?)
                selfData(fidx) = totalData(fidx);
            end
            s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(fidx, selfData(fidx), hasMPI ) );
        end

        % output percentage
        s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatNicePercent(selfData(key_data_field),totalData(key_data_field)));

        if totalData(key_data_field) > 0,
            dataRatio = selfData(key_data_field)/totalData(key_data_field);
        else
            dataRatio= 0;
        end

        % generate histogram
        s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10></td>', ...
            bluePixelGif, round(100*dataRatio));
        s{end+1} = '</tr>';

        % Totals row
        s{end+1} = '<tr>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Totals</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';

        % output totals for each kind of data
        for fi=1:length(field_order)
            fidx = field_order(fi);
            %             formatIndex = fidx;
            %             if hasMPI && fidx==2
            %             formatIndex = 1; % indicate it is a time measurement
            %             end

            s{end+1} = sprintf('<td class="td-linebottomrt" bgcolor="#F0F0F0">%s</td>',formatData(fidx, totalData(fidx), hasMPI) );
        end

        % percentage is always 100% or 0%
        if totalData(key_data_field) > 0,
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">100%</td>';
        else
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">0%</td>';
        end

        % no histogram for totals
        s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">&nbsp;</td>';

        s{end+1} = '</tr>';

        s{end+1} = '</table>';
    end

    s{end+1} = '<div class="grayline"/>';
end

% --------------------------------------------------
% End children list section
% --------------------------------------------------

if mFileFlag && ~filteredFileFlag
    % Calculate beginning and ending lines for the current function
    % In the expression ftok = xmtok(f), ftok returns information
    % about line continuations.

    ftok = xmtok(f);

    % ftItem.FileName is the path on the lab, if the client's path does not 
    % contain exactly the same string, a call to callstats('file_lines', file) 
    % returns empty. iCallStatsOnClient calls callstats and if this fails, uses
    % findFileNameOnClient to find the client path to the file.
    runnableLineIndex = iCallStatsOnClient('file_lines', ftItem.FileName);
    runnableLines = zeros(size(f));
    runnableLines(runnableLineIndex) = runnableLineIndex;

    % FunctionName takes one of several forms:
    % 1. foo
    % 2. foo>bar
    % 3. foo1\private\foo2
    % 4. foo1/private/foo2>bar
    %
    % We need to strip off everything except for the very last \w+ string

    fname = regexp(ftItem.FunctionName,'(\w+)$','tokens','once');

    strc = getcallinfo(fullName,'-v7.8');
    fcnList = {strc.name};
    fcnIdx = find(strcmp(fcnList,fname)==1);

    if length(fcnIdx) > 1
        % In rare situations, two nested functions can have exactly the
        % same name twice in the same file. In these situations, I will
        % default to the first occurrence.
        fcnIdx = fcnIdx(1);
        warning('distcomp:mpiprofview:FunDisplayWarning', 'Function name %s appears more than once in this file.\nOnly the first occurrence is being displayed.', ...
            fname{1});
    end

    if isempty(fcnIdx)
        % ANONYMOUS FUNCTIONS
        % If we can't find the function name on the list of functions
        % and subfunctions, assume this is an anonymous
        % function. Just display the entire file in this case.
        startLine = 1;
        endLine = length(f);
        lineMask = (startLine:endLine)';
    else
        startLine = strc(fcnIdx).firstline;
        endLine = strc(fcnIdx).lastline;
        lineMask = strc(fcnIdx).linemask;
    end

    runnableLines = runnableLines .* lineMask;

    moreSubfunctionsInFileFlag = 0;
    if endLine < length(f)
        moreSubfunctionsInFileFlag = 1;
    end
    % hiliteOption = [ time | numcalls | coverage | noncoverage | allocmem | freedmem | peakmem | none ]
    % getpref doesn't like spaces in the option names. is there a way around this?
    hiliteOption = getpref('mpiprofiler','hiliteOption',key_unit);

    % if we have no memory data but the current hiliteOption is
    % memory related, we must default back to the current type
    % we are sorting by (i.e. memory).
    if ~hasMem && (strcmp(hiliteOption, 'allocated memory') || ...
            strcmp(hiliteOption, 'freed memory') || ...
            strcmp(hiliteOption, 'peak memory'))
        hiliteOption = key_unit;
    end

    % see iGetOptionStringsMPI() function for MPI options
    if ~hasMPI && any(strcmp(hiliteOption, iGetOptionStringsMPI ))
        hiliteOption = key_unit;
    end

    mlintstrc = [];
    if strcmp(hiliteOption,'mlint') || mlintDisplayMode
        mlintstrc = mlint(fullName,'-struct');

        % Sometimes the number of lines reported for a single mlint message
        % is greater than one. When this is true, we will split the single
        % message into two similar messages, each with its own line number.
        sortFlag = false;
        for i = 1:length(mlintstrc)
            if length(mlintstrc(i).line)>1
                mlintLineList = mlintstrc(i).line;
                % The original mlint message gets one of the line numbers.
                % Deal the rest of the messages out to new messages at the
                % end of the structure.
                sortFlag = true;
                mlintstrc(i).line = mlintLineList(1);
                for j = 2:length(mlintLineList)
                    mlintstrc(end+1) = mlintstrc(i);
                    mlintstrc(end).line = mlintLineList(j);
                end
            end
        end

        % Only sort the mlint structure if multiple lines per message were
        % encountered.
        if sortFlag
            % Sort the result so they go in order of line number
            mlintLines = [mlintstrc.line];
            [~,sortIndex] = sort(mlintLines);
            mlintstrc = mlintstrc(sortIndex);
        end

    end
end

% --------------------------------------------------
% M-Lint list section
% --------------------------------------------------
if mlintDisplayMode
    s{end+1} = '<strong>M-Lint results</strong><br/>';

    if ~mFileFlag || filteredFileFlag
        s{end+1} = 'No MATLAB code to display';
    else
        if isempty(mlintstrc)
            s{end+1} = 'No M-Lint messages.';
        else
            % Remove mlint messages outside the function region
            mlintLines = [mlintstrc.line];
            mlintstrc([find(mlintLines < startLine) find(mlintLines > endLine)]) = [];
            s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
            s{end+1} = '<tr>';
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Line number</td>';
            s{end+1} = '<td class="td-linebottomrt" bgcolor="#F0F0F0">Message</td>';
            s{end+1} = '</tr>';

            for n = 1:length(mlintstrc)
                if (mlintstrc(n).line <= endLine) && (mlintstrc(n).line >= startLine)
                    s{end+1} = '<tr>';
                    if listingDisplayMode
                        s{end+1} = sprintf('<td class="td-linebottomrt"><a href="#Line%d">%d</a></td>', mlintstrc(n).line, mlintstrc(n).line);
                    else
                        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td>', mlintstrc(n).line);
                    end
                    s{end+1} = sprintf('<td class="td-linebottomrt"><span class="mono">%s</span></td>', mlintstrc(n).message);
                    s{end+1} = '</tr>';
                end
            end
            s{end+1} = '</table>';
        end
    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End M-Lint list section
% --------------------------------------------------


% --------------------------------------------------
% Coverage section
% --------------------------------------------------
if coverageDisplayMode
    s{end+1} = '<strong>Coverage results</strong><br/>';

    if ~mFileFlag || filteredFileFlag
        s{end+1} = 'No MATLAB code to display';
    else
        s{end+1} = sprintf('[ <a href="matlab: coveragerpt(fileparts(urldecode(''%s'')))">Show coverage for parent directory</a> ]<br/>', ...
            urlencode(fullName));

        linelist = (1:length(f))';
        canRunList = find(linelist(startLine:endLine)==runnableLines(startLine:endLine)) + startLine - 1;
        didRunList = ftItem.ExecutedLines(:,1);
        notRunList = setdiff(canRunList,didRunList);
        neverRunList = find(runnableLines(startLine:endLine)==0);

        s{end+1} = '<table border=0 cellspacing=0 cellpadding=6>';
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Total lines in function</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', endLine-startLine+1);
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Non-code lines (comments, blank lines)</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(neverRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Code lines (lines that can run)</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(canRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Code lines that did run</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(didRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Code lines that did not run</td>';
        s{end+1} = sprintf('<td class="td-linebottomrt">%d</td></tr>', length(notRunList));
        s{end+1} = '<tr><td class="td-linebottomrt" bgcolor="#F0F0F0">Coverage (did run/can run)</td>';
        if ~isempty(canRunList)
            s{end+1} = sprintf('<td class="td-linebottomrt">%4.2f %%</td></tr>', 100*length(didRunList)/length(canRunList));
        else
            s{end+1} = sprintf('<td class="td-linebottomrt">N/A</td></tr>');
        end
        s{end+1} = '</table>';

    end
    s{end+1} = '<div class="grayline"/>';
end
% --------------------------------------------------
% End Coverage section
% --------------------------------------------------


% --------------------------------------------------
% File listing
% --------------------------------------------------
% Make a lookup table to speed index identification
% The executedLines table is as long as the file and stores the index
% value for every executed line.

% check if the file changed in some major way
if oldListingDisplayMode && badListingDisplayMode
    s{end+1} = sprintf('<p><span class="warning">This file was modified or was different on the cluster than it is on your client matlab. Function listing disabled.</span></p>');
end

if listingDisplayMode
    s{end+1} = '<b>Function code listing</b><br/>';

    if ~mFileFlag || filteredFileFlag
        s{end+1} = 'No MATLAB code to display';
    else

        executedLines = zeros(length(f),1);
        executedLines(ftItem.ExecutedLines(:,1)) = 1:size(ftItem.ExecutedLines,1);

        % Enumerate all alphanumeric values for later use in linking code
        alphanumericList = ['a':'z' 'A':'Z' '0':'9' '_'];
        alphanumericArray = zeros(1,128);
        alphanumericArray(alphanumericList) = 1;

        [bgColorCode,bgColorTable,textColorCode,textColorTable] = makeColorTables( ...
            f,hiliteOption, ftItem, ftok, startLine, endLine, executedLines, runnableLines,...
            mlintstrc, maxNumCalls);

        % ----------------------------------------------
        s{end+1} = '<form method="POST" action="matlab:mpiprofviewgateway">';
        s{end+1} = 'Color highlight code according to ';
        s{end+1} = sprintf('<input type="hidden" name="profileIndex" value="%d" />',idx);
        s{end+1} = '<select name="hiliteOption" onChange="this.form.submit()">';
        optionsList = { };
        optionsList{end+1} = 'time';
        optionsList{end+1} = 'numcalls';
        optionsList{end+1} = 'coverage';
        optionsList{end+1} = 'noncoverage';
        optionsList{end+1} = 'mlint';
        if hasMem
            % add more hilight options when memory data is available
            optionsList{end+1} = 'allocated memory';
            optionsList{end+1} = 'freed memory';
            optionsList{end+1} = 'peak memory';
        end

        if hasMPI
            %   mpioptionstrings
            %            'data sent';
            %            'data rec';
            %            'comm waiting time';
            %
            % CHK add true or false
            mpioption = iGetOptionStringsMPI();
            optionsList(end:end+2) = mpioption(2:4);
        end
        optionsList{end+1} = 'none';
        for n = 1:length(optionsList)
            if strcmp(hiliteOption, optionsList{n})
                selectStr='selected';
            else
                selectStr = '';
            end
            s{end+1} = sprintf('<option %s>%s</option>', selectStr, optionsList{n});
        end
        s{end+1} = '</select>';
        s{end+1} = '</form>';


        % --------------------------------------------------
        s{end+1} = '<pre>';

        % Display column headers across the top
        s{end+1} = ' <span style="color: #FF0000; font-weight: bold; text-decoration: none">  time</span> ';
        s{end+1} = '<span style="color: #0000FF; font-weight: bold; text-decoration: none">  calls</span> ';

        if hasMem
            s{end+1} = '<span style="color: #20AF20; font-weight: bold; text-decoration: none">                mem</span> ';
        end

        if hasMPI
            mpiCodeListingFieldColor = '#20AF20';
            s{end+1} = sprintf('<span style="color: %s; font-weight: bold; text-decoration: none">&nbsp;&nbsp;&nbsp;(sent/rec/waiting)</span> ', mpiCodeListingFieldColor);
        end

        % hook this up to gui later
        showJitLines = getpref('mpiprofiler','showJitLines',false);

        if showJitLines
            % Don't expect this to work - we don't have the runtime
            % information from the labs about what lines were jitted while
            % profiling. Even using iCallStatsOnClient doesn't fix this.
            jitLines = callstats('jit_lines',ftItem.FileName);
            s{end+1} = '<span style="color: #FF0000; font-weight: bold; text-decoration: none"> unjitted</span> ';
        end

        s{end+1} = ' <span style="font-weight: bold; text-decoration: none">line</span><br/>';

        % Cycle through all the lines
        for n = startLine:endLine

            lineIdx = executedLines(n);
            if lineIdx>0,
                callsPerLine = ftItem.ExecutedLines(lineIdx,2);
                timePerLine = ftItem.ExecutedLines(lineIdx,3);
                if hasMem %
                    memAlloc = ftItem.ExecutedLines(lineIdx,4);
                    memFreed = ftItem.ExecutedLines(lineIdx,5);
                    peakMem = ftItem.ExecutedLines(lineIdx,6);
                end
                if hasMPI %
                    % getting [byteSent byteRec timeWasted];
                    mpiFieldVector = ftItem.ExecutedLines(lineIdx,4:6);
                end

            else
                timePerLine = 0;
                callsPerLine = 0;
                memAlloc = 0;
                memFreed = 0;
                peakMem = 0;
                % byteSent   byteRec  timeWasted stored in mpiFieldVector
                mpiFieldVector = [0 0 0];
            end

            % Display the mlint message if necessary
            color = bgColorTable{bgColorCode(n)};
            textColor = textColorTable{textColorCode(n)};

            if mlintDisplayMode
                if any([mlintstrc.line]==n)
                    s{end+1} = sprintf('<a name="Line%d"></a>',n);
                end
            end

            if strcmp(hiliteOption,'mlint')
                % Use the color as the indicator that an mlint message
                % occurred on this line
                if ~strcmp(color,'#FFFFFF')
                    % Mark this line for in-document linking from the mlint
                    % list
                    mlintIdx = find([mlintstrc.line]==n);
                    for nMsg = 1:length(mlintIdx)
                        s{end+1} = '                    ';
                        s{end+1} = sprintf('<span style="color: #F00">%s</span><br/>', ...
                            mlintstrc(mlintIdx(nMsg)).message);
                    end
                end
            end

            % Modify text so that < and > don't cause problems
            if n > length(f)    % insurance
                codeLine = '';    % file must have changed
            else
                codeLine = code2html(f{n});
            end

            % Display the time
            if timePerLine > 0.01,
                s{end+1} = sprintf('<span style="color: #FF0000"> %5.2f </span>', ...
                    timePerLine);
            elseif timePerLine > 0
                s{end+1} = '<span style="color: #FF0000">&lt; 0.01 </span>';
            else
                s{end+1} = '       ';
            end

            % Display the number of calls
            if callsPerLine > 0,
                s{end+1} = sprintf('<span style="color: #0000FF">%7d </span>', ...
                    callsPerLine);
            else
                s{end+1} = '        ';
            end

            % Display memory data
            if hasMem
                if memAlloc > 0 || memFreed > 0 || peakMem > 0
                    suff = {'b' 'k' 'm' 'g'};
                    str = sprintf('%s/%s/%s', ...
                        toKb(memAlloc,'%0.3g',suff), ...
                        toKb(memFreed,'%0.3g',suff), ...
                        toKb(peakMem,'%0.3g',suff));
                    % 3 5-digit numbers, 2 slashes, 2 spaces = 19 spaces
                    str = sprintf('<span style="color: #20AF20">%19s </span>', str);
                else
                    str = '                    ';
                end
                s{end+1} = str;
            end
            if hasMPI
                if any(mpiFieldVector > 0)
                    suff = {'b' 'k' 'm' 'g'}; %bytes kilo mega giga
                    str = sprintf('%s/%s/%.3gs', ...
                        toKb(mpiFieldVector(1),'%0.3g',suff), ...
                        toKb(mpiFieldVector(2),'%0.3g',suff), ...
                        mpiFieldVector(3));

                    % 3 5-digit numbers, 2 slashes, 2 spaces = 20 spaces
                    str = sprintf('<span style="color: #20AF20">%20s&nbsp;</span>', str);
                else
                    str = sprintf('%20s&nbsp;', ' ');
                end
                s{end+1} = str;
            end

            if showJitLines
                if any(jitLines==n) || runnableLines(n) == 0 || callsPerLine == 0
                    s{end+1} = '        ';
                else
                    s{end+1} = '<span style="color: #FF0000">    X   </span>';
                end
            end

            % Display the line number
            if callsPerLine > 0
                s{end+1} = sprintf('<span style="color: #000000; font-weight: bold"><a href="matlab: opentoline(urldecode(''%s''),%d)">%4d</a></span> ', ...
                    urlencode(fullName), n, n);
            else
                s{end+1} = sprintf('<span style="color: #A0A0A0">%4d</span> ', n);
            end

            if any(n==maxDataLineList),
                % Mark the busy lines in the file with an anchor
                s{end+1} = sprintf('<a name="Line%d"></a>',n);
            end

            if callsPerLine > 0
                % Need to add a space to the end to make sure the last
                % character is an identifier.
                codeLine = [codeLine ' '];
                % Use state machine to substitute in linking code
                codeLineOut = '';

                state = 'between';

                substr = [];
                for m = 1:length(codeLine),
                    ch = codeLine(m);
                    % Deal with the line with identifiers and Japanese comments .
                    % 128 characters are from 0 to 127 in ASCII
                    if abs(ch)>127
                        alphanumeric = 0;
                    else
                        alphanumeric = alphanumericArray(ch);
                    end

                    switch state
                        case 'identifier'
                            if alphanumeric,
                                substr = [substr ch];
                            else
                                state = 'between';
                                if isfield(targetHash,substr)
                                    substr = sprintf('<a href="matlab: mpiprofview(%d);">%s</a>', targetHash.(substr), substr);
                                end
                                codeLineOut = [codeLineOut substr ch];
                            end
                        case 'between'
                            if alphanumeric,
                                substr = ch;
                                state = 'identifier';
                            else
                                codeLineOut = [codeLineOut ch];
                            end
                        otherwise

                            error('distcomp:mpiprofiler:UnexpectedState','Unknown case %s', state);

                    end
                end
                codeLine = codeLineOut;
            end

            % Display the line
            s{end+1} = sprintf('<span style="color: %s; background: %s; padding: 1">%s</span><br/>', ...
                textColor, color, codeLine);

        end

        s{end+1} = '</pre>';
        if moreSubfunctionsInFileFlag
            s{end+1} = '<p><p>Other subfunctions in this file are not included in this listing.';
        end
    end
end

% --------------------------------------------------
% End file list section
% --------------------------------------------------

s{end+1} = '</body>';
s{end+1} = '</html>';



% --------------------------------------------------
function shortFileName = truncateDisplayName(longFileName,maxNameLen)
%TRUNCATEDISPLAYNAME  Truncate the name if it gets too long

shortFileName = longFileName;
if length(longFileName) > maxNameLen,
    shortFileName = char(com.mathworks.util.FileUtils.truncatePathname( ...
        longFileName, maxNameLen));
end

% --------------------------------------------------
function b = hasMpiData(s)
% Does this profiler data structure have profiling information in it?
b = (isfield(s, 'BytesSent') || ...
    (isfield(s, 'FunctionTable') && isfield(s.FunctionTable, 'TimeWasted')));


% --------------------------------------------------
function b = hasMemoryData(s)
% Does this profiler data structure have profiling information in it?
b = (isfield(s, 'PeakMem') || ...
    (isfield(s, 'FunctionTable') && isfield(s.FunctionTable, 'PeakMem')));

% --------------------------------------------------
function s = formatData(key_data_field, num, hasMPI)
% Format a number as seconds or bytes depending on the
% value of key_data_field (1 == time else memory)
if nargin == 2
    hasMPI = false;
end
if (key_data_field == 1) || ((key_data_field == 4 || key_data_field == 5) && hasMPI)
    if num > 0
        s = sprintf('%4.3f&nbsp;s', num);
    else
        s = '0&nbsp;s';
    end
else

    s = toKb(num);
end

% --------------------------------------------------
function s = formatNicePercent(a, b)
% Format the ratio of two numbers as a percentage.
% Use 0% when either number is zero.
if b > 0 && a > 0
    s = sprintf('%3.1f%%', 100*a/b);
else
    s = '0%';
end

% --------------------------------------------------
function x = toKb(y,fmt,suffixes)
% convert number of bytes into a nice printable string

values = {1 1024 1024 1024 1024 };

if nargin < 3
    suffixes = { '&nbsp;b' '&nbsp;Kb' '&nbsp;Mb' '&nbsp;Gb' '&nbsp;Tb' };
end

suff = suffixes{1};

for i = 1:length(values)
    if abs(y) >= values{i}
        suff = suffixes{i};
        y = y ./ values{i};
    else
        break;
    end
end

if nargin == 1
    if strcmp(suff, suffixes{1})
        fmt = '%4.0f';
    else
        fmt = '%4.2f';
    end
end

x = sprintf([fmt suff], y);

% --------------------------------------------------
function n = busyLineSortKeyStr2Num(str)
% Convert between string names and profile data sort types
% (see key_data_field)
mpiStrList = iGetOptionStringsMPI();
mpiStrMatch = strcmp(str, mpiStrList);
if strcmp(str, 'time')
    n = 1;
    % check for has MPI values like communication time
elseif any(mpiStrMatch)
    indexConv = 1:numel(mpiStrMatch);
    n = indexConv(mpiStrMatch);
elseif strcmp(str, 'allocated memory')
    n = 2;
elseif strcmp(str, 'freed memory')
    n = 3;
elseif strcmp(str, 'peak memory')
    n = 4;

else
    warning('distcomp:mpiprofiler:UnknownSortKind','Unknown sort kind: %s', str);
    n = 1;
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function str = busyLineSortKeyNum2StrMPI(n)
% Convert from data sort types to string name.
% (see key_data_field)


optionsList = iGetOptionStringsMPI();
str = optionsList{n};

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function optionsList = iGetOptionStringsMPI
optionsList = {'time' 'data sent' 'data rec' 'comm waiting time' 'active com time'};

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function str = busyLineSortKeyNum2Str(n)
% Convert from data sort types to string name.
% (see key_data_field)
strs = { 'time' 'allocated memory' 'freed memory' 'peak memory' };
str = strs{n};

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function [bgColorCode,bgColorTable,textColorCode,textColorTable] = makeColorTables( ...
    f, hiliteOption, ftItem, ftok, startLine, endLine, executedLines, ...
    runnableLines, mlintstrc, maxNumCalls)

% Take a first pass through the lines to figure out the line color
bgColorCode = ones(length(f),1);
textColorCode = ones(length(f),1);
textColorTable = {'#228B22','#000000','#A0A0A0'};
hasMPI = hasMpiData(ftItem);
% Ten shades of green
memColorTable = { '#FFFFFF' '#00FF00' '#00EE00' '#00DD00' '#00CC00' ...
    '#00BB00' '#00AA00' '#009900' '#008800' '#007700'};
shadesOfRed = {'#FFFFFF','#FFF0F0','#FFE2E2','#FFD4D4', '#FFC6C6', ...
    '#FFB8B8','#FFAAAA','#FF9C9C','#FF8E8E','#FF8080'};
mpioption = iGetOptionStringsMPI;
switch hiliteOption
    case 'time'
        % Ten shades of red
        bgColorTable = shadesOfRed;
        key_data_field = 1;
    case 'numcalls'
        % Ten shades of blue
        bgColorTable = {'#FFFFFF','#F5F5FF','#ECECFF','#E2E2FF', '#D9D9FF', ...
            '#D0D0FF','#C6C6FF','#BDBDFF','#B4B4FF','#AAAAFF'};
    case 'coverage'
        bgColorTable = {'#FFFFFF','#E0E0FF'};
    case 'noncoverage'
        bgColorTable = {'#FFFFFF','#E0E0E0'};
    case 'mlint'
        bgColorTable = {'#FFFFFF','#FFE0A0'};

    case 'allocated memory'
        bgColorTable = memColorTable;
        key_data_field = 2;

    case 'freed memory'
        bgColorTable = memColorTable;
        key_data_field = 3;

    case 'peak memory'
        bgColorTable = memColorTable;
        key_data_field = 4;
        %case mpioption{1}


    case 'none'
        bgColorTable = {'#FFFFFF'};
    otherwise
        bgColorTable = memColorTable;
        key_data_field = -1;
        % check for mpi options
        if hasMPI % TRUE
            for i=1:numel(mpioption)
                if strcmp(hiliteOption, mpioption{i});
                    %          bgColorTable = memColorTable;
                    key_data_field = i;

                end
            end
        end
        if key_data_field < 0
            warning('distcomp:mpiprofiler:UnknownHiliteOption', 'hiliteOption %s unknown', hiliteOption);
            bgColorTable = shadesOfRed;
            key_data_field = 1;
        end
end




maxData(1) = max(ftItem.ExecutedLines(:,3));
[~, len] = size(ftItem.ExecutedLines);
if len > 3
    % if len > 3 then we must have memory data available
    maxData(2) = max(ftItem.ExecutedLines(:,4));
    maxData(3) = max(ftItem.ExecutedLines(:,5));
    maxData(4) = max(ftItem.ExecutedLines(:,6));
end

for n = startLine:endLine

    if ftok(n) == 0
        % Non-code line, comment or empty. Color is green
        textColorCode(n) = 1;
    elseif ftok(n) < n
        % This is a continuation line. Make it the same color
        % as the originating line
        bgColorCode(n) = bgColorCode(ftok(n));
        textColorCode(n) = textColorCode(ftok(n));
    else
        % This is a new executable line
        lineIdx = executedLines(n);
        mpioptions = iGetOptionStringsMPI();
        % added has MPI stuff
        if (strcmp(hiliteOption,'time') || any(strcmp(hiliteOption, mpioptions)) || ...
                strcmp(hiliteOption,'allocated memory') || ...
                strcmp(hiliteOption,'freed memory') || ...
                strcmp(hiliteOption,'peak memory'))

            if lineIdx > 0
                textColorCode(n) = 2;
                if ftItem.ExecutedLines(lineIdx,key_data_field+2) > 0
                    dataPerLine = ftItem.ExecutedLines(lineIdx,key_data_field+2);
                    ratioData = dataPerLine/maxData(key_data_field);
                    bgColorCode(n) = ceil(10*ratioData);
                else
                    % The amount of time (or memory) spent on the line was negligible
                    bgColorCode(n) = 1;
                end
            else
                % The line was not executed
                textColorCode(n) = 3;
                bgColorCode(n) = 1;
            end

        elseif strcmp(hiliteOption,'numcalls')

            if lineIdx > 0
                textColorCode(n) = 2;
                if ftItem.ExecutedLines(lineIdx,2)>0;
                    callsPerLine = ftItem.ExecutedLines(lineIdx,2);
                    ratioNumCalls = callsPerLine/maxNumCalls;
                    bgColorCode(n) = ceil(10*ratioNumCalls);
                else
                    % This line was not called
                    bgColorCode(n) = 1;
                end
            else
                % The line was not executed
                textColorCode(n) = 3;
                bgColorCode(n) = 1;
            end

        elseif strcmp(hiliteOption,'coverage')

            if lineIdx > 0
                textColorCode(n) = 2;
                bgColorCode(n) = 2;
            else
                % The line was not executed
                textColorCode(n) = 3;
                bgColorCode(n) = 1;
            end

        elseif strcmp(hiliteOption,'noncoverage')

            % If the line did execute or it is a
            % non-breakpointable line, then it should not be
            % flagged
            if (lineIdx > 0) || (runnableLines(n) == 0)
                textColorCode(n) = 2;
                bgColorCode(n) = 1;
            else
                % The line was not executed
                textColorCode(n) = 2;
                bgColorCode(n) = 2;
            end

        elseif strcmp(hiliteOption,'mlint')

            if any([mlintstrc.line]==n)
                bgColorCode(n) = 2;
                textColorCode(n) = 2;
            else
                bgColorCode(n) = 1;
                if lineIdx > 0
                    textColorCode(n) = 2;
                else
                    % The line was not executed
                    textColorCode(n) = 3;
                end
            end

        elseif strcmp(hiliteOption,'none')

            if lineIdx > 0
                textColorCode(n) = 2;
            else
                % The line was not executed
                textColorCode(n) = 3;
            end

        end
    end
end


% -------------------------------------------------------------------------
% mpiprofiler addition:
% Function that displays plots on the profiled program generated in
% dctMpiProfHelpers
% -------------------------------------------------------------------------
function s = iMakePlotPage(profileInfo, labSelectionListBoxHtml, viewSelectedOptions)

hasMPI = hasMpiData(profileInfo);

s = {};
s{1} = makeheadhtml;
% All html produced for parallel mode profiler.java should have a labindex and
% number of labs in the title.
% In Plot View there is no distinction between distributed, parallel and serial
% where numberOfLabs == 1;

% *********
% Stores the state of mpiprofview in the html title for parsing by
% Profiler.java
% iLabInt2Str allows us to deal with labno which do not correspond to
% labindex.
%
% format <title > selectedLabIndex, numlabs, numcomparisons, comparisonLabIndex .... </title>
% no particular lab is selected in plotview but the persistent info is
% passed on to Profiler.java via the title.
numOfComp = numel(viewSelectedOptions.compLabInd);
s{end+1} = sprintf('<title>%d, %d, %d, %s, Plot Page</title>', ...
    viewSelectedOptions.mainLabInd,...
    (viewSelectedOptions.numberOfLabs),...
    numOfComp, ...
    int2str(viewSelectedOptions.compLabInd));
% **********

cssfile = which('matlab-report-styles.css');
s{end+1} = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);
s{end+1} = '</head>';
s{end+1} = '<body>';

% Summary info
status = mpiprofile('status');
s{end+1} = '<span style="font-size: 14pt; padding: 0; background: #FFE4B0">Plot View</span><br/>';
s{end+1} = sprintf('<i>Generated %s using %s time.</i><br/>',datestr(now), status.Timer);

if isempty(profileInfo.FunctionTable)
    s{end+1} = '<p><span style="color:#F00">No profile information to display.</span><br/>';
    s{end+1} = 'Note that built-in functions do not appear in this report.<p>';
end

if hasMPI
    s{end+1}=    '<span style="font-size: 14pt; padding: 0;background: #FFBB00">';
    s{end+1} = [ viewSelectedOptions.displayTxtMsg '</span><br/>'];
end
s{end+1} = [labSelectionListBoxHtml '<br/>'] ;
% display all the images generated in the dctMpiProfHelpers and stored int
% he OptionData structure. This is at the moment just static as its not
% possible to easily link autogenerated images .
s{end+1} = sprintf('<img src="file:///%s" style="padding: 8;" > </img>', viewSelectedOptions.savedImageFiles{:});
s{end+1} = '</body> </html>';


% -------------------------------------------------------------------------
% Function that displays the table heading for make summary page
% -------------------------------------------------------------------------
% Refactored and moved outside of makesummarypage
% so that the heading can be repeated inside the table listing
function [str sortIndex] = iMakeSummaryPageTableHeadingAndSortIndex(profileInfo, sortMode, labDescription)
hasMem = hasMemoryData(profileInfo);
hasMPI = hasMpiData(profileInfo);

allTimes = [profileInfo.FunctionTable.TotalTime];
totalTimeFontWeight = 'normal';
selfTimeFontWeight = 'normal';
alphaFontWeight = 'normal';
numCallsFontWeight = 'normal';
allocMemFontWeight = 'normal';
freeMemFontWeight = 'normal';
peakMemFontWeight = 'normal';
selfMemFontWeight = 'normal';

if hasMPI
    selfComFontWeight = 'normal';
    bytesFontWeight = 'normal';
    compratioFontWeight = 'normal';
    comTimeFontWeight = 'normal';
end

% Calculate self time and optionally self memory list and mpi com times
allSelfTimes = zeros(size(allTimes));
if hasMem
    allSelfMem = zeros(size(allTimes));
end

if hasMPI
    allSelfCom = zeros(size(allTimes));
end

for i = 1:length(profileInfo.FunctionTable)
    allSelfTimes(i) = profileInfo.FunctionTable(i).TotalTime - ...
        sum([profileInfo.FunctionTable(i).Children.TotalTime]);
    if hasMem
        netMem = (profileInfo.FunctionTable(i).TotalMemAllocated - ...
            profileInfo.FunctionTable(i).TotalMemFreed);
        childNetMem = (sum([profileInfo.FunctionTable(i).Children.TotalMemAllocated]) - ...
            sum([profileInfo.FunctionTable(i).Children.TotalMemFreed]));
        allSelfMem(i) = netMem - childNetMem;
    end
    if hasMPI
        % redPixel = [pixelPath 'one-pixel.gif'];
        netCom = profileInfo.FunctionTable(i).TimeWasted;
        childCom = sum([profileInfo.FunctionTable(i).Children.TimeWasted]);
        allSelfCom(i) = netCom - childCom;
    end

end
% end self time calculation for sorting

switch(sortMode)

    case 'totaltime'
        totalTimeFontWeight = 'bold';
        [~,sortIndex] = sort(allTimes,'descend');
    case 'comtime'
        comTimeFontWeight = 'bold';
        [~,sortIndex] = sort([profileInfo.FunctionTable.CommTime],'descend');
    case 'compratio'
        compratioFontWeight = 'bold';
        totalTimeV = [profileInfo.FunctionTable.TotalTime];
        [~,sortIndex] = sort( ( totalTimeV - [profileInfo.FunctionTable.CommTime])./totalTimeV,'ascend');
    case 'bytestot'
        bytesFontWeight = 'bold';
        [~,sortIndex] = sort(([profileInfo.FunctionTable.BytesReceived]+[profileInfo.FunctionTable.BytesSent]),'descend');
    case 'selfwasted'
        selfComFontWeight = 'bold';
        [~,sortIndex] = sort(allSelfCom,'descend');
    otherwise
        % original profview code
        if strcmp(sortMode,'totaltime')
            totalTimeFontWeight = 'bold';
            [~,sortIndex] = sort(allTimes,'descend');
        elseif strcmp(sortMode,'selftime')
            selfTimeFontWeight = 'bold';
            [~,sortIndex] = sort(allSelfTimes,'descend');
        elseif strcmp(sortMode,'alpha')
            alphaFontWeight = 'bold';
            allFunctionNames = {profileInfo.FunctionTable.FunctionName};
            [~,sortIndex] = sort(allFunctionNames);
        elseif strcmp(sortMode,'numcalls')
            numCallsFontWeight = 'bold';
            [~,sortIndex] = sort([profileInfo.FunctionTable.NumCalls],'descend');
        elseif strcmp(sortMode,'allocmem')
            allocMemFontWeight = 'bold';
            [~,sortIndex] = sort([profileInfo.FunctionTable.TotalMemAllocated],'descend');
        elseif strcmp(sortMode,'freedmem')
            freeMemFontWeight = 'bold';
            [~,sortIndex] = sort([profileInfo.FunctionTable.TotalMemFreed],'descend');
        elseif strcmp(sortMode,'peakmem')
            peakMemFontWeight = 'bold';
            [~,sortIndex] = sort([profileInfo.FunctionTable.PeakMem],'descend');
        elseif strcmp(sortMode,'selfmem')
            selfMemFontWeight = 'bold';
            [~,sortIndex] = sort(allSelfMem,'descend');
        else
            warning('distcomp:mpiprofiler:BadSortMode', 'Unsupported sort mode %s', sortMode);
        end
end

s{1} = '<tr bgcolor="#D0D0D0">';
s{end+1} = '<td class="td-linebottomrt"  valign="top">';
s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''alpha'');mpiprofview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Function Name</span></a>',alphaFontWeight);

if ~isempty(labDescription)
    s{end+1} = sprintf('<br/><span style="color: #FF0000;font-size: 10pt">comparison with lab %s </span>', labDescription);
end

s{end+1} = '</td>';
s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''numcalls'');mpiprofview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Calls</span></a></td>',numCallsFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''totaltime'');mpiprofview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Total Time</span></a></td>',totalTimeFontWeight);
s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''selftime'');mpiprofview(0)">';
s{end+1} = sprintf('<span style="font-weight:%s">Self Time</span></a>*</td>',selfTimeFontWeight);

if hasMem
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''allocmem'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Allocated Memory</span></a></td>',allocMemFontWeight);

    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''freedmem'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Freed Memory</span></a></td>',freeMemFontWeight);

    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''selfmem'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Self Memory</span></a></td>',selfMemFontWeight);

    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''peakmem'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Peak Memory</span></a></td>',peakMemFontWeight);
end
% reset mpiHTML
mpiHTML = '';
if hasMPI
    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''comtime'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Total Comm Time</span></a></td>',comTimeFontWeight);

    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''selfwasted'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Self Comm Waiting Time</span></a></td>',selfComFontWeight);

    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''bytestot'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Total Interlab Data</span></a></td>',bytesFontWeight);

    s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">';
    s{end+1} = '<a href="matlab: setpref(''mpiprofiler'',''sortMode'',''compratio'');mpiprofview(0)">';
    s{end+1} = sprintf('<span style="font-weight:%s">Computation <br/>Time Ratio  </span></a></td>',compratioFontWeight);

    mpiHTML = 'and <span style="color: #FF6F00"> orange band </span> is self waiting time';
end
s{end+1} = '<td class="td-linebottomrt" bgcolor="#D0D0D0" valign="top">Total Time Plot<br/>';

s{end+1} = sprintf('<span style="font-size: 10pt">(<span style="color: #0000FF;">dark</span> band is self time %s)</span></td>', mpiHTML);
s{end+1} = '</tr>';
str = [s{:}];

% -------------------------------------------------------------------------
% calls multiple imakeListbox functions to create a html listbox toolbar
% -------------------------------------------------------------------------
function headerhtml = iGenHtmlListBoxAndButtonMenu(funName, idx, hasMPI, hasPerLab, pageType, callbackViewOptionStruct)
% Checking for hasMPI here to allow a basic selection of labno for non
% parallel profile infos for future integration with distributed jobs.

inPlotPage = strcmp(pageType, 'Plot');

defaultListBoxStruct = struct('selectedStr', '', ...
    'titleString', '', ...
    'selectionOptionStrings', '', ...
    'selectionDisplayStrings', '', ...
    'buttonTitleString', '',...
    'Type', 'Main');

% Currently  the button titlestring is only used by the
% plotSelectionListBoxFunction
titleFontSpan = '<span style="font-size: 12pt;font-weight: bold; padding: 0">';

currentLabNo = callbackViewOptionStruct.mainLabInd;

if hasMPI
    plotListBox = defaultListBoxStruct;
    plotListBox.Type = 'Plot';
    plotListBox.titleString = '<span style="font-size: 10pt"> Show Figures (all labs):&nbsp;</span>';
    plotListBox.buttonTitleString = '';
    if inPlotPage
        plotListBox.selectedStr = callbackViewOptionStruct.plotSelectionStr;
    end
    if hasPerLab
        plotListBox.selectionOptionStrings = {'',...
            'Plot TotalTime Histogram', ...
            'Plot PerLab Communication'...
            'Plot CommTimePerLab'...
            };
        plotListBox.selectionDisplayStrings = plotListBox.selectionOptionStrings;
        plotListBox.selectionDisplayStrings{1} = 'No Plot';
        plotListBox.selectionDisplayStrings{2} = 'Plot Time Histograms';
        plotListBox.selectionDisplayStrings{3} = 'Plot All PerLab Communication';

    else
        plotListBox.selectionOptionStrings = {'',...
            'Plot TotalTime Histogram', ...
            };
        plotListBox.selectionDisplayStrings = {'No Plot',...
            'Plot Time Histograms', ...
            };

    end


    plotListBoxHtml = iMakePlotSelectionListBox(funName, plotListBox, currentLabNo, idx);
else
    % No mpi fields present
    % notify the user they are not able to use full features of parallel profiler
    plotListBoxHtml = [titleFontSpan 'No communication fields found</span>. <br/> Use <a href="matlab: doc(''mpiprofile'');">MPIPROFILE ON</a> before running your code.'];
end

% In case of the plot page only show the one listbox
if inPlotPage
    headerhtml = plotListBoxHtml;
    return;
end

numberOfLabs = callbackViewOptionStruct.numberOfLabs;

% This button will show for all profile info
buttonStruct.buttonTitleStr =  'Compare (max vs. min TotalTime)';
buttonStruct.mainLabStr = 'max TotalTime';
buttonStruct.compLabStr = 'min TotalTime';
buttonStruct.Type = 'AutoSelectComparison';
compareMaxMinButtonHtml = iMakeAutoSelectComparisonButton(currentLabNo, funName,...
    idx, buttonStruct);

if hasMPI
    buttonHtml{1} = [titleFontSpan 'Automatic&nbsp;Comparison&nbsp;Selection</span><br/>'];
    buttonHtml{2} = compareMaxMinButtonHtml;
    buttonStruct.buttonTitleStr =  'Compare (max vs. min CommTime)';
    buttonStruct.mainLabStr = 'max CommTime';
    buttonStruct.compLabStr = 'min CommTime';
    buttonStruct.Type = 'AutoSelectComparison';
    buttonHtml{3} = iMakeAutoSelectComparisonButton(currentLabNo, funName,...
        idx, buttonStruct);

    compListBox = defaultListBoxStruct;
    compListBox.selectedStr = callbackViewOptionStruct.compSelectionStr;

    % User visible selection strings
    compListBox.selectionOptionStrings = {...
        'None', ...
        'min TotalTime', ...
        'maxAggregate',...
        'min Executed Aggregate'};
    compListBox.selectionDisplayStrings = {...
        'None', ...
        'min TotalTime', ...
        'max Time Aggregate   ',...
        'min Time >0 Aggregate'};

    comparisonListBoxHtml = iMakeComparisonLabSelectionListBox(numberOfLabs,...
        currentLabNo,...
        compListBox,...
        funName,...
        idx);

else % No MPI (maybe even standard profile infos)
    % Deals with generating the two features allowed with no MPI:
    % maxmin Time comparison and Reset (clear comparison).
    if strcmp(pageType, 'Summary')
        buttonHtml{1} = compareMaxMinButtonHtml;
        buttonStruct.buttonTitleStr =  'Clear Comparison';
        buttonStruct.mainLabStr = '1';
        buttonStruct.compLabStr = 'None';
        buttonStruct.Type = 'AutoSelectComparison';
        buttonHtml{2} = iMakeAutoSelectComparisonButton(currentLabNo, funName,...
            idx, buttonStruct);
    else
     buttonHtml{1} = '';
     buttonHtml{2} = '';
    end
    comparisonListBoxHtml = '';
end
mainListBox = defaultListBoxStruct;
if hasMPI
    mainListBox.selectionOptionStrings = {...
        'max TotalTime',...
        'maxAggregate'};
    mainListBox.selectionDisplayStrings = {...
        'max Total Time',...
        'max Time Aggregate'};

    mainListBox.selectedStr = callbackViewOptionStruct.labSelectionStr;
    mainListBoxHtml = iMakeLabSelectionListBox(numberOfLabs,...
        currentLabNo,...
        mainListBox,...
        funName,...
        idx);
    selectionTitle = [titleFontSpan '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Manual&nbsp;Comparison&nbsp;Selection</span><br/>'];
else
    mainListBoxHtml = '';
    selectionTitle = [titleFontSpan 'Comparisons&nbsp;are&nbsp;disabled</span><br/>Use the top toolbar to browse other labs.'];
end
headerhtml = iGenHtmlListBoxTable({plotListBoxHtml},...
    buttonHtml,...
    { selectionTitle mainListBoxHtml comparisonListBoxHtml });

% -------------------------------------------------------------------------
% Formats a nice html table to fit all the listboxes and buttons
% expects at least one button and three listBoxHtmlCells
% -------------------------------------------------------------------------
function s = iGenHtmlListBoxTable(plotListBoxCell, buttonHtmlCell, listBoxHtmlCell)
labSelectionCellColor = 'bgcolor="#BABABA"';
buttonHtml = sprintf('<td align="right" %s> %s </td>',...
    labSelectionCellColor, [buttonHtmlCell{:}],...
    labSelectionCellColor, [listBoxHtmlCell{:}]);
s = sprintf('<table name="topMenuTable" border="1" cellspacing="0" cellpadding="2" bgcolor="#D0D0FF"> <tr align="right">  %s <td>%s </td></tr></table><br/>',...
    buttonHtml, [plotListBoxCell{:}]);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function valid = iIsString(value)
valid = ischar(value) && (size(value, 2) == numel(value));

% -------------------------------------------------------------------------
% returns a formated html table row for the function name specified in the
% currentTableEntry which is of the form profileInfo.FunctionTable(n).
% -------------------------------------------------------------------------
function htmlout = iMakeSummaryPageTableRow(comparisonInfo, isComparison, maxTime,  functionName, fcnIndex, rowHighLightColor, comparisonGifFiles)
% iGenerateComparisonRow is modelled on one iteration of the for loop
% inside makesummarypage function of profview.

redPixelGif = comparisonGifFiles{1};
lightPixelGif = comparisonGifFiles{2};
orangePixelGif = comparisonGifFiles{3};

hasMem = hasMemoryData(comparisonInfo);
hasMPI = hasMpiData(comparisonInfo);

s = {};

% by default highlight the comparison rows a tint specified in
% makesummarypage and passed in as redPixelGif
thisLabNo = comparisonInfo.LabNo;
isAggregate = iIsLabIndexAnAggregate(thisLabNo);
if fcnIndex == 0
    % adds a temporary empty function table entry so that the comparison
    % can display that this function was not executed on the comparison lab
    fcnIndex = numel(comparisonInfo.FunctionTable)+1;
    comparisonInfo.FunctionTable(fcnIndex) = iGetEmptyFunctionTable();
    comparisonInfo.FunctionTable(fcnIndex).FunctionName = functionName;

end
if isComparison>0
    % use the main lab fcnIndex to link
    linkindex = isComparison;
    colorOfFont = '#AA5501';
    fontStyle = ' font-style: italic;';
else
    % its the main index
    linkindex = fcnIndex;
    colorOfFont = '#000000';
    fontStyle = '';
end
s{end+1} = sprintf('<tr %s frame="void" border=0 style="color: %s; font-weight: normal; %s text-decoration: none">', rowHighLightColor, colorOfFont, fontStyle);

% Truncate the name if it gets too long
displayFunctionName = truncateDisplayName(functionName, 40);

numCalls = comparisonInfo.FunctionTable(fcnIndex).NumCalls;

% Specifies the highlight color for the first cell of functions which are not called by this
% comparison lab
if numCalls == 0
    % apply only to num Calls
    formatCellColor = ' bgcolor="#FFF0F0"';
else
    formatCellColor = '';
end

if isAggregate
    thisFcnLabNo = comparisonInfo.FcnTableLabIndex(fcnIndex);
    % reusable temp variable mpiHTML
    mpiHTML = sprintf('(lab&nbsp;%d)', thisFcnLabNo);
else
    mpiHTML = '';
end

s{end+1} = ...
    sprintf('<td class="td-linebottomrt"> <a href="matlab: dctMpiProfHelpers(''changeFcn'', %d);">%s</a> %s', ...
    linkindex, displayFunctionName, mpiHTML);

if isempty(regexp(comparisonInfo.FunctionTable(fcnIndex).Type,'^M-','once'))
    s{end+1} = sprintf(' (%s)</td>', ...
        comparisonInfo.FunctionTable(fcnIndex).Type);
else
    s{end+1} = '</td>';
end

s{end+1} = sprintf('<td %s class="td-linebottomrt">%d</td>', ...
    formatCellColor, numCalls);

totalTime = comparisonInfo.FunctionTable(fcnIndex).TotalTime;
% Don't display the time if it's less than zero
% TOTAL TIME
if  totalTime> 0,
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', ...
        formatData(1, totalTime));
else
    s{end+1} = '<td class="td-linebottomrt">0 s</td>';
end

if hasMPI
    childTime = sum([comparisonInfo.FunctionTable(fcnIndex).Children.TimeWasted]);
    peakTimeWasted = comparisonInfo.FunctionTable(fcnIndex).TimeWasted;
    selfTimeWasted = peakTimeWasted - childTime;
else
    selfTimeWasted = 0;
end

if maxTime > 0,
    timeRatio = totalTime/maxTime;
    selfTime = totalTime - sum([comparisonInfo.FunctionTable(fcnIndex).Children.TotalTime]);
    selfTimeRatio = selfTime/maxTime;
    selfWastedRatio = selfTimeWasted/maxTime;
else
    timeRatio = 0;
    selfTime = 0;
    selfTimeRatio = 0;
    selfWastedRatio = 0;
end
% SELF TIME
s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>', formatData(1, selfTime));

if hasMem
    % display alloc, freed, self and peak mem on summary page
    totalAlloc = comparisonInfo.FunctionTable(fcnIndex).TotalMemAllocated;
    totalFreed = comparisonInfo.FunctionTable(fcnIndex).TotalMemFreed;
    netMem = totalAlloc - totalFreed;
    childAlloc = sum([comparisonInfo.FunctionTable(fcnIndex).Children.TotalMemAllocated]);
    childFreed = sum([comparisonInfo.FunctionTable(fcnIndex).Children.TotalMemFreed]);
    childMem = childAlloc - childFreed;
    selfMem = netMem - childMem;
    peakMem = comparisonInfo.FunctionTable(fcnIndex).PeakMem;
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalAlloc));
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,totalFreed));
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,selfMem));
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',formatData(2,peakMem));
end

if hasMPI %
    % display CommTime, Self TimeWasted (waited), TotalBytes, Percentage Computation Time
    totalRec = comparisonInfo.FunctionTable(fcnIndex).BytesReceived;
    totalSent = comparisonInfo.FunctionTable(fcnIndex).BytesSent;
    netTotalBytes = totalRec + totalSent;

    % The following adds a ** to any time value that may not be accurate due to
    % some underlying profiling limitation (e.g. scalapack functions do not
    % return correct communication time).
    IsNotAccurateStr = '';

    if iHasInaccurateMPITimings(comparisonInfo.FunctionTable(fcnIndex).FunctionName)

        IsNotAccurateStr = '**';
    end
    commTime = comparisonInfo.FunctionTable(fcnIndex).CommTime;
    % computatioon time is approx total time - commtime
    computationTime = (totalTime - commTime);

    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',[formatData(1,commTime) IsNotAccurateStr]);
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',[formatData(1,selfTimeWasted) IsNotAccurateStr]);
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',[formatData(2,netTotalBytes)  IsNotAccurateStr]);
    s{end+1} = sprintf('<td class="td-linebottomrt">%s</td>',[formatNicePercent(computationTime,totalTime) IsNotAccurateStr]);
end

if hasMPI
    % produce a comparative plot of self time, self wasted comm time
    % and remaining total time in function
    mpiHTML = sprintf('<img src="%s" width=%d height=10 alt="light blue bar shows total time.">', orangePixelGif, round(100*selfWastedRatio));
else
    mpiHTML = '';
end

s{end+1} = sprintf('<td class="td-linebottomrt"><img src="%s" width=%d height=10>%s<img src="%s" width=%d height=10></td>', ...
    redPixelGif, round(100*(selfTimeRatio - selfWastedRatio)), mpiHTML, ...
    lightPixelGif, round(100*(timeRatio-selfTimeRatio)));
% note selfWastedRatio will be zero if mpidata does not exists

s{end+1} = '</tr>';
% output the lines as a single html string
htmlout = [s{:}];

%--------------------------------------------------------------------------
% iMakeAutoSelectComparisonButton(curLab, funName, fidx)
%--------------------------------------------------------------------------
function str = iMakeAutoSelectComparisonButton(curLab, funName, fidx, buttonTitleAndLabStruct)

if funName == 0
    funName = '';
end
s = {};
s{end+1} = '<form method="GET" action="matlab:dctMpiProfHelpers htmlpost">';
s{end+1} = sprintf('<input type="submit" value="%s" STYLE="font-weight:normal; background:#f0f0f0 none; width:22em" />',...
    buttonTitleAndLabStruct.buttonTitleStr);

s{end+1} = sprintf('<input type="hidden" name="Type" value="AutoSelectComparison" />');
s{end+1} = sprintf('<input type="hidden" name="SelectionStr" value="%s" />', buttonTitleAndLabStruct.mainLabStr);
s{end+1} = sprintf('<input type="hidden" name="CurFunIndex" value="%d" />', fidx);
s{end+1} = sprintf('<input type="hidden" name="CurLab" value="%d" />', curLab);
s{end+1} = sprintf('<input type="hidden" name="CompSelectionStr" value="%s" />',  buttonTitleAndLabStruct.compLabStr);
if iIsString(funName)
    s{end+1} = sprintf('<input type="hidden" name="CurFcnName" value="%s" />', funName);
else
    s{end+1} = '<input type="hidden" name="CurFcnName" value="" />';
end
s{end+1} = '</form>';
str = [s{:}];

%--------------------------------------------------------------------------
% iMakePlotSelectionListBox(funName, titleString, selectedStr, selectionOptionStrings)
%--------------------------------------------------------------------------
function str = iMakePlotSelectionListBox(funName, listBoxStruct, currentLabNo, functionIndex)
%     listBoxStruct = struct('selectedStr', '', 'titleString', '',...
%         'selectionOptionStrings', '', ...
%         'selectionDisplayStrings', '', ...
%         'buttonTitleString', '',...
%         'Type', '');
% numel(selectionOptionStrings) MUST BE EQUAL to
% numel(selectionDisplayStrings)

buttonTitle =  listBoxStruct.buttonTitleString;
selectedStr = listBoxStruct.selectedStr;
s={};
s{end+1} = sprintf('<form method="GET" action="matlab: dctMpiProfHelpers htmlpost">');
s{end+1} = listBoxStruct.titleString;

if ~isempty(buttonTitle)
    s{end+1} = sprintf('<br/><input type="submit" value="%s" />', buttonTitle);
    autoSubmission = '';
else
    if isunix
        autoSubmission = ' onKeyPress="this.form.submit()" onClick="this.form.submit()"';
    else
        autoSubmission = ' onChange="this.form.submit()"';
    end
end

s{end+1} = sprintf('<input type="hidden" name="plotqxqType" value="%s" />', listBoxStruct.Type );
% Add the CurFuncIndex and set CurLab to a sensible value for plots.  Need this because:
% 1.    Need to ensure that the CurLab value specified here is the same as all other instances of 
%       CurLab in the html source.  Otherwise, bad stuff happens in the browsers on 64-bit platforms 
%       (Windows and Linux) and on Mac.
% 2.    We can't rely on CurFcnName to be accurate because the ">" character is not dealt with 
%       properly.  Therefore we need to be able to deduce the function name from the CurLab and 
%       CurFuncIndex in dctMpiProfHelpers.m.
s{end+1} = sprintf('<input type="hidden" name="CurLab" value="%d" />', currentLabNo);
s{end+1} = sprintf('<input type="hidden" name="CurFunIndex" value="%d" />',functionIndex);
% -1 indicates an invalid choice for the html post to dctMpiProfHelpers helpers.
s{end+1} = sprintf('<tt> <select name="SelectionStr" %s multiple="multiple" size="4">', autoSubmission);
% number of selection items which are defined not by lab no but description
% like max lab etc.
% max selects the lab with the maximum value whoever that may be
optionsList = listBoxStruct.selectionOptionStrings;
displayStrings = listBoxStruct.selectionDisplayStrings;


% we use a for loop here as this is the way profview generates listbox.
% can also be done with vectorized sprintf

for n = 1:length(optionsList)
    if strcmp(selectedStr, optionsList{n})
        selectStr='selected';
    else
        selectStr = '';
    end
    s{end+1} = sprintf('<option value="%s" %s>%s</option>', optionsList{n}, selectStr, displayStrings{n} );
end


s{end+1} = '</select>';

if iscell(funName)
    % show a selection of funNames that can be selected
    s{end+1} = sprintf('<select name="CurFcnName" %s>', autoSubmission);
    s{end+1} = sprintf('<option>%s</option>', funName{:});
    s{end+1} = ' <option selected></option>';
    s{end+1} = '</select>';
else
    % otherwise submit a default form with current selected function
    s{end+1} = sprintf('<input type="hidden" name="CurFcnName" value="%s" />',funName);
end

s{end+1} = '</form></tt>';
str = [s{:}];


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function str = iMakeLabSelectionListBox(numberOfLabs, mainLabInd, curListBox, funName, fidx)
s={};
mainLabStr = curListBox.selectedStr;
% A number of selection items which are defined not by labindex but description
% like max lab etc.
optionStrings = curListBox.selectionOptionStrings;

s{end+1} = sprintf('<form method="GET" action="matlab: dctMpiProfHelpers htmlpost">');
s{end+1} = '<span style="font-size: 10pt">&nbsp;&nbsp;&nbsp;&nbsp;Go&nbsp;to lab: </span>';
% input name has been changed as a work around to the faulty browser form cache in r2007a
% on Linux see G377435. XXXXqxqType is removed and replaced with Type in iParseHtmlPost in
% dctMpiProfHelpers.
s{end+1} = '<input type="hidden" name="mainqxqType" value="Main" />';
s{end+1} = sprintf('<input type="hidden" name="CurLab" value="%d" />',mainLabInd);
s{end+1} = sprintf('<input type="hidden" name="CurFunIndex" value="%d" />',fidx);

s{end+1} = '<select name="SelectionStr" onChange="this.form.submit()" STYLE="width:14em;">';

numTxtItems = numel(optionStrings);
optionsList = cell(numberOfLabs + numTxtItems,1);
displayStrings = optionsList;

for ii = 1:numberOfLabs
    optionsList{numTxtItems + ii} = int2str(ii);
end

displayStrings(numTxtItems+1:end) = optionsList(numTxtItems+1:end);
displayStrings(1:numTxtItems) = curListBox.selectionDisplayStrings;

% add the max all text options to listbox
optionsList(1:numTxtItems) = optionStrings;
% optionsList{end-1} = 'all labs TotalTime Histogram';
% we use a for loop here as this is the way profview generates listbox.
% can also be done with vectorized sprintf
foundStr = false;
for n = 1:length(optionsList)
    if strcmp(mainLabStr, optionsList{n})
        foundStr = true;
        selectStr='selected';
    else
        selectStr = '';
    end
    % displayes the displayStrings but passes the values from
    % selectionOptionStrings
    s{end+1} = sprintf('<option value="%s" %s>%s</option>', optionsList{n}, selectStr, displayStrings{n} );
end

%if the selection string was not found add to list and select
if ~foundStr
    s{end+1} = sprintf('<option selected>%s</option>', mainLabStr);
end
s{end+1} = '</select>';
% This field is currently not used as posts do not work correctly for all
% function names (April 2007).
s{end+1} = sprintf('<input type="hidden" name="CurFcnName" value="%s" />',funName);

s{end+1} = '</form>';
str = [s{:}];

%--------------------------------------------------------------------------
% str = iMakeComparisonLabSelectionListBox
%--------------------------------------------------------------------------
function str = iMakeComparisonLabSelectionListBox(numberOfLabs, curLab, compListBox, funName, fidx)
s={};
selectedStr = compListBox.selectedStr;
% the comparison strings to show in additon to the labindex selection
optionStrings = compListBox.selectionOptionStrings;

s{end+1} = sprintf('<form method="GET" action="matlab: dctMpiProfHelpers htmlpost">');
s{end+1} = '<span style="font-size: 10pt">Compare with: </span>';

s{end+1} = '<input type="hidden" name="compqxqType" value="Comparison" />';
s{end+1} = sprintf('<input type="hidden" name="SelectionStr" value="%d" />',curLab);
s{end+1} = sprintf('<input type="hidden" name="CurFunIndex" value="%d" />',fidx);
s{end+1} = sprintf('<input type="hidden" name="CurLab" value="%d" />',curLab);

s{end+1} = '<select name="CompSelectionStr" onChange="this.form.submit()" STYLE="width:14em;">';
% Adds options for selection by description at end of optionlist
% selects the lab with the minimum valueoverall or in current function
% depending on funName field

numTxtItems = numel(optionStrings);
optionsList = cell(numberOfLabs + numTxtItems,1);

% generate the labindex options
for ii = 1:numberOfLabs
    optionsList{ii + numTxtItems} = sprintf('%d',(ii));
end
% add the text options to listbox
optionsList(1:numTxtItems) = optionStrings;
displayStrings = optionsList;
displayStrings(1:numTxtItems) = compListBox.selectionDisplayStrings;

foundStr = false;
for n = 1:length(optionsList)
    if strcmp(selectedStr, optionsList{n})
        selectStr='selected';
        foundStr = true;
    else
        selectStr = '';
    end
    % displayes the displayStrings but passes the values from
    % selectionOptionStrings
    s{end+1} = sprintf('<option value="%s" %s>%s</option>', optionsList{n}, selectStr, displayStrings{n} );
end
%if the selection string was not found add to list and select but dont do
%anything if clicked
if ~foundStr
    s{end+1} = sprintf('<option value="None" selected>%s</option>', selectedStr);
end

s{end+1} = '</select>';
% not currently used see iMakeLabSelectionListBox
s{end+1} = sprintf('<input type="hidden" name="CurFcnName" value="%s" />',funName);

s{end+1} = '</form>';
str = [s{:}];

%--------------------------------------------------------------------------
% Returns a boolean indicating if the function is a Scalapack or related function
% which does not have accurate communication data.
%--------------------------------------------------------------------------
function isInaccurate = iHasInaccurateMPITimings(functionName)
strCell = {'distributed.svd', '@distributed/private/scalaSvdmex', ...
    '@distributed/private/scalaSvd', ...
    '/lapack/dgeqrf', ...
    'dgetrf', ...
    '/lapack/dormqr', ...
    '@distributed/private/scalaCholmex', ...
    '@distributed/private/scalaEigmex', ...
    '@distributed/private/scalaLUmex', ...
    'matfun/@distributed/private/scalaSvdmex', ...
    '@distributed/private/scalaLUsolvemex'
    };
isInaccurate = any(strcmp(functionName, strCell));



%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [sortedForComparisonData numCalls] = iGetExecutedDataForLines(compareItem, dataLineList)
% find data for matching lines from a comparison item (which must be a FunctionTable
% Entry). This function is called from makefilepage when hasComparison is
% true
execLinesDataMatrix = compareItem.ExecutedLines;
indexRange = 1:size(execLinesDataMatrix,1);

numberOfLines = numel(dataLineList);
indexes = zeros(numberOfLines,1);
numCalls = zeros(numberOfLines,1);

% Use intersect
for i= 1:numberOfLines
    dataidx = indexRange(execLinesDataMatrix(:,1) == dataLineList(i));
    if ~isempty(dataidx)
        indexes(i) = dataidx;
    end
end
nonZeroIndexes = (indexes>0);
% find all the corresponding data for lines called in current lab and
% current function

sortedForComparisonData(nonZeroIndexes, 1:5) = execLinesDataMatrix(indexes(nonZeroIndexes), 3:end);
numCalls(nonZeroIndexes) = execLinesDataMatrix(indexes(nonZeroIndexes), 2);
% Insert empty values for line indexes which could not be found in the
% execLinesDataMatrix
numZeroRows = sum(~nonZeroIndexes);
sortedForComparisonData(~nonZeroIndexes, 1:5) = zeros(numZeroRows, 5);


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function eft = iGetEmptyFunctionTable( funcTableEntry, reset)
persistent emptyFT;
% reset the persistent table entry
if nargin > 1 && reset
emptyFT = [];
return;
end

if isempty(emptyFT)
    emptyFT = dctMpiProfHelpers('getEmptyFunctionTable');
end
eft = emptyFT;
if nargin>0
    % copy the function name and related fields to new empty version of
    % that function's FunctionTable entry.
    eft.CompleteName = funcTableEntry.CompleteName;
    eft.FunctionName = funcTableEntry.FunctionName;
    eft.FileName = funcTableEntry.FileName;
    eft.ExecutedLines = zeros(size(funcTableEntry.ExecutedLines));
    % ensure the line numbers are the same ensure the line numbers are the same in the executed lines field.

    if ~isempty(eft.ExecutedLines)
        eft.ExecutedLines(:,1) = funcTableEntry.ExecutedLines(:,1);
    end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [sortedExecutedLines sortedDataIndex] = iSortExecutedLinesByField ( ftItem , lnindex)
[~, sortedDataIndex] = sort(ftItem.ExecutedLines(:,lnindex));
%change to descending
sortedDataIndex = flipud(sortedDataIndex);
% fipud is mostly equivalent to option (1, 'Descend') in sort.
% However I have to use flipud instead of descend because otherwise
% different lines are selected when all the lines have the same time
sortedExecutedLines = ftItem.ExecutedLines(sortedDataIndex,:);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% does an ascending sort
function [sortedTable sortedVector resortIndex] = iSortTableAndVectorByField ( tableMatrix, tableVector, field)
[~, resortIndex] = sort(tableMatrix(:, field), 1, 'Descend');
sortedTable =  tableMatrix(resortIndex,:);
sortedVector = tableVector(resortIndex);

%--------------------------------------------------------------------------
% light version of int2str which assumes NaN = -1
%--------------------------------------------------------------------------
function str = iLabInt2Str(mynum)
if isnan(mynum)
    mynum = -1;
end
str = sprintf('%d', mynum);


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function str = iGetLabDescription(labIndex)

if iIsLabIndexAnAggregate(labIndex)
    switch(labIndex) % get a descriptive explanation
        case -1
            str =  'max time';
        case -2
            str = 'min time';
        otherwise
            str = 'Aggregate';

    end
% else it must be a labindex
elseif ~isempty(labIndex)
    str = sprintf('%d', labIndex);
else
    str = '';
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function ist = iIsLabIndexAnAggregate(labIndex)
ist = labIndex<0;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function colorStr = iGetColorStrIndicatorForDecimal(calcOverTotalTime)
% if less than 20% spent in communication
% highlight as green
greenBackgroundColor = '#90FF90';
normalProfilerPinkishColor = '#FFE4B0';
redBackgroundColor =  '#FFCCCC';
if calcOverTotalTime > 0.80
    colorStr = greenBackgroundColor;
elseif calcOverTotalTime > 0.60
    colorStr = normalProfilerPinkishColor;
else
    colorStr = redBackgroundColor;
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [ind indexFcnsNotToDisplay] = iFindIndexOfFcnsToFilterOut(profileInfo)
% Index of functions to filter out just in makefilepage and makesummarypage
% (makesummarypage and makefilepage) Here we can add any functions that we
% do not want displayed based on the actual function name
% allFunctionNames = {profileInfo.FunctionTable.FunctionName};
% indexFcnsNotToDisplay =  strcmp(allFunctionNames, {'distributed.mtimes'};
ind = profileInfo.RootIndex;
indexFcnsNotToDisplay = false(numel(profileInfo.FunctionTable));
indexFcnsNotToDisplay(ind) = 1;

% -------------------------------------------------------------------------
% finds the MATLAB file using which. Will only be called if pGetMcode() fails
% -------------------------------------------------------------------------
function [fullName finderr]  = iFindFileOnClient(ftItem, fullName)
% if we cannot find the full path because the cluster does't have a
% shared file system with client display user message notifying
% file location is different to worker
iDisplayMessageInConsoleOnce(...
    ['File name %s for function %s \n'...
    'is not in the same location that was run on the MATLAB worker\n'...
    'MPIPROFVIEW is assuming the file is available on the client path.\n'...
    'This message will only be shown once. See MPIPROFILE in the Parallel\n'...
    'Computing Toolbox documentation.\n'],...
    fullName, ftItem.FunctionName);

% check and find the correct file if its a private function or on clients path
[fullName finderr] = findFileNameOnClient(fullName);


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function hasfields = iHasPerLabFields(profileInfo)
hasfields = ~isempty(profileInfo.FunctionTable) && isfield(profileInfo.FunctionTable, 'BytesReceivedPerLab');

% %--------------------------------------------------------------------------
% %--------------------------------------------------------------------------
% function whichFileName = iGetFileFromFunctionName(ftItem)
% whichFileName = ftItem.FunctionName;
% whichFileName = regexprep(whichFileName, '>.*', '');
% whichFileName(find(whichFileName == '.', 1, 'last')) = '/';

% -------------------------------------------------------------------------
% Error message handler. It either just displays message or warning .
% should not abort so error is not called
% -------------------------------------------------------------------------
function iDisplayMessageInConsoleOnce(varargin)
persistent warnOnce;
if isempty(warnOnce)
    warnOnce = true;
    fprintf(varargin{:});
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function onworker = iIsOnWorker()
onworker = system_dependent('isdmlworker');

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function iVerifyOnClient(numargs)
%iVerifyOnClient :verifies that this function is running on MATLAB client.
% Error if trying to execute profview on the labs.
if iIsOnWorker()
    error('distcomp:mpiprofview:RunOnLabs', ...
        ['Should not execute %s with %d args on the MATLAB worker.\n'...
        'Run MPIPROFILE VIEWER in PMODE or with a profile info array on the client.\n'...
        'See also the Parallel Computing Toolbox documentation.'], mfilename, numargs);
else
    % Do nothing
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function out = iCallStatsOnClient( arg, filename )
% filename could be the path to a file on the lab/worker. If this
% location is not on the client's path with exactly the same string
% callstats('file_lines',..) returns empty. If this happens, we use
% findFileNameOnClient to get a path to the file on the client, and use
% this to call callstats a second time.

% callstats on original filename
out = callstats( arg, filename );

% If the output is empty AND this is a file_lines call, try again with
% findFileNameOnClient
if isempty( out ) && strcmp( arg, 'file_lines' )
    out = callstats( arg, findFileNameOnClient( filename ) );
end

