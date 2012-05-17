function varargout = simscope(varargin)
%SIMSCOPE Simulink Scope block
%   SIMSCOPE manages the user interface for the Simulink scope block.
%   The implementation is split between this file and  Util.m in
%   toolbox/simulink/simulink/+Simulink/+scopes
%
%   The actions are listed in non-alphabetical order to allow diff with
%   previous versions
%

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.144.4.46.2.1 $

% arguments (see below) 
%
%% The following actions are callbacks for the current block
% 
%  arg{1} = block handle
%  scope.cpp  sets gcb to be the block prior to call
%  gcb or Util.getFromBlock can be used
%
% 'BlockClose' 
% 'BlockDelete', 
% 'BlockIsBeingDestroyed', 
% 'BlockNameChange' 
% 'BlockOpen', 
% 'BlockPreSave',
% 'BlockStart',
% 'BlockTerminate', 
% 'BlockUpdateDiagram',
% 'ExtLogInitialize',
% 'ExtLogTerminate',
% 'GetWirelessPorts'
% 'SigSelectChange', 
%
%% The following actions are callbacks for the current figure
% 
%  Use gcbo or Util.GetFromFig
% 
% 'AxesClick' 
% 'CloseReq', 
% 'DeleteFcn',
% 'LockDownAxes' 
% 'Resize', 
% 'SelectedAxes' 
%
%% The following actions are callbacks from various places and
% take arguments
%
% Use gcb or gcbo, use your judgement
%
% 'AddSelection'  (BlockHandle,AxesNumber,addSel)
% 'AxesContextMenu',(~,menuItme)
% 'AxesPropDlg',
% 'DialogClosing'
% 'DialogSelection',
% 'GetSelection' (BlockHandle,AxesNumber)
% 'OverrideTRange',
% 'PrintFigure'
% 'PropDialogApply',
% 'RemoveSelection' (BlockHandle,AxesNumber,remSel)
% 'ResizeHiLites'
% 'Save'
% 'ScopeBar',
% 'SetNewNumPorts'(scopeBlk,newNumber) 
% 'SetSelectedAxes',
% 'SimTimeSpan',
% 'SwitchSelection'  (BlockHandle,AxesNumber,oldSel,newSel)

%
Action = varargin{1};
args   = varargin(2:end);
	
switch Action,
    
case 'Resize',
    %
    % Graphical resize of window.
    %
    modified      = 0;
    [block, scopeFig, scopeUserData] = Simulink.scopes.Util.GetFromFig;
    posScope = get(handle(scopeFig), 'Position');
    %
    % Resize the axes.
    %
    axesGeom = Simulink.scopes.Util.CreateAxesGeom(scopeFig, scopeUserData);
    [modified, scopeUserData] = Simulink.scopes.Util.ResizeAxes(scopeFig, scopeUserData, ...
                                             axesGeom);
    
    %
    % Update line data.
    %
    scopeLineData = get_block_param(block, 'CopyDataBuffer');
    
    Simulink.scopes.Util.ShiftNPlotAllAxes(scopeUserData, scopeLineData, 0);
    
    %
    % Update user data.
    %
    if modified,
        set(scopeFig, 'UserData', scopeUserData);
    end
    
