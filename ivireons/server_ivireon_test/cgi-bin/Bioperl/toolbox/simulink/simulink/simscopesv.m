function varargout = simscopesv(varargin)
%SIMSCOPESV Simulink Signal Viewer.
%   SIMSCOPESV manages the user interface for the Signal Viewer.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.47 $

Action = varargin{1};
args   = varargin(2:end);

switch Action,
    
    case 'Resize',
        %
        % Graphical resize of window.
        %
        scopeFig      = gcbf;
        scopeUserData = get(scopeFig, 'UserData');
        
        scopeUserData = i_Resize(scopeFig, scopeUserData);
       
        % g452469 : There were some bug fixes in the drawnow method in R2008a
        % due to which drawnow expose does not work anymore. So updating the
        % line below to drawnow. Note that this happens only on Windows. drawnow
        % expose works fine on Linux though.
        drawnow; 
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'BlockOpen',
        
        gcbLocal = gcb;
        if strcmp(get_param(bdroot(gcbLocal),'Lock'), 'on') || ...
                strcmp(get_param(gcbLocal,'LinkStatus'),'implicit')
            errordlg(DAStudio.message('Simulink:blocks:ScopeInLockedSystem'),...
                'Error', 'modal')
            return
        end
        
        %
        % Received request to open scope.
        %
        scopeFig = get_param(gcbLocal, 'Figure');
        if ishandle(scopeFig),
            scopeUserData = get(scopeFig, 'UserData');
        else
            scopeUserData = [];
        end
        
        [scopeFig, scopeUserData] = ...
            i_ProcessOpenRequest(scopeFig, scopeUserData);
        
        %
        % For wireless scopes, lock down axes so that when
        % it is just opened, signal selections won't be
        % accidentally altered.
        %
        if strcmp(get_param(gcbLocal,'Wireless'), 'on')
            scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
        end
        
        %
        % Process the selected signals in the SelectedSignals parameter
        % and update the userdata field.  We don't need to update the
        % SelectedPortHandles here because they were updated in
        % i_UpdateAxesConfig.
        %
        %i_LoadSelectionData(gcbLocal);
        
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'SigSelectChange',
        scopeFig      = get_param(gcb, 'Figure');
        
        if ishandle(scopeFig)
            scopeUserData = get(scopeFig, 'UserData');
            
            %
            % User clicked on a signal wire in the block diagram
            % or lines were selected programmatically, which the
            % scope block detected and then called here.
            %
            % SelectedAxesIdx indicates which axes the user
            % wants the new signal selections to be displayed on
            % (wireless scopes only).
            %
            currAxes = get_param(scopeUserData.block, 'SelectedAxesIdx');
            
            %
            % Current Axes is a work index used for updating the scopes.
            %
            set_param(scopeUserData.block, 'CurrentAxesIdx', currAxes);
            i_CreateLinesForCurrentAxes(scopeFig, scopeUserData);
            
            %
            % Update the YTick attributes
            %
            yTickInfo = i_GetYTickInfo(scopeUserData, currAxes, false);
            i_SetYTickInfo(scopeUserData.scopeAxes(currAxes), yTickInfo);
            i_FixPositionOfAxes(scopeUserData);
            
            % Force the figure to be redrawn
            get_param(scopeUserData.block, 'InvalidateBlitBuffer');
            
            %
            % Save the SelectionData and update the Selected Port Handles
            % to keep them synchronized.
            %
            %i_SaveSelectionData(scopeUserData.block);
            %i_UpdateSelectedPortHandles(scopeUserData.block);
        end
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'LockDownAxes'
        
        scopeFig = gcbf;
        
        if ishandle(scopeFig)
            scopeUserData = get(scopeFig, 'UserData');
        else
            % Quietly ignore requests to LockDown invalid figure handles
            return;
        end
        
        scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'ResizeHiLites'
        
        %
        % Resize the axes highlights to make them consistent with the
        % axes limits.  This is usually called by "scopezoom" after
        % the axes limits have changed.
        %
        
        scopeFig       = varargin{2};
        scopeUserData  = get(scopeFig, 'UserData');
        block          = scopeUserData.block;
        scopeAxes      = scopeUserData.scopeAxes;
        nAxes          = length(scopeAxes);
        
        for i=1:nAxes,
            ax   = scopeAxes(i);
            xLim = get(ax,'XLim');
            yLim = get(ax,'YLim');
            
            i_HiLiteResize(scopeUserData,i,xLim,yLim);
            i_RenderInsideTickLabels(block, ax);
        end
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
        % Call 'Resize' callback in case y-axis tick labels have grown
        %  one character bigger
        simscopesv('Resize');
        
    case 'AxesClick'
        
        scopeFig       = gcbf;
        scopeUserData  = get(scopeFig, 'UserData');
        modelBased    = i_IsModelBased(scopeUserData.block);
        
        %
        % If this is a model-based scope, then this callback is
        % intended to highlight the axes and make them ready for
        % configuration via the SignalSelector.  Otherwise, its
        % intended to unlock the axes for selection, so we need
        % to pass control to the 'SelectedAxes' case.  We assume
        % that this never gets called while the simulation is
        % running.
        %
        if modelBased
            %
            % Turn off focus at previous wireless scope and set 'this'
            % scope to be the current scope in focus.
            %
            [scopeUserData,scopeFigFocusChanged] = i_GrabWirelessScopeFocus(scopeFig);
            
            %
            % Lockdown the old axes just in case they're still active.
            %
            scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
            oldAxes = get_param(scopeUserData.block, 'SelectedAxesIdx');
            %i_HiLiteOff(scopeUserData,oldAxes);
            
            %
            % Get the new axis.
            %
            axH = get(scopeFig, 'CurrentAxes');
            ax  = find(scopeUserData.scopeAxes == axH);
            if isempty(ax)
                ax = 1;
            end
            ax = ax(1);
            
            %
            % Make this the current axis and turn on the HiLite
            %
            set_param(scopeUserData.block, 'SelectedAxesIdx', ax);
            i_HiLiteOn(scopeUserData,ax);
            
            signalselector('UpdateInputNum',scopeUserData.block,ax);
            
        else
            callbackCall = strcmp(get(scopeFig,'SelectionType'), 'normal');
            if (callbackCall || nargin > 1)
                if nargin == 2
                    if ~strcmp(varargin{2},'Dialog')
                        DAStudio.error('Simulink:blocks:UnknownOptionInSelectedAxes', ...
                            varargin{2});
                    end
                end
            end
            scopeUserData = i_SelectAxes(scopeFig,scopeUserData);
        end
        % g391103: Update the scope figure before calling UpdateEraseBuffer
        % g397662: Need to refresh the buffer with the most updated scopeUserData
        set(scopeFig, 'UserData', scopeUserData);
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'SetSelectedAxes',
        scopeFig = varargin{2};
        axIdx    = varargin{3};
        
        scopeUserData = get(scopeFig,'UserData');
        axH           = scopeUserData.scopeAxes(axIdx);
        
        set(scopeFig, 'CurrentAxes', axH);
        scopeUserData = i_SelectAxes(scopeFig,scopeUserData);
        set(scopeFig,'UserData',scopeUserData);
        
    case 'SelectedAxes'
        
        scopeFig = gcbf;
        
        if ishandle(scopeFig),
            callbackCall = strcmp(get(scopeFig,'SelectionType'), 'normal');
        else
            if nargin == 3,
                scopeFig = varargin{3};
            else
                DAStudio.error('Simulink:blocks:InternalScopeError');
            end
            callbackCall = 0;
        end
        
        scopeUserData = get(scopeFig, 'UserData');
        
        if (callbackCall || nargin > 1)
            if nargin == 2
                if ~strcmp(varargin{2},'Dialog')
                    DAStudio.error('Simulink:blocks:UnknownOptionInSelectedAxes', ...
                        varargin{2});
                end
            end
        end
        
        scopeUserData = i_SelectAxes(scopeFig,scopeUserData);
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'DialogSelection',
        %
        % Signal Selection via the signal selector is complete.
        %
        scopeFig = varargin{2};
        scopeUserData = get(scopeFig,'UserData');
        
        % First clear the set lines in the block diagram. Then,
        % set the lines in the block diagram for this axes.
        %
        hl = find_system(scopeUserData.block_diagram,'findall', 'on', ...
            'type', 'line','selected','on');
        for i=1:length(hl),
            set_param(hl(i),'selected','off');
        end
        
        %
        % Retrieve the new list and select the lines.  The
        % internal scope code will pick up the selected
        % signals and use them.
        %
        hl = varargin{3};
        
        for i=1:length(hl),
            set_param(hl(i),'selected','on');
        end
        
        scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'GetWirelessPorts'
        %
        % Return the list of ports used by a wireless scope.
        % Note that this function is designed to be called
        % from within the scope's EvalParamsFcn (in C).  It
        % does not set the 'SelectedPortHandles' parameter,
        % because that would trigger another call to the
        % EvalParamsFcn.
        %
        %         if 0
        %             hPorts = i_GetWirelessPorts(gcb);
        %             varargout{1} = hPorts;
        %         end
        varargout{1} = [];
        
    case 'BlockStart',
        %
        % Simulation is initializing.
        %
        scopeFig      = get_param(gcb, 'Figure');
        scopeUserData = get(scopeFig, 'UserData');
        
        %
        % Common set of operations at startup
        %
        
        scopeUserData = i_SimulationStart(scopeFig, scopeUserData);
        set(scopeFig, 'UserData', scopeUserData);
        
        if ishandle(scopeUserData.scopePropDlg),
            scppropsv('BlockStart', scopeUserData.scopePropDlg);
        end
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        signalselector('BlockStart', gcbh);
    case 'BlockTerminate',
        %
        % Simulation is terminating.
        %
        scopeFig = get_param(gcb, 'Figure');
        scopeUserData = get(scopeFig, 'UserData');
        
        scopeUserData = i_SimulationTerminate(scopeFig, scopeUserData);
        set(scopeFig, 'UserData', scopeUserData);
        
        if ishandle(scopeUserData.scopePropDlg),
            scppropsv('BlockTerminate', scopeUserData.scopePropDlg);
            scopeUserData = get(scopeFig,'UserData');
        end
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        signalselector('BlockTerminate', gcbh);
    case 'ExtLogInitialize',
        %
        % External data log event is initializing (armed)
        %
        scopeFig      = get_param(gcb, 'Figure');
        scopeUserData = get(scopeFig,  'UserData');
        
        scopeUserData = i_SimulationStart(scopeFig, scopeUserData);
        set(scopeFig, 'UserData', scopeUserData);
        
        
        scopePropDlg = scopeUserData.scopePropDlg;
        if ishandle(scopePropDlg) && onoff(get(scopePropDlg, 'Visible'))
            scppropsv('BlockStart', scopeUserData.scopePropDlg);
        end
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'ExtLogTerminate',
        %
        % External data log event is terminating.
        %
        scopeFig      = get_param(gcb,'Figure');
        scopeUserData = get(scopeFig, 'UserData');
        
        scopeUserData = i_SimulationTerminate(scopeFig, scopeUserData);
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'BlockUpdateDiagram',
        %
        % The block diagram is being updated.
        %
        scopeFig      = get_param(gcb, 'Figure');
        if ishandle(scopeFig),
            scopeUserData = get(scopeFig, 'UserData');
            scopeUserData = i_UpdateTitles(scopeUserData);
            
            i_UpdateEraseBufferIfNeeded(scopeFig);
        end
        
    case {'BlockDelete', 'BlockIsBeingDestroyed'},
        %
        % Block has been destoyed.  Note that some old models have
        % been saved with scopes whose delete callback of
        % 'BlockIsBeingDestroyed'.  This is a remnant of a very early
        % version of V2.0.  I've left this flag in for backward compat
        % with these models and some of our older tests.
        %
        currentScope = get_param(bdroot(gcb), 'FloatingScope');
        if ~strcmp(currentScope, '')
            if get_param(currentScope, 'Handle') == gcbh
                set_param(bdroot(gcb), 'FloatingScope', '');
            end
        end
        
        scopeFig = get_param(gcb, 'Figure');
        if ((scopeFig ~= INVALID_HANDLE ) && (ishandle(scopeFig)))
            delete(scopeFig);
        end
        
        %
        % Delete any signal selectors
        %
        signalselector('Delete', gcbh);
        
    case 'DeleteFcn',
        %
        % HG Figure's deletefcn.
        %
        scopeFig       = gcbo;
        scopeUserData  = get(scopeFig, 'UserData');
        block          = scopeUserData.block;
        
        set_param(block, 'Open', 'off', 'Figure', INVALID_HANDLE);
        
        % Get the UserData again as the above set_param may have modified it
        scopeUserData = get(scopeFig, 'UserData');
        
        if scopeUserData.scopePropDlg ~= INVALID_HANDLE,
            delete(scopeUserData.scopePropDlg);
        end
        
        i_DeleteAxesPropDlgs(scopeUserData);
        
        set(scopeFig, 'Visible', 'off');
        
    case 'CloseReq',
        %
        % HG Figure's closerequestfcn.
        %
        scopeUserData = get(gcbf,'UserData');
        set_param(scopeUserData.block, 'open', 'off');
        
    case 'BlockClose',
        %
        % Close (hide) the figure (called from: set_param(block,'Open','off'))
        %
        fig = get_param(gcb, 'Figure');
        
        if ishandle(fig),
            scopeUserData = get(fig,'UserData');
            block = scopeUserData.block;
            
            %
            % Delete the main scope propertied dialog (if needed).
            %
            if ishandle(scopeUserData.scopePropDlg),
                delete(scopeUserData.scopePropDlg);
                scopeUserData.scopePropDlg = INVALID_HANDLE;
                set(fig, 'UserData', scopeUserData);
            end
            
            %
            % Delete any individual axes property dialogs.
            %
            i_DeleteAxesPropDlgs(scopeUserData);
            
            %
            % Delete any signal selectors
            %
            signalselector('Delete', block);
            
            %
            % Close ("hide") the figure.
            %
            set(fig,'Visible','off');
            
            %
            % Check the selection data, to make sure it is consistent.
            % This should not be necessary, but it will throw a warning
            % and fix discrepencies if something is wrong.
            %
            i_VerifySelectionData(block)
            
        end
        
    case 'BlockPreSave',
        %
        % block diagram has been saved.
        %
        block         = gcb;
        scopeFig      = get_param(block, 'Figure');
        
        if ishandle(scopeFig),
            scopeUserData = get(scopeFig,'UserData');
            scopeAxes     = scopeUserData.scopeAxes;
            
            %
            % Save windows position.
            %
            hgRect = get(scopeFig, 'Position');
            set_param(block, 'Location', rectconv(hgRect, 'simulink'));
            
            %
            % Save legend locations.
            %
            haveLegends = ~isempty(legend('-find',scopeAxes(1)));
            locs = i_GetLegendLocsFromFig(scopeUserData,haveLegends);
            locStr = num2str(locs);
            set_param(block,'LegendLocations',locStr);
        end
        
    case 'SimTimeSpan',
        %
        % Public access to:
        %  i_ComputeSimulationTimeSpan(block, block_diagam, simStatus)
        %
        varargout = {i_ComputeSimulationTimeSpan(varargin{2:end})};
        
    case 'BlockNameChange',
        %
        % Handle name change event.
        %   Name of block changed
        %   block diagram name change (save/save as)
        %   Subsystem name change
        %   etc
        %
        block    = gcb;
        scopeFig = get_param(block, 'Figure');
        
        if ishandle(scopeFig),
            scopeUserData = get(scopeFig, 'UserData');
            
            %
            % Update scope name
            %
            windowTitle = viewertitle(scopeUserData.block, false);
            
            set(scopeFig, 'Name', windowTitle);
            block_diagram = bdroot(scopeUserData.block);
            if ~strcmp(block_diagram,scopeUserData.block_diagram)
                scopeUserData.block_diagram = block_diagram;
                set(scopeFig,'UserData',scopeUserData);
            end
            
            %
            % Update scope property dialog name
            %
            if ishandle(scopeUserData.scopePropDlg),
                scppropsv('BlockNameChange', scopeUserData.scopePropDlg);
            end
            
            %
            % Update the names of any open axes property dialogs.
            %
            block     = scopeUserData.block;
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            
            for i=1:nAxes,
                ax         = scopeAxes(i);
                axUserData = get(ax, 'UserData');
                
                if ishandle(axUserData.propDlg),
                    axesIdxStr = sprintf('%d', i);
                    dlgName    = i_GetAxesPropDlgName(ax, block, axesIdxStr);
                    set(axUserData.propDlg, 'Name', dlgName);
                end
            end
            
            %
            % Update current floating scope name if this is the one
            %
            formattedBlockPath = getfullname(block);
            set_param(bdroot(block), 'FloatingScope', formattedBlockPath);
        end
        
    case 'PropDialogApply',
        scopeFig      = varargin{2};
        scopeUserData = get(scopeFig, 'UserData');
        floatingStr   = get_param(scopeUserData.block, 'Floating');
        floating      = strcmp(floatingStr, 'on');
        modelBasedStr = get_param(scopeUserData.block, 'ModelBased');
        modelBased    = i_IsModelBased(scopeUserData.block);
        wirelessStr   = get_param(scopeUserData.block, 'Wireless');
        wireless      = strcmp(wirelessStr, 'on');
        bd            = scopeUserData.block_diagram;
        
        if i_IsSimActive(bd),
            simStatus = 'running';
        else
            simStatus = 'stopped';
        end
        
        if floating,
            scopezoom('off', scopeFig);
            scopebarsv(scopeFig, 'CtrlUI', simStatus);
        end
        
        if ~wireless,
            i_RestorePortConnections(scopeUserData.block);
        end
        
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        set(scopeFig, 'UserData', scopeUserData);
        
        %
        % Sync toolbar floating-related buttons with
        % new dialog selections.  Float button exists
        % if not 'ModelBased' (i.e. the 'Signal Viewer
        % Scope').
        %
        if ~i_IsSimActive(bdroot(scopeUserData.block)) && ~modelBased,
            scopebarsv(scopeFig, 'FloatButton', 'on', floatingStr);
        end
        
        %
        % We need to reload 'SelectedSignals' into the Axes user data here,
        % because the axes may have changed, and signals will need to be
        % reloaded.  The Port Handles will need updating, too.
        %
        %i_LoadSelectionData(scopeUserData.block);
        %i_UpdateSelectedPortHandles(scopeUserData.block);
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'SetNewNumPorts'
        scopeBlk  = args{1};
        newNumber = args{2};
        
        set_param(scopeBlk, 'NumInputPorts', newNumber);
        scopeFig = get_param(scopeBlk, 'Figure');
        
        if ishandle(scopeFig)
            scopeUserData = get(scopeFig, 'UserData');
            
            scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData);
            scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData,'on');
            
            set(scopeFig, 'UserData', scopeUserData);
            
        end
        
    case 'AxesContextMenu',
        scopeFig      = gcbf;
        contextAxes   = get(scopeFig, 'CurrentAxes');
        menuItem      = varargin{2};
        scopeUserData =   i_ManageContextMenuCB(scopeFig, contextAxes, menuItem);
        i_UpdateEraseBufferIfNeeded(scopeFig);
    case 'AxesPropDlg',
        dialogAction   = varargin{2};
        dialogFig      = varargin{3};
        axesIdx        = varargin{4};
        
        i_ManageAxesPropDlg(dialogAction, dialogFig, axesIdx);
        
    case 'WSContextMenu',
        scopeFig      = gcbf;
        scopeUserData = get(scopeFig, 'UserData');
        menuItem      = varargin{2};
        scopeUserData = i_ManageWSContextMenuCB( ...
            scopeFig, scopeUserData, menuItem);
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
    case 'ScopeBar',
        buttonType    = varargin{2};
        buttonAction  = varargin{3};
        scopeFig      = varargin{4};
        scopeUserData = get(scopeFig, 'UserData');
        
        scopeUserData = i_ManageScopeBar( ...
            scopeFig, scopeUserData, buttonType, buttonAction);
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
    case 'Save'
        % Do nothing -- for backward compatibility.
        
    case 'PrintFigure'
        %This function was created for the Report Generator.  It creates
        %a button-free temporary print figure and returns the handle to
        %that figure.  The user must pass in a handle to the scope they
        %wish to print.
        
        scopeFig = varargin{2};
        scopeUserData=get(scopeFig,'UserData');
        
        varargout{1} = i_CreatePrintFigure(scopeFig,scopeUserData);
        
    case 'OverrideTRange',
        block = varargin{2};
        
        scopeFig = get_param(block, 'Figure');
        
        if ishandle(scopeFig) && onoff(get(scopeFig,'Visible'))
            scopeUserData = get(scopeFig,'UserData');
            scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData);
            
            i_UpdateEraseBufferIfNeeded(scopeFig);
        end
        
    case 'MarkerCB',
        block    = args{1};
        scopeFig = get_param(block,'Figure');
        
        if ishandle(scopeFig),
            scopeUserData = get(scopeFig, 'UserData');
            
            i_MarkerCB(scopeFig,scopeUserData);
        end
        
    case 'LegendCB',
        block    = args{1};
        scopeFig = get_param(block,'Figure');
        
        if ishandle(scopeFig),
            scopeUserData = get(scopeFig,'UserData');
            
            scopeUserData = i_LegendCB(scopeFig,scopeUserData);
            set(scopeFig,'UserData',scopeUserData);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Signal Selector support below     %%
        %% API Definition for GET/ADD/REMOVE %%
        %% port selection for a block        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    case 'GetSelection'
        BlockHandle = args{1};
        AxesNumber  = args{2};
        %varargout{1} = i_GetSelection(BlockHandle, AxesNumber);
        
        %
        % Call into Signal & Scope Manager to get default behavior
        %
        selection = sigandscopemgr(Action,BlockHandle,AxesNumber);
        varargout{1} = selection;
        
    case 'AddSelection'
        BlockHandle = args{1};
        AxesNumber  = args{2};
        addSel      = args{3};
        floating    = onoff(get_param(BlockHandle,'Floating'));
        
        %
        % Call into Signal & Scope Manager to get default behavior
        %
        if ~floating,
            sigandscopemgr(Action,BlockHandle,AxesNumber,addSel);
        else
            i_AddSelection(BlockHandle, AxesNumber, args{3});
        end
        
    case 'RemoveSelection'
        BlockHandle = args{1};
        AxesNumber  = args{2};
        remSel      = args{3};
        floating    = onoff(get_param(BlockHandle,'Floating'));
        
        %
        % Call into Signal & Scope Manager to get default behavior
        %
        if ~floating,
            sigandscopemgr(Action,BlockHandle,AxesNumber,remSel);
        else
            i_RemoveSelection(BlockHandle, AxesNumber, args{3});
        end
        
    case 'SwitchSelection'
        BlockHandle = args{1};
        AxesNumber  = args{2};
        oldSel      = args{3};
        newSel      = args{4};
        %i_SwitchSelection(BlockHandle, AxesNumber, args{3}, args{4});
        
        %
        % Call into Signal & Scope Manager to get default behavior
        %
        sigandscopemgr(Action,BlockHandle,AxesNumber,oldSel,newSel);
        
    case 'DialogClosing'
        BlockHandle = args{1};
        i_DialogClosing(BlockHandle);
        
    otherwise,
        %
        % Default action.
        %
        DAStudio.error('Simulink:blocks:InvalidAction', Action);
end



%******************************************************************************
%
% -------=======***        Start Internal Functions       ***=======-------
%
%******************************************************************************

function scopeUserData = i_LegendCB(scopeFig,scopeUserData)
scopeUserData = i_UpdateLegends(scopeFig,scopeUserData);
%endfunction

function locs = i_GetLegendLocsFromFig(scopeUserData,haveLegends)
locs = [];

