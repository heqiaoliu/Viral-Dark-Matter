function varargout = signalbuilder(blockH, method, varargin)
%SIGNALBUILDER - Command line interface to the Simulink Signal Builder block.
%
%  [TIME, DATA] = SIGNALBUILDER(BLOCK) Returns the X coordinates, TIME, and Y
%  coordinates, DATA, of the Signal Builder block, BLOCK.  TIME and DATA take
%  different formats depending on the block configuration:
%
%    Configuration:        TIME/DATA format:
%
%    1 signal, 1 group     Row vector of break points
%
%    >1 signal, 1 group    Column cell vector where each element corresponds to
%                          a separate signal and contains a row vector of breakpoints
%
%    1 signal, >1 group    Row cell vector where each element corresponds to a
%                          separate group and contains a row vector of breakpoints
%
%    >1 signal, >1 group   Cell matrix where each element (i, j) corresponds to
%                          signal i and group j.
%
%
%  [TIME, DATA, SIGNAMES] = SIGNALBUILDER(BLOCK) Returns the signal names,
%  SIGNAMES, in a string or a cell array of strings.
%
%  [TIME, DATA, SIGNAMES, GROUPNAMES] = SIGNALBUILDER(BLOCK) Returns the group
%  names, GROUPNAMES in a string or a cell array of strings.
%  
%  CREATING A NEW BLOCK 
%    
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES) 
%  Creates a new Signal Builder block at PATH using the specified values. 
%  If PATH is empty, the function creates the block in a new model with a 
%  default name. If DATA is a cell array and TIME is a vector, the function 
%  duplicates the TIME values for each element of DATA.  Each vector within 
%  TIME and DATA must be the same length and have at least two elements.  
%  If TIME is a cell array, all elements in a column must have the same 
%  initial and final value.  To use default values for signal names, SIGNAMES,
%  and group names, GROUPNAMES, omit these values.  The function returns the 
%  path to the new block, BLOCK.
%
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES, VIS) 
%  Creates a new Signal Builder block and sets the visible signals in each 
%  group based on the values of the matrix VIS. VIS must be the same size as 
%  the cell array DATA. When you first create a signal builder block, its
%  first signal is always visible. This behavior is regardless of the value
%  of the VIS option.
%
%  BLOCK = SIGNALBUILDER(PATH, 'CREATE', TIME, DATA, SIGNAMES, GROUPNAMES, VIS, POS)
%  Creates a new Signal Builder block and sets the block position to POS.
%
%  ADDING NEW GROUPS
%
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPEND', TIME, DATA, SIGNAMES, GROUPNAMES) or 
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPENDGROUP', TIME, DATA, SIGNAMES, GROUPNAMES) 
%  Appends new groups to the Signal Builder block, BLOCK.  The TIME and DATA 
%  arguments must have the same number of signals as the existing block.
%   
%  ADDING NEW SIGNALS TO CURRENT GROUPS
%
%  BLOCK = SIGNALBUILDER(BLOCK, 'APPENDSIGNAL', TIME, DATA, SIGNAMES)
%  Appends new signals to ALL groups in Signal Builder block, BLOCK. You 
%  must append signals to all groups in the block; you cannot append signals 
%  to only a subset of groups. As a result, you must provide TIME and DATA 
%  arguments for either one  group (append the same signal(s) to all groups) 
%  or for all  groups. You can omit signal names, SIGNAMES, to use default
%  values.
%
%  SETTING SIGNALS VISIBILITY
%
%  SIGNALBUILDER(BLOCK, 'SHOWSIGNAL', SIGNAL, GROUP) 
%  Sets signals, SIGNAL, from groups, GROUP, to be visible. SIGNALs can 
%  be the unique name of a signal, a scalar index of a signal, or an array 
%  of signal indices.  GROUP parameter can be a unique group name, a scalar 
%  index, or an array of indices.
%
%  SIGNALBUILDER(BLOCK, 'HIDESIGNAL', SIGNAL, GROUP) 
%  Set signals, SIGNAL, from groups, GROUP, to be invisible.
%
%  GET/SET METHODS FOR SPRECIFIC SIGNALS AND GROUPS 
%
%  [TIME, DATA] = SIGNALBUILDER(BLOCK, 'GET', SIGNAL, GROUP) Gets the time and 
%  data values for the specified signal(s) and group(s).  The SIGNAL parameter 
%  can be the unique name of a signal, a scalar index of a signal, or an array 
%  of signal indices.  The GROUP parameter can be a unique group name, a scalar 
%  index, or an array of indices.
%
%  SIGNALBUILDER(BLOCK, 'SET', SIGNAL, GROUP, TIME, DATA) Sets the time and 
%  data values for the specified signal(s) and group(s).  To remove groups and
%  signals, use empty values of TIME and DATA. You can only remove signals
%  from all groups. You cannot delete signals from only a subset of groups. 
%
%  QUERY AND SET THE ACTIVE GROUP USED IN SIMULATION
%
%  INDEX = SIGNALBUILDER(BLOCK, 'ACTIVEGROUP') Gets the index of the currently 
%  active group
% 
%  SIGNALBUILDER(BLOCK, 'ACTIVEGROUP', INDEX) Sets the active group index
%  to INDEX
%
%  PRINTING
%
%  SIGNALBUILDER(BLOCK, 'PRINT', CONFIG, <PRINT ARGS>) Prints a single group.  
%  The function includes the contents of the group after removing the interface 
%  items from the window. Refer to the help on PRINT for information about the 
%  available calling syntax and format for <PRINT ARGS>.  You can control the 
%  details of printing with the optional CONFIG structure. This structure can 
%  contain the following fields:
% 
%      groupIndex := Group Index
%       timeRange := Time range (limited to full group range)
%  visibleSignals := Index of signals to display
%         yLimits := Cell array of Y Limits for each signal
%          extent := Pixel extent of captured figure
%       showTitle := True (default) indicates a title should be added
% 
%  The default value of each parameter is based on the current display. If the 
%  interface is not open, then the default of each parameter is based on the last 
%  active display 
% 
%  FIGH = SIGNALBUILDER(BLOCK, 'PRINT', CONFIG, 'FIGURE') Prints the signal builder
%  to a new hidden figure handle FIGH.