case 'BlockOpen',
    
  % 
  % Use the block handle passed in
  scopeBlk  = args{1};
  scopeFig = get_param(scopeBlk, 'Figure');
  %
  %  [scopeBlk, scopeFig,~] = Simulink.scopes.Util.GetFromBlock;
    if strcmp(get_param(bdroot(scopeBlk),'Lock'), 'on') || ...
            strcmp(get_param(scopeBlk,'LinkStatus'),'implicit')
    errordlg(Simulink.scopes.Util.lclMessage('ScopeInLockedSystem'),...
            'Error', 'modal')
        return
    end
    
    %
    % Received request to open scope.
    %
    if scopeFig == INVALID_HANDLE
        scopeFig = Simulink.scopes.Util.Initialize(scopeBlk);
        newFig = true;
    else
        newFig = false;
    end
    
    Simulink.scopes.Util.OpenFigure(scopeBlk,newFig, scopeFig);

    %
    % For wireless scopes, lock down axes so that when 
    % it is just opened, signal selections won't be 
    % accidentally altered.
    %
    if strcmp(get_block_param(scopeBlk,'Wireless'), 'on')
      scopeUserData = get(handle(scopeFig), 'UserData');
      Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
    end
    
    %
    % Process the selected signals in the SelectedSignals parameter
    % and update the userdata field.  We don't need to update the
    % SelectedPortHandles here because they were updated in
    % Simulink.scopes.Util.UpdateAxesConfig.
    %

 case 'SigSelectChange',
    [block, scopeFig, scopeUserData] = Simulink.scopes.Util.GetFromBlock;
    
    if ishandle(scopeFig)
        
        %
        % User clicked on a signal wire in the block diagram
        % or lines were selected programmatically, which the 
        % scope block detected and then called here.
        %
        % SelectedAxesIdx indicates which axes the user
        % wants the new signal selections to be displayed on
        % (wireless scopes only).
        %
        currAxes = get_block_param(block, 'SelectedAxesIdx');

        %
        newLines = Simulink.scopes.Util.CreateLinesForAxes( ...
            block, scopeUserData, currAxes);
        if ~isempty(newLines)
            set_param(scopeUserData.block, 'AxesLineHandles', newLines);
        end
        %
        % Update the YTick attributes
        %
        yTickInfo = Simulink.scopes.Util.GetYTickInfo(scopeUserData, currAxes, false);
        Simulink.scopes.Util.SetYTickInfo(scopeUserData.scopeAxes(currAxes), yTickInfo);
        Simulink.scopes.Util.FixPositionOfAxes(scopeUserData);

        % Force the figure to be redrawn
        get_block_param(block, 'InvalidateBlitBuffer');  
        
        %
        % Save the SelectionData and update the Selected Port Handles
        % to keep them synchronized.
        %  
    end
    
     
case 'LockDownAxes'
    
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromFig;
    
    if ~ishandle(scopeFig)
        % Quietly ignore requests to LockDown invalid figure handles
        return;
    end
    
    Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
    
    
case 'ResizeHiLites'

    %
    % Resize the axes highlights to make them consistent with the 
    % axes limits.  This is usually called by "scopezoom" after 
    % the axes limits have changed.
    %
    % HD don't use FromFig or FromBlock?
    % HD move this to a scopes.Util function
    scopeFig = varargin{2};
    scopeUserData  = get(handle(scopeFig), 'UserData');
    scopeAxes = scopeUserData.scopeAxes;
    nAxes     = length(scopeAxes);

    for i=1:nAxes,
        ax   = scopeAxes(i);
        xLim = get(ax,'XLim');
        yLim = get(ax,'YLim');
        
        Simulink.scopes.Util.HiLiteResize(scopeUserData,i,xLim,yLim);
    end
    % Call 'Resize' callback in case y-axis tick labels have grown
    %  one character bigger
    simscope('Resize');
 