if haveLegends,
    scopeAxes = scopeUserData.scopeAxes;
    nAxes     = length(scopeAxes);
    
    for ax=1:nAxes,
        hax  = scopeAxes(ax);
        hleg = legend('-find',hax);
        
        if ~isempty(hleg),
            pos = get(hleg,'position');
        else
            pos = [0 0 0 0];
        end
        
        locs   = [locs; pos];
    end
end
%endfunction


function locs = i_GetLegendLocsFromBD(scopeUserData)
block   = scopeUserData.block;
nAxes   = length(scopeUserData.scopeAxes);

locStrs = get_param(block,'LegendLocations');
locs    = str2num(locStrs);

if ~isempty(locs),
    nLocs = size(locs,1);
    if nLocs > nAxes,
        locs = locs(1:nAxes,:);   %truncate
    elseif nLocs < nAxes,
        locs(nAxes,:) = [0 0 0 0]; %zero pad
    end
end
%endfunction


function i_AllNanLinesToInf(scopeFig,scopeUserData,axIdx,useInf)
block = scopeUserData.block;
set_param(block,'CurrentAxesIdx',axIdx);
hLines = get_param(block,'AxesLineHandles');

if ~isempty(hLines)
    hLines = [hLines{:}];
end

if (useInf),
    for i=1:length(hLines),
        hl = hLines(i);
        xDat = get(hl,'Xdata');
        
        if all(isnan(xDat))
            xDat(1) = inf;
            set(hl,'Xdata',xDat);
        end
    end
else
    for i=1:length(hLines)
        hl = hLines(i);
        xDat = get(hl,'Xdata');
        
        if isinf(xDat(1))
            xDat(1) = nan;
            set(hl,'Xdata',xDat);
        end
    end
end
%endfunction

function locValid = i_isLocValid(loc)
locValid = all(loc <= 1) && all(loc >= 0);

%endfunction

function scopeUserData = i_AddLegends(scopeFig,scopeUserData,locs,resize)
block     = scopeUserData.block;
legInfo   = get_param(block,'LegendString');


%
% If current leg info is not avail, get the cached info (from
% previous sim).  Note that the 'LegendString' is not avail
% when the simulation is not running.
%
if isempty(legInfo) || isempty(legInfo{1})
    legInfo = scopeUserData.cachedLegStrs;
end

if isempty(legInfo) | isempty(legInfo{1})
    warning('off','backtrace');
    DAStudio.warning('Simulink:blocks:LegendInfoNA');
    warning('on','backtrace');
    return;
end

nAxes     = length(legInfo);
scopeAxes = scopeUserData.scopeAxes;

if nAxes ~= length(scopeAxes),
    DAStudio.error('Simulink:blocks:UnexpectedNoOfAxes');
end

nLocs = size(locs,1);
if ~isempty(locs) && (nAxes ~= nLocs),
    if nLocs > nAxes,
        locs = locs(1:nAxes,:);   %truncate
    elseif nLocs < nAxes,
        locs(nAxes,:) = [0 0 0 0]; %zero pad
    end
end

for ax=1:nAxes,
    axInfo  = legInfo{ax};
    
    if isempty(axInfo), continue; end
    
    %legStrs = cat(1,axInfo{:}{:});
    legStrs = {};
    nSigs = length(axInfo);
    for i=1:nSigs,
        regs = axInfo{i};
        for j=1:length(regs),
            els = regs{j};
            for k=1:length(els),
                legStrs{end+1} = els{k};
            end
        end
    end
    
    i_AllNanLinesToInf(scopeFig,scopeUserData,ax,true);
    haveLocs = (~isempty(locs) && (all(locs(ax,:) ~= 0))) && ...
        i_isLocValid(locs(ax,:));
    
    if ~haveLocs | resize,
        [hLegAx,hLegObjs] = legend(scopeAxes(ax),legStrs);
        if (resize),
            legend(hLegAx,'hide');
        end
    else
        [hLegAx,hLegObjs] = legend(scopeAxes(ax),legStrs,'Location',locs(ax,:));
    end
    
    % Turn off text interpretation
    set(findobj(hLegObjs,'type','text'),'Interpreter','none');
    
    i_AllNanLinesToInf(scopeFig,scopeUserData,ax,false);
    set(hLegAx,'xcolor','w','ycolor','w');
    %legend(scopeAxes(ax),'boxoff');
    hLegTextObjs      = findobj(hLegObjs,'Type','text');
    set(hLegTextObjs,'Color','w');
    
    if ~isempty(hLegAx)
        scopeUserData.scopeLegends(ax) = hLegAx;
    end
    
    origBD = get(hLegAx,'ButtonDownFcn');
    origCM = get(get(hLegAx,'UIContextMenu'),'Callback');
    if (ax == 1)
        scopeUserData.origLegBD = origBD;
        scopeUserData.origLegCM = origCM;
    end
    newBD = origBD;
    newBD{1} = @i_LegendBDFcn;
    set(hLegAx,  'ButtonDownFcn', newBD);
    set(hLegObjs,'ButtonDownFcn', newBD);
    
    % g373563 - Remove any ButtonDownFcn callbacks on the legend string. In
    % viewers we want to disable the ability to change the strings since
    % they represent SL signals.
    hLegTxt = findobj(hLegObjs,'Type','text');
    if ~isempty(hLegTxt),
        set(hLegTxt,'ButtonDownFcn','');
    end
    
    set(get(hLegAx,'UIContextMenu'),'Callback',@i_LegendContextFcn);
    for i=1:length(hLegObjs)
        set(get(hLegObjs(i),'UIContextMenu'),'Callback',@i_LegendContextFcn);
    end
    
end
set(scopeFig, 'UserData', scopeUserData);
i_UpdateEraseBuffer(scopeFig);
scopeUserData = get(scopeFig, 'UserData');
%endfunction


function i_LegendBDFcn(hSrcObj,eventData,varargin)

scopeFig      = gcbf;
scopeUserData = get(scopeFig,'UserData');
origLegBD     = scopeUserData.origLegBD;

if ~isempty(origLegBD)
    feval(origLegBD{1},hSrcObj,eventData,varargin{:});
end

scopeUserData.origLegBU  = get(scopeFig,'WindowButtonUpFcn');
scopeUserData.origLegMot = get(scopeFig,'WindowButtonMotionFcn');
% g418348-Removed WindowButtonUpFcn and WindowButtonMotionFcn callbacks
% as they are not required.
%   set(scopeFig, ...
%       'UserData',              scopeUserData,  ...
%       'WindowButtonUpFcn',     @i_LegendBUFcn, ...
%       'WindowButtonMotionFcn', @i_LegendMotFcn);

set(scopeFig,'UserData',scopeUserData);
%endfunction

function i_LegendBUFcn(hSrcObj,eventData)
scopeFig      = gcbf;
scopeUserData = get(scopeFig,'UserData');
origLegBU     = scopeUserData.origLegBU;

if ~isempty(origLegBU)
    feval(origLegBU{1},hSrcObj,eventData,origLegBU{2:end});
end
% g418348-Removed WindowButtonUpFcn and WindowButtonMotionFcn callbacks
% as they are not required.
%   set(scopeFig, ...
%       'WindowButtonUpFcn',     '', ...
%       'WindowButtonMotionFcn', '');

set(scopeFig,'UserData',scopeUserData);
% Swapped the order of the  UpdateEraseBuffer and set(scopeFig) functions
% so that when UpdateEraseBuffer is executed, the scopeFig correctly
% reflects the changes made it to in the calling function. This is
% possible only if the scopeFig has captured all those changes vis
% set(scopeFig) before the call to UpdateEraseBuffer is made.
i_UpdateEraseBuffer(scopeFig);
%endfunction

function i_LegendMotFcn(hSrcObj,eventData)
scopeFig      = gcbf;
scopeUserData = get(scopeFig,'UserData');
origLegMot    = scopeUserData.origLegMot;

if ~isempty(origLegMot)
    if iscell(origLegMot)
        feval(origLegMot{1},hSrcObj,eventData,origLegMot{2:end});
    else
        feval(origLegMot,hSrcObj,eventData);
    end
end

set(scopeFig,'UserData',scopeUserData);
% Swapped the order of the  UpdateEraseBuffer and set(scopeFig) functions
% for the same reasons as above.
i_UpdateEraseBuffer(scopeFig);

%endfunction

function i_LegendMenuCB(hSrcObj,eventData,varargin)
scopeFig        = gcbf;
scopeUserData   = get(scopeFig,'UserData');
origLegMenCBFcn = scopeUserData.origLegMenCBFcn;

if ~isempty(origLegMenCBFcn)
    feval(scopeUserData.origLegMenCBFcn,hSrcObj,eventData,varargin{:});
end

i_UpdateEraseBuffer(scopeFig);
%endfunction


function i_LegendContextFcn(hSrcObj,eventData)
scopeFig      = gcbf;
scopeUserData = get(scopeFig,'UserData');
origLegCM     = scopeUserData.origLegCM;

if ~isempty(origLegCM)
    feval(origLegCM{1},hSrcObj,eventData,origLegCM{2:end});
end

menuItems       = findall(hSrcObj,'Type','uimenu');
locItem         = findobj(menuItems,'Label','Location');
locItemChildren = findall(locItem,'Type','uimenu');
locItemChildren = locItemChildren(2:end);
removeItems     = [locItem; locItemChildren];
for i=1:length(removeItems)
    lab = lower(get(removeItems(i),'Label'));
    if ~isempty(findstr(lab,'outside'))
        removeItems(i) = -1;
    end
    %if ~isempty(findstr(lab,'best'))
    %  removeItems(i) = -1;
    %end
end
removeItems(removeItems == -1) = [];

%
%
%
for i=1:length(locItemChildren)
    cb = get(locItemChildren(i),'Callback');
    if ~isempty(cb) && ~isempty(cb{1}) && ~isequal(cb{1},@i_LegendMenuCB)
        cbFcn = cb{1};
        scopeUserData.origLegMenCBFcn = cbFcn; %all menuitems have same cb fcn
        cb{1} = @i_LegendMenuCB;
        set(locItemChildren(i),'Callback',cb);
    end
end

%
% Disable the rest.
%
menuItems = setdiff(menuItems,removeItems);
set(menuItems,'Enable','off');

set(scopeFig,'UserData',scopeUserData);

%endfunction

function scopeUserData = i_SelectAxes(scopeFig,scopeUserData)
%
% Received a callback request to change the Selected Axes
% (and its index).  The Callback that calls this entry point
% is installed only for wireless scopes.
%
modelBased    = i_IsModelBased(scopeUserData.block);

%
% Turn off focus at previous wireless scope and set 'this'
% scope to be the current scope in focus.
%
[scopeUserData,scopeFigFocusChange] = i_GrabWirelessScopeFocus(scopeFig);

axH = get(scopeFig, 'CurrentAxes');
ax  = find(scopeUserData.scopeAxes == axH);
if isempty(ax)
    ax = 1;
end
ax = ax(1);
oldAxes = get_param(scopeUserData.block,'SelectedAxesIdx');
%
% set the new axes immediately to avoid stale state farther down.
%
set_param(scopeUserData.block, 'SelectedAxesIdx', ax);
scopeLockedDown = strcmp( ...
    get_param(scopeUserData.block, 'LockDownAxes'), ...
    'on');

%
% If this is a model-based scope, the highlight needs to
% change whenever the 'SelectedAxesIdx' changes.
%
if modelBased && ~i_IsSimActive(scopeUserData.block_diagram)
    i_HiLiteOff(scopeUserData,oldAxes);
    i_HiLiteOn(scopeUserData,ax);
end

%
% Highlight the selected axes, either via axes selection
% or via removal of a LockDown on this scope.
%
if (ax ~= oldAxes || scopeFigFocusChange || scopeLockedDown )
    %
    % Set the lockdown mode
    %
    scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'off');
    
    if (~modelBased && ~ishandle(scopeUserData.scopeHiLite(ax)))
        simscopesv('PropDialogApply', scopeFig);
        scopeUserData = get(scopeFig, 'UserData');
    end
    
    if scopeLockedDown
        set_param(scopeUserData.block, 'LockDownAxes', 'off');
    end
    
    sigHandles = get_param(scopeUserData.block,'IOSignals');
    
    %
    % First clear the set lines in the block diagram.
    % Then, set the previous lines in the block diagram
    % for this axes.
    %
    hLines = find_system(scopeUserData.block_diagram, 'findall', 'on', ...
        'type', 'line', 'selected', 'on');
    for k=1:length(hLines)
        set_param(hLines(k),'selected','off');
    end
    
    %     if 0
    %         axUserData = get(scopeUserData.scopeAxes(ax),'UserData');
    %         for k=1:length(axUserData.signals)
    %             set_param(axUserData.signals(k),'selected','on');
    %         end
    %     end
    
    sigHandles = sigHandles{ax};
    for k=1:length(sigHandles)
        handle    = sigHandles(k).Handle;
        mdlRefStr = sigHandles(k).RelativePath;
        if ishandle(handle) && strcmp(mdlRefStr,'')
            line = get_param(handle,'Line');
            if ishandle(line)
                set_param(line,'selected','on');
            end
        end
    end
    
    ax = find(scopeUserData.scopeAxes == axH);
    if ~isempty(ax)
        signalselector('UpdateInputNum',scopeUserData.block,ax);
    end
    
    % figure has re-rendered
    scopeUserData.dirty = 1;
end
% Update the scope figure with the new scopeUserData
set(scopeFig,'UserData',scopeUserData);
%endfunction


% Function: INVALID_HANDLE ====================================================
% Abstract:
%    A method to generate an invalid handle that appears "static" to this file.
%
function h = INVALID_HANDLE
h = (-1);

% Function: i_struct2cell =====================================================
% Abstract:
%    Convert from a cell to a structure array.  Same as struct2cell, but
%    handles empty matrices for input arguments.

function out = i_struct2cell(structMat)

if isempty(structMat)
    out = {};
else
    out = struct2cell(structMat);
end


% Function: i_DeleteAxesPropDlgs ==============================================
% Abstract:
%    Delete any open axes property dialogs.
function i_DeleteAxesPropDlgs(scopeUserData)

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);

for i=1:nAxes,
    ax         = scopeAxes(i);
    axUserData = get(ax, 'UserData');
    if ishandle(axUserData.propDlg)
        delete(axUserData.propDlg);
    end
end


% Function: i_CreateAxesGeom ==================================================
% Abstract:
%    Create the geometry constants and other info required to calculate the
%    positions of the axes.

function axesGeom = i_CreateAxesGeom(scopeUserData)

block = scopeUserData.block;
scopeFig = get_param(block, 'Figure');


%
% g464733, 499614 and related gecks.
%  Here we update the units of the textExtent and the axes so that they always match
%  the units of the scope figure they are associated with. Not doing so will cause 
%  issues asseen in the gecks above since the scopeUserData does not automatically 
%  units of its fields when the units of the figure changes.
%
 if ishandle(scopeFig)
     figUnits = get(scopeFig,'Units');
     set(scopeUserData.textExtent,'Units', figUnits);
     set(scopeUserData.scopeAxes,'Units', figUnits);
     set(scopeFig,'UserData',scopeUserData);
 end
axesGeom.showTitles   = 0;
axesGeom.tickLabelOpt = get_param(block, 'TickLabels');

%
% Define constants.
%
axExt = i_AxesExtent(scopeUserData);
tickLabelWidth  = axExt(3);

set(scopeUserData.textExtent, ...
    'FontName',       scopeUserData.uiFontName, ...
    'FontSize',       scopeUserData.uiFontSize, ...
    'String',         'Time offset:' ...
    );
uiExt = get(scopeUserData.textExtent, 'Extent');

expFactor = 1.55;  % leave room for exponents;

%
% Define geometry constants:
%   hTitle         - height of the titles including space between top of
%                    axes and bottom of text
%   hYTickLabelExp - height of exponent for y-axis
%   hTimeOffset    - height of time offset including dead space above it. we
%                    allocate some extra space so that the axes starts high
%                    enough above the bottom of the axes that the x-axis
%                    exponent (when shown) will fit on the figure
%   hXTickLabel    - height of tick label including space between label and
%                    axes (applies to all axes except bottom one)
%   hXTickLabel1   - height of the bottom most axes tick label including space
%                    between label and axes
%   wYTickLabel    - width of tick labels on y-axis + extra space between
%                    labels and axes + extra space between left edge of figure
%                    and start of the text
%   wRightSpace    - horizontal space between the right edge of the axes
%                    and the edge of the figure.  It must be big enough to
%                    accommodate the part of the last x tick label that hangs
%                    passed the axes edge
%   hTopSpace      - space between the top axes and the toolbar
%   hAxesSpace     - vertical space between axes (not including titles)
%   hBottomSpace   - vertical space between bottom of figure and first axes
%

if ~strcmp(axesGeom.tickLabelOpt, 'off')
    
    hTitle = 0; % No extra space needed.  It fits in the space allocated
    % for the y exponent.
    
    hYTickLabelExp = axExt(4) * expFactor;
    hTimeOffset    = max(uiExt(4) + 2, axExt(4) * expFactor);
    
    if strcmp(axesGeom.tickLabelOpt, 'OneTimeTick')
        axesGeom.hXTickLabel = 0;
    else
        axesGeom.hXTickLabel = axExt(4) + 2;
    end
    
    axesGeom.hXTickLabel1   = axExt(4) + 2;
    axesGeom.wYTickLabel    = tickLabelWidth + 3;
    axesGeom.wRightSpace    = axesGeom.wYTickLabel / 1.7;
    axesGeom.hTopSpace      = hYTickLabelExp;
    
    axesGeom.hAxesSpace = ...
        max(hYTickLabelExp, hTitle) + ...
        axesGeom.hXTickLabel        + ...
        2;
    
    axesGeom.hBottomSpace = hTimeOffset + axesGeom.hXTickLabel1;
    
else
    axesGeom.hXTickLabel    = 0;
    axesGeom.hXTickLabel1   = 0;
    axesGeom.wYTickLabel    = 0;
    axesGeom.wRightSpace    = 0;
    axesGeom.hTopSpace      = 0;
    axesGeom.hAxesSpace     = 0;
    axesGeom.hBottomSpace   = 0;
end


% Function: i_GetYTickInfo =====================================================
% Abstract:
%
%   Get YTickLabelMode, YTickLabels & YTicks for the specified axes.
%
%   The return argument is a structure with the following fields
%     - Tick:          [] OR [values for enumerated data type]
%     - TickMode:      'auto' OR 'manual'
%     - TickLabel:     [] OR {strings for enumerated data type}
%     - TickLabelMode: 'auto' OR 'manual'
%
function info = i_GetYTickInfo(scopeUserData, idx, changeNumberOfAxes)

block = scopeUserData.block;

% Default values if YTickLabels are disabled
info.TickLabelMode = 'auto';
info.TickLabel     = [];
info.TickMode      = 'auto';
info.Tick          = [];

% If number of axes is changing, just use the defaults
if changeNumberOfAxes
    return;
end

% If simulation is stopped or terminating, leave axes unchanged
simStatus = get_param(bdroot(block), 'SimulationStatus');
if (isequal(simStatus, 'stopped') || ...
        isequal(simStatus, 'terminating'))
    axis = scopeUserData.scopeAxes(idx);
    info.TickLabelMode = get(axis, 'YTickLabelMode');
    info.TickLabel     = get(axis, 'YTickLabel');
    info.TickMode      = get(axis, 'YTickMode');
    info.Tick          = get(axis, 'YTick');
    return;
end

% Get name of data type for this axes if it is unique
set_param(block, 'CurrentAxesIdx', idx);
dataType = get_param(block, 'AxesCommonBaseType');

% Early return if data type is mixed or model is not compiled
if isempty(dataType)
    return
end

% Special treatment for enumerated data types
metaClass = Simulink.getMetaClassIfValidEnumDataType(dataType);
if ~isempty(metaClass)
    info.TickLabelMode = 'manual';
    info.TickMode      = 'manual';
    
    [info.TickLabel, info.Tick] = ...
        Simulink.getUniqueListOfEnumNamesAndValues(metaClass);
end
% end i_GetYTickInfo


% Function: i_SetYTickInfo =====================================================
% Abstract:
%   Utility function for applying yTickInfo to a set of axes.
%
function i_SetYTickInfo(hAxes, yTickInfo)

% NOTE:
%   We must set YTick before YTickMode because otherwise when
%   you set YTick the YTickMode gets switched to 'manual'.
%   Same goes for YTickLabel & YTickLabelMode.
set(hAxes, ...
    'YTickLabel',     yTickInfo.TickLabel, ...
    'YTickLabelMode', yTickInfo.TickLabelMode, ...
    'YTick',          yTickInfo.Tick, ...
    'YTickMode',      yTickInfo.TickMode);

% end i_SetYTickInfo


% Function: i_FixPositionOfAxes(scopeUserData)
% Abstract:
%   Tweak horizontal position of axes to fit YTickLabels.
%
function i_FixPositionOfAxes(scopeUserData)

axes = scopeUserData.scopeAxes;

% EARLY RETURN if no tick labels being displayed
tickLabelsOff = strcmp(get_param(scopeUserData.block, 'TickLabels'), 'off');
if tickLabelsOff
    return
end

% Otherwise change x-position (and width) of axes to fit YTickLabels.
pos      = get(axes, 'Position');
outerPos = get(axes, 'OuterPosition');

if iscell(pos)
    pos      = cell2mat(pos);
    outerPos = cell2mat(outerPos);
end

if all(strcmp(get(axes, 'YTickLabelMode'), 'auto'))
    % All axes using "auto" tick labels
    % ==> Return to nominal axes positions
    axExt = i_AxesExtent(scopeUserData);
    left  = axExt(3);
    width = pos(1,1)+pos(1,3)-left;
else
    % Resize axes to force outerLeft edge inside figure
    outerLeft = outerPos(:,1);
    farLeft   = min(outerLeft)-5;
    left  = pos(1,1)-farLeft;
    width = pos(1,3)+farLeft;
    
    % Width must be positive
    if width <= 0
        left  = left+width;
        width = 1;
    end
end

pos(:,1) = left;
pos(:,3) = width;

for idx = 1:length(axes)
    set(axes(idx), 'Position', pos(idx, :));
end
% end i_FixPositionOfAxes


% Function: i_ComputeAxesInfo =================================================
% Abstract:
%
% Compute the axes information based on the current window configuration.
% The return argument is an array of structures (1xnAxes) with fields:
%   - Position:       [xLeft, yBottom, width, height]
%   - XTickLabelMode: 'auto' OR 'manual'
%   - YTickInfo:
%     - Tick:          [] OR [values for enumerated data type]
%     - TickMode:      'auto' OR 'manual'
%     - TickLabel:     [] OR {strings for enumerated data type}
%     - TickLabelMode: 'auto' OR 'manual'
%
function axesInfo = i_ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxes)

posScope       = get(scopeFig, 'Position');
hScope         = posScope(4);
wScope         = posScope(3);
tickLabelModes = {'manual', 'auto'};
changeNumberOfAxes = (nAxes ~= length(scopeUserData.scopeAxes));

%
% Determine the nominal horizontal dimensions for the axes (left & width).
% NOTE:
% - All axes have the same horizontal dimensions.
% - This position may get tweaked if the YTickLabels don't fit onto the scope.
%
left  = axesGeom.wYTickLabel;
right = wScope - axesGeom.wRightSpace;
wAxes = max(right - left, 1); % keep dims > 1

%
% Determine the axes height.  Note that all axes are the same height.
%
hAxesSpaces = axesGeom.hAxesSpace  * (nAxes - 1);

hAllAxes = ...
    hScope                  - ...
    hAxesSpaces             - ...
    axesGeom.hTopSpace      - ...
    axesGeom.hBottomSpace;

hAxes = max((hAllAxes / nAxes), 1); % keep dims > 1