%

%  Copyright 2003-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.20.2.1 $  $Date: 2010/07/12 15:22:55 $

error(nargchk(1, 8, nargin, 'struct'));
if ( ( nargin == 1 || ~strcmpi(method, 'create') ) && isempty(blockH))
    error('signalbuilder:signalbuilder:noBlockSpecified',...
          'BLOCK must be specified when METHOD is not ''create'' or number of inputs is one.');
end

if nargin < 2
    method = 'props';
end

if ~ischar(method)
    error('signalbuilder:signalbuilder:stringMethod', 'METHOD (second input argument) should be a string.');
end

% Put arguments in a canonical form
if  ~strcmpi(method, 'create')       % if method is NOT create
    if  ~is_signal_builder_block(blockH)
        error('signalbuilder:signalbuilder:invalidBlock', 'Not a SignalBuilder block.');            
    end
    objH = get_param(blockH, 'Handle');
    blockH = objH;    
else                                 % if method is create
    if  ~isempty(blockH) && ~is_valid_path(blockH)
        error('signalbuilder:signalbuilder:invalidBlockPath', 'Invalid block path.');
    end
end

switch lower(method)
    %---------------------------------------------------------------------%       
    case 'get'
        % nargin = 4 : [ Time, Data ] = signalbuilder( blockH, 'get', SignalIdx, GroupIdx )
        local_nargin_check(method, nargin, 4);
        [signal, group] = local_get_set_nargin_check(method, varargin{:});
        
        SBSigSuite = getSBSigSuite(blockH);
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = groupSignalGet(SBSigSuite, signal, group);

    %---------------------------------------------------------------------%       
    case 'appendsignal' 
        % nargin = 5 : signalbuilder( blockH, 'appendsignal', Time, Data, sigNames )
        local_nargin_check(method, nargin, 5);

        if nargin < 4
            error('signalbuilder:signalbuilder:appendSignalMethod', ...
                'TIME AND DATA cannot be empty.');
        end
        SBSigSuite = getSBSigSuite(blockH);
        
        if nargin < 5
            groupSignalAppend(SBSigSuite, varargin{1}, varargin{2});
        else
            groupSignalAppend(SBSigSuite, varargin{1}, varargin{2}, varargin{3});
        end
        
        signal_append(blockH, SBSigSuite);
        varargout{1} = blockH;

    %---------------------------------------------------------------------%       
    case 'movesignal'
        % nargin = 4 : signalbuilder( blockH, 'movesignal', oldIdx, newIdx)
    %---------------------------------------------------------------------%       
    case 'movegroup'
        % nargin = 4 : signalbuilder( blockH, 'movesignal', oldIdx, newIdx)
    %---------------------------------------------------------------------%
    %
   
    case 'showsignal'
        % nargin = 4 : signalbuilder( blockH, 'showsignal', SignalIdx, GroupIdx )
        local_nargin_check(method, nargin, 4);
        [signal, group] = local_get_set_nargin_check(method, varargin{:});   
        SBSigSuite = getSBSigSuite(blockH);
        [signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, signal, group);             
        ActiveGroup = SBSigSuite.ActiveGroup;
     
        forceOpen = false;
        figH = get_param(blockH, 'UserData');
        if isempty(figH) || ~ishghandle(figH, 'figure')
            forceOpen = true;
            open_system(blockH);
            figH = get_param(blockH, 'UserData');
        end
        UD = get(figH, 'UserData');        
        
        
        grpCnt = length(groupIdx);
        sigCnt = length(signalIdx);
        for gidx = 1:grpCnt;
            m = groupIdx(gidx);
            curVis = UD.dataSet(m).activeDispIdx;
            for sidx = 1:sigCnt
                n = signalIdx(sidx);
                % if signal n is already visible, don't do anything.
                if (m == ActiveGroup)
                    toAdd = (curVis == n);
                    %if (sum(toAdd) == 0)
                    if (~any(toAdd))
                        UD = signal_show(UD, n, m);
                    end
                end
            end
            newVis = signalIdx;
            totalVis = unique([curVis newVis]);
            totalVis = sort(totalVis(:), 'descend')';
            UD.dataSet(m).activeDispIdx = totalVis;
        end
        
        UD = cant_undo(UD);
        set(UD.dialog, 'UserData', UD) 
        
        % Close the GUI if it was forced open
        if(forceOpen)
            UD = set_dirty_flag(UD);
            close_internal(UD);
        end        
        
    %---------------------------------------------------------------------%       
    case 'hidesignal'
        % nargin = 4 : signalbuilder( blockH, 'hidesignal', SignalIdx, GroupIdx )
        local_nargin_check(method, nargin, 4);
        [signal, group] = local_get_set_nargin_check(method, varargin{:});   
        SBSigSuite = getSBSigSuite(blockH);
        [signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, signal, group);             
        ActiveGroup = SBSigSuite.ActiveGroup;
       
        forceOpen = false;
        figH = get_param(blockH, 'UserData');
        if isempty(figH) || ~ishghandle(figH, 'figure')
            forceOpen = true;
            open_system(blockH);
            figH = get_param(blockH, 'UserData');
        end
        UD = get(figH, 'UserData');        

        grpCnt = length(groupIdx);
        sigCnt = length(signalIdx);
        for gidx = 1:grpCnt;
            m = groupIdx(gidx);
            curVis = UD.dataSet(m).activeDispIdx;
            for sidx = 1:sigCnt
                n = signalIdx(sidx);
                toRemove = (curVis == n);
                %if (sum(toRemove) ~= 0)
                if (any(toRemove))
                    curVis(toRemove) = [];
                    if (m == ActiveGroup)
                        axesIdx = find(UD.dataSet(m).activeDispIdx == n);
                        UD = signal_hide(UD, n, m, axesIdx);
                    end
                end
            end
            UD.dataSet(m).activeDispIdx = curVis;
        
        end
        
        UD = cant_undo(UD);
        set(UD.dialog, 'UserData', UD) 
        
        % Close the GUI if it was forced open
        if(forceOpen)
            UD = set_dirty_flag(UD);
            close_internal(UD);
        end        
        
    %---------------------------------------------------------------------%       
    case 'set' 
        % nargin = 4 : signalbuilder( blockH, 'set', SignalIdx, GroupIdx )
        % nargin = 5 : signalbuilder( blockH, 'set', SignalIdx, GroupIdx, Time )
        % nargin = 6 : signalbuilder( blockH, 'set', SignalIdx, GroupIdx, Time, Data )
        local_nargin_check(method, nargin, 6);
        [signal, group, time, data] = local_get_set_nargin_check(method, varargin{:});       
        SBSigSuite = getSBSigSuite(blockH);
        [signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, signal, group);        
        
        ActiveGroup = SBSigSuite.ActiveGroup;
        grpCnt = SBSigSuite.NumGroups;
        sigCnt = SBSigSuite.Groups(ActiveGroup).NumSignals;      
        
        
        % Scenario 1: time and data are empty
        if isempty(time) && isempty(data)   
            signalIdx = sort(signalIdx(:), 'ascend')';
            groupIdx = sort(groupIdx(:), 'ascend')';            
            removeGroups = groupIdx;
            if isequal(signalIdx, 1:sigCnt)
                if isequal(groupIdx, 1:grpCnt)
                   warning('signalbuilder:signalbuilder:removeALLGroupsAndALLSignals', ...
                        'You cannot remove every groups or signals');
                   removeGroups = groupIdx(2:end);        
                end
    
                % GUI Operations:
                %----------------
                % Force open the GUI if needed
                forceOpen = false;
                figH = get_param(blockH, 'UserData');
                if isempty(figH) || ~ishghandle(figH, 'figure')
                    forceOpen = true;
                    open_system(blockH);
                    figH = get_param(blockH, 'UserData');
                end
                
                groupRemove(SBSigSuite, removeGroups(:));
                UD = get(figH, 'UserData');
                UD = cant_undo(UD);
                UD = group_delete(UD, removeGroups(:)');
                
                % Close the GUI if it was forced open
                if(forceOpen)
                    close_internal(UD);
                end
                
                return;
                
            elseif isequal(groupIdx, 1:grpCnt)
                removeSignals = signalIdx;

                % GUI Operations:
                %----------------
                % Force open the GUI if needed
                forceOpen = false;
                figH = get_param(blockH, 'UserData');
                if isempty(figH) || ~ishghandle(figH, 'figure')
                    forceOpen = true;
                    open_system(blockH);
                    figH = get_param(blockH, 'UserData');
                end
                UD = get(figH, 'UserData');
                % Need to remove signals in reverse order
                groupSignalRemove(SBSigSuite, removeSignals);
                for sigIdx = sort(removeSignals(:), 'descend')'
                    UD = remove_channel(UD, sigIdx);
                end
                UD = cant_undo(UD);
                set(UD.dialog, 'UserData', UD) % save changes
                
                % Close the GUI if it was forced open
                if(forceOpen)
                    close_internal(UD);
                end                
                return;
                
            else
                ME = MException('signalbuilder:signalbuilder:removeGroupOrSignal', ...
                    'You can only remove signals from all groups. \nYou cannot delete signals from only a subset of groups.');
                throw(ME);
            end        
        
        elseif iscell(data) & find(cellfun('isempty',data), 1) %#ok<AND2>
            % check for input like {[];[]}
            if numel(find(cellfun('isempty',data))) == numel(data)
                ME = MException('signalbuilder:set:multipleemptyinput', ...
                    'Only one empty value is needed to delete signals.');
                throw(ME);
                
            end
            ME = MException('signalbuilder:set:simultaneouschangeanddelete', ...
                'Simultaneous changing and deletion of time and signal data is not allowed.');
            throw(ME);
        end
        
        % Scenario 2: time and data are NOT empty which means we are 
        % going to set signals or groups to new values.
        groupSignalSet(SBSigSuite, signalIdx, groupIdx, time, data);
 
        sigCnt = length(signalIdx);

        % Get the existing signal data
        figH = get_param(blockH, 'UserData');
        if ~isempty(figH) && ishghandle(figH, 'figure')
            guiOpen = 1;
            UD = get(figH, 'UserData');
            activeIdx = UD.current.dataSetIdx;
        else
            guiOpen = 0;
            fromWsH = find_system(blockH, 'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
                'BlockType', 'FromWorkspace');
            savedUD = get_param(fromWsH, 'SigBuilderData');
            activeIdx = savedUD.dataSetIdx;
        end

        if any(groupIdx == activeIdx)
            activeDataCol = groupIdx == activeIdx;
            ActiveGroup = groupIdx(activeDataCol);
        else
         
            ActiveGroup = [];
        end

        if guiOpen
            % Apply the active data if it exists
            if ~isempty(ActiveGroup)
                for idx = 1:sigCnt
                    sigIdx = signalIdx(idx);
                    if ~isempty(UD.channels(sigIdx).lineH)
                        axIdx = UD.channels(sigIdx).axesInd;
                        ptime = SBSigSuite.Groups(ActiveGroup).Signals(sigIdx).XData;
                        pdata = SBSigSuite.Groups(ActiveGroup).Signals(sigIdx).YData;
                        UD = apply_new_channel_data(UD, sigIdx, ptime, pdata, 1);
                        UD = rescale_axes_to_fit_data(UD, axIdx, sigIdx, []);
                    end
                end
            end
            UD.sbobj = SBSigSuite;
            UD = cant_undo(UD);
            set(UD.dialog, 'UserData', UD) % Push changes before calling vnv_manager
        else  % if GUI is closed

            savedUD.sbobj = SBSigSuite;
            set_param(fromWsH, 'SigBuilderData', savedUD);
        end        
    %---------------------------------------------------------------------%       
    case 'activegroup'
        % nargin = 2 : groupIdx = signalbuilder( blockH, 'activegroup' )
        % nargin = 3 : groupIdx = signalbuilder( blockH, 'activegroup', Index )
        local_nargin_check(method, nargin, 3);
        SBSigSuite = getSBSigSuite(blockH);
        if nargin == 3
            % set the activegroup to the indexed one
            newIdx = varargin{1};
            %setActiveGroup(SBSigSuite, newIdx);            
            SBSigSuite.ActiveGroup = newIdx;
          

             % GUI Operations:
             %-----------------
             figH = get_param(blockH, 'UserData');

            if ~isempty(figH) && ishghandle(figH, 'figure')
                UD = get(figH, 'UserData');
                UD = showTab(UD, newIdx);
                set(UD.dialog, 'UserData', UD);
            else
                fromWsH = find_system(blockH, 'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
                    'BlockType', 'FromWorkspace');
                savedUD = get_param(fromWsH, 'SigBuilderData');
                savedUD.sbobj = SBSigSuite;

                savedUD.dataSetIdx = newIdx;

                set_param(fromWsH, 'SigBuilderData', savedUD);
                vnv_notify('sbBlkGroupChange', blockH, newIdx);
            end            
        end

        if nargout > 0
            % get the activegroup
%            varargout{1} = getActiveGroup(SBSigSuite);
            varargout{1} = SBSigSuite.ActiveGroup;
        end        
     
    %---------------------------------------------------------------------%       
    case 'print'
        % can only use figure or cmd (default) method from command line 
        % nargin = 3 : figH = signalbuilder( blockH, 'print', Config )
        % nargin = 4 : figH = signalbuilder( blockH, 'print', Config, 'figure' )
        % nargin = 4 -> 8 : figH = signalbuilder( blockH, 'print', Config, <print args> )
        if nargin > 3 && ischar(varargin{2}) && strcmpi(varargin{2}, 'figure')
            options = {varargin{:}};
        else
            options = {varargin{1} 'cmd' varargin{2:end}};
        end
        
        % try to print signal builder block gui        
        [figH, errMsg] = sigbuilder('print', blockH, [], options{:});
        
        % catch any errors with printing or print parameters
        if ~isempty(errMsg)
            error('signalbuilder:signalbuilder:printError', errMsg);
        end
        
        if nargout > 0
            varargout{1} = figH;
        end
        
    %---------------------------------------------------------------------%       
    case {'appendgroup', 'append'}
        % nargin = 2 -> 6: blockH = signalbuilder( blockH,'append', time, data, SigNames, GroupNames ) 
        local_nargin_check(method, nargin, 6);
        if (nargin < 4)
            error('signalbuilder:signalbuilder:appendMethod', 'TIME AND DATA cannot be empty.');
        end
        SBSigSuite = getSBSigSuite(blockH);
        [SBSigSuite, ~] = groupAppend(SBSigSuite, varargin{1:end});
        
        group_append(blockH, SBSigSuite); 
        varargout{1} = blockH;
    %---------------------------------------------------------------------%       
    case 'create'
        % nargin = 2 -> 8: blockH = signalbuilder( path, 'create', time, data, SigNames, GroupNames, Visibility, blkPos )        
        local_nargin_check(method, nargin, 8);
        if (nargin < 4)
            error('signalbuilder:signalbuilder:createMethod', ...
                'TIME AND DATA cannot be empty.');
        end
         visibility = [];    
         blkPos = [];
         if nargin > 6
             SBSigSuite = SigSuite(varargin{1:4});
         else
             SBSigSuite = SigSuite(varargin{:});
         end
         
         if nargin >= 7
            if ~isnumeric(varargin{5})
                error('signalbuilder:signalbuilder:matrixVIS', ...
                    'VIS should be a matrix');
            end
            visibility = varargin{5};
        end
        
        if nargin >= 8
            if ~isnumeric(varargin{6}) || length(varargin{6}) ~= 4
                error('signalbuilder:signalbuilder:vectorPOS', ...
                    'POS should be a 4 element vector');
            end
            blkPos = varargin{6};
        end
        
        % Check for valid path
        blockPath = blockH;
        if ~isempty(blockPath) && ~ischar(blockPath)
            error('signalbuilder:signalbuilder:needCharacterPath', ...
                'PATH must be a character array');
        end

        % Check visibility
        if ~isempty(visibility)
            grpCnt = SBSigSuite.NumGroups;
            ActiveGroup = SBSigSuite.ActiveGroup;
            sigCnt = SBSigSuite.Groups(ActiveGroup).NumSignals;
            
            [visRows, visCols] = size(visibility);
            if (visRows ~= sigCnt || visCols ~= grpCnt)
                error('signalbuilder:signalbuilder:visibilityRowsColumns', ...
                    'VIS (visibility) must have same number of rows as signals and number of columns as groups');
            end

            % Make at least one signal visible in every group to prevent errors
            visibility(1, :) = visibility(1, :) + (sum(visibility, 1) == 0);
        end

        
        % create model and/or add signal builder block to model
        apiData = create_gui_data(SBSigSuite, visibility); 
        apiData.sbobj = SBSigSuite;

        
            % Create the GUI
        dialog = create([]);
        UD = get(dialog, 'UserData');
        UD = restore_from_saveStruct(UD, apiData);

        % Create the block
        UD = export_to_simulink(UD, blockPath, blkPos); 
        set(dialog, 'UserData', UD);
        update_titleStr(UD);

        % need this due to the restore call above.
        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end;

        vnv_notify('sbBlkUpdateGroupInfo', UD.simulink.subsysH);

        if nargout > 0
            varargout{1} = UD.simulink.subsysH;
        end       
        
    %---------------------------------------------------------------------%       
    case 'props'
        % nargin = 1: [ Time, Data, SignalName, GroupName ] = signalbuilder( blockH );

        % collect output data
        SBSigSuite = getSBSigSuite(blockH);
        [time, data, sigNames, grpNames] = groupSignalGetAll(SBSigSuite);
        
        varargout{1} = time;
        varargout{2} = data;
        
        if nargout > 2
            varargout{3} = sigNames;
        end
        
        if nargout > 3
            varargout{4} = grpNames;
        end        
    %---------------------------------------------------------------------%       
    otherwise
        DAStudio.error('Shared:sigbldr:APIUnknownMethod', method);
        %error('signalbuilder:signalbuilder:unknownMethod', ['Unexpected METHOD value: "' method '"']);
end
%--------------------------------------------------------------------------
% Nested Functions
%--------------------------------------------------------------------------
% getSBSigSuite(blockH)
%--------------------------------------------------------------------------
    function SBSigSuite = getSBSigSuite(blockH)
        if isa(blockH, 'SigSuite')
            SBSigSuite = blockH;
        else
            figH = get_param(blockH, 'UserData');
            if ~isempty(figH) && ishghandle(figH, 'figure')
                UD = get(figH, 'UserData');
                SBSigSuite = UD.sbobj;
            else
                SBSigSuite = update_sbobj(blockH);
            end
        end
    end
%--------------------------------------------------------------------------
%local_check_set_time
%--------------------------------------------------------------------------
    function time_out = local_check_set_time(time_in)
        % test input before assignment
        if ~iscell(time_in) && ~isnumeric(time_in)
            error('signalbuilder:signalbuilder:vectorOrCellTime', 'TIME should be a vector or cell array.');
        end
        time_out = time_in;
    end
%--------------------------------------------------------------------------
% local_check_set_data
%--------------------------------------------------------------------------
    function data_out = local_check_set_data(data_in)
        % test input before assignment
        if ~iscell(data_in) && ~isnumeric(data_in)
            error('signalbuilder:signalbuilder:vectorOrCellData', 'DATA should be a vector or cell array.');
        end
        data_out = data_in;
    end
%--------------------------------------------------------------------------
% local_get_set_nargin_check
%--------------------------------------------------------------------------
    function [signal, group, time, data] = local_get_set_nargin_check(method, varargin)
        % preallocate optional inputs
        time = []; data = [];
        
        if nargin < 3
            DAStudio.error('Shared:sigbldr:APINeedSignalAndGroupParams', method);
          %  error('signalbuilder:signalbuilder:needSignalAndGroupParams', ['The ' method ' method requires SIGNAL and GROUP parameters.']);
        else
            if (~ischar(varargin{1}) && ~isnumeric(varargin{1})) || ...
                    isempty(varargin{1})
                error('signalbuilder:signalbuilder:needStringOrNumericSignal', ...
                    'SIGNAL should be a nonempty string or numeric.');
            end
            if (~ischar(varargin{2}) && ~isnumeric(varargin{2})) || ...
                    isempty(varargin{1})
                error('signalbuilder:signalbuilder:stringOrNumericGroup', ...
                    'GROUP should be a nonempty string or numeric.');
            end
            signal = varargin{1};
            group = varargin{2};
        end
        
        % nargin >= 4 is only called for set method
        if nargin >= 4
            time = local_check_set_time(varargin{3});
        end
        
        if nargin >= 5
            data = local_check_set_data(varargin{4});
        end 
    end
%--------------------------------------------------------------------------
% local_nargin_check
%--------------------------------------------------------------------------
    function local_nargin_check(method, argSize, max)
        if argSize > max
            DAStudio.error('Shared:sigbldr:APIMaxArgCheck', method);
        end

    end
end

%--------------------------------------------------------------------------
% Subfunctions
%--------------------------------------------------------------------------
% local_resolve_signal_group_index
%--------------------------------------------------------------------------
function [signalIdx, groupIdx] = local_resolve_signal_group_index(SBSigSuite, signal, group)
    groupIdx = []; %#ok<NASGU>
    msg = '';

    ActiveGroup = SBSigSuite.ActiveGroup;
    grpCnt = SBSigSuite.NumGroups;
    sigCnt = SBSigSuite.Groups(ActiveGroup).NumSignals;

    if isempty(signal)
        signalIdx = 1:sigCnt;
    elseif ischar(signal)
        allNames = {SBSigSuite.Groups(ActiveGroup).Signals.Name};
        signalIdx = find(strcmp(signal, allNames));
        if isempty(signalIdx)
            msg = ['Signal "' signal '" does not exist'];
        end
        if length(signalIdx) > 1
            msg = ['Signal "' signal '" is not unique'];
        end
    else
        if islogical(signal)
            signalIdx = find(signal);
        else
            signalIdx = signal;
        end
        
        if any(signalIdx < 1)
            msg = 'Invalid signal index';
        end
        
        if any(signalIdx > sigCnt)
            msg = 'Invalid signal index';
        end
    end
    if ~isempty(msg)
        ME = MException('signalbuilder:signalbuilder:invalidSignalOrGroupIndex', '''%s''', msg);
        throw(ME);
    end
    
    
    if isempty(group)
        groupIdx = 1:grpCnt;
    elseif ischar(group)
        allNames = {SBSigSuite.Groups.Name};
        groupIdx = find(strcmp(group, allNames));
        
        if isempty(groupIdx)
            msg = ['Group "' group '" does not exist'];
        end
        
        if length(groupIdx) > 1
            msg = ['Group "' group '" is not unique'];
        end
    else
        if islogical(group)
            groupIdx = find(group);
        else
            groupIdx = group;
        end
        
        if any(groupIdx < 1)
            msg = 'Invalid group index';
        end
        
        if any(groupIdx > grpCnt)
            msg = 'Invalid group index';
        end
    end
    
    if ~isempty(msg)
        ME = MException('signalbuilder:signalbuilder:invalidSignalOrGroupIndex', '''%s''', msg);
        throw(ME);
    end
  
end
%--------------------------------------------------------------------------