case 'AxesClick'
    
   [block,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromFig;

    modelBased    = Simulink.scopes.Util.IsModelBased(block);
        
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
        Simulink.scopes.Util.GrabWirelessScopeFocus(scopeFig);

        %
        % Lockdown the old axes just in case they're still active.
        %
        Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
        oldAxes = get_block_param(block, 'SelectedAxesIdx');
        Simulink.scopes.Util.HiLiteOff(scopeUserData,oldAxes);

        %
        % Get the new axis.
        %
        axH = get(handle(scopeFig), 'CurrentAxes');
        ax  = find(scopeUserData.scopeAxes == axH);
        if isempty(ax)
            ax = 1;
        end
        ax = ax(1);
        
        %
        % Make this the current axis and turn on the HiLite
        %
        set_param(block, 'SelectedAxesIdx', ax);
        Simulink.scopes.Util.HiLiteOn(scopeUserData,ax);
        
        signalselector('UpdateInputNum',block,ax);
    else
        simscope('SelectedAxes');
    end
    
 case 'SetSelectedAxes',
  scopeFig = varargin{2};
  axIdx    = varargin{3};
  
  scopeUserData = get(handle(scopeFig),'UserData');
  axH           = scopeUserData.scopeAxes(axIdx);
  
  set(scopeFig, 'CurrentAxes', axH);
  scopeUserData  = Simulink.scopes.Util.ChangeBlueAxes(scopeFig,scopeUserData,axH);
  set(scopeFig,'UserData',scopeUserData);
    
 case 'SelectedAxes'
  
  scopeFig =  gcbf;
  
  if ishandle(scopeFig)
    callbackCall = strcmp(get(handle(scopeFig),'SelectionType'), 'normal');
  else
    if nargin == 3,
      scopeFig = varargin{3};
    else
      DAStudio.error('Simulink:blocks:InternalScopeError');
    end
    callbackCall = 0;
  end
  
  if (callbackCall || nargin > 1)
    if nargin == 2
      if ~strcmp(varargin{2},'Dialog')
        DAStudio.error('Simulink:blocks:UnknownOptionInSelectedAxes', ...
                       varargin{2});
      end
    end

    scopeUserData  = get(handle(scopeFig), 'UserData');
    axH            = get(handle(scopeFig), 'CurrentAxes');
    
    scopeUserData  = Simulink.scopes.Util.ChangeBlueAxes(scopeFig,scopeUserData,axH);
    set(scopeFig,'UserData',scopeUserData);
    
    ax = find(scopeUserData.scopeAxes == axH);
    if ~isempty(ax)
      signalselector('UpdateInputNum',scopeUserData.block,ax);
    end
  end
    
case 'DialogSelection',
    % 
    % Signal Selection via the signal selector is complete.
    %
    scopeFig = varargin{2};
    scopeUserData = get(handle(scopeFig),'UserData');
    
    % First clear the set lines in the block diagram. Then,
    % set the lines in the block diagram for this axes.
    %
    hl = find_system(scopeUserData.block_diagram,'findall', 'on', ...
        'type', 'line','selected','on');
    for i=1:length(hl)
        set_param(hl(i),'selected','off');
    end
    
    %
    % Retrieve the new list and select the lines.  The 
    % internal scope code will pick up the selected 
    % signals and use them.
    %
    hl = varargin{3};
    
    for i=1:length(hl)
        set_param(hl(i),'selected','on');
    end
    
    Simulink.scopes.Util.SetWirelessScopeLockdownMode(scopeUserData, 'on');
    
case 'GetWirelessPorts' 
    %
    % Return the list of ports used by a wireless scope.
    % Note that this function is designed to be called 
    % from within the scope's EvalParamsFcn (in C).  It 
    % does not set the 'SelectedPortHandles' parameter,
    % because that would trigger another call to the
    % EvalParamsFcn.
    %
    varargout{1} = [];
    
case 'BlockStart',
    %
    % Simulation is initializing.
    %
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromBlock;
    
    % 
    % Common set of operations at startup
    %
    [scopeUserData, modified] = Simulink.scopes.Util.SimulationStart(scopeFig, scopeUserData);
    if modified == 1,
        set(scopeFig, 'UserData', scopeUserData);
    end
    
    if ishandle(scopeUserData.scopePropDlg)
        scpprop('BlockStart', scopeUserData.scopePropDlg);
    end

    % Notify Signal Selector
    signalselector('BlockStart', gcbh);
 
case 'BlockTerminate',
    %
    % Simulation is terminating.
    %
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromBlock;

    [scopeUserData, modified] = Simulink.scopes.Util.SimulationTerminate ...
        (scopeFig, scopeUserData);
    if modified == 1,
        set(scopeFig, 'UserData', scopeUserData);
    end
    
    if ishandle(scopeUserData.scopePropDlg)
        scpprop('BlockTerminate', scopeUserData.scopePropDlg);
    end
     % Notify Signal Selector
    signalselector('BlockTerminate', gcbh);
 
case 'ExtLogInitialize',
    %
    % External data log event is initializing (armed)
    %
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromBlock;
    
    [scopeUserData, bModified] = Simulink.scopes.Util.SimulationStart( ...
        scopeFig, scopeUserData);
    if bModified == 1,
        set(scopeFig, 'UserData', scopeUserData);
    end
    
    scopePropDlg = scopeUserData.scopePropDlg;
    if ishandle(scopePropDlg) && onoff(get(scopePropDlg, 'Visible'))
        scpprop('BlockStart', scopeUserData.scopePropDlg);
    end
    
case 'ExtLogTerminate',
    %
    % External data log event is terminating.
    %
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromBlock;
    
    [scopeUserData, bModified] = Simulink.scopes.Util.SimulationTerminate( ...
        scopeFig, scopeUserData);
    if bModified == 1,
        set(scopeFig, 'UserData', scopeUserData);
    end
    
case 'BlockUpdateDiagram',
    %
    % The block diagram is being updated.
    %
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromBlock;
    if ishandle(scopeFig)
      Simulink.scopes.Util.UpdateTitles(scopeUserData);
    end
    
case {'BlockDelete', 'BlockIsBeingDestroyed'},
    [scopeBlkH,scopeFig,~] = Simulink.scopes.Util.GetFromBlock;

    %
    % Block has been destoyed.  Note that some old models have
    % been saved with scopes whose delete callback of
    % 'BlockIsBeingDestroyed'.  This is a remnant of a very early
    % version of V2.0.  I've left this flag in for backward compat
    % with these models and some of our older tests.
    %
    currentScope = get_param(bdroot(scopeBlkH), 'FloatingScope');
    if ~strcmp(currentScope, '')
        if get_param(currentScope, 'Handle') == scopeBlkH,
            set_param(bdroot(scopeBlkH), 'FloatingScope', '');
        end
    end
    
    if ((scopeFig ~= INVALID_HANDLE ) && (ishandle(scopeFig)))
        delete(scopeFig);
    end
    
    %
    % Delete any signal selectors
    %
    signalselector('Delete', scopeBlkH);
    
case 'DeleteFcn',
    
    % HG Figure's deletefcn, called back by "delete(scopeFig)"
    %
    [scopeBlkH,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromFig;

     % why call the block now, it may be destroyed?
     set_param(scopeBlkH, 'Open', 'off', 'Figure', INVALID_HANDLE);
     if ishandle(scopeUserData.scopePropDlg)
         delete(scopeUserData.scopePropDlg);
     end
     scopeUserData.scopePropDlg = INVALID_HANDLE;
     
     Simulink.scopes.Util.DeleteAxesPropDlgs(scopeUserData);
     
     set(scopeFig, 'Visible', 'off');
    
case 'CloseReq',
    %
    % Figure's closerequestfcn.
    %
    [~,~,scopeUserData] = Simulink.scopes.Util.GetFromFig;
    set_param(scopeUserData.block, 'open', 'off');
    
case 'BlockClose',
    %
    % Close (hide) the figure (called from: set_param(block,'Open','off'))
    block = args{1};
    
    % Don't call GetFromBlock, block is being destroyed possibly
    fig = get_param(gcb, 'Figure');
  
    if ishandle(fig)     
        %
        % Delete the main scope properties dialog (if needed).
        %
        scopeUserData = get(handle(fig),'UserData');
        if ishandle(scopeUserData.scopePropDlg)
            delete(scopeUserData.scopePropDlg);
            scopeUserData.scopePropDlg = INVALID_HANDLE;
            set(fig, 'UserData', scopeUserData);
        end
        
        %
        % Delete any individual axes property dialogs.
        %
        Simulink.scopes.Util.DeleteAxesPropDlgs(scopeUserData);

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

    end
    
case 'BlockPreSave',
    %
    % block diagram has been saved.
    %
    [scopeBlk, scopeFig, ~] = Simulink.scopes.Util.GetFromBlock();
    %scopeBlk = gcb;
    
    %
    % Save windows position.
    %
    if ishandle(scopeFig)
        hgRect = get(handle(scopeFig), 'Position');
        set_param(scopeBlk, 'Location', rectconv(hgRect, 'simulink'));
    end

    %
    % We need to save the Selection Data again here, because 
    % a new file name will cause all the names of the selected
    % signals to change.  We should not need to update the
    % selected port handles in this case, because only the names changed.
    %
    
case 'SimTimeSpan',
    %
    % Public access to:
    %  Simulink.scopes.Util.ComputeSimulationTimeSpan(block, block_diagam, simStatus)
    %
    varargout = {Simulink.scopes.Util.ComputeSimulationTimeSpan(varargin{2:end})};
    
case 'BlockNameChange',
    %
    % Handle name change event.
    %   Name of block changed
    %   block diagram name change (save/save as)
    %   Subsystem name change
    %   etc
    %
    [scopeBlk,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromBlock;
  
    if ishandle(scopeFig)     
        %
        % Update scope name
        %
        blockName     = get_param(scopeBlk, 'Name');
        if Simulink.scopes.Util.IsModelBased(scopeBlk)
          windowTitle = viewertitle(scopeBlk, false);
        else
          floating  = onoff(get_param(scopeBlk,'Floating'));
          if floating,
            depSuffix = '';
          else
            %depSuffix = ' (Deprecated)';
            depSuffix = '';
          end
          
          windowTitle = [blockName depSuffix];
        end
    
        set(scopeFig, 'Name', windowTitle);
        block_diagram = bdroot(scopeUserData.block);
        if ~strcmp(block_diagram,scopeUserData.block_diagram)
            scopeUserData.block_diagram = block_diagram;
            set(scopeFig,'UserData',scopeUserData);
        end
        
        %
        % Update scope property dialog name
        %
        if ishandle(scopeUserData.scopePropDlg)
            scpprop('BlockNameChange', scopeUserData.scopePropDlg);
        end
        
        %
        % Update the names of any open axes property dialogs.
        %
        scopeAxes = scopeUserData.scopeAxes;
        nAxes     = length(scopeAxes);
        
        for i=1:nAxes,
            ax         = scopeAxes(i);
            axUserData = get(ax, 'UserData');
            
            if ishandle(axUserData.propDlg)
                axesIdxStr = sprintf('%d', i);
                dlgName    = Simulink.scopes.Util.GetAxesPropDlgName(ax, scopeBlk, axesIdxStr);
                set(axUserData.propDlg, 'Name', dlgName);
            end
        end
        
        %
        % Update current floating scope name if this is the one
        %
        formattedBlockPath = getfullname(scopeBlk);
        set_param(bdroot(scopeBlk), 'FloatingScope', formattedBlockPath);
    end
    
case 'PropDialogApply',
    scopeFig      = varargin{2};
    Simulink.scopes.Util.PropDialogApply(scopeFig);

case 'SetNewNumPorts'
    scopeBlk  = args{1};
    newNumber = args{2}; 
    Simulink.scopes.Util.SetNumPorts(scopeBlk, newNumber);
    
case 'AxesContextMenu',
    [~,scopeFig,scopeUserData] = Simulink.scopes.Util.GetFromFig;
    contextAxes   = get(handle(scopeFig), 'CurrentAxes');
    menuItem      = varargin{2};
    [modified, scopeUserData] = Simulink.scopes.Util.ManageContextMenuCB( ...
        scopeFig, scopeUserData, contextAxes, menuItem);
    if (modified)
        set(scopeFig, 'UserData', scopeUserData);
    end
    
case 'AxesPropDlg',
    dialogAction   = varargin{2};
    dialogFig      = varargin{3};
    axesIdx        = varargin{4};
    
    Simulink.scopes.Util.ManageAxesPropDlg(dialogAction, dialogFig, axesIdx);
    
case 'ScopeBar',
    buttonType    = varargin{2};
    buttonAction  = varargin{3};
    scopeFig      = varargin{4};
    
    Simulink.scopes.Util.ManageScopeBar( ...
        scopeFig, buttonType, buttonAction);

case 'Save'
    % Do nothing -- for backward compatibility.
    
case 'OverrideTRange',
  block = varargin{2};
  
  scopeFig = get_block_param(block, 'Figure');
  
  if ishandle(scopeFig) && onoff(get(handle(scopeFig),'Visible')),
      scopeUserData = get(handle(scopeFig),'UserData');
      [modified, scopeUserData] = Simulink.scopes.Util.UpdateAxesConfig(scopeFig, scopeUserData);
      if (modified)
          set(scopeFig, 'UserData', scopeUserData);
      end
  end

case 'PrintFigure'
    %This function was created for the Report Generator.  It creates
    %a button-free temporary print figure and returns the handle to
    %that figure.  The user must pass in a handle to the scope they
    %wish to print.
    
    scopeFig = varargin{2};
    scopeUserData=get(handle(scopeFig),'UserData');
    
    varargout{1} = Simulink.scopes.Util.CreatePrintFigure(scopeFig,scopeUserData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Signal Selector support below     %%
    %% API Definition for GET/ADD/REMOVE %%
    %% port selection for a block        %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
 case 'GetSelection'
    BlockHandle = args{1};
    AxesNumber  = args{2};
    floating    = onoff(get_block_param(BlockHandle,'Floating'));
    
    if ~floating,
      %
      % Call into Signal & Scope Manager to get default behavior
      %
      selection = sigandscopemgr(Action,BlockHandle,AxesNumber);
      varargout{1} = selection;      
    else
%      varargout{1} = Simulink.scopes.Util.GetSelection(BlockHandle, AxesNumber);
      selection = sigandscopemgr(Action,BlockHandle,AxesNumber);
      varargout{1} = selection;      
    end
 
 case 'AddSelection'
    BlockHandle = args{1};
    AxesNumber  = args{2};
    addSel      = args{3};
    floating    = onoff(get_block_param(BlockHandle,'Floating'));

    %
    % Call into Signal & Scope Manager to get default behavior
    %
    if ~floating,
      sigandscopemgr(Action,BlockHandle,AxesNumber,addSel);
    else
      Simulink.scopes.Util.AddSelection(BlockHandle, AxesNumber, args{3});
    end
    
 case 'RemoveSelection'
  BlockHandle = args{1};
  AxesNumber  = args{2};
  remSel      = args{3};
  floating    = onoff(get_block_param(BlockHandle,'Floating'));
  
  %
  % Call into Signal & Scope Manager to get default behavior
  %
  if ~floating,
    sigandscopemgr(Action,BlockHandle,AxesNumber,remSel);
  else
    Simulink.scopes.Util.RemoveSelection(BlockHandle, AxesNumber, remSel);
  end
  
 case 'SwitchSelection'
  BlockHandle = args{1};
  AxesNumber  = args{2};
  oldSel      = args{3};
  newSel      = args{4};
  floating    = onoff(get_block_param(BlockHandle,'Floating'));
  
  %
  % Call into Signal & Scope Manager to get default behavior
  %
  if ~floating,
    sigandscopemgr(Action,BlockHandle,AxesNumber,oldSel,newSel);
  else
    % xxx I don't think that this gets called for the hardwired 
    % xxx scope..should never get here
    DAStudio.warning('Simulink:blocks:UnexpectedCodePath');
    Simulink.scopes.Util.SwitchSelection(BlockHandle, AxesNumber, args{3}, args{4});    
  end
  
 case 'DialogClosing'
    BlockHandle = args{1};
    Simulink.scopes.Util.DialogClosing(BlockHandle);

    %
    % HD HG2 Update time offset text
    %
    %  case 'UpdateTimeOffset'
    %BlockHandle = args{1};
    %offset = args{2}; % HD ??
    %[~, ~, scopeUserData] = Simulink.scopes.Util.GetFromFig
    %Simulink.scopes.Util.InitTickOffset(scopeUserData,offset);
    %
otherwise,
    %
    % Default action.
    %
  DAStudio.error('Simulink:blocks:InvalidAction', Action);
end
end %simscope


% Function: INVALID_HANDLE ====================================================
% Abstract:
%    A method to generate an invalid handle that appears "static" to this file.
%
function h = INVALID_HANDLE
    h = (-1);
end

% Function get_block_param ===================================================
% Abstract:
%    Single entry point to C++ block code
function p = get_block_param(block, param)
    p = get_param(block,param);
end