%
% ... set up axes positions, ticks & labels
%
bottom = axesGeom.hBottomSpace;
axesInfo = struct('Position', cell(1,nAxes)); % Preallocate
if strcmp(axesGeom.tickLabelOpt, 'off')
    % If no tick labels displayed the axes fill the figure but set XTickLabelMode
    % to 'auto' so that signal viewer scope can display "inside" tick labels
    xTickLabelMode = 'auto';
else
    xTickLabelMode = tickLabelModes{(axesGeom.hXTickLabel ~= 0)+1};
end

for i=nAxes:-1:1,
    axesInfo(i).Position       = [left bottom wAxes hAxes];
    axesInfo(i).XTickLabelMode = xTickLabelMode;
    axesInfo(i).YTickInfo      = i_GetYTickInfo(scopeUserData, i, changeNumberOfAxes);
    
    top    = bottom + hAxes;
    bottom = top + axesGeom.hAxesSpace;
end

%
% ... handle the bottom-most axes specially, as it may be the only one
%     with tick labels on the x-axis
%
if strcmp(axesGeom.tickLabelOpt, 'off')
    % If no tick labels displayed the axes fill the figure but set XTickLabelMode
    % to 'auto' so that signal viewer scope can display "inside" tick labels
    axesInfo(nAxes).XTickLabelMode = 'auto';
else
    axesInfo(nAxes).XTickLabelMode = tickLabelModes{(axesGeom.hXTickLabel1 ~= 0)+1};
end

% Function: i_ComputeSimulationTimeSpan =======================================
% Abstract:
%
% Compute the simulation time span - used for resolving 'auto' time range.
%
% There are 2 cases:
%   1) Simulation is running (or initialized):
%      The actual time span (tFinal - tStart) will be returned.  Note that this
%      routine will not be aware of any changes to start or stop time that are
%      made while the simulation is running.
%
%   2) Simulation not running:
%      Try to evaluate tStart and tFinal in the base workspace.  If they don't
%      exist, return 10.
%
function simTimeSpan = ...
    i_ComputeSimulationTimeSpan(block, block_diagram, simStatus)

strStartTime   = get_param(block_diagram, 'StartTime');
strStopTime    = get_param(block_diagram, 'StopTime');
defSimTimeSpan = 10;
simTimeSpan    = -1;

if ~strcmp(simStatus, 'stopped')
    simTimeSpan = get_param(block, 'SimTimeSpan');
    if strcmp(simStatus,'initializing') && simTimeSpan == 0
        simTimeSpan = defSimTimeSpan;
    end
    if strcmp(simStatus,'updating') && simTimeSpan == 0
        simTimeSpan = defSimTimeSpan;
    end
else
    startTime = evalin('base', strStartTime, 'NaN');
    stopTime  = evalin('base', strStopTime,  'NaN');
    
    %
    % Try to calculate the simTimeSpan, assuming valid start/stop times.
    %
    try
        if isnan(startTime) || isnan(stopTime) || stopTime == Inf ||...
                stopTime - startTime == 0,
            simTimeSpan = defSimTimeSpan;
        else
            simTimeSpan = stopTime - startTime;
        end
    end
    
    %
    % Verify that we wound up with "nice" positive, scalar timespan.
    % Note, there are bizarre cases such as g292455 where users can
    % put strings into the stoptime field of the sim params dialog
    % box.  The strings can accidentally or otherwise resolve to Matlab
    % functions that return crazy things such as transfer function
    % objects which we don't really expect here.  The 'try' above and
    % below guard against these conditions.
    %
    try
        if ~isnumeric(simTimeSpan) || (simTimeSpan <= 0) ||...
                ~isreal(simTimeSpan) || ~isscalar(simTimeSpan)
            simTimeSpan = defSimTimeSpan;
        end
    catch
        simTimeSpan = defSimTimeSpan;
    end
end


% Function: i_ComputeAxesLimits ===============================================
% Abstract:
%
% Calculate the axes limits based on stored values.
%
% tLim   - the limits of the axes [0 tRange]
% offset - the corresponding offset (add to tLim to get actual)
% yLim   - A matrix of y-limits is returned where each row corresponds to an
%          axis.  Row 1 is the top-most axes.

function [tLim, yLim, offset] = i_ComputeAxesLimits(scopeFig, scopeUserData)

block         = scopeUserData.block;
block_diagram = scopeUserData.block_diagram;
simStatus     = get_param(block_diagram, 'SimulationStatus');

%
% Build "eval-able" strings for the ymin and ymax vectors.  They are
% stored in the models as: ymin1~ymin2~ymin3....
%
strYMin                 = get_param(block, 'YMin');
strYMin(strYMin == '~') = ',';
strYMin                 = ['[' strYMin ']'];

strYMax                 = get_param(block, 'YMax');
strYMax(strYMax == '~') = ',';
strYMax                 = ['[' strYMax ']'];

strTRange = i_GetTimeRange(block);

%
% Calculate Y-Limits.  The strings are stored in the mdl file in the form:
%   "ymax1 ymax2 ymax3 ... ymaxN"
%   "ymin1 ymin2 ymin3 ... yminN"
%
yMin = (eval(strYMin,'DAStudio.error(''Simulink:blocks:UnexpectedString4YMin'')'))';
yMax = (eval(strYMax,'DAStudio.error(''Simulink:blocks:UnexpectedString4YMax'')'))';

yLim = [yMin yMax];

eqLimits = find(yLim(:,1) == yLim(:,2));
for rowIdx = eqLimits,
    val   = yLim(rowIdx,1);
    delta = 0.05 * abs(val);
    yLim(rowIdx,:) = [val - delta, val + delta];
end

%
% Calculate T-Limits.
%
if strcmp(strTRange, 'auto')
    tRange = i_ComputeSimulationTimeSpan(block, block_diagram, simStatus);
    if isinf(tRange)
        tRange = 10.0;
    end
else
    tRange = sscanf(strTRange, '%lf');
end

offset = get_param(block, 'offset');
tLim   = [0 tRange];


% Function: i_SetBlockYLims ===================================================
% Abstract:
%
% Given a matrix of yLims (1 row per axes) build the appropriate strings for
% the YMin and YMax properties of the blocks.  The strings are ~ separated
% lists of the form:
%   yminAx1~yminAx2~yMinax3, ...

function i_SetBlockYLims(block, yLim)

% Don't issue set_param if the parameter value doesn't change
% This is necessary because the string representation of exponential numbers
% is different on the various platforms.  For example, UNIX: 1.0e-15, PC: 1.0e-015
% Since the string size changes, the models were getting dirtied on model load

try
    strYMin                 = get_param(block, 'YMin');
    strYMin(strYMin == '~') = ',';
    strYMin                 = ['[' strYMin ']'];
    oldYMin = eval(strYMin);
    
    strYMax                 = get_param(block, 'YMax');
    strYMax(strYMax == '~') = ',';
    strYMax                 = ['[' strYMax ']'];
    oldYMax = eval(strYMax);
    changed = ~isequal(yLim(:,1), oldYMin') || ~isequal(yLim(:,2), oldYMax');
catch
    changed = 1;
end

if changed
    yMinStr = sprintf('%g~', yLim(:,1));  yMinStr(end) = [];
    yMaxStr = sprintf('%g~', yLim(:,2));  yMaxStr(end) = [];
    set_param(block, 'YMin', yMinStr, 'YMax', yMaxStr);
end

% Function: TitleCell2Struct ==================================================
% Abstract:
%
% Convert a cell array of title strings into a struct of the form:
% struct.axes1 = 'title1';
% struct.axes2 = 'title2';
% ...

function outStruct = TitleCell2Struct(titles)

nTitles    = length(titles);
fieldNames = cell(1, nTitles);

for i=1:nTitles,
    fieldNames{i} = ['axes' sprintf('%d',i)];
end

outStruct = cell2struct(titles, fieldNames,1);


% Function: i_UpdateTitles ====================================================
% Abstract:
%
% Update the titles on all the axes.

function scopeUserData = i_UpdateTitles(scopeUserData)

block = scopeUserData.block;
DefaultAxesTitlesString = get_param(block,'DefaultAxesTitlesString');

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);
titles    = get_param(block, 'AxesTitles');

%
% Convert titles to cell array.
%

titles  = i_struct2cell(titles);
nTitles = length(titles);
changed = 0;

%
% Update the titles stored by the block - if needed.
%
if (nTitles > nAxes)
    % remove the extras
    titles(nAxes+1:end) = [];
    changed = 1;
end

if (nTitles < nAxes)
    % pad with default title
    [titles{end+1:nAxes,1}] = deal(DefaultAxesTitlesString);
    changed = 1;
end

if changed,
    % update the block
    set_param(block, 'AxesTitles', TitleCell2Struct(titles));
end

%
% Update the titles on the scope figure.
%
fontSize     = scopeUserData.axesFontSize;
fontName     = scopeUserData.axesFontName;

if strcmp(get_param(block, 'Ticklabels'), 'off')
    visible = 'off';
else
    visible = 'on';
end

titles = i_struct2cell(get_param(block,'ResolvedAxesTitles'));
for i=1:nAxes,
    ax           = scopeAxes(i);
    hTitle       = get(ax, 'Title');
    currentTitle = get(hTitle, 'String');
    if strcmp(get_param(block, 'Floating'), 'on')
        newTitle = '';
    else
        newTitle = titles{i};
    end
    
    %
    % Update the axes's title - if needed
    %
    
    % ... make sure that both use the same form of empty to
    %     work around bug (i.e., make sure that both are
    %     0x0)
    if isempty(newTitle), newTitle = ''; end
    if isempty(currentTitle), currentTitle = ''; end
    
    if ~strcmp(newTitle, currentTitle)
        scopeUserData.dirty = 1;
        set(hTitle, ...
            'String',       newTitle,...
            'FontName',     fontName, ...
            'FontSize',     fontSize, ...
            'Visible',      visible, ...
            'Interpreter',  'none', ...
            'Color',        get(ax, 'XColor'));
    else
        % make sure that the visibility is correct
        set(hTitle, 'Visible', visible);
    end
end
%endfunction


% Function: i_UpdateDefLimits =================================================
% Abstract:
%
% Update all defYlim and defTLims.  These are the cached values of the axes
% limits used to determine if the 'save current settings' menu items and
% toolbar buttons should be enabled.

function i_UpdateDefLimits(scopeUserData)

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);

yLims = get(scopeAxes, 'YLim');
if iscell(yLims)
    yLims = cat(1, yLims{:});
end

xLim = get(scopeAxes(1), 'XLim');

for i=1:nAxes,
    ax           = scopeAxes(i);
    axesUserData = get(ax, 'UserData');
    
    axesUserData.defXLim = xLim;
    axesUserData.defYLim = yLims(i,:);
    
    set(ax, 'UserData', axesUserData);
end


% Function: i_AxesColors ======================================================
% Abstract:
%
% Determine color attributes of scope axes.
function [axesColor, ticColor, axesColorOrder] = i_AxesColors(thisComputer)

%
% Set up color info.
%
switch(thisComputer)
    
    case 'PCWIN',
        axesColor      = [0.84 0.83 0.75];
        ticColor       = [0.2 0.2 0.2];
        %axesColorOrder = get(0, 'DefaultAxesColorOrder');
        
        
        axesColorOrder = [
            0 0 1
            1 0 0
            1 0 1
            0 1 1
            1 1 0
            0 0.8 0.25];
        
        
    case 'MAC2',
        axesColor      = get(0, 'DefaultAxesColor');
        ticColor       = get(0, 'DefaultAxesXColor');
        %axesColorOrder = get(0, 'DefaultAxesColorOrder');
        
    otherwise,  % X
        axesColor      = [0.84 0.83 0.75];
        ticColor       = [0.2 0.2 0.2];
        %axesColorOrder = get(0, 'DefaultAxesColorOrder');
        
        
        axesColorOrder = [
            0 0 1
            1 0 0
            1 0 1
            0 1 1
            1 1 0
            0 0.8 0.25];
        
end


% Function: i_UpdateAxesConfig ================================================
% Abstract:
%   Create the scope axes and time offset label - if needed.  ScopeUserData is
%   always modified.  Make sure that the number of input ports is set to the
%   desired number before calling this function.

function scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, doTimeRangeUpdate)

if nargin < 3
    doTimeRangeUpdate = true;
end

block        = scopeUserData.block;
scopeAxes    = scopeUserData.scopeAxes;
nAxes        = length(scopeAxes);
scopeHiLite  = scopeUserData.scopeHiLite;
floating     = onoff(get_param(block,'Floating'));
modelBased   = i_IsModelBased(block);
wireless     = onoff(get_param(block,'Wireless'));
axesGeom     = i_CreateAxesGeom(scopeUserData);
[tLim, yLim] = i_ComputeAxesLimits(scopeFig, scopeUserData);

if wireless,
    nAxesNeeded = eval(get_param(block,'NumInputPorts'));
    nAxesNeeded = nAxesNeeded(1); % number requested by user
else
    nAxesNeeded = get_param(block, 'ports');
    nAxesNeeded = nAxesNeeded(1); %number of input ports
end
axesAddedDeleted = (nAxesNeeded ~= nAxes);

%
% Compute the positions & other information for the axes.
% The upper most axes is the axis with index 1.
%
axesInfo = i_ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxesNeeded);

if (axesAddedDeleted)
    
    % start from scratch by deleting the axes and their prop dialogs (if opened)
    for i=1:nAxes,
        axUserData = get(scopeAxes(i), 'UserData');
        if ishandle(axUserData.propDlg)
            delete(axUserData.propDlg);
        end
        i_DeleteAxesHiLite(scopeAxes(i));
    end
    
    delete(scopeAxes);
    
    [axesColor, ticColor, axesColorOrder] = ...
        i_AxesColors(scopeUserData.thisComputer);
    
    %
    % Create the axes.
    %
    scopeUserData.scopeAxes      = 1:nAxesNeeded; % alloc
    scopeUserData.scopeHiLite    = INVALID_HANDLE*ones(1,nAxesNeeded); % alloc
    axUserData.propDlg           = INVALID_HANDLE;
    axUserData.defXLim           = tLim;
    axUserData.defYLim           = [];
    axUserData.idx               = [];
    axUserData.signals           = [];
    
    %
    % ...If there are more axes than stored yLim settings, than pad the yLim
    %    matrix with the proper number of default axes limits.  If the number has
    %    decreased remove the extra entries.
    %
    numToAdd = nAxesNeeded - size(yLim,1);
    if numToAdd > 0,
        defLims = [-5 5];
        newLims = defLims(ones(1,numToAdd), :);
        yLim = [yLim; newLims];
    end
    
    if numToAdd < 0,
        yLim = yLim(1:nAxesNeeded, :);
    end
    
    %
    % ...create the axes.
    %
    for i=1:nAxesNeeded,
        axUserData.idx     = i;
        axUserData.defYLim = yLim(i,:);
        if isfield(axUserData,'insideTickLabelsX')
            axUserData=rmfield(axUserData,{'insideTickLabelsX','insideTickLabelsY'});
        end
        
        scopeUserData.scopeAxes(i) = axes(...
            'Parent',           scopeFig,...
            'Units',            'pixel', ...
            'Position',         axesInfo(i).Position, ...
            'DrawMode',         'fast', ...
            'XLim',             tLim, ...
            'YLim',             yLim(i,:), ...
            'XGrid',            'on', ...
            'YGrid',            'on', ...
            'Color',            axesColor, ...
            'ColorOrder',       axesColorOrder, ...
            'XColor',           ticColor, ...
            'YColor',           ticColor, ...
            'TickLength',       [0 0], ...
            'XTickLabelMode',   axesInfo(i).XTickLabelMode, ...
            'XTickMode',        'auto', ...
            'Box',              'on', ...
            'FontSize',         scopeUserData.axesFontSize, ...
            'FontName',         scopeUserData.axesFontName, ...
            'Interruptible',    'off', ...
            'Busy',             'queue', ...
            'ZLimMode',         'manual', ...
            'CLimMode',         'manual', ...
            'ALimMode',         'manual', ...
            'UserData',         axUserData, ...
            'UIContextMenu',    scopeUserData.axesContextMenu.root);
        
        i_RenderInsideTickLabels(block, scopeUserData.scopeAxes(i));
        
        if wireless
            scopeUserData.scopeHiLite(i) = i_CreateAxesHiLite(scopeFig, ...
                scopeUserData.scopeAxes(i), ...
                tLim, yLim(i,:));
        end
    end
    
    %
    % Update the SelectedSignals to keep it in sync with
    % the scopeAxes data.  Then update the SelectedPortHandles
    % to keep them in sync.
    %
    i_UpdateSelectionDataNumAxes(block,nAxesNeeded);
    i_UpdateSelectedPortHandles(block);
    
    
    nAxes = nAxesNeeded;
    
    %
    % By default, the uppermost axes (#1) is selected and
    % NOT activated upon opening the first wireless scope.
    %
    if wireless
        selAxesIdx = get_param(block,'selectedAxesIdx');
        if selAxesIdx < 1 | selAxesIdx > nAxes
            selAxesIdx = 1;
            set_param(block, 'SelectedAxesIdx', selAxesIdx);
            % Note: The HiLite is handled below
        end
        
        set(scopeFig, 'CurrentAxes', scopeUserData.scopeAxes(selAxesIdx));
        set_param(block, 'CurrentAxesIdx', selAxesIdx);
        scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
    end
    
    %
    % Update the blocks YMin and YMax so that the strings are of the
    % proper length  (i.e., one element per axis)
    %
    i_SetBlockYLims(block, yLim);
    
else
    
    if ~strcmp(scopeUserData.tickLabelOpt, axesGeom.tickLabelOpt),
        % force a redraw in the current configuration
        scopeUserData = i_ResizeAxes(scopeFig, scopeUserData, axesGeom);
    end
    
    %
    % Update time ranges - if needed
    %
    if doTimeRangeUpdate
        blockTimeRange = tLim(2);
        axesTimeRange  = get(scopeAxes(1), 'XLim');
        axesTimeRange  = axesTimeRange(2) - axesTimeRange(1);
        
        if (blockTimeRange ~= axesTimeRange),
            scopeAxes = scopeUserData.scopeAxes;
            nAxes     = length(scopeAxes);
            for i=1:nAxes,
                ax           = scopeAxes(i);
                axesUserData = get(ax, 'UserData');
                
                set(ax, 'XLim', tLim);
                axesUserData.defXLim = tLim;
                set(ax, 'UserData', axesUserData);
                
                %
                % Update wireless scope highlighting positions
                % if they exist.
                %
                if ishandle(scopeUserData.scopeHiLite(i))
                    i_HiLiteResize(scopeUserData,i,tLim,yLim(i,:));
                else
                    scopeUserData.scopeHiLite(i) = INVALID_HANDLE;
                    i_DeleteAxesHiLite(ax);
                end
            end
        end
    end
end

% Always set up the YTick attributes for the axes
for i=1:nAxesNeeded,
    i_SetYTickInfo(scopeUserData.scopeAxes(i), axesInfo(i).YTickInfo);
end
i_FixPositionOfAxes(scopeUserData);

%
% Update status of the tick offset controls.
%
if ~strcmp(axesGeom.tickLabelOpt, 'off')
    if scopeUserData.timeOffsetLabel == INVALID_HANDLE,
        scopeUserData = i_CreateTimeOffsetCtrls(scopeFig, scopeUserData);
        set(scopeUserData.timeOffset, 'String', '0');
    else
        set([scopeUserData.timeOffsetLabel, scopeUserData.timeOffset], ...
            'Visible',  'on');
    end
else
    if scopeUserData.timeOffsetLabel ~= INVALID_HANDLE,
        set([scopeUserData.timeOffsetLabel, scopeUserData.timeOffset], ...
            'Visible',  'off');
    end
end

%
% Update the status of floating scope highlighting/focus rectangles
%
if wireless
    for i=1:nAxes,
        % create blue focus rectangle(s) and callback(s)
        % if they don't exist, reset axes to nominal.
        if ~ishandle(scopeUserData.scopeHiLite(i))
            set(scopeUserData.scopeAxes(i), ...
                'XLim',       tLim, ...
                'YLim',       yLim(i,:) ...
                );
            
            scopeUserData.scopeHiLite(i) = i_CreateAxesHiLite( ...
                scopeFig, ...
                scopeUserData.scopeAxes(i), ...
                tLim, yLim(i,:));
        end
    end
    
    selAxesIdx = get_param(block,'SelectedAxesIdx');
    
    if floating
        % Mouse selection enabled only for floating scope.
        set(scopeFig, 'ButtonDownFcn', 'simscopesv(''LockDownAxes'')');
    end
    
    
    %
    % Set selected axes focus if LockDown is off
    %
    if strcmp(get_param(block, 'LockDownAxes'), 'off'),
        
        oldScope = get_param(scopeUserData.block_diagram,'FloatingScope');
        
        if strcmp(oldScope,'')
            formattedBlockPath = getfullname(block);
            set_param(scopeUserData.block_diagram, 'FloatingScope', ...
                formattedBlockPath);
        end
    end
else
    for i=1:nAxes,
        % delete the highlighting rectangle and references to it.
        if ishandle(scopeUserData.scopeHiLite(i))
            scopeUserData.scopeHiLite(i) = INVALID_HANDLE;
        end
        i_DeleteAxesHiLite(scopeUserData.scopeAxes(i));
        
        % remove any buttondown callback from this axes
        set(scopeUserData.scopeAxes(i), 'ButtonDownFcn', '');
    end
    % remove any buttondown callback from the figure background
    set(scopeFig, 'ButtonDownFcn', '');
end

%
% Update context menu and support Signal selector on java supported platforms
%
if wireless && usejava('MWT')
    set(scopeUserData.axesContextMenu.select,'Visible','on', 'Enable', 'on');
else
    set(scopeUserData.axesContextMenu.select,'Visible','off');
end

scopeAxes = scopeUserData.scopeAxes;
if ~isempty(scopeAxes)
    for i=1:nAxes
        i_RenderInsideTickLabels(block, scopeAxes(i));
    end
end

%
% Update titles
%
scopeUserData = i_UpdateTitles(scopeUserData);

% Update Zoom Data Structure if axes have been added/deleted
if (axesAddedDeleted)
    %
    % Create/Update the Scope Zoom Data Structure
    %
    scopeUserData.zoomUserStruct = ...
        i_CreateZoomDataStructure(scopeUserData,scopeFig,nAxesNeeded);
    
    %
    % update the zoom button state and enabledness
    %
    scopebarsv(scopeFig, 'ZoomModeSwitch', get_param(scopeUserData.block,'ZoomMode'));
    i_DisableZoom(scopeFig, scopeUserData);
end

% figure has re-rendered
scopeUserData.dirty = 1;
set(scopeFig,'UserData',scopeUserData);
%endfunction i_UpdateAxesConfig



% Function: i_CreateZoomDataStructure =========================================
% Abstract:
%    Creates the scope zoom data structure and attaches it to the scope
%    user data.
%
function zoomUserStruct = ...
    i_CreateZoomDataStructure(scopeUserData, scopeFig, nNewAxes),

hAx = scopeUserData.scopeAxes;

%
% Total Number of Axis in the scope
%
zoomUserStruct.AXnum = nNewAxes;

%
% Axis stack - initialize to 20 levels.
%  Each row contains 4 #'s:  [xmin xmax ymin ymax]
%
zoomUserStruct.stack = zeros(nNewAxes, 20, 4);

%
% Index of current top of stack.
%
zoomUserStruct.topOfStack = 0;

%
% Handles to lines for rbbox.
%
zoomUserStruct.hLines = zeros(4, 1) - 1;

%
% Keep a copy of the original axis settings.
%  This way we'll have access to them, even
%  if the stack is empty.
%
zoomUserStruct.originalLimits = zeros(nNewAxes, 4);
for i=1:nNewAxes,
    zoomUserStruct.originalLimits(i,:) = ...
        [get(hAx(i), 'XLim'), get(hAx(i), 'YLim')];
end

%
% Create fields for previous selection type.
%
zoomUserStruct.oldSelectionType = 'blah';


% Function: i_Initialize ======================================================
% Abstract:
%    Create the scope figure window, toolbar and axes.

function [scopeFig, scopeUserData] = i_Initialize()

block          = gcb;
blockName      = get_param(block, 'Name');
block          = get_param(block, 'Handle');
block_diagram  = bdroot(block);
simStatus      = get_param(block_diagram, 'SimulationStatus');
uiFontName     = get(0, 'FactoryUicontrolFontName');
uiFontSize     = get(0, 'FactoryUicontrolFontSize');
axesFontName   = uiFontName;
axesFontSize   = uiFontSize;
scopePosition  = rectconv(get_param(block, 'Location'), 'hg');
wireless       = onoff(get_param(block,'Wireless'));
modelBased     = i_IsModelBased(block);
thisComputer   = computer;
%figColor       = [0.5 0.5 0.5];
%figColor       = [0.5 0.6 0.5];
figColor        = [0.60 0.64 0.65];

if strcmp(thisComputer, 'MAC2')
    figColor = get(0, 'DefaultFigureColor');
end

if wireless
    LockDownCallbackStr = 'simscopesv(''LockDownAxes'')';
else
    LockDownCallbackStr = '';
end

%
% Initialize some figure userdata fields.
%
scopeUserData.block            = block;
scopeUserData.block_diagram    = block_diagram;
scopeUserData.thisComputer     = thisComputer;
scopeUserData.toolGeom         = [];
scopeUserData.scopePropDlg     = INVALID_HANDLE;
scopeUserData.dialogGeom       = [];
scopeUserData.graphical        = [];
scopeUserData.timeOffsetLabel  = INVALID_HANDLE;
scopeUserData.timeOffset       = INVALID_HANDLE;
scopeUserData.scopeAxes        = [];
scopeUserData.scopeHiLite      = [];
scopeUserData.tickLabelOpt     = '';
scopeUserData.scopeLegends     = [];
scopeUserData.cachedLegStrs    = [];
scopeUserData.legLocsFig       = [];
scopeUserData.firstResize      = true;

%
% If this is a Model-based scope (aka 'Signal Viewer'), remove the
% prefix string from the block name and add something to the title
% to differentiate it from a regular scope of the same name.
%
if modelBased
    windowTitle = viewertitle(block, false);
else
    windowTitle = blockName;
end


%
% Create the figure.
%
scopeFig = figure(...
    'MenuBar',                          'none', ...
    'Units',                            'pixels', ...
    'Name',                             windowTitle, ...
    'Tag',                              'SIMULINK_SIMSCOPE_FIGURE',...
    'Position',                         figpos(scopePosition), ...
    'NextPlot',                         'new', ...  % g554783 Prevent subplot from hijacking scope   
    'NumberTitle',                      'off', ...
    'Visible',                          'off', ...
    'Renderer',                         'painters', ...
    'DoubleBuffer',                     'on', ...
    'BackingStore',                     'off', ...
    'ButtonDownFcn',                    LockDownCallbackStr, ...
    'DefaultUicontrolFontSize',         uiFontSize, ...
    'DefaultUicontrolFontName',         uiFontName, ...
    'DefaultUicontrolHorizontalAlign',  'left', ...
    'DefaultAxesUnits',                 'pixels', ...
    'ColorMap',                         [], ...
    'Color',                            figColor, ...
    'IntegerHandle',                    'off');

b = hggetbehavior(scopeFig,'PlotTools');
b.ActivatePlotEditOnOpen = false;

if (usejava('awt') == 1)
    scopeUserData.delayedCB = delayedcallback;
else
    scopeUserData.delayedCB = [];
end

%
% Create the context menu used by the axes.
%
hRoot = uicontextmenu( ...
    'Parent',          scopeFig, ...
    'Callback',        'simscopesv(''AxesContextMenu'',''Adjust'')');

scopeUserData.axesContextMenu.root = hRoot;

scopeUserData.axesContextMenu.Legends = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeLegends'), ...
    'Enable',       'on',...
    'Callback',     'simscopesv(''AxesContextMenu'',''Legend'')');

scopeUserData.axesContextMenu.zoomout = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeZoomOut'), ...
    'Enable',       'off',...
    'Callback',     'simscopesv(''AxesContextMenu'',''ZoomOut'')');

scopeUserData.axesContextMenu.find = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeAutoscale'), ...
    'Callback',     'simscopesv(''AxesContextMenu'',''Find'')');

scopeUserData.axesContextMenu.sync = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeSaveAxesSettings'), ...
    'Enable',       'off', ...
    'Callback',     'simscopesv(''AxesContextMenu'',''Sync'')');

scopeUserData.axesContextMenu.select = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeSignalSelection'), ...
    'Enable',       'on', ...
    'Callback',     'simscopesv(''AxesContextMenu'',''Select'')');

scopeUserData.axesContextMenu.properties = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeAxesProperties'), ...
    'Callback',     'simscopesv(''AxesContextMenu'',''Properties'')', ...
    'Separator',    'off');

scopeUserData.axesContextMenu.properties = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeParameters'), ...
    'Callback',     'simscopesv(''AxesContextMenu'',''Parameters'')', ...
    'Separator',    'on');

scopeUserData.axesContextMenu.tickLabels = uimenu(hRoot, ...
    'Label',        lclMessage('ScopeTickLabels'), ...
    'Separator',    'off');

scopeUserData.axesContextMenu.tickall = uimenu(hRoot,   ...
    'Parent',       scopeUserData.axesContextMenu.tickLabels, ...
    'Label',        lclMessage('ScopeParametersAll'),        ...
    'Callback',     'simscopesv(''AxesContextMenu'',''TickLabelAll'')', ...
    'Separator',    'off');

scopeUserData.axesContextMenu.tickinside = uimenu(hRoot, ...
    'Parent', scopeUserData.axesContextMenu.tickLabels,  ...
    'Label',        lclMessage('ScopeParametersInside'),      ...
    'Callback',     'simscopesv(''AxesContextMenu'',''TickLabelInside'')', ...
    'Separator',    'off');

scopeUserData.axesContextMenu.tickbottom = uimenu(hRoot, ...
    'Parent', scopeUserData.axesContextMenu.tickLabels,  ...
    'Label',        lclMessage('ScopeParametersBottomAxis'), ...
    'Callback',     'simscopesv(''AxesContextMenu'',''TickLabelBottom'')', ...
    'Separator',    'off');

%
% Create the context menu launched from whitespace.
%
hwsRoot = uicontextmenu( ...
    'Parent',          scopeFig, ...
    'Callback',        'simscopesv(''AxesContextMenu'',''Adjust'')');

set(scopeFig,'uicontextmenu',hwsRoot);

scopeUserData.wsContextMenu.root = hwsRoot;

scopeUserData.wsContextMenu.Legends = uimenu(hwsRoot, ...
    'Label',        lclMessage('ScopeLegends'), ...
    'Callback',     'simscopesv(''WSContextMenu'',''Legend'')', ...
    'Separator',    'off');

scopeUserData.wsContextMenu.properties = uimenu(hwsRoot, ...
    'Label',        lclMessage('ScopeParameters'), ...
    'Callback',     'simscopesv(''WSContextMenu'',''Parameters'')', ...
    'Separator',    'on');

scopeUserData.wsContextMenu.tickLabels = uimenu(hwsRoot, ...
    'Label',        lclMessage('ScopeTickLabels'), ...
    'Separator',    'off');

scopeUserData.wsContextMenu.tickall = uimenu(hwsRoot,   ...
    'Parent', scopeUserData.wsContextMenu.tickLabels, ...
    'Label',        lclMessage('ScopeParametersAll'),        ...
    'Callback',     'simscopesv(''WSContextMenu'',''TickLabelAll'')', ...
    'Separator',    'off');

scopeUserData.wsContextMenu.tickinside = uimenu(hwsRoot, ...
    'Parent', scopeUserData.wsContextMenu.tickLabels,  ...
    'Label',        lclMessage('ScopeParametersInside'),      ...
    'Callback',     'simscopesv(''WSContextMenu'',''TickLabelInside'')', ...
    'Separator',    'off');

scopeUserData.wsContextMenu.tickbottom = uimenu(hwsRoot, ...
    'Parent', scopeUserData.wsContextMenu.tickLabels,  ...
    'Label',        lclMessage('ScopeParametersBottomAxis'), ...
    'Callback',     'simscopesv(''WSContextMenu'',''TickLabelBottom'')', ...
    'Separator',    'off');

%
% Create a hidden uicontrol for text sizing & define fonts.
%
scopeUserData.textExtent = uicontrol(...
    'Style',          'text', ...
    'Visible',        'off' ...
    );

scopeUserData.uiFontName    = uiFontName;
scopeUserData.uiFontSize    = uiFontSize;
scopeUserData.axesFontName  = axesFontName;
scopeUserData.axesFontSize  = axesFontSize;

%
% Create the scope axes and the toolbar.
%
scopeUserData = scopebarsv(scopeFig, 'Create', scopeUserData);
scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData);

set(scopeFig, 'Visible', 'on'); % the scope is ready for display
drawnow;

%
% Setup the lineStyle order.
%
scopeUserData.lineStyleOrder = {'-','--',':','-.'};

scopeUserData.dirty = 0;

%
% Set the updated user data & finish off figure properties.
%
set(scopeFig,...
    'UserData',                 scopeUserData, ...
    'CloseRequestFcn',          'simscopesv CloseReq', ...
    'DeleteFcn',                'simscopesv DeleteFcn', ...
    'ResizeFcn',                'simscopesv Resize', ...
    'HandleVisibility',         'callback' ...
    );

%
% Now that the user data is set, initialize the toolbar zoom buttons
%

scopebarsv(scopeFig, 'ZoomModeSwitch', get_param(scopeUserData.block,'ZoomMode'));

%
% Let the model know whats going on out here.
%

set_param(block, 'Figure', scopeFig);

%endfunction i_Initialize


% Function: i_GetAllLineHandles ===============================================
% Abstract:
%    Get handles to all lines on all axes.

function allLines = i_GetAllLineHandles(block,scopeAxes)

nAxes = length(scopeAxes);

allLines = [];
for i=1:nAxes,
    set_param(block,'CurrentAxesIdx',i);
    hLines = get_param(block,'AxesLineHandles');
    if ~isempty(hLines)
        hLines = [hLines{:}];
        allLines = [allLines hLines];
    end
end
allLines(allLines==-1) = [];

% Function: i_ShiftNPlotAllAxes ===============================================
% Abstract:
%
% Call the i_ShiftNPlot function for all axes and clean up any "lit"
% pixels that have no associated data.
%
% endLiveTrace: Set to 1 if the scope is in the process of going from live
%               trace to data analysis mode (e.g., end of the simulation or
%               end of a data logging event in external mode).

function i_ShiftNPlotAllAxes( ...
    scopeUserData, modelDataLogs, endLiveTrace)

if isempty(modelDataLogs), return, end

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);

if ~isequal(nAxes, length(modelDataLogs.who))
    return;
end

for i=1:nAxes,
    currDataLog = eval(['modelDataLogs.axes', num2str(i)]);
    if ~isempty(currDataLog) && ishandle(currDataLog)
        i_ShiftNPlot(scopeUserData, currDataLog, i);
    end
end

%
% Get rid of "lit" pixels that have no associated data (if needed).
%
if endLiveTrace,
    block        = scopeUserData.block;
    offset       = get_param(block, 'offset');
    axIdx        = 1;
    ax           = scopeAxes(axIdx);
    xLim         = get(ax, 'XLim');
    
    set_param(block,'CurrentAxesIdx',axIdx);
    hLines = get_param(block,'AxesLineHandles');
    
    % Convert hLines to a regular array if it is a cell array.
    if iscell(hLines)
        hLines = [hLines{:}];
    end
    
    if ~isempty(hLines),
        
        xData = get(hLines(1), 'XData');
        
        if xData(1) > xLim(1),
            %
            % Clear background
            %
            get_param(block, 'BlitBackground');
            
            %
            % Force lines to redraw with their current data.
            %
            allLines = i_GetAllLineHandles(block,scopeAxes);
            set(allLines, 'Visible', 'off', 'Visible', 'on');
        end
    end
end

% Function: i_ShiftNPlot ======================================================
% Abstract:
%    Retrieve data from block, time shift it to comply with current scope
%    limits & offset and assign it to the lines.  Do this for the specied
%    axis.

function i_ShiftNPlot(scopeUserData, tsObject, axesIdx)

if isempty(tsObject) || ~isa(tsObject, 'Simulink.ScopeDataLogs')
    return;
end

block        = scopeUserData.block;
scopeAxes    = scopeUserData.scopeAxes;
ax           = scopeAxes(axesIdx);
offset       = get_param(block, 'offset');
axesUserData = get(ax, 'UserData');

set_param(block,'CurrentAxesIdx',axesIdx);

hLines = get_param(block,'AxesLineHandles');
if isempty(hLines), return, end
hLines = [hLines{:}];
nLines = length(hLines);

stairFlags = get_param(block,'AxesLineStairFlags');
stairFlags = [stairFlags{:}];

set(hLines, 'Visible', 'off');
xlim = get(ax,'xlim'); set(ax,'xlim',[-1 1]); set(ax,'xlim',xlim); %force redraw
newIdx = i_ShiftNPlotRecursive(hLines, stairFlags, offset, 1, tsObject);
set(hLines, 'Visible', 'on');

% Function: i_ShiftNPlotRecursive ==============================================
% Abstract:
%    Recursively descend into the ModelDataLogs and its associated TsArrays
% to do the processing described in i_ShiftNPlot above.
function newIndex = i_ShiftNPlotRecursive(hLines, stairFlags, offset, index, ...
    tsObject)

dataElems = [];

if isa(tsObject, 'Simulink.ScopeDataLogs')
    dataElems = tsObject.who;
elseif isa(tsObject, 'Simulink.TsArray')
    dataElems = tsObject.who;
elseif isa(tsObject, 'Simulink.Timeseries')
    time = tsObject.Time;
    data = tsObject.Data;
    
    newIndex = i_DrawLines(hLines, time, data, index, stairFlags, offset);
    return;
end

for i=1:length(dataElems)
    elem = dataElems{i};
    
    % If there are any single quotes embedded in the signal name, we need
    % to preprocess it so that it can be eval'd successfully below
    % Example  signal name is: ('n'')  -> signal name is n'
    % Modified signal name is: ('n''')
    new_elem = elem(3:end-2);  % strip out leading (' and trailing ')
    if any(strfind(new_elem, ''''))
        new_elem = strrep(new_elem, '''', '''''');
        elem = ['(''', new_elem, ''')'];
    end
    
    % If there are any newlines embedded in the signal name, we need
    % to preprocess it so that it can be eval'd successfully below
    % Example signal name is: ('Actual          <--- newline!
    %                           Temperature')
    % Modified signal name is: (['Actual', sprintf('\n'), 'Temperature'])
    if any(strfind(elem, sprintf('\n')))
        elem = strrep(elem, sprintf('\n'), ''', sprintf(''\n''), ''');
        elem = ['([', elem(2:end-1), '])'];
    end
    
    obj = eval(['tsObject.', elem]);
    if isa(obj, 'Simulink.TsArray')
        index = i_ShiftNPlotRecursive(hLines, stairFlags, offset, index, obj);
    elseif isa(obj, 'Simulink.Timeseries')
        time = obj.Time;
        data = obj.Data;
        index = i_DrawLines(hLines, time, data, index, stairFlags, offset);
    end
end

newIndex = index;

% Function: i_DrawLines =======================================================
% Abstract:
%      Helper routine to draw lines given the data and time info.
%
function newIndex = i_DrawLines(hLines, time, data, index, stairFlags, offset)

%
% Continue if empty
%
if isempty(time) || isempty(data)
    newIndex = index + 1;
    return;
end

%
% Scalar information
%
if isscalar(time) && isscalar(data)
    newIndex = index + 1;
    return;
end

%
% Use the double representation of fixpoint data
%
if isa(data, 'embedded.fi')
    data  = data.double;
end

%
% Reshape matrix data from a 3-d matrix to a 2-d matrix with
% the same number of rows as the length of the time vector
%
dims = size(data);
if length(dims) >=2
    P = size(data);
    
    % Make sure that we have at least 3 dimensions in P so the
    % calculations below do not transpose the data. g402193
    %       if length(P) < 3
    %           P = [P 1];
    %       end
    % Reshape data by adding ones in the end if time is scalar
    % Otherwise, only if data is 3-d, then reshape differently.
    if isscalar(time) % g419893
        data = reshape(data, prod(P), 1).';
    elseif length(dims) >2 % g420600, g419893
        data = reshape(data, prod(P(1:end-1)),P(end)).';
    end
end
dims = size(data);

for i=1:dims(2)
    if stairFlags(index),
        [xData, yData] = ...
            stairs(time - offset, data(:, i));
        set(hLines(index), 'XData', xData, 'YData', double(yData));
    else
        set(hLines(index), ...
            'XData', time - offset, 'YData', double(data(:, i)));
    end
    index = index + 1;
end
newIndex = index;

% Function: i_RestoreDefaultAxesLimits ========================================
% Abstract:
%    Restore axes to default limits (the limits stored in the block as opposed
%    to the current limits which may be the result of zooming).  Do this for
%    each axis.

function scopeUserData = i_RestoreDefaultAxesLimits(scopeFig, scopeUserData)

block     = scopeUserData.block;
scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);

%
% Reset the limits.
%
[tLim, yLim] = i_ComputeAxesLimits(scopeFig, scopeUserData);

limitsChanged = 0;
for i=1:nAxes,
    ax = scopeAxes(i);
    
    oldTLim = get(ax, 'XLim');
    oldYLim = get(ax, 'YLim');
    
    if (~all(oldTLim == tLim)) || (~all(oldYLim == yLim(i,:)))
        
        limitsChanged = 1;
        set(ax, 'XLim', tLim, 'YLim', yLim(i,:));
        i_RenderInsideTickLabels(block, ax);
        
        if onoff(get_param(block, 'Wireless'))
            i_HiLiteResize(scopeUserData,i,tLim,yLim(i,:));
        end
        
        %
        % Set the data of all lines to empty prior to resetting the axes limits.
        % This avoid an annoying flash of the old data before starting the trace for
        % the current sim.
        %
        set_param(block,'CurrentAxesIdx',i);
        hLines = get_param(block,'AxesLineHandles');
        
        if (~isempty(hLines))
            hLines = [hLines{:}];
            set(hLines, {'XData';'YData'}, {NaN, NaN});
        end
    end
end

if limitsChanged,
    % figure has re-rendered
    scopeUserData.dirty = 1;
end


% Function: i_InitTickOffset ==================================================
% Abstract:
%    Initialize offset text ctrl (if required).

function i_InitTickOffset(scopeUserData, offset)

if ~strcmp(get_param(scopeUserData.block, 'TickLabels'), 'off')
    set(scopeUserData.timeOffset, 'String', sprintf('%-16g', offset));
end


% Function: i_GetDataFromPreviousSim ==========================================
% Abstract:
%
% Check for data from the previous sim.  Make sure that the data matches the
% current scope configuration (e.g., the number of axes present is the same
% as the number of data sets contained by the logVar).  If the data is not
% consistent with the scope configuration, we throw it away.  This can
% happens if the number of ports is changed after the sim has run.

function modelDataLogs = i_GetDataFromPreviousSim(scopeFig, scopeUserData)

block = scopeUserData.block;

modelDataLogs = get_param(block, 'CopyDataBuffer');
if isempty(modelDataLogs), return, end;

nAxes = length(scopeUserData.scopeAxes);

%
% Check for matching configurations.  If not a match, throw away the
% data.  There is one signal per axes (it may be a vector signal).
%
if isempty(modelDataLogs) || ~ishandle(modelDataLogs)
    modelDataLogs = [];
    return;
end

nSignalsInData = length(modelDataLogs.who);

if (nAxes ~= nSignalsInData),
    modelDataLogs = [];
end


% Function: i_IsEmptyLogData ===================================================
% Abstract:
%
% Return true if the time series object representing the line data is "empty".
% "Empty" means that it doesn't exist, or all of it's fields are empty.  The
% latter can happen on error conditions and via the S-function API to models
% where the logVar can be created, but never filled in.

function empty = i_IsEmptyLogData(logData)

if isempty(logData)
    empty = 1;
else
    logDataInfo = logData.who;
    len = length(logDataInfo);
    if len == 1 && isa(logData, 'Simulink.ScopeDataLogs')
        empty = 0;
    else
        for indx = logDataInfo(:)'
            currDataLog =   indx{1};
            if ~isempty(currDataLog)
                empty = 0;
            else
                empty = 1;
                break;
            end
        end
    end
end


% Function: i_ProcessOpenRequest ==============================================
% Abstract:
%    Process open request for block.

function [scopeFig, scopeUserData] = ...
    i_ProcessOpenRequest(scopeFig, scopeUserData)

block          = gcb;
block_diagram  = bdroot(block);
simStatus      = get_param(block_diagram, 'SimulationStatus');

if scopeFig ~= INVALID_HANDLE,
    disabled   = onoff(get_param(block,'ResolvedDisabled'));
    visible    = onoff(get(scopeFig,'Visible'));
    treatAsVis = visible & ~disabled;
    
    %
    % It's a valid figure.
    %
    switch onoff(treatAsVis),
        
        case 'on',
            %
            % Already visible - pop it to foreground.
            %
            figure(scopeFig);
            
        case 'off',
            %
            % Make it visible and re-initialize.
            %
            if ~strcmp(simStatus, 'stopped')
                i_CreateLinesIfNeeded(scopeFig, scopeUserData);
                i_SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, 'off');
                scopeUserData = i_RestoreDefaultAxesLimits(scopeFig, scopeUserData);
                
                %
                % Draw the data that we already have.
                %
                modelDataLogs = get_param(block, 'CopyDataBuffer');
                i_ShiftNPlotAllAxes(scopeUserData, modelDataLogs, 0);
            else
                
                [tLim, yLim, offset] = ...
                    i_ComputeAxesLimits(scopeFig, scopeUserData);
                
                %
                % Show data from previous sim.
                %
                modelDataLogs = i_GetDataFromPreviousSim(scopeFig, scopeUserData);
                i_SetEnableForNonRunWithData(scopeFig, scopeUserData);
                if ~i_IsEmptyLogData(modelDataLogs),
                    %
                    % Have data from previous sim - show it.
                    %
                    i_CreateLinesIfNeeded(scopeFig, scopeUserData);
                    i_InitTickOffset(scopeUserData, offset);
                    i_ShiftNPlotAllAxes(scopeUserData, modelDataLogs, 0);
                end
                
                %
                % Cache the current axes limits for later comparison.  This allows
                % the proper enabling the "Save axes settings" toolbar button.
                %
                i_UpdateDefLimits(scopeUserData);
            end
            
            i_MarkerCB(scopeFig,scopeUserData),
            
            set(scopeFig, 'Visible', 'on');
            % g380645:If the scope is opened while the simulation is already running,
            % add drawnow to flush the queue. Note that in order to fix the axes
            % refresh issue, the scope should be visible before drawnow is called in
            % order to flush the queue.
            if strcmp(simStatus, 'running')
                % g452469: Regression of g380645: there were some bug fixes in
                % the drawnow method in R2008a (earlier drawnow update
                % was doing everything that drawnow did, the same reason why
                % drawnow('update') used to work here before the bug fix).
                % updating this to drawnow expose instead.
                drawnow expose;
            end
        otherwise,
            %
            % Should never happen (utAssert).
            %
            DAStudio.error('Simulink:blocks:InvalidVisibilityString');
    end
    
else
    %
    % It's not a valid figure -- create one.
    %
    [scopeFig, scopeUserData] = i_Initialize;
    
    block = scopeUserData.block;
    
    if strcmp(simStatus, 'stopped')
        [tLim, yLim, offset] = ...
            i_ComputeAxesLimits(scopeFig, scopeUserData);
        
        %
        % Show data from previous sim.
        %
        modelDataLogs = i_GetDataFromPreviousSim(scopeFig, scopeUserData);
        if ~i_IsEmptyLogData(modelDataLogs),
            %
            % Have data from previous sim - show it.
            %
            i_CreateLinesIfNeeded(scopeFig, scopeUserData);
            i_SetEnableForNonRunWithData(scopeFig, scopeUserData);
            i_InitTickOffset(scopeUserData, offset);
            i_ShiftNPlotAllAxes(scopeUserData, modelDataLogs, 0);
        else
            %
            % No data from previous sim - disable everything.
            %
            i_SetEnableForNonRunWithNoData(scopeFig, scopeUserData);
        end
        
        %
        % Cache the current axes limits for later comparison.  This allows
        % the proper enabling the "Save axes settings" toolbar button.
        %
        i_UpdateDefLimits(scopeUserData);
    else
        i_CreateLinesIfNeeded(scopeFig, scopeUserData);
        
        %
        % Draw the data that we already have.
        %
        modelDataLogs = get_param(block, 'CopyDataBuffer');
        i_ShiftNPlotAllAxes(scopeUserData, modelDataLogs, 0);
        
        scopeUserData.dirty = 1;
        set(scopeFig, 'UserData', scopeUserData); %g381592
        i_UpdateEraseBufferIfNeeded(scopeFig);
        scopeUserData = get(scopeFig, 'UserData');
    end
end

if onoff(get_param(block,'Floating'))
    param = 'OverrideFloatScopeTimeRange';
else
    param = 'OverrideScopeTimeRange';
end
if ~isnan(get_param(block_diagram, param))
    scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData);
end
set(scopeFig, 'UserData', scopeUserData);


% Function: i_CreateLinesIfNeeded =============================================
% Abstract:
%    Create the scope lines (if needed) and set them in the scope block.

function i_CreateLinesIfNeeded(scopeFig, scopeUserData)

block     = scopeUserData.block;
scopeAxes = scopeUserData.scopeAxes;

nAxes = length(scopeAxes);

for i=1:nAxes,
    set_param(block, 'CurrentAxesIdx', i);
    i_CreateLinesForCurrentAxes(scopeFig, scopeUserData);
end


% Function: ====================================================================
%
function scopeUserData = i_DestroyLegends(scopeFig,scopeUserData)
scopeAxes = scopeUserData.scopeAxes;

haveLegends = ~isempty(legend('-find',scopeAxes(1)));
if (haveLegends),
    scopeUserData.legLocsFig = i_GetLegendLocsFromFig(scopeUserData,haveLegends);
    nAxes = length(scopeAxes);
    for ax=1:nAxes,
        legend(scopeAxes(ax),'off');
    end
    scopeUserData.scopeLegends = [];
    % g466483: We need to dirty the scopeUserData to capture this change
    scopeUserData.dirty = 1;
end
%endfunction


% Function: ====================================================================
% Abstract:
%
function scopeUserData = i_UpdateLegends(scopeFig,scopeUserData,resize)
block     = scopeUserData.block;

if nargin < 3,
    resize = false;
end

%
% Assume that all are out of date..destroy them
%
scopeUserData = i_DestroyLegends(scopeFig,scopeUserData);

%
% Re-create if requested
%
legendsOn = onoff(get_param(block,'ShowLegends'));
if legendsOn,
    
    %
    % If the locations are empty, the legends have not been drawn.
    % Retrieve the legend locs from the bd.
    %
    locs = scopeUserData.legLocsFig; %assume
    if isempty(locs),
        locs = i_GetLegendLocsFromBD(scopeUserData);
    end
    scopeUserData = i_AddLegends(scopeFig,scopeUserData,locs, resize);
    
    % Hack alert.  When resizing the window, the legend dimension seem
    % to get screwed up.  For that case, I put them up with no explicit
    % loc.  Get the width and dimemsions that legend uses as they are nice
    % then update the original location with the new dims.
    %
    if resize
        if ~isempty(locs) && ~all(locs(:) == 0),
            haveLegends = true;
            tmpLocs = i_GetLegendLocsFromFig(scopeUserData,haveLegends);
            
            nLocs    = size(locs,1);
            nTmpLocs = size(tmpLocs,1);
            
            if nLocs ~= nTmpLocs,
                if nLocs > nTmpLocs,
                    locs = locs(1:nTmpLocs,:);   %truncate
                elseif nLocs < nTmpLocs,
                    locs(nTmpLocs,:) = [0 0 0 0]; %zero pad
                end
            end
            locs(:,[3 4]) = tmpLocs(:,[3 4]);
            scopeUserData = i_DestroyLegends(scopeFig,scopeUserData);
            scopeUserData = i_AddLegends(scopeFig,scopeUserData,locs, false);
        end
    end
    % g475614: The viewer does not refresh correctly when opened during
    % simulation (with legends turned on). This issue is seen only 
    % on Windows. The viewers refresh fine on Linux.
    % This issue originated in R2008a. This fix is a temporary hack. We
    % still need to discuss with the HG team why this bug has shown up recently.
    drawnow;

    for indx = 1:length(scopeUserData.scopeLegends)
        legend(scopeUserData.scopeLegends(indx), 'show'); % g374553
    end
end
set(scopeFig, 'UserData', scopeUserData);
%endfunction


% Function: i_SimulationStart =================================================
% Abstract:
%    Perform simulation init tasks.

function scopeUserData = i_SimulationStart(scopeFig, scopeUserData)

block      = scopeUserData.block;
scopeAxes  = scopeUserData.scopeAxes;
modelBased = i_IsModelBased(block);

scopeUserData = i_UpdateAxesConfig(scopeFig,scopeUserData);
i_CreateLinesIfNeeded(scopeFig,scopeUserData);
i_SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, 'off');
scopeUserData = i_RestoreDefaultAxesLimits(scopeFig, scopeUserData);

scopeUserData = i_UpdateTitles(scopeUserData);

%
% Handle legend
%
scopeUserData = i_UpdateLegends(scopeFig,scopeUserData);
%endFunction

% Function: i_BufferInUse =====================================================
% Abstract:
%   Return true if the scope is storing data in its buffers.

function bufferInUse = i_BufferInUse(block)

bufferInUse = ~((strcmp(get_param(block, 'LimitDataPoints'), 'on')) && ...
    (evalin('base',get_param(block, 'MaxDataPoints')) == 0.0));


% Function: i_SimulationTerminate =============================================
% Abstract:
%    Handle simulation termination.

function scopeUserData = i_SimulationTerminate(scopeFig, scopeUserData)

block       = scopeUserData.block;
scopeAxes   = scopeUserData.scopeAxes;
simStatus   = 'terminating';
bufferInUse = i_BufferInUse(block);
modelBased  = i_IsModelBased(scopeUserData.block);
%
% Enable appropriate UI controls.
%
i_SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, 'on');

% 
% Skip last plot if freeze is on
%
disabled = onoff(get_param(block,'Disabled')); 
if bufferInUse && ~disabled,
    %
    % Fill in line data for last screen (currently there are "lit pixels"
    % with no data because we use erasemode none for animation.
    %
    modelDataLogs = get_param(block, 'CopyDataBuffer');
    if ~i_IsEmptyLogData(modelDataLogs),
        i_ShiftNPlotAllAxes(scopeUserData, modelDataLogs, 1);
    end
end

%
% Cache the current axes limits for later comparison.  This allows
% the proper enabling the "Save axes settings" toolbar button.
%
i_UpdateDefLimits(scopeUserData);

%
% Cache the current legend strings for later use (they are not avail
% when sim is not running.
%
scopeUserData.cachedLegStrs = get_param(block,'LegendString');

%
% Turn zoom on (if needed).
%
floating = onoff(get_param(block, 'Floating'));
zoomMode = get_param(block, 'ZoomMode');
if bufferInUse && ~floating,
    scopezoom(zoomMode, scopeFig);
    scopezoom('reset', scopeFig);
end

% Turn on selection rectangle if scope is model-based.  If the user
% clicked on an axes during simulation, the HG current axes may have
% changed, so we should fix it here.
if modelBased
    selAxesIdx = get_param(block,'SelectedAxesIdx');
    set(get_param(block,'Figure'), 'CurrentAxes', scopeAxes(selAxesIdx));
end


% Function: i_ResizeAxes ======================================================
% Abstract:
%    Handle all the tasks needed to be done when resizing an axes.

function scopeUserData = i_ResizeAxes(scopeFig, scopeUserData, axesGeom)

scopeAxes       = scopeUserData.scopeAxes;
nAxes           = length(scopeAxes);
axesGeom        = i_CreateAxesGeom(scopeUserData);
axesInfo        = i_ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxes);
block           = scopeUserData.block;

for i=1:length(scopeAxes),
    ax = scopeAxes(i);
    set(ax, ...
        'XTickLabel',     [], ...
        'XTickLabelMode', axesInfo(i).XTickLabelMode, ...
        'Position',       axesInfo(i).Position);
    i_SetYTickInfo(scopeAxes(i), axesInfo(i).YTickInfo);
    i_RenderInsideTickLabels(block, ax);
end
i_FixPositionOfAxes(scopeUserData);

if ~strcmp(scopeUserData.tickLabelOpt, axesGeom.tickLabelOpt),
    scopeUserData.tickLabelOpt = axesGeom.tickLabelOpt;
end

scopeUserData.dirty = 1;
set(scopeFig, 'UserData', scopeUserData); %g388178
%endfunction


% Function: i_SetEnableForNonRuntimeCtrls =====================================
% Abstract:
%    Disable/Enable UI ctrls that are not appropriate for runtime use.

function i_SetEnableForNonRuntimeCtrls(scopeFig, scopeUserData, onoffState)

switch(onoffState),
    
    case 'on',
        state = 'notrunning';
        
    case 'off',
        state = 'running';
        scopezoom('off', scopeFig);
        
    otherwise,
        DAStudio.error('Simulink:blocks:InvalidState');
end

scopebarsv(scopeFig, 'CtrlUI', state);


% Function: i_SetEnableForNonRunWithData ======================================
% Abstract:
%    Set enabled for case of opening a scope in a non-running block diagram
%    with previous simulation data.

function i_SetEnableForNonRunWithData(scopeFig, scopeUserData)

children = scopeUserData.toolbar.children;
block    = scopeUserData.block;
floating = onoff(get_param(block, 'Floating'));

if ~floating,
    iconsOn = [
        children.modeIcons.ZoomNormal
        children.modeIcons.ZoomX
        children.modeIcons.ZoomY
        children.actionIcons.Print
        children.actionIcons.Find];
    
    iconsOff = [];
    zoomMode = get_param(block, 'ZoomMode');
else
    iconsOn =[];
    
    iconsOff = [
        children.modeIcons.ZoomNormal
        children.modeIcons.ZoomX
        children.modeIcons.ZoomY
        children.actionIcons.Find];
    
    zoomMode = 'off';
end

scopebarsv(scopeFig, 'EnableIcon', iconsOn,  'on');
scopebarsv(scopeFig, 'EnableIcon', iconsOff, 'off');
scopezoom(zoomMode, scopeFig);


% Function: i_SetEnableForNonRunWithNoData ====================================
% Abstract:
%    Set enabled for case of opening a scope in a non-running block diagram
%    with no previous simulation data.

function i_SetEnableForNonRunWithNoData(scopeFig, scopeUserData)

children = scopeUserData.toolbar.children;
block    = scopeUserData.block;

iconsOff = [
    children.modeIcons.ZoomNormal
    children.modeIcons.ZoomX
    children.modeIcons.ZoomY
    children.actionIcons.Find];

scopebarsv(scopeFig, 'EnableIcon', iconsOff,  'off');
scopezoom('off', scopeFig);


% Function: i_DisableZoom =====================================================
% Abstract:
%    Disable zoom buttons on the scope bar.
%

function i_DisableZoom(scopeFig, scopeUserData)

children = scopeUserData.toolbar.children;
block    = scopeUserData.block;

iconsOff = [
    children.modeIcons.ZoomNormal
    children.modeIcons.ZoomX
    children.modeIcons.ZoomY];

scopebarsv(scopeFig, 'EnableIcon', iconsOff,  'off');
scopezoom('off', scopeFig);


% Function: i_CreateTimeOffsetCtrls ===========================================
% Abstract:
%    Create text objects for time offset.

function scopeUserData = i_CreateTimeOffsetCtrls(scopeFig, scopeUserData)

scopeAxes     = scopeUserData.scopeAxes(end);
block         = scopeUserData.block;
txtColor      = get(scopeAxes, 'XColor');
scopeFigColor = get(scopeFig, 'Color');

%
% Determine size of text label.
%
textExtent = scopeUserData.textExtent;
set(textExtent, ...
    'FontName',       scopeUserData.uiFontName, ...
    'FontSize',       scopeUserData.uiFontSize, ...
    'String',         [lclMessage('ScopeTimeOffset') ' ']);
ext = get(textExtent, 'Extent');

pos = [1, 1, ext(3), ext(4)];

%
% Create text label.
%
scopeUserData.timeOffsetLabel = uicontrol( ...
    'Parent',             scopeFig, ...
    'Style',              'text', ...
    'String',             lclMessage('ScopeTimeOffset'), ...
    'Position',           pos, ...
    'ForegroundColor',    txtColor, ...
    'BackgroundColor',    scopeFigColor, ...
    'Visible',            'on');

%
% Create offset text object.
%
pos(1) = pos(1) + pos(3) + 2;
pos(3) = 100;

scopeUserData.timeOffset = uicontrol( ...
    'Parent',             scopeFig, ...
    'Style',              'text', ...
    'Tag',                'offset',...
    'Position',           pos, ...
    'ForegroundColor',    txtColor, ...
    'BackgroundColor',    scopeFigColor, ...
    'Visible',            'on');

%
% Hand the block the uicontrols handle.
%
set_param(block, 'TimeOffsetHandle', scopeUserData.timeOffset);


% Function: i_GetStrField =====================================================
% Abstract:
%    Given a block string delimited by '~' (e.g., ymin, ymax, titles), return
%    the i'th field.  The string MUST be of the form: 'field1~field2~field3'

function outStr = i_GetStrField(inStr, i)

if isempty(inStr),
    outStr = '';
    return;
end

toks   = [0 find(inStr == '~') length(inStr)+1];
start  = toks(i)+1;
stop   = toks(i+1) - 1;

outStr = inStr(start:stop);


% Function: i_SetStrField =====================================================
% Abstract:
%    Given a block string delimited by '~' (e.g., ymin, ymax, titles), set
%    the i'th field to the new value.  The string must be of the form:
%
%    'field1~field2~field3'

function outStr = i_SetStrField(inStr, i, newStr)

if ~isempty(inStr),
    toks   = [0 find(inStr == '~') length(inStr)+1];
    start  = toks(i)+1;
    stop   = toks(i+1) - 1;
    
    outStr = [inStr(1:toks(i)) newStr inStr(toks(i+1):end)];
else
    outStr = newStr;
end


% Function: i_GetAxesPropDlgName ==============================================
% Abstract:
%
function dlgName = i_GetAxesPropDlgName(ax, block, axesIdxStr)

hTitle   = get(ax, 'Title');
titleStr = get(hTitle, 'String');

if ~isempty(titleStr) && ~all(titleStr == ' ')
    dlgName = lclMessage('ScopeAxesPropertiesTitle', get_param(block, 'name'), titleStr);
else
    dlgName = lclMessage('ScopeAxesPropertiesTitleAxis', get_param(block, 'name'), axesIdxStr);
end


% Function: i_SyncAxPropertiesDialog ==========================================
% Abstract:
%    Sync fields of axes property dialog with block.

function i_SyncAxPropertiesDialog(block, dialogUserData, axesIdx)

children = dialogUserData.children;

h            = children.yMinEdit;
blockYMinStr = get_param(block, 'YMin');
str          = i_GetStrField(blockYMinStr, axesIdx);
set(h, 'String', str);

h            = children.yMaxEdit;
blockYMaxStr = get_param(block, 'YMax');
str          = i_GetStrField(blockYMaxStr, axesIdx);
set(h, 'String', str);

h            = children.titleEdit;
blockTitles  = i_struct2cell(get_param(block, 'AxesTitles'));
str          = blockTitles{axesIdx};
set(h, 'String', str);


% Function: i_CreateAxPropertiesDialog ========================================
% Abstract:
%    Create the properties dialog box for the specified axis.  If it exist,
%    pop it to the foreground.

function i_CreateAxPropertiesDialog(scopeFig, scopeUserData, axesIdx)

ax         = scopeUserData.scopeAxes(axesIdx);
axUserData = get(ax, 'UserData');
block      = scopeUserData.block;
axesIdxStr = sprintf('%d',axesIdx);

%
% If it already exist, bring it to the foreground.
%
if ishandle(axUserData.propDlg),
    figure(axUserData.propDlg);
    return;
end

%
% Create geometry contants.
%
sysOffsets = sluigeom('character');

maxTitleWidth = 'This seems like a pretty good max title width   ';

dlgGeom.hText          = 1 + sysOffsets.text(4);
dlgGeom.hEdit          = 1 + sysOffsets.edit(4);
dlgGeom.wYMinLabel     = length('Y-Min: ');
dlgGeom.wYMaxLabel     = dlgGeom.wYMinLabel;
dlgGeom.wStdEdit       = length('0.123456789012') + sysOffsets.edit(3);
dlgGeom.colSpace       = 4;
dlgGeom.rowSpace       = 1;
dlgGeom.topFigSpace    = 1;
dlgGeom.bottomFigSpace = 0.5;
dlgGeom.sideFigSpace   = 2;
dlgGeom.titleLabel     = ['Title (''' get_param(block,'DefaultAxesTitlesString') ''' replaced by signal name): '];
dlgGeom.wTitleLabel    = length(dlgGeom.titleLabel);
dlgGeom.wTitleEdit     = length(maxTitleWidth);
dlgGeom.hSpacer        = 1.25;
dlgGeom.wSysButton     = 9   + sysOffsets.pushbutton(3);
dlgGeom.hSysButton     = 1.1 + sysOffsets.pushbutton(4);
dlgGeom.sysButtonDelta = 1.2;


%
% Calculate fig width and height.
%
row1 = ...
    dlgGeom.wYMinLabel + ...
    dlgGeom.wYMaxLabel + ...
    (dlgGeom.colSpace + (2 * dlgGeom.wStdEdit));

wAllSysButtons = (3 * dlgGeom.wSysButton) + (2 * dlgGeom.sysButtonDelta);

widestRow = max([row1, dlgGeom.wTitleLabel, dlgGeom.wTitleEdit, wAllSysButtons]);

wDlg = widestRow + (2 * dlgGeom.sideFigSpace);

hDlg = ...
    dlgGeom.topFigSpace + ...
    dlgGeom.hEdit       + ...
    dlgGeom.hSpacer     + ...
    dlgGeom.hText       + ...
    dlgGeom.hEdit       + ...
    dlgGeom.hSpacer     + ...
    dlgGeom.hSysButton  + ...
    dlgGeom.bottomFigSpace;

%
% Calculate ctrl positions.
%
cxCur = dlgGeom.sideFigSpace;
cyCur = hDlg - dlgGeom.topFigSpace - dlgGeom.hEdit;

ctrlPos.yMinLabel = [cxCur cyCur dlgGeom.wYMinLabel, dlgGeom.hText];

cxCur = cxCur + dlgGeom.wYMinLabel;
ctrlPos.yMinEdit = [cxCur cyCur dlgGeom.wStdEdit dlgGeom.hEdit];

cxCur = cxCur + dlgGeom.wStdEdit + dlgGeom.colSpace;
ctrlPos.yMaxLabel = [cxCur cyCur dlgGeom.wYMaxLabel, dlgGeom.hText];

cxCur = cxCur + dlgGeom.wYMaxLabel;
ctrlPos.yMaxEdit = [cxCur cyCur dlgGeom.wStdEdit dlgGeom.hEdit];

cxCur = dlgGeom.sideFigSpace;
cyCur = cyCur - dlgGeom.hSpacer - dlgGeom.hText;
ctrlPos.titleLabel = [cxCur cyCur dlgGeom.wTitleLabel dlgGeom.hText];

cyCur    = cyCur - dlgGeom.hText;
tmpWidth = max(dlgGeom.wTitleLabel, (wDlg - (2*dlgGeom.sideFigSpace)));
ctrlPos.titleEdit = [cxCur cyCur tmpWidth dlgGeom.hEdit];

cxCur = wDlg -  dlgGeom.sideFigSpace - wAllSysButtons;
cyCur = cyCur - dlgGeom.hSpacer - dlgGeom.hSysButton;
ctrlPos.ok = [cxCur cyCur dlgGeom.wSysButton dlgGeom.hSysButton];

cxCur = cxCur + dlgGeom.wSysButton + dlgGeom.sysButtonDelta;
ctrlPos.cancel = [cxCur cyCur dlgGeom.wSysButton dlgGeom.hSysButton];

cxCur = cxCur + dlgGeom.wSysButton + dlgGeom.sysButtonDelta;
ctrlPos.apply = [cxCur cyCur dlgGeom.wSysButton dlgGeom.hSysButton];

% g500766: Since this geck was NAP-ped
% and setting the units to character started
% refiring the Resize event from R2008b
% we want to continue not firing the resize event
% So setting the resizeFcn to null before set.
resizeFcn = get(scopeFig,'resizeFcn');
set(scopeFig,'resizeFcn','');

%
% Calculate figure position (in character units).
%
figUnits  = get(scopeFig, 'Units');
axUnits   = get(ax, 'Units');
set([scopeFig ax], 'Units', 'character');

scopePos = get(scopeFig, 'Position');
axPos    = get(ax, 'Position');

cxAxCenter = scopePos(1) + axPos(1);
cyAxCenter = scopePos(2) + axPos(2);

set(scopeFig, 'Units', figUnits);
set(ax,       'Units', axUnits);

% Reset resizeFcn to the original value after 
% resetting of units is done.
set(scopeFig,'resizeFcn',resizeFcn);

xposDlg = cxAxCenter - (wDlg/2);
if xposDlg < 0, xposDlg = 0; end;
yposDlg = cyAxCenter - (hDlg/2);
if yposDlg < 5, yposDlg = 5; end;

pos = [ xposDlg, yposDlg, wDlg, hDlg ];

%
% Set up the figure's user data.
%
dialogUserData.parent   = scopeFig;
dialogUserData.axesIdx  = axesIdx;
dialogUserData.children = [];

%
% Create the figure.
%
fontName = get(0, 'FactoryUIControlFontName');
fontSize = get(0, 'FactoryUIControlFontSize');
color    = get(0, 'FactoryUIControlBackgroundColor');

dlgName   = i_GetAxesPropDlgName(ax, block, axesIdxStr);
deleteFcn = ['simscopesv(''AxesPropDlg'', ''FigDeleteFcn'', gcbf, ' axesIdxStr ')'];

dialogFig = figure( ...
    'Visible',                            'on', ...
    'DefaultUIControlHorizontalAlign',    'left', ...
    'DefaultUIControlFontname',           fontName, ...
    'DefaultUIControlFontsize',           fontSize, ...
    'DefaultUIControlUnits',              'character', ...
    'DefaultUIControlBackgroundColor',    color, ...
    'HandleVisibility',                   'off', ...
    'Colormap',                           [], ...
    'Name',                               dlgName, ...
    'IntegerHandle',                      'off', ...
    'Resize',                             'off', ...
    'Units',                              'character', ...
    'Position',                           pos, ...
    'MenuBar',                            'none', ...
    'Color',                              color, ...
    'NumberTitle',                        'off', ...
    'DeleteFcn',                          deleteFcn);

axUserData.propDlg = dialogFig;
set(ax, 'UserData', axUserData);

%
% Create the uicontrols.
%
children.yMinLabel = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'text', ...
    'String',           'Y-min:', ...
    'Position',         ctrlPos.yMinLabel);

children.yMinEdit = uicontrol( ...
    'Parent',           dialogFig,...
    'Style',            'edit',...
    'BackgroundColor',  'w',...
    'Position',         ctrlPos.yMinEdit);

children.yMaxLabel = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'text', ...
    'String',           'Y-max:', ...
    'Position',         ctrlPos.yMaxLabel);

children.yMaxEdit = uicontrol( ...
    'Parent',           dialogFig,...
    'Style',            'edit',...
    'BackgroundColor',  'w',...
    'Position',         ctrlPos.yMaxEdit);

children.titleLabel = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'text', ...
    'String',           dlgGeom.titleLabel, ...
    'Position',         ctrlPos.titleLabel);

children.titleEdit = uicontrol( ...
    'Parent',           dialogFig,...
    'Style',            'edit',...
    'BackgroundColor',  'w',...
    'Position',         ctrlPos.titleEdit);

children.ok = uicontrol( ...
    'Parent',               dialogFig, ...
    'Style',                'pushbutton', ...
    'String',               'OK', ...
    'HorizontalAlignment',  'center', ...
    'Position',             ctrlPos.ok);

children.cancel = uicontrol( ...
    'Parent',               dialogFig, ...
    'Style',                'pushbutton', ...
    'String',               'Cancel', ...
    'Enable',               'on', ...
    'HorizontalAlignment',  'center', ...
    'Position',             ctrlPos.cancel);

children.apply = uicontrol( ...
    'Parent',               dialogFig, ...
    'Style',                'pushbutton', ...
    'String',               'Apply', ...
    'HorizontalAlignment',  'center', ...
    'Position',             ctrlPos.apply);

dialogUserData.children = children;

i_SyncAxPropertiesDialog(block, dialogUserData, axesIdx);

%
% Install callbacks.
%
h  = children.ok;
cb = ['simscopesv(''AxesPropDlg'', ''OK'', gcbf, ' axesIdxStr ')'];
set(h, 'Callback', cb);

h  = children.cancel;
cb = ['simscopesv(''AxesPropDlg'', ''Cancel'', gcbf, ' axesIdxStr ')'];
set(h, 'Callback', cb);

h  = children.apply;
cb = ['simscopesv(''AxesPropDlg'', ''Apply'', gcbf, ' axesIdxStr ')'];
set(h, 'Callback', cb);

%
% Install user data and show figure.
%
dialogUserData.block = block;
set(dialogFig, 'UserData', dialogUserData, 'Visible', 'on');


% Function: i_SimpleSimStatus =================================================
% Abstract:
%  Get the simplified status of the simulation.  This is the usual
%  'SimulationStatus' of the block diagram, with 'external' mapped to either
%  'running' or 'stopped'.  In external mode, the state will be 'stopped' if
%  the uploadStatus is 'inactive' or 'running' otherwise.
function status = i_SimpleSimStatus(hMdl)
status        = get_param(hMdl, 'SimulationStatus');
uploadStatus  = get_param(hMdl, 'ExtModeUploadStatus');

if strcmp(status, 'external')
    if ~strcmp(uploadStatus, 'inactive')
        status = 'running';
    else
        status = 'stopped';
    end
end

%endfunction i_SimpleSimStatus


% Function: i_RestoreYLimits ==================================================
% Abstract:
%    Restore the y limits of all axes to the values saved in the block.
function i_RestoreYLimits(scopeFig, scopeUserData)

wireless      = onoff(get_param(scopeUserData.block, 'Wireless'));
simStatus     = i_SimpleSimStatus(scopeUserData.block_diagram);

for k=1:length(scopeUserData.scopeAxes),
    ax = scopeUserData.scopeAxes(k);
    scopezoom('restore', ax, simStatus);
    newXLim = get(ax, 'XLim');
    newYLim = get(ax, 'YLim');
    if wireless,
        i_HiLiteResize(scopeUserData,k,newXLim,newYLim);
    end
end


% Function: i_UpdateYLimits ===================================================
% Abstract:
%    Update the y-limits of the designated axes based on the current
%    block settings.

function scopeUserData = i_UpdateYLimits(scopeFig, scopeUserData, axesArray)

block                = scopeUserData.block;
scopeAxes            = scopeUserData.scopeAxes;
nAxes                = length(scopeAxes);
if nargin < 3
    axesArray = (1:nAxes);
end
wireless             = onoff(get_param(block, 'Wireless'));
[tLim, yLim] = i_ComputeAxesLimits(scopeFig, scopeUserData);

for i=1:length(axesArray)
    axesIdx = axesArray(i);
    ax           = scopeAxes(axesIdx);
    axesUserData = get(ax, 'UserData');
    currentYLim  = get(ax, 'YLim');
    newYLim      = yLim(axesIdx,:);
    
    if ~all(currentYLim == newYLim),
        currentXLim  = get(ax, 'XLim');
        set(ax, 'YLim', newYLim);
        if wireless,
            i_HiLiteResize(scopeUserData,axesIdx,currentXLim,newYLim);
        end
        
        axesUserData.defYLim = newYLim;
        set(ax, 'UserData', axesUserData);
        i_RenderInsideTickLabels(block, ax);
        
        scopeUserData.dirty = 1;
    end
end
%endfunction


% Function: i_ApplyAxesPropDialog =============================================
% Abstract:
%    Handle the applying of properties for the axes property dialog.

function [scopeUserData,error] = ...
    i_ApplyAxesPropDialog(dialogFig, dialogUserData, ...
    scopeFig,scopeUserData,...
    axesIdx)

error    = 0;
block    = scopeUserData.block;
children = dialogUserData.children;

%
% Validate ymin and ymax
%
h       = children.yMinEdit;
yMinStr = deblank(get(h, 'String'));
try
    yMinVal = evalin('base', yMinStr);
    if isnan(yMinVal),
        error = 1;
    end
catch
    error = 1;
end
if error,
    beep;
    errordlg(DAStudio.message('Simulink:blocks:InvalidYMinEntry'), 'Error', 'modal');
    return;
end

h         = children.yMaxEdit;
yMaxStr   = deblank(get(h, 'String'));
try
    yMaxVal = evalin('base', yMaxStr);
    if isnan(yMaxVal),
        error = 1;
    end
catch
    error = 1;
end
if error,
    beep;
    errordlg(DAStudio.message('Simulink:blocks:InvalidYMaxEntry'), 'Error', 'modal');
    return;
end

if (length(yMinVal) ~= 1) || (length(yMaxVal) ~= 1) || (yMinVal >= yMaxVal),
    beep;
    error = 1;
    errordlg(DAStudio.message('Simulink:blocks:InvalidYMinOrYMaxEntry'), 'Error', 'modal');
    return;
end

yMinStr = sprintf('%0.16g', yMinVal);
yMaxStr = sprintf('%0.16g', yMaxVal);


%
% Create new 'Y-min' and 'Y-max' strings in block.  Note that these strings
% represent the setting for all axes.
%
blockYMinStr = get_param(block, 'YMin');
blockYMinStr = i_SetStrField(blockYMinStr, axesIdx, yMinStr);

blockYMaxStr = get_param(block, 'YMax');
blockYMaxStr = i_SetStrField(blockYMaxStr, axesIdx, yMaxStr);

%
% Create new titles string in block.
%
h           = children.titleEdit;
titleStr    = get(h,'String');
blockTitles = i_struct2cell(get_param(block, 'AxesTitles'));
if isempty(titleStr), titleStr = ' '; end;
blockTitles{axesIdx} = titleStr;

%
% Update the block settings and update the figure.
%
set_param(block, ...
    'YMin',       blockYMinStr, ...
    'Ymax',       blockYMaxStr, ...
    'AxesTitles', TitleCell2Struct(blockTitles));

scopeUserData = i_UpdateYLimits(scopeFig, scopeUserData, axesIdx);
scopeUserData = i_UpdateTitles(scopeUserData);
%endfunction


% Function: i_ManageAxesPropDlg ===============================================
% Abstract:
%    Handle callbacks for the axes property dialog.

function i_ManageAxesPropDlg(dialogAction, dialogFig, axesIdx)

dialogUserData = get(dialogFig, 'UserData');
scopeFig       = dialogUserData.parent;
scopeUserData  = get(scopeFig,'UserData');

switch(dialogAction),
    
    case 'OK',
        [scopeUserData,error] = ...
            i_ApplyAxesPropDialog(dialogFig, dialogUserData, ...
            scopeFig,  scopeUserData, ...
            axesIdx);
        if ~error,
            close(dialogFig);
        end
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        scopeUserData = get(scopeFig, 'UserData');
        
        % Call i_ResizeAxes in case y-axis tick labels have grown
        %  one character bigger
        axesGeom      = i_CreateAxesGeom(scopeUserData);
        scopeUserData = i_ResizeAxes(scopeFig, scopeUserData, axesGeom);
        set(scopeFig, 'UserData', scopeUserData);
        
    case 'Cancel',
        close(dialogFig);
        
    case 'Apply',
        [scopeUserData,error] = ...
            i_ApplyAxesPropDialog(dialogFig, dialogUserData, ...
            scopeFig,  scopeUserData, ...
            axesIdx);
        
        i_UpdateEraseBufferIfNeeded(scopeFig);
        
        scopeUserData = get(scopeFig, 'UserData');
        % Call i_ResizeAxes in case y-axis tick labels have grown
        %  one character bigger
        axesGeom      = i_CreateAxesGeom(scopeUserData);
        scopeUserData = i_ResizeAxes(scopeFig, scopeUserData, axesGeom);
        set(scopeFig, 'UserData', scopeUserData);
        
    case 'FigDeleteFcn',
        scopeAxes      = scopeUserData.scopeAxes;
        ax             = scopeAxes(axesIdx);
        
        axUserData = get(ax, 'UserData');
        axUserData.propDlg = INVALID_HANDLE;
        set(ax, 'UserData', axUserData);
        
    otherwise,
        DAStudio.error('Simulink:blocks:UnexpectedDialogAction');
end

%endfunction


% Function: i_SyncAxesSettingsAll =============================================
% Abstract:
%
function i_SyncAxesSettingsAll(scopeFig, scopeUserData)

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);

for i=1:nAxes,
    ax           = scopeAxes(i);
    axesUserData = get(ax, 'UserData');
    i_SyncAxesSettings(scopeFig, scopeUserData, ax, axesUserData),
end

if ishandle(scopeUserData.scopePropDlg),
    scppropsv('SyncCallBack', scopeUserData.scopePropDlg);
end


% Function: i_SyncAxesSettings ================================================
% Abstract:
%    Sync the axes settings for the current axes.

function i_SyncAxesSettings(scopeFig, scopeUserData, ax, axesUserData)

axesIdx  = axesUserData.idx;
block    = scopeUserData.block;
wireless = onoff(get_param(block, 'Wireless'));

%
% Get limits and limit strings for current axes.
%
xLim  = get(ax, 'XLim');
xSpan = xLim(2) - xLim(1);
if isinf(xSpan)
    xLim = i_ComputeAxesLimits(scopeFig, scopeUserData);
    xSpan = xLim(2) - xLim(1);
end

xLimStr = sprintf('%0.16g', xSpan);

yLim    = get(ax, 'YLim');
yMinStr = sprintf('%0.16g', yLim(1));
yMaxStr = sprintf('%0.16g', yLim(2));

%
% Get block wide setting strings and modify with new settings.
%
blockYMinStr = get_param(block, 'YMin');
blockYMaxStr = get_param(block, 'YMax');

blockYMinStr = i_SetStrField(blockYMinStr, axesIdx, yMinStr);
blockYMaxStr = i_SetStrField(blockYMaxStr, axesIdx, yMaxStr);

set_param(block, ...
    'YMin',         blockYMinStr, ...
    'YMax',         blockYMaxStr, ...
    'TimeRange',    xLimStr);

if ishandle(axesUserData.propDlg),
    dialogUserData = get(axesUserData.propDlg, 'UserData');
    i_SyncAxPropertiesDialog(block, dialogUserData, axesIdx);
end

%
% Update the cached default limits.
%
axesUserData.defXLim = xLim;
axesUserData.defYLim = yLim;
set(ax, 'UserData', axesUserData);


% Function: i_AdjustContextMenuItems ==========================================
% Abstract:
%    Based on current simulation state and other scope states, update the
%    status of the context menus (figure and axes) (e.g., enabledness of items).

function i_AdjustContextMenuItems(ax, axesUserData, scopeUserData, simStatus)

h1         =  scopeUserData.axesContextMenu.sync;
h2         =  scopeUserData.axesContextMenu.select;
block      =  scopeUserData.block;
floating   =  onoff(get_param(block,'Floating'));
modelbased =  i_IsModelBased(block);

if ~strcmp(simStatus, 'stopped')
    set(h1, 'Enable', 'off');
else
    if ~all(axesUserData.defXLim == get(ax, 'XLim'))
        set(h1, 'Enable', 'on');
    else
        set(h1, 'Enable', 'off');
    end
end

% Turn on the signal selector option if necessary
if usejava('MWT')
    set(h2, 'Visible', 'on');
    if modelbased
        if strcmp(simStatus, 'stopped')
            set(h2, 'Enable', 'on');
        else
            set(h2, 'Enable', 'off');
        end
    elseif floating
        set(h2, 'Enable', 'on');
    else
        set(h2, 'Enable', 'off');
    end
else
    set(h2, 'Visible', 'off');
end

% Update the "checked status of the legends context menu"

showLegends = get_param(block,'ShowLegends');

if strcmp(showLegends,'on')
    legendContextMenuChecked = 'on';
else
    legendContextMenuChecked = 'off';
end

axesLegendsHandle = scopeUserData.axesContextMenu.Legends;
wsLegendsHandle   = scopeUserData.wsContextMenu.Legends;

set(axesLegendsHandle,'Checked',legendContextMenuChecked);
set(wsLegendsHandle,'Checked',legendContextMenuChecked);

% Function: i_ManageContextMenuCB =============================================
% Abstract:
%    Handle callback for axes context menus.

function scopeUserData = i_ManageContextMenuCB(scopeFig, contextAxes, menuItem)
scopeUserData = get(scopeFig, 'UserData');
axesUserData  = get(contextAxes, 'UserData');
axesIdx       = axesUserData.idx;

switch(menuItem),
    
    case 'Legend'
        
        scopeBlock = scopeUserData.block;
        showLegends = get_param(scopeBlock,'ShowLegends');
        
        if strcmp(showLegends,'off');
            set_param(scopeBlock,'ShowLegends','on');
        else
            set_param(scopeBlock,'ShowLegends','off');
        end
        
        simscopesv('LegendCB',scopeBlock);
    case 'ZoomOut',
        set(scopeFig,'UserData', scopeUserData);
        scopezoom('butdwn', 'ContextMenu');
        scopeUserData = get(scopeFig,'UserData');
        
    case 'Adjust',
        bd            = scopeUserData.block_diagram;
        simStatus     = get_param(bd, 'SimulationStatus');
        scopeAxes     = scopeUserData.scopeAxes;
        ax            = scopeAxes(axesIdx);
        
        i_AdjustContextMenuItems(ax, axesUserData, scopeUserData, simStatus);
        
    case 'Find',
        block_diagram = scopeUserData.block_diagram;
        simStatus     = get_param(block_diagram, 'SimulationStatus');
        
        [updatedX, updatedY] = i_FindRequest(scopeUserData, simStatus, axesIdx);
        if updatedX || updatedY,
            scopeUserData.dirty = 1;
        end
        
    case 'Select',
        %
        % User requested a selection dialog for signals:
        % Need to set the source to be the current (blue) axes.
        %
        
        i_HiLiteOn(scopeUserData,axesIdx);
        
        simscopesv('SelectedAxes', 'Dialog', scopeFig);
        signalselector('Create', 'simscopesv', ...
            scopeUserData.block, ...
            str2num(get_param(scopeUserData.block, 'NumInputPorts')), ...
            axesIdx, ...
            DAStudio.message('Simulink:blocks:ScopeAxes'), ...
            true, ... % MultipleSigs = true
            i_SignalSelectorTitle(scopeUserData.block));
        
    case 'Sync',
        scopeAxes = scopeUserData.scopeAxes;
        ax        = scopeAxes(axesIdx);
        
        i_SyncAxesSettings(scopeFig, scopeUserData, ax, axesUserData);
        if ishandle(scopeUserData.scopePropDlg),
            scppropsv('SyncCallBack', scopeUserData.scopePropDlg);
        end
        
    case 'Properties',
        i_CreateAxPropertiesDialog(scopeFig, scopeUserData, axesIdx);
        
    case 'Parameters',
        scppropsv('create', scopeFig);
        scopeUserData = get(scopeFig,'UserData');
        
    case 'TickLabelAll'
        set_param(scopeUserData.block, 'TickLabels','on');
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, false);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        
    case 'TickLabelInside'
        set_param(scopeUserData.block, 'TickLabels','off');
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, false);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        
    case 'TickLabelBottom'
        set_param(scopeUserData.block, 'TickLabels','OneTimeTick');
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, false);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        
    otherwise,
        DAStudio.error('Simulink:blocks:UnexpectedMenuItem');
        
end

% Function: i_ManageWSContextMenuCB ===========================================
% Abstract:
%    Handle callback for whitespace context menu.

function scopeUserData = i_ManageWSContextMenuCB( ...
    scopeFig, scopeUserData, menuItem)

switch(menuItem),
    
    case 'Legend',
        scopeBlock = scopeUserData.block;
        showLegends = get_param(scopeBlock,'ShowLegends');
        
        if strcmp(showLegends,'off');
            set_param(scopeBlock,'ShowLegends','on');
        else
            set_param(scopeBlock,'ShowLegends','off');
        end
        
        simscopesv('LegendCB',scopeBlock,scopeUserData);
        
    case 'Parameters',
        scppropsv('create', scopeFig);
        scopeUserData = get(scopeFig,'UserData');
        
    case 'TickLabelAll'
        set_param(scopeUserData.block, 'TickLabels','on');
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, false);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        
    case 'TickLabelInside'
        set_param(scopeUserData.block, 'TickLabels','off');
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, false);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        
    case 'TickLabelBottom'
        set_param(scopeUserData.block, 'TickLabels','OneTimeTick');
        scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData, false);
        scopeUserData = i_TickStyle_Checkmark(scopeUserData);
        
    otherwise,
        DAStudio.error('Simulink:blocks:UnexpectedMenuItemWS');
        
end


% Function: i_FindRequestAllAxes ==============================================
% Abstract:
%    Issue a find request for each axes.

function scopeUserData = i_FindRequestAllAxes(scopeFig, scopeUserData)

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);
simStatus = i_SimpleSimStatus(scopeUserData.block_diagram);

for i=1:nAxes,
    [updatedX, updatedY] = i_FindRequest(scopeUserData, simStatus, i);
    if updatedX || updatedY,
        scopeUserData.dirty = 1;
    end
end
%endfunction


% Function: i_FindRequest =====================================================
% Abstract:
%
% Find the signals (autoscale) for the specified axis.  If the y-limits of
% this axis were changed updatedY will be true.  If the x-limits were changed
% then updatedX will be true.  Note that the latter applies to all axes,
% since it is required that the x scales of all axes be identical.

function [updatedX, updatedY] = i_FindRequest( ...
    scopeUserData, simStatus, axesIdx)

updatedY      = 0;
updatedX      = 0;
scopeAxes     = scopeUserData.scopeAxes;
ax            = scopeAxes(axesIdx);
axesUserData  = get(ax, 'UserData');
block         = scopeUserData.block;
block_diagram = scopeUserData.block_diagram;
scopeHiLite   = scopeUserData.scopeHiLite;

if ishandle(scopeHiLite),
    hiLiteVis = get(scopeHiLite,'Visible');
    set(scopeUserData.scopeHiLite,'Visible','off');
end

% quick exit if axis is not connected to any signal
ioSigs=get_param(block,'IOSignals');
currIOSigs = ioSigs{axesIdx};
if length(currIOSigs) == 1 && currIOSigs.Handle == -1
    return;
end

try
    
    if ~strcmp(simStatus, 'stopped')
        %
        % Simulation is running.  Retrieve auto limits from block.
        %
        set_param(block, 'CurrentAxesIdx', axesIdx);
        yLim = get_param(block, 'PlotLimits');
        
        %
        % Handle degenerate cases.
        %
        if any(isinf(yLim)), return, end
        
        origYLim = get(ax, 'YLim');
        loda     = yLim(1);
        hida     = yLim(2);
        
        %
        % In the case of min==max (a.k.a "PROBLEM # 1" in
        % axrender.c/compute_axis_limits()), resolve by using
        % hard defaults the same as compute_axis_limits().
        %
        if (loda==hida),
            def_lim = [0.0, 1.0];
            dlim    = def_lim(2) - def_lim(1);
            yLim    = [ loda-dlim, hida+dlim ];
        end
        
        %
        % Protect the ylim with the same precision checks as the C-code used for
        % for axes rendering. See axrender.c/CheckPrecisionOfLimits(), where
        % we are preventing
        %     if ( (hida - loda) < (precision * (fabs(hida) + fabs(loda))) ) {
        % from being true. Note, the body of CheckPrecisionOfLimits() is slightly
        % different than below ... the C code correction doesn't necessarily
        % result in a range large enough to satisfy the said condition.
        %
        
        precision = 1.e-10;
        
        allowableRange = (precision * (abs(hida) + abs(loda)));
        
        if ((hida - loda) < allowableRange),
            mid    = (hida + loda)/2.0;
            
            allowableRange  = allowableRange * 1.1;
            
            hida   = mid + allowableRange/2;
            loda   = mid - allowableRange/2;
            
            yLim = [loda hida];
        end
        
        %
        % Set the limits to the those stored by the block.
        %
        set(ax, 'YLim', yLim);
        
        %
        % Since we are storing these limits as well as displaying them in
        % the blocks dialog, we clean up the limits by using MATLAB's chosen
        % tick positions.
        %
        yTick    = get(ax, 'YTick');
        yTickDel = (yTick(end) - yTick(end-1)) / 2;
        
        %
        % ...We know that the upper limit is set to accommodate the max value.
        %    So, at this point, the data should all be equal to or less than
        %    the upper limit.  If the highest tick mark is equal to the upper
        %    limit, then the limit value is already a "nice" number.  If the
        %    highest tick mark is less than the set limit, then we probably
        %    don't have a "nice" number.  In that case, we clean it up as
        %    follows:
        %
        if yTick(end) < yLim(2),
            nDels   = ceil( (yLim(2) - yTick(end)) / yTickDel );
            yLim(2) = yTick(end) + (yTickDel * nDels);
        end
        
        %
        % Same idea for the lower limit.
        %
        if yTick(1) > yLim(1),
            nDels   = ceil( (yTick(1) - yLim(1)) / yTickDel );
            yLim(1) = yTick(1) - (yTickDel * nDels);
        end
        
        set(ax, 'YLim', yLim);
        
        if ~all(yLim == origYLim),
            updatedY = 1;
        end
        
        %
        % Do auto scaling on the Time Limits.  The algorithm is as follows:
        %   time range < simulation time span, then do nothing
        %   time range > simulation time span, then timerange = time span
        %
        % Note that this is done to all axes in order to keep the time
        % scales in sync.
        %
        simTimeSpan  = get_param(block, 'SimTimeSpan');
        strTimeRange = i_GetTimeRange(block);
        timeRange    = sscanf(strTimeRange, '%f');
        
        if ~strcmp(strTimeRange, 'auto') && (timeRange > simTimeSpan),
            updatedX = 1;
            set(scopeAxes, 'XLim', [0 simTimeSpan]); % all axes
        end
        
        %
        % Let the block and any open dialogs know about the new settings.
        %
        if updatedY,
            newYLims = get(scopeAxes, 'YLim');
            if iscell(newYLims),
                newYLims = cat(1, newYLims{:});
            end
            i_SetBlockYLims(block, newYLims);
            
            %
            % Let the axes property dialog know that a 'find' has occurred.
            %
            if ishandle(axesUserData.propDlg),
                i_SyncAxPropertiesDialog(block, dialogUserData, axesIdx);
            end
            
        end
        
        if updatedX,
            strTRange = sprintf('%-16g', simTimeSpan);
            set_param(block, 'TimeRange', strTRange);
            
            %
            % Let the main property dialog know that a 'find' has occurred.
            %
            if ishandle(scopeUserData.scopePropDlg),
                scppropsv('FindCallBack', scopeUserData.scopePropDlg);
            end
        end
        
        %
        % Update the line data.
        %
        modelDataLogs = get_param(block, 'CopyDataBuffer');
        currDataLog = eval(['modelDataLogs.axes', num2str(axesIdx)]);
        if ~isempty(currDataLog) && ishandle(currDataLog)
            i_ShiftNPlot(scopeUserData, currDataLog, axesIdx);
        end
        
    else
        %
        % Simulation is not running.  Update the axes, but don't update the block
        % settings.  This is considered a "data exploration" option and should not
        % change how the block runs when the next sim starts.  This operation
        % retrieve's all data from the block (if needed), and zeros out the time
        % offset.
        %
        
        % check for degenerate case
        if ~i_BufferInUse(block),
            return;
        end
        
        %
        % Unshift the data (remove offset).  This must be done to all axes in
        % order to keep their time bases in sync.
        %
        if (get_param(block, 'Offset') ~= 0),
            updatedX = 1;
            nAxes    = length(scopeAxes);
            offset   = get_param(block, 'Offset');
            for i=1:nAxes,
                thisAx = scopeAxes(i);
                
                set_param(block,'CurrentAxesIdx',i);
                hLines = get_param(block,'AxesLineHandles');
                if ~isempty(hLines)
                    hLines = [hLines{:}];
                    nLines = length(hLines);
                    
                    set(hLines, 'Visible', 'off');
                    
                    %
                    % Shift the data.
                    %
                    for j=1:nLines,
                        h = hLines(j);
                        set(h, 'XData', get(h,'XData') + offset);
                    end
                    
                    set(thisAx, 'XLimMode','auto');
                    set(hLines, 'Visible', 'on');
                end
            end
            
            %
            % Set offset value to zero.
            %
            if (ishandle(scopeUserData.timeOffset))
                set(scopeUserData.timeOffset, 'String', '0');
            end
            set_param(block, 'Offset', 0.0);
        end
        
        origYLim = get(ax, 'YLim');
        set(ax, 'YLimMode', 'auto');
        newYLim  = get(ax, 'YLim');
        if ~all(origYLim == newYLim),
            updatedY = 1;
        end
        
        origXLim = get(ax, 'XLim');
        set(ax, 'XLimMode', 'auto');
        newXLim = get(ax, 'XLim');
        if ~all(origXLim == newXLim),
            updatedX = 1;
            
            %
            % Make sure that all axes keep the same x-limits.
            %
            set(scopeAxes, 'XLim', newXLim);
        end
        
        if ~strcmp(get_param(block, 'ZoomMode'), 'off') && (updatedX | updatedY),
            scopezoom('reset', get_param(block,'Figure'));
        end
        
        set(ax,'YLimMode','manual','XLimMode','manual');
    end
    
    %
    % Update the highlight rectangle for all axes.
    %
    simscopesv('ResizeHiLites', get_param(block,'Figure'));
end

if ishandle(scopeHiLite),
    if iscell(hiLiteVis)
        set(scopeUserData.scopeHiLite,{'Visible'},hiLiteVis);
    else
        set(scopeUserData.scopeHiLite,'Visible',hiLiteVis);
    end
end

%endfunction i_FindRequest


% Function: i_CreatePrintFigure ===============================================
% Abstract:
%    Create a new invisible figure without buttons for printing

function printFig = i_CreatePrintFigure(scopeFig,scopeUserData)

scopeAxes = scopeUserData.scopeAxes;
nAxes     = length(scopeAxes);
axesGeom  = i_CreateAxesGeom(scopeUserData);

%
% Compute axes positions as if there was no toolbar.
%
scopeUserData.toolGeom.height = 0; %change only local copy
axesInfo = i_ComputeAxesInfo(scopeFig, scopeUserData, axesGeom, nAxes);

positions = vertcat(axesInfo.Position);

printFig = figure(...
    'HandleVisibility',   'off',...
    'IntegerHandle',      'off', ...
    'Visible',            'off',...
    'MenuBar',            'none', ...
    'NumberTitle',        'off',...
    'Position',           get(scopeFig, 'Position'), ...
    'Name',               get(scopeFig, 'Name'), ...
    'PaperUnits',         'inches');

paperSize = get(printFig, 'PaperSize');
paperPos  = [0.25 0.25 paperSize(1)-0.5 paperSize(2)-0.5];
set(printFig, 'PaperPosition', paperPos, 'Units', 'normal');

printAxes = copyobj(scopeAxes, printFig);

fontSize = scopeUserData.axesFontSize;
fontName = scopeUserData.axesFontName;

for i=1:nAxes,
    printAx  = printAxes(i);
    hTitle   = get(scopeAxes(i), 'Title');
    titleStr = get(hTitle, 'String');
    
    set(printAx, ...
        'Units',        'pixel', ...
        'Position',     positions(i,:));
    
    if strcmp(get(hTitle, 'Visible'), 'on')
        color    = get(hTitle, 'Color');
        hTitle   = get(printAx, 'Title');
        
        set(hTitle, ...
            'String',       titleStr,...
            'FontName',     fontName, ...
            'FontSize',     fontSize, ...
            'Interpreter',  'none', ...
            'Color',        color); 
    end
      if strcmp(get_param(scopeUserData.block,'ShowLegends'),'on') &&...
            i <= length(scopeUserData.scopeLegends)
        axLegend= scopeUserData.scopeLegends(i);
        if strcmp(get(axLegend, 'Visible'), 'on')
            legendString = get(axLegend,'String');
            legend(printAx,legendString);
        end
    end
end

set(printAxes, 'Units', 'normal');


%
% Create an invisible axes for placement of the time offset text.
%
pos    = get(printAxes(1), 'Position');
pos(2) = 1;

timeOffsetAxes = axes(...
    'Parent',       printFig, ...
    'Visible',      'off', ...
    'Units',        'pixel', ...
    'Position',     pos);

tOffsetLabel = scopeUserData.timeOffsetLabel;
tOffset      = scopeUserData.timeOffset;

if ishandle(tOffsetLabel) && ishandle(tOffset),
    txtString  = [get(tOffsetLabel, 'String') ' ' get(tOffset, 'String')];
    
    tmpOffsetLabel = text(...
        'Parent',         timeOffsetAxes, ...
        'VerticalAlign',  'bottom', ...
        'color',          get(scopeAxes(1), 'XColor'), ...
        'Position',       [0 0 0], ...
        'String',         txtString, ...
        'FontName',       get(tOffsetLabel,'FontName'), ...
        'FontSize',       get(tOffsetLabel,'FontSize'));
end


% Function: i_PrintScopeWindow ================================================
% Abstract:
%    Print the scope window without the toolbar.

function i_PrintScopeWindow(scopeFig, scopeUserData)

printFig=i_CreatePrintFigure(scopeFig,scopeUserData);

if ~isunix,
    printdlg(printFig);
else
    h=printdlg(printFig);
    if ~isempty(h)
        waitfor(h);
    end
end

delete(printFig);


% Function: i_ManageScopeBar ==================================================
% Abstract:
%    Manage callbacks from scope toolbar.
function scopeUserData = i_ManageScopeBar(scopeFig, scopeUserData, buttonType, buttonAction)

switch(buttonType),
    
    case 'ActionIcon',
        
        switch(buttonAction),
            
            case 'Find',
                scopeUserData = i_FindRequestAllAxes(scopeFig, scopeUserData);
                
            case 'Sync',
                i_SyncAxesSettingsAll(scopeFig, scopeUserData);
                
            case 'Restore',
                i_RestoreYLimits(scopeFig, scopeUserData);
                
            case 'Print',
                i_PrintScopeWindow(scopeFig, scopeUserData);
                
            case 'PropDlg',
                scppropsv('create', scopeFig);
                scopeUserData = get(scopeFig,'UserData');
                
            case 'Float',
                %
                % Set floating scope state
                %
                actionIcons = scopeUserData.toolbar.children.actionIcons;
                
                setting = get(gcbo,'State');
                %
                % Set the scope's Floating parameter to the new
                % setting and then activate the zoom buttons if
                % possible.
                %
                
                bd = scopeUserData.block_diagram;
                
                if ~i_IsSimActive(bd),
                    %
                    % Only transition to enable if simulation is stopped.
                    %
                    set_param(scopeUserData.block, 'Floating', setting);
                    if strcmp(setting, 'off')
                        %
                        % Check the selection data, to make sure it is consistent.
                        % This should not be necessary, but it will throw a warning
                        % and fix discrepencies if something is wrong.
                        %
                        i_VerifySelectionData(scopeUserData.block)
                        
                        i_RestorePortConnections(scopeUserData.block);
                        
                        i_SetEnableForNonRunWithNoData(scopeFig, scopeUserData);
                    end
                    
                    %
                    % Manage buttons and THEN redraw axes (axes key off of
                    % lock state set by lockdown mode).
                    %
                    scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
                    scopebarsv(scopeFig, 'SelectButton', setting);
                    
                    scopeUserData = i_UpdateAxesConfig(scopeFig, scopeUserData);
                    
                    %
                    % Selection Data needs to be re-loaded here, because 'UserData'
                    % stored in the axes keeps handles to lines, and these handles
                    % can change as lines are connected/disconnected from the scope.
                    % E.G. Mux output lines that are disconnected from a scope and
                    % reconnected above may get destroyed and recreated with new
                    % handles.
                    %
                    %i_LoadSelectionData(scopeUserData.block);
                    %i_UpdateSelectedPortHandles(scopeUserData.block);
                end
                
            case 'LockAxes',
                %
                % Set the lock button tooltip
                %
                newState = get(gcbo, 'State');
                scopebarsv(scopeFig, 'LockButton', 'on', newState);
                
                if strcmp(newState, 'off')
                    %
                    % First, grab focus from all other scopes,
                    % then manage this scope's lockdown.
                    %
                    [scopeUserData,dum] = i_GrabWirelessScopeFocus(scopeFig);
                    simscopesv('SelectedAxes', 'Dialog', scopeFig);
                else
                    scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, 'on');
                end
                
            case 'Select',
                simscopesv('SelectedAxes', 'Dialog', scopeFig);
                scopeUserData = get(scopeFig, 'UserData');
                
                currAxesIdx   = get_param(scopeUserData.block, 'SelectedAxesIdx');
                i_HiLiteOn(scopeUserData,currAxesIdx);
                
                signalselector('Create', 'simscopesv', ...
                    scopeUserData.block, ...
                    str2num(get_param(scopeUserData.block, 'NumInputPorts')), ...
                    currAxesIdx, ...
                    DAStudio.message('Simulink:blocks:ScopeAxes'), ...
                    true, ... % MultipleSigs = true
                    i_SignalSelectorTitle(scopeUserData.block));
                
            otherwise,
                DAStudio.error('Simulink:blocks:UnexpectedButtonAction');
        end
        
    otherwise,
        DAStudio.error('Simulink:blocks:UnexpectedButtonType');
end
%endfunction


% Function: i_CreateLinesForCurrentAxes =======================================
% Abstract:
%
% Create lines for the current axes of the current scope block.  It is assumed
% that the block sets up the current axes prior to calling this function.  The
% get/set params operate on the current axes.
%
function i_CreateLinesForCurrentAxes(scopeFig, scopeUserData)

block = scopeUserData.block;

numLinesNeeded = get_param(block, 'NumLinesNeeded');
if isempty(numLinesNeeded),
    return;
end

axIdx          = get_param(block, 'CurrentAxesIdx');
lineStyleIdxs  = get_param(block, 'LineStyleIndices');

nSigs = length(numLinesNeeded);
ax    = scopeUserData.scopeAxes(axIdx);

lineStyleOrder    = scopeUserData.lineStyleOrder;
lineStyleOrderLen = length(lineStyleOrder);
colorOrder        = get(ax,'ColorOrder');
nColors           = length(colorOrder);

markerStr = i_GetMarkerStr(block);

%
% Create the lines.
%
newLines = cell(1,nSigs);
colorIdx = 1;

for sigIdx=1:nSigs,
    numLines = numLinesNeeded(sigIdx);
    if (numLines ~= 0),
        lines(numLines) = 0; %pre-alloc
        
        lineStyleIdx = 1;
        for i=1:numLines,
            lineStyle    = lineStyleOrder{lineStyleIdx};
            lineStyleIdx = lineStyleIdx+1;
            if lineStyleIdx > lineStyleOrderLen,
                lineStyleIdx = 1;
            end
            
            color = colorOrder(colorIdx,:);
            
            defaultLineWidth = get(0,'FactoryLineLineWidth');
            
            if isunix
                
                switch lineStyle
                    case ':'
                        lineWidth = 3.5;
                    case '-.'
                        lineWidth = 1.5;
                    otherwise
                        lineWidth = defaultLineWidth;
                end
                
            else
                
                switch lineStyle
                    case ':'
                        lineWidth = 1.5;
                    case '-.'
                        lineWidth = 1.5;
                    otherwise
                        lineWidth = defaultLineWidth;
                end
                
            end
            
            lines(i) = line(...
                'Parent',         ax, ...
                'Color',          color, ...
                'LineStyle',      lineStyle, ...
                'XData',          [nan,nan], ...
                'YData',          [nan,nan], ...
                'UIContextMenu',  get(ax,'UIContextMenu'),...
                'Marker',         markerStr,...
                'EraseMode',      'none', ...
                'LineWidth',      lineWidth);
        end
        
        colorIdx = colorIdx + 1;
        if (colorIdx > nColors),
            colorIdx = 1;
        end
        
        newLines{sigIdx} = lines;
    end
end

%
% Set the lines.
%
set_param(block, 'AxesLineHandles', newLines);


% Function: i_GrabWirelessScopeFocus ==========================================
% Abstract:
%    Make this scope the one with the blue rectangle in an axes.
%
function [scopeUserData,scopeFigFocusChanged] = ...
    i_GrabWirelessScopeFocus(scopeFig)
scopeUserData  = get(scopeFig, 'UserData');
scopeBlockName = getfullname(scopeUserData.block);

oldScope       = get_param(scopeUserData.block_diagram,'FloatingScope');

scopeFigFocusChanged = 0;
if ~isempty(oldScope)
    oldScopeFig      = get_param(oldScope, 'Figure');
    oldScopeUserData = get(oldScopeFig, 'UserData');
    if ~strcmp(scopeBlockName,oldScope)
        scopeFigFocusChanged = 1;
        oldScopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,oldScopeUserData, 'on');
        set(oldScopeFig,'UserData',oldScopeUserData);
        % g391103: Update the buffer with the updated (old) scope figure
        % g397529: axes deselected i.e. blue border turns off in the old figure.
        i_UpdateEraseBufferIfNeeded(oldScopeFig);
    end
else
    scopeFigFocusChanged = 1;
end

if scopeFigFocusChanged,
    set_param(scopeUserData.block_diagram, 'FloatingScope', scopeBlockName);
end

scopebarsv(scopeFig, 'LockButton', 'on', 'off');

%endfunction i_GrabWirelessScopeFocus


% Function: i_DeleteAxesHiLite ================================================
% Abstract:
%    Delete any rectangles in the axes.  Robust to axes that don't have
%    highlighting rectangles.
%
function hiLiteHandle = i_DeleteAxesHiLite(axesHandle)

%
% Delete any existing rectangles in the axes
%

axesChildren = get(axesHandle, 'Children');
if ~isempty(axesChildren),
    rectHandleList = strmatch('rectangle', get(axesChildren, 'Type'));
    if ~isempty(rectHandleList),
        delete(axesChildren(rectHandleList));
    end
end

%endfunction i_DeleteAxesHiLite


% Function: i_AxesExtent =======================================================
% Abstract:
%    Calculates the "Extent" required to display the Y-axis tick labels

function axExt = i_AxesExtent(scopeUserData)
numAxis = size(scopeUserData.scopeAxes,2);
extentStr = '11';
maxWidth = length(extentStr);
if (numAxis > 0)
    %scan axes for largest y-axis tick label string
    for nAxis=1:numAxis
        yTickLabelWidth = size(get(scopeUserData.scopeAxes(nAxis),'YTickLabel'),2);
        if (yTickLabelWidth > maxWidth)
            maxWidth = yTickLabelWidth;
            yTickLabel = get(scopeUserData.scopeAxes(nAxis),'YTickLabel');
            % pad 'Extent' with string '1' in case edge tick label 'Extent' is smaller
            % this prevents clipping left-most pixels in tick label string
            extentStr = [yTickLabel(1,:),'1'];
        end
    end
end
% Encode largest encountered tick label
set(scopeUserData.textExtent, ...
    'FontName',       scopeUserData.axesFontName, ...
    'FontSize',       scopeUserData.axesFontSize, ...
    'String',         extentStr ...
    );
axExt = get(scopeUserData.textExtent, 'Extent');


% Function: i_CreateAxesHiLite ================================================
% Abstract:
%
% Create the highlighting rectangle used to highlight the selected axes
% of a wireless scope.  The rectangle will be invisible when the axes
% is not the selected axes and a color (blue) when selected and the figure
% is not locked down.
%
function hiLiteHandle = i_CreateAxesHiLite(scopeFig, axesHandle, tLim, yLim)

hiLiteCallback = 'simscopesv(''AxesClick'')';
%
% install a callback to allow selection of
% axes (Note: this also undoes a "lockdown")
%
set(scopeFig, 'CurrentAxes', axesHandle);
set(axesHandle, 'ButtonDownFcn', hiLiteCallback);

%
% Delete any existing highlighting rectangles
%
i_DeleteAxesHiLite(axesHandle);

% Make a highlighting rectangle on the axes
% NOTE: only the 'inner' half of 'linewidth' is visible
if tLim(2) == Inf
    tRange = 10; % NOTE: i_ComputeSimulationTimeSpan() seems inconsistent
else
    tRange = tLim(2);
end

hiLiteHandle = rectangle(...
    'Parent',    axesHandle, ...
    'Position', [0, yLim(1), tRange, yLim(2)-yLim(1)], ...
    'LineWidth', 8, ...
    'FaceColor', 'none', ...
    'EdgeColor', 'none', ...
    'ButtonDownFcn', hiLiteCallback);

%endfunction i_CreateAxesHiLite


% Function: i_HiLiteOn ========================================================
% Abstract:
%    Make the axes HiLite visible.
%
function i_HiLiteOn(scopeUserData,ax)

if ishandle(scopeUserData.scopeHiLite(ax))
    set(scopeUserData.scopeHiLite(ax),'EdgeColor','blue');
end

%endfunction i_HiLiteOn

% Function: i_HiLiteOff =======================================================
% Abstract:
%    Make the axes HiLite invisible.
%
function i_HiLiteOff(scopeUserData,ax)

if ishandle(scopeUserData.scopeHiLite(ax))
    set(scopeUserData.scopeHiLite(ax),'EdgeColor','none');
end

%endfunction i_HiLiteOff


% Function: i_HiLiteResize ====================================================
% Abstract:
%    Resizes the HiLite given the new X axes limits and new Y axes limits.
%
function i_HiLiteResize(scopeUserData, ax, xLim, yLim)

if ishandle(scopeUserData.scopeHiLite(ax))
    set(scopeUserData.scopeHiLite(ax), 'Position',...
        [xLim(1), yLim(1), xLim(2)-xLim(1), yLim(2)-yLim(1)]);
end

%endfunction i_HiLiteResize



% Function: i_SetWirelessScopeLockdownMode ====================================
% Abstract:
%    Set the blue pick focus for a given wireless scope and sync the
%    lock button state on the toolbar.
%
%    First Input argument is scopeUserData, but not necessarily from 'this'
%    scope.
%
function scopeUserData = i_SetWirelessScopeLockdownMode(scopeFig,scopeUserData, state)

floating   = onoff(get_param(scopeUserData.block, 'Floating'));
modelBased = i_IsModelBased(scopeUserData.block);

set_param(scopeUserData.block, 'LockDownAxes', state);
%
% Turn off any existing highlighting to show that the axes
% are no longer selected.
%
selectedAxes = get_param(scopeUserData.block,'SelectedAxesIdx');
if ((floating || modelBased) && ishandle(scopeUserData.scopeHiLite(selectedAxes)))
    if (onoff(state))
        i_HiLiteOff(scopeUserData,selectedAxes);
    else
        i_HiLiteOn(scopeUserData,selectedAxes);
    end
    
    % figure has re-rendered
    scopeUserData.dirty = 1;
end

%
% Set the lock button state on the toolbar if floating
%
enabledness = get_param(scopeUserData.block, 'Wireless');
if ~modelBased
    if strcmp(enabledness, 'off')
        lockButtonState = 'off';
    else
        lockButtonState = state;
    end
    set(scopeFig,'UserData',scopeUserData);
    scopebarsv(scopeFig, 'LockButton', enabledness, lockButtonState);
    scopeUserData = get(scopeFig,'UserData');
end
%endfunction


% Function: i_IsSimActive =====================================================
% Abstract:
%    Return 1 if simulation is running or paused or in active external mode.
function simIsActive = i_IsSimActive(hMdl)

simStatus = i_SimpleSimStatus(hMdl);

if strcmp(simStatus,'stopped')
    simIsActive = 0;
else
    simIsActive = 1;
end

%endfunction i_isSimActive


% Function: i_RestorePortConnections ==========================================
% Abstract:
%    If there are line segments adjacent to unconnected ports on the scope,
%    reconnect them as long as we are allowed to change the block diagram.
%
function i_RestorePortConnections(scope)

portHandles = get_param(scope,'PortHandles');
inHandles   = portHandles.Inport;

for k=1:length(inHandles),
    if ~ishandle(get_param(inHandles(k),'Line')) && ~i_IsSimActive(bdroot(scope))
        portCoords = get_param(inHandles(k), 'Position');
        newLineHandle = add_line(get_param(scope, 'Parent'), ...
            [portCoords; portCoords]);
        if ~ishandle(get_param(newLineHandle, 'SrcPortHandle'))
            delete_line(newLineHandle);
        end
    end
end

%endfunction i_RestorePortConnections


% Function: i_SignalSelectorTitle ==============================================
% Abstract:
%   Returns a title to be used in the signal selector dialog box.
%
function title = i_SignalSelectorTitle(block)
if i_IsModelBased(block)
    title = viewertitle(block, true);
else
    title = getfullname(block);
end

%endfunction i_SignalSelectorTitle

% Function: SIG_SEP ===========================================================
% Abstract:
%    Constant function for a signal separator, scoped to this file.
%
function str = SIG_SEP
str = '|';

% Function: PORT_SEP ==========================================================
% Abstract:
%    Constant function for a port separator, scoped to this file.
%
function str = PORT_SEP
str = ':';

% Function: i_ParseSelectionData ===============================================
% Abstract:
%    Get the SelectedSignals saved in the block.
%
function signals = i_ParseSelectionData(block)

try  %Added for safety since errors here will cause models to NOT load
    data          = get_param(block, 'SelectedSignals');
    if isempty(data)
        signals = {[]};
        return;
    end
    
    numDataAxes = length(fieldnames(data));
    
    signals = cell(numDataAxes,1);  %pre-allocate cell array
    for i = 1:numDataAxes
        sigList      = eval(['data.axes' num2str(i)]);
        
        % if the siglist is empty, continue.  The code below doesn't
        % work correctly if there are no signals.
        if isempty(sigList)
            continue;
        end
        
        % Create a cell array with one element for each signal.
        sigCell      = eval(['{''' strrep(sigList, SIG_SEP, ''',''') '''}']);
        signals{i}(length(sigCell)) = 0;  %pre-allocate line list
        badSigs = 0;
        for j = 1:length(sigCell)
            sig = sigCell{j};
            if isempty(sig)
                badSigs = badSigs + 1;
                continue;
            end
            idx = find(sig == PORT_SEP);
            blk = sig(1:idx(end)-1);
            
            % Get the block Handle
            try
                blkH = get_param(blk, 'Handle');
            catch me %#ok<NASGU>
                try
                    % If an error occurred, it may have been caused by a block name change.
                    % Use the current name of the block and try again.  Looking for the
                    % first '/' in the block name suffices for finding the old bdroot,
                    % because '/' is not a valid character in filenames.
                    idx2 = find(blk == '/');
                    bdName = get_param(bdroot(block),'Name');
                    blk = [bdName blk(idx2(1):end)];
                    blkH = get_param(blk, 'Handle');
                catch me %#ok<NASGU>
                    % If an error occurred here, then the block is truly invalid.  Punt.
                    badSigs = badSigs + 1;
                    continue;
                end
            end
            
            port = str2num(sig(idx(end)+1:end));
            portHs   = get_param(blkH, 'PortHandles');
            ports    = cat(2, portHs.Outport, portHs.State);
            sig_port = ports(port);
            sig_line = get_param(sig_port, 'Line');
            if ishandle(sig_line)
                signals{i}(j-badSigs) = sig_line;
            else
                badSigs = badSigs + 1;
            end
        end
        %Trim the list if some elements were invalid.
        if (badSigs > 0)
            signals{i} = signals{i}(1:length(sigCell)-badSigs);
        end
    end
catch me %#ok<NASGU>
    signals = {};
    DAStudio.warning('Simulink:blocks:DataParsingError');
end  %Added for safety since errors here will cause models to NOT load



% Function: i_LoadSelectionData ===============================================
% Abstract:
%    Get the SelectedSignals saved in the block and setup the userdata
%    of the scope figure window.
%
function i_LoadSelectionData(block)
if 0,
    dirtyState = get_param(bdroot(block), 'Dirty');
    
    try  %Added for safety since errors here will cause models to NOT load
        scopeFig      = get_param(block, 'Figure');
        scopeUserData = get(scopeFig, 'UserData');
        numAxes       = length(scopeUserData.scopeAxes);
        
        signals = i_ParseSelectionData(block);
        if isempty(signals)
            return;
        end
        
        num = min(length(signals), numAxes);
        
        for i = 1:num
            axesUserData = get(scopeUserData.scopeAxes(i), 'UserData');
            axesUserData.signals = signals{i};
            set(scopeUserData.scopeAxes(i), 'UserData', axesUserData);
        end
        
        set(scopeFig, 'UserData', scopeUserData);
        
    catch
        DAStudio.warning('Simulink:blocks:DataLoadingError');
    end  %Added for safety since errors here will cause models to NOT load
    
    set_param(bdroot(block), 'Dirty', dirtyState);
end

% Function: i_SaveSelectionData ===============================================
% Abstract:
%    Get the selected port handles from the figures userdata
%    and set the selection data for the block so that it gets saved.
%    Saving format is | separated list with ':Num' appended for port number
%    to the block name.
%
function i_SaveSelectionData(block)
if 0
    data     = [];
    scopeFig = get_param(block, 'Figure');
    
    try % Added for safety for R12.1
        if ishandle(scopeFig)
            scopeUserData = get(scopeFig, 'UserData');
            numAxes       = length(scopeUserData.scopeAxes);
            
            for i = 1:numAxes
                axesUserData = get(scopeUserData.scopeAxes(i), 'UserData');
                signals      = axesUserData.signals;
                sigList = '';
                pList   = [];
                if ~isempty(signals)
                    % Construct string based on number of signals
                    for j = 1:length(signals)
                        if ishandle(signals(j))
                            p = get_param(signals(j), 'SrcPortHandle');
                            % ignore duplicate port refs
                            if ishandle(p) && isempty(find(p==pList))
                                pList = [ pList; p ]; % hit list
                                blk = strrep(get_param(p, 'Parent'), sprintf('\n'), ' ');
                                num = get_param(p, 'PortNumber');
                                sigList = [sigList blk ':' num2str(num) '|'];
                            end
                        end
                    end
                    if (length(sigList) > 0) && (sigList(end) == '|')
                        sigList(end) = [];
                    end
                end
                
                % Set the nth axes field
                eval(['data.axes' num2str(i) '= sigList;']);
            end
            
            % Set the SelectedSignals field
            set_param(block, 'SelectedSignals', data);
        end
    catch
        DAStudio.warning('Simulink:blocks:DataSavingError');
    end % Added for safety - silently fail
end

% Function: i_GetWirelessPorts ======================================
% Abstract:
%    Parse the Selection Data saved in the 'SelectedSignals' param
% and return a cell array that contains a 'SrcPortHandle' for each
% signal.
%
function hPorts = i_GetWirelessPorts(block)
if 0
    signals = i_ParseSelectionData(block);
    
    numAxes = length(signals);
    hPorts = cell(numAxes,1);
    for i=1:numAxes
        if ~isempty(signals{i})
            if ishandle(signals{i})
                hpCell = get_param(signals{i}, 'SrcPortHandle');
                if iscell(hpCell)
                    hPorts(i) = { unique([hpCell{:}]') };
                else
                    hPorts(i) = { hpCell };
                end
            else
                hPorts(i) = { [] };
            end
        end
    end
end


% Function: i_VerifySelectionData =================================
% Abstract:
%    Check that the SelectedSignals parameter is consistent
% with the signals stored in the axes.  If it is not, send a
% warning, repair SelectedSignals, and update SelectedPortHandles.
%
function i_VerifySelectionData(block)
if 0
    valid = 1;
    
    % Create a warning string to use if a problem is detected.
    warningStr    = ['Selection Data corruption found in scope ''' ...
        get_param(block,'Name') '''.'];
    if strcmp(get_param(block,'Wireless'),'on')
        warningStr = [warningStr '  Re-selected signals for this scope.'];
    end
    
    try  %Catch any errors that may occur.
        scopeFig      = get_param(block, 'Figure');
        scopeUserData = get(scopeFig, 'UserData');
        numAxes       = length(scopeUserData.scopeAxes);
        
        signals = i_ParseSelectionData(block);
        
        if isempty(signals)
            warningStr = [warningStr '  <Empty selection data found when verifying.>'];
            valid = 0;
        else
            if (length(signals) ~= numAxes)
                warningStr = [warningStr ...
                    '  <Length of selection data does not match number of axes.>'];
                valid = 0;
            end
            numAxes = min(length(signals), numAxes);
            
            for i = 1:numAxes
                axesUserData = get(scopeUserData.scopeAxes(i), 'UserData');
                if (length(signals{i}) ~= length(axesUserData.signals))
                    warningStr = [warningStr ...
                        '  <Axis ' int2str(i) ' Has ' int2str(length(signals{i})) ...
                        ' signals in ''SelectedSignals'' and ' ...
                        int2str(length(axesUserData.signals)) ...
                        ' signals in Axis User Data.>'];
                    valid = 0;
                    break;
                end
                
                numSigs = min(length(signals{i}), length(axesUserData.signals));
                for j = 1:numSigs
                    if (signals{i}(j) ~= axesUserData.signals(j))
                        warningStr = [warningStr ...
                            '  <Axis ' int2str(i) ' signal #' int2str(j) ...
                            ' in ''SelectedSignals'' (' num2str(signals{i}(j)) ...
                            ') does not match signal #' int2str(j) ...
                            ' in Axis User Data (' num2str(axesUserData.signals(j)) ...
                            ').>'];
                        valid = 0;
                        break;
                    end
                end
            end
        end
    catch
        warningStr = [warningStr '  <Unknown Error>'];
        valid = 0;
    end
    
    % If anything went wrong, re-save SelectedSignals and update
    % SelectedPortHandles
    if ~valid
        DAStudio.warning('Simulink:blocks:DataVerificationErrors',warningStr);
        i_SaveSelectionData(block);
        i_UpdateSelectedPortHandles(block);
    end
end


% Function: i_UpdateSelectedPortHandles ===========================
% Abstract:
%    Get the list of wireless ports and update the
% "SelectedPortHandles" parameter to match it.
%
function i_UpdateSelectedPortHandles(block)
if 0
    hPorts = i_GetWirelessPorts(block);
    set_param(block,'SelectedPortHandles',hPorts);
end

% Function: i_UpdateSelectionDataNumAxes ======================================
% Abstract:
%    Change the selection data to remove data for axes that are eliminated or
% add empty arrays for axes that are added.  This function was added because it
% became important to keep the selection data tightly synchronized with the
% selected signal information in the axes.
%
function i_UpdateSelectionDataNumAxes(block, newNumAxes)

try  %Added for safety since errors here will cause models to NOT load
    oldData    = get_param(block, 'SelectedSignals');
    newData    = [];
    
    % Read this value from the Saved Data.  This is important, because when the
    % axes are first created, the old number of axes will be inconsistent with
    % what is saved in 'SelectedSignals'.
    if isempty(oldData)
        oldNumAxes = 0;
    else
        oldNumAxes = length(fieldnames(oldData));
    end
    
    % Move the data over for each axis that still exists, and add empty
    % data for new axes.
    for i = 1:newNumAxes
        if (i<=oldNumAxes)
            eval(['newData.axes' num2str(i) '= oldData.axes' num2str(i) ';']);
        else
            eval(['newData.axes' num2str(i) '= '''';']);
        end
    end
    
    % Set the SelectedSignals field
    set_param(block, 'SelectedSignals', newData);
catch
    DAStudio.warning('Simulink:blocks:DataUpdateError');
end  %Added for safety since errors here will cause models to NOT load


% Function: i_GetSelection ====================================================
% Abstract:
%    Return port selection
%
function ports = i_GetSelection(block, axesIdx)

scopeFig      = get_param(block, 'Figure');
scopeUserData = get(scopeFig, 'UserData');

% Set the selected axes
set(scopeFig, 'CurrentAxes', scopeUserData.scopeAxes(axesIdx));
simscopesv('SelectedAxes', 'Dialog', scopeFig);

% Determine lines
axUserData = get(scopeUserData.scopeAxes(axesIdx),'UserData');
lines      = axUserData.signals;
ports      = get_param(lines, 'SrcPortHandle');
if iscell(ports)
    ports = [ports{:}]';
end


% Function: i_AddSelection ====================================================
% Abstract:
%    Add ports to selection list.
%
function i_AddSelection(block, ax, ports)

%
% Select lines and children.
%
lines = get_param(ports, 'Line');
if iscell(lines)
    lines = [lines{:}]';
end

for i = 1:length(lines)
    if (lines(i) > 0)
        set_param(lines(i), 'Selected', 'on')
    end
end

%
% Add entries to IOSignals.  If this axes is the 'blue one', then the
% act of selecting the lines takes care of setting up the iosigs.
%
ioSigs   = get_param(block,'IOSignals');
ioSigs   = i_RemoveInvalHandles(ioSigs,ax);
axIOSigs = ioSigs{ax};

for i=1:length(ports),
    hp = ports(i);
    if ishandle(hp),
        axIOSigs(end+1) = struct('Handle',hp,'RelativePath','');
    end
end
[b,i,j] = unique([axIOSigs.Handle]);
axIOSigs = axIOSigs(i);
ioSigs{ax} = axIOSigs;
set_param(block,'IOSignals',ioSigs);

%endfunction


% Function: i_DeselectLinesAndChildren ========================================
% Abstract:
%
function i_DeselectLinesAndChildren(line)

set_param(line, 'Selected', 'off');
children = get_param(line, 'LineChildren');
if iscell(children)
    children = [children{:}]';
end
for j = 1:length(children)
    i_DeselectLinesAndChildren(children(j));
end


% Function: i_RemoveSelection =================================================
% Abstract:
%    Remove ports from selection list.
%
function i_RemoveSelection(block, ax, ports)

%
% Deselect lines and children
%
lines = get_param(ports, 'Line');
if iscell(lines)
    lines = [lines{:}]';
end

for i = 1:length(lines)
    % Do set_param only for valid lines
    if (lines(i) > 0)
        i_DeselectLinesAndChildren(lines(i));
    end
end

%
% Prune out appropriate entries from IOSignals
%
ioSigs   = get_param(block,'IOSignals');
%ioSigs   = i_RemoveInvalHandles(ioSigs);
axIOSigs = ioSigs{ax};

for i=1:length(ports),
    hp = ports(i);
    if ishandle(hp),
        for j=1:length(axIOSigs)
            axIOSigs(axIOSigs(j).Handle == hp) = [];
        end
    end
end
ioSigs{ax} = axIOSigs;
set_param(block,'IOSignals',ioSigs);

%endfunction


% Function: i_SwitchSelection =================================================
% Abstract:
%    Switch the selection from one port to another.
%
function i_SwitchSelection(block, ax, oldPort, newPort)
scopeFig      = get_param(block, 'Figure');
scopeUserData = get(scopeFig, 'UserData');

% Get axes user data of the relevant axes
axUserData = get(scopeUserData.scopeAxes(ax), 'UserData');

if (oldPort ~= INVALID_HANDLE)
    %% Deselect line and children
    oldLine = get_param(oldPort, 'Line');
    
    % Do set_param only for valid lines
    if (oldLine > 0)
        i_DeselectLinesAndChildren(oldLine);
        
        % Remove this from the userdata
        idx = find(axUserData.signals == oldLine);
        if ~isempty(idx)
            axUserData.signals(idx) = [];
        end
    end
end

if (newPort ~= INVALID_HANDLE)
    newLine = get_param(newPort, 'Line');
    
    % Do set_param only for valid lines
    if (newLine > 0)
        set_param(newLine, 'Selected', 'on')
        
        % Add this to the userdata
        if ~any(axUserData.signals == newLine)
            axUserData.signals(end+1) = newLine;
        end
    end
end

% Update axes userdata
set(scopeUserData.scopeAxes(ax), 'UserData', axUserData);
set(scopeFig, 'UserData', scopeUserData);

% Save the selection data and update the Selected Port Handles.
i_SaveSelectionData(block);
i_UpdateSelectedPortHandles(block);


% Function: i_DialogClosing
% ===================================================
% Abstract:
%    Signal Selector Dialog is closing, so lock down axes
%
function i_DialogClosing(block)

scopeFig = get_param(block, 'Figure');

if ishandle(scopeFig)
    scopeUserData = get(scopeFig, 'UserData');
else
    % Quietly ignore requests to Lock down invalid figure handles
    return;
end

% Turn off the Hi Liting of any axes

scopeAxes = scopeUserData.scopeAxes;

for i=1:length(scopeAxes)
    i_HiLiteOff(scopeUserData,i);
end
% g456028 added figure input to function call as it was missing
i_SetWirelessScopeLockdownMode(scopeFig, scopeUserData, 'on');

function out = i_IsModelBased(block)
ioType = get_param(block,'IOType');
out   = strcmp(ioType,'viewer');
%end


function i_PostResizeHack(hSrcObj,eventData,scopeFig)
scopeUserData = get(scopeFig,'UserData');

scopeUserData = i_Resize(scopeFig,scopeUserData);
%drawnow;

resize = true;
scopeUserData = i_UpdateLegends(scopeFig,scopeUserData,resize);

i_UpdateEraseBuffer(scopeFig);
scopeUserData = get(scopeFig, 'UserData');
scopeUserData.firstResize = true;
set(scopeFig,'UserData',scopeUserData);

%disp('last resize');
%endfunction


% Function: i_Resize ============================================================
%
function scopeUserData = i_Resize(scopeFig, scopeUserData)
scopeAxes = scopeUserData.scopeAxes;

haveLegends = ~isempty(legend('-find',scopeAxes(1)));
if scopeUserData.firstResize && haveLegends,
    scopeUserData.firstResize = false;
    set(scopeFig,'UserData',scopeUserData);
    
    if (usejava('awt') == 1)
        scopeUserData = i_DestroyLegends(scopeFig,scopeUserData);
        cb = {@i_PostResizeHack;gcbf};
        set(scopeUserData.delayedCB,'DelayedCallback',cb);
        % request postResize callback after this one completely finishes
        % or drawnow is called - this means that calling
        % drawnow inside this resizefcn could change event order
        postCallback(scopeUserData.delayedCB);
    end
end

axesGeom  = i_CreateAxesGeom(scopeUserData);
block     = scopeUserData.block;
posScope  = get(scopeFig, 'Position');

%
% Resize the axes.
%
scopeUserData = i_ResizeAxes(scopeFig, scopeUserData, axesGeom);

%endfunction


function i_UpdateEraseBuffer(scopeFig)
scopeUserData = get(scopeFig,'UserData');
block     = scopeUserData.block;
scopeAxes = scopeUserData.scopeAxes;
allLines  = i_GetAllLineHandles(block,scopeAxes);

set(allLines,'Visible','off');
get_param(scopeUserData.block, 'InvalidateBlitBuffer');
set(allLines,'Visible','on');

scopeUserData.dirty = 0;
set(scopeFig, 'UserData', scopeUserData);
%endfunction

function i_UpdateEraseBufferIfNeeded(scopeFig)
if ~ishghandle(scopeFig), return; end
scopeUserData = get(scopeFig,'UserData');
if (scopeUserData.dirty),
    i_UpdateEraseBuffer(scopeFig);
end
%endfunction


function ioSigsCell = i_RemoveInvalHandles(ioSigsCell,ax)
currIOSigsCell = ioSigsCell{ax};
for i=1:length(currIOSigsCell)
    currIOSigsCell(currIOSigsCell(i).Handle == -1) = [];
end
ioSigsCell{ax} = currIOSigsCell;
%endfunction


%
%
%
function markerStr = i_GetMarkerStr(block)
if onoff(get_param(block,'ShowDataMarkers'))
    markerStr = '+';
else
    markerStr = 'none';
end
%endfunction


%
%
%
function i_MarkerCB(scopeFig,scopeUserData)
block     = scopeUserData.block;
scopeAxes = scopeUserData.scopeAxes;
allLines  = i_GetAllLineHandles(block,scopeAxes);
markerStr = i_GetMarkerStr(block);

set(allLines,'Marker',markerStr);

%endfunction


% ------------------------------------------------------------------


function [htX, htY] = i_InsideTickLabels(ax)

fontName = get(0,'FactoryAxesFontName');
fontSize = 10;

xticks = get(ax,'xtick');
yticks = get(ax,'ytick');

xLim = get(ax,'XLim');
yLim = get(ax,'YLim');

%
% xTickLabels
%
xtickLabs      = cellstr(get(ax,'xTickLabel'));
yLoc           = ones(size(xticks)) * yLim(1);
xtickLabs{end} = i_AddExpToTickLab(xLim, xtickLabs{end},'x');

htX = text(xticks, yLoc, xtickLabs, ...
    'Parent',           ax, ...
    'FontName',         fontName, ...
    'FontSize',         fontSize, ...
    'VerticalAlign',    'Bottom', ...
    'Color',            'black', ...
    'Interpreter',      'none');
set(htX(end),'HorizontalAlign','Right');
set(htX(1),'Visible','off');

%
% yTickLabels
%
ytickLabs      = cellstr(get(ax,'yTickLabel'));
xLoc           = ones(size(yticks)) * xLim(1);
ytickLabs      = strcat({' '},ytickLabs);
ytickLabs{end} = i_AddExpToTickLab(yLim, ytickLabs{end},'y');

htY = text(xLoc, yticks, ytickLabs, ...
    'Parent',           ax, ...
    'FontName',         fontName, ...
    'FontSize',         fontSize, ...
    'HorizontalAlign',  'Left', ...
    'Color',            'black', ...
    'Interpreter',      'none');
set(htY(end),'VerticalAlign','top');
set(htY(1),'Visible','off');

%
% Hide tick from inside
%
set(ax,'TickDir','out');

%endfunction i_InsideTickLabels


% ------------------------------------------------------------------


function tickLab = i_AddExpToTickLab(lims,tickLab,ax)

up = lims(2);

% Guard exponent calculation against uppper TickLabel being zero (0)
% In this instance, use one (1) for "reasonable" approximation
tickNum = str2num(tickLab);
if (tickNum == 0)
    tickNum = 1;
end

% Exponential notation only possible for tick label strings
% greater than or equal to one
if abs(tickNum) >= 1
    expNum = floor(log10(up/tickNum));
else
    expNum = 0;
end

if expNum > 0
    upExtStr = ['e+' num2str(expNum)];
elseif expNum < 0
    upExtStr = ['e' num2str(expNum)];
else
    upExtStr = '';
end

if (ax == 'y')
    tickLab = [tickLab upExtStr];
else
    if ~isempty(upExtStr),
        tickLab = sprintf('%s\n%s',upExtStr,tickLab);
    end
end

%endfunction i_AddExpToTickLab


% ------------------------------------------------------------------


function i_RenderInsideTickLabels(block, ax)

axesUserData  = get(ax, 'UserData');
if isfield(axesUserData,'insideTickLabelsX')
    delete(axesUserData.insideTickLabelsX);
    delete(axesUserData.insideTickLabelsY);
    axesUserData=rmfield(axesUserData,{'insideTickLabelsX','insideTickLabelsY'});
end
if strcmp(get_param(block,'TickLabels'), 'off')
    [axesUserData.insideTickLabelsX, axesUserData.insideTickLabelsY] = ...
        i_InsideTickLabels(ax);
end
set(ax,'UserData',axesUserData);
%endfunction i_RenderInsideTickLabels

function scopeUserData =i_TickStyle_Checkmark(scopeUserData)
tickLabels = get_param(scopeUserData.block, 'TickLabels');
set(scopeUserData.axesContextMenu.tickall,'checked','off');
set(scopeUserData.axesContextMenu.tickinside,'checked','off');
set(scopeUserData.axesContextMenu.tickbottom,'checked','off');
set(scopeUserData.wsContextMenu.tickall,'checked','off');
set(scopeUserData.wsContextMenu.tickinside,'checked','off');
set(scopeUserData.wsContextMenu.tickbottom,'checked','off');
if strcmp(tickLabels, 'on')
    set(scopeUserData.axesContextMenu.tickall,'checked','on');
    set(scopeUserData.wsContextMenu.tickall,'checked','on');
elseif strcmp(tickLabels, 'off')
    set(scopeUserData.axesContextMenu.tickinside,'checked','on');
    set(scopeUserData.wsContextMenu.tickinside,'checked','on');
else
    set(scopeUserData.axesContextMenu.tickbottom,'checked','on');
    set(scopeUserData.wsContextMenu.tickbottom,'checked','on');
end
%endfunction i_TickStyle_Checkmark


function tRange = i_GetTimeRange(block)

bd = bdroot(block);

if onoff(get_param(block,'Floating'))
    param = 'OverrideFloatScopeTimeRange';
else
    param = 'OverrideScopeTimeRange';
end
tRange = get_param(bd, param);
if isnan(tRange),
    tRange = get_param(block, 'TimeRange');
else
    tRange = num2str(tRange);
end
%endfunction

function msg = lclMessage(ID, varargin)

msg = DAStudio.message(['Simulink:blocks:' ID], varargin{:});

% [EOF] simscopesv.m
