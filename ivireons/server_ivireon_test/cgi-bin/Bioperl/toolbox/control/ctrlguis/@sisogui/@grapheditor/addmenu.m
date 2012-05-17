function h = addmenu(Editor,Anchor,MenuType)
%ADDMENU  Creates generic editor context menus.
% 
%   H = ADDMENU(EDITOR,ANCHOR,MENUTYPE) creates a menu item, related
%   submenus, and associated listeners.  The menu is attached to the 
%   parent object with handle ANCHOR.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.38.4.10 $ $Date: 2010/05/10 16:59:17 $

switch MenuType
   
   case 'add'
      % Add Pole/Zero menu
      LoopData = Editor.LoopData;
      h = uimenu(Anchor,'Label',sprintf('Add Pole/Zero'));
      uimenu(h,'Label',sprintf('Real Pole'),...
         'Callback',{@LocalAddPZ Editor 'Real' 'Pole'},...
         'Tag','AddRealPole');
      uimenu(h,'Label',sprintf('Complex Pole'),...
         'Callback',{@LocalAddPZ Editor 'Complex' 'Pole'},...
         'Tag','AddComplexPole');
      uimenu(h,'Label',sprintf('Integrator'),...
         'Callback',{@LocalAddInt Editor},...
         'Tag','AddIntegrator');
      uimenu(h,'Label',sprintf('Real Zero'),...
         'Callback',{@LocalAddPZ Editor 'Real' 'Zero'}, ...
         'Separator','on',...
         'Tag','AddRealZero');
      uimenu(h,'Label',sprintf('Complex Zero'),...
         'Callback',{@LocalAddPZ Editor 'Complex' 'Zero'},...
         'Tag','AddComplexZero');
      uimenu(h,'Label',sprintf('Differentiator'),...
         'Callback',{@LocalAddDiff Editor},...
         'Tag','AddDifferentiator');
      uimenu(h,'Label',sprintf('Lead'),...
         'Callback',{@LocalAddPZ Editor 'Lead' ''}, ...
         'Separator','on',...
         'Tag','AddLead');
      uimenu(h,'Label',sprintf('Lag'),...
         'Callback',{@LocalAddPZ Editor 'Lag' ''},...
         'Tag','AddLag');
      uimenu(h,'Label',sprintf('Notch'),...
         'Callback',{@LocalAddPZ Editor 'Notch' ''},...
         'Tag','AddNotch');
      
      % Add listeners to edit mode changes
      lsnr = handle.listener(Editor,findprop(Editor,'EditMode'),...
         'PropertyPostSet',{@LocalModeChanged 'add' h});
      set(h,'UserData',lsnr)  % Anchor listeners for persistency
      
   case 'constraint'
      % Constraints menu
      if usejava('MWT'),
         h = uimenu(Anchor, 'Label', sprintf('Design Requirements'), ...
            'Tag','DesignRequirement');
         % Constraint submenus          
         hs1 = uimenu(h, 'Label', sprintf('New...'), ...      
            'Callback', {@LocalDesignConstr Editor 'new'}, ...   
            'Tag','NewRequirement');
         hs2 = uimenu(h, 'Label', sprintf('Edit...'), ...     
            'Callback', {@LocalDesignConstr Editor 'edit'}, ...
            'Tag','EditRequirement');
         %Hide menu if view does not support requirements
         if isempty(Editor.newconstr)
            set(h,'Visible','off')
         else
            set(h,'Visible','on');
         end
      else
         h = [];
      end
      
   case 'delete'
      % Delete Pole/Zero menu
      h = uimenu(Anchor,'Label',sprintf('Delete Pole/Zero'), ...
         'Callback',{@LocalDeletePZ Editor});
      
      % Add listeners to edit mode changes
      lsnr = handle.listener(Editor,findprop(Editor,'EditMode'),...
         'PropertyPostSet',{@LocalModeChanged 'delete' h});
      set(h,'UserData',lsnr)  % Anchor listeners for persistency
      
   case 'edit'
      % Edit Compensator
      h = uimenu(Anchor,'Label',...
         sprintf('Edit Compensator...'),'Callback',{@LocalShowEditor Editor});
      
   case 'grid'
      % Grid
      h = uimenu(Anchor,'Label',sprintf('Grid'),'Callback',{@LocalSetGrid Editor});
      L = handle.listener(Editor.Axes,findprop(Editor.Axes,'Grid'),...
         'PropertyPostSet',{@GridMenuState h});
      % Anchor listeners for persistency
      set(h,'UserData',L)
      
   case 'property'
      % Properties
      h = uimenu(Anchor,'Label',sprintf('Properties...'),...
         'Callback',{@LocalOpenEditor Editor});
      
   case 'snapshot'
      % Show menu
      h = uimenu(Anchor,'Label',sprintf('Design Snapshots'));
      
   case 'show'
      % Show menu
      h = uimenu(Anchor,'Label',sprintf('Show'));
      
    case 'multiplemodel'
        % Show menu
        h = uimenu(Anchor,'Label', ...
            ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDisplay'),...
            'Tag','multiplemodel');
      
   case 'zoom'
      % Zoom
      hout = uimenu(Anchor,'label',sprintf('Full View'),'Enable','off',...
          'Callback',{@LocalZoomOut Editor});
      
      % Add listener to enable/disable full view menu
      p = [Editor.Axes.findprop('XlimMode');Editor.Axes.findprop('YlimMode')];
      L2 = handle.listener(Editor.Axes,p,'PropertyPostSet',{@LocalZoomOutEnable Editor hout});
      set(hout,'UserData',L2)  % Anchor listeners for persistency
      
    case 'Compensator'
        % Closed loop bode compensator selector
        h = uimenu(Anchor,'Label',sprintf('Select Compensator'));
        LocalUpdataCompensatorTargetMenu([],[],Editor,h)
        set(h,'UserData', ...
            [handle.listener(Editor.LoopData,'ConfigChanged', ...
            {@LocalUpdataCompensatorTargetMenu Editor h}); ...
            handle.listener(Editor,Editor.findprop('EditedLoop'),'PropertyPostSet', ...
            {@LocalUpdataCompensatorTargetMenu Editor h})]);
    
    case 'GainTarget'
        % Target for which compensator gain should be modified during
        % graphical drags
        h = uimenu(Anchor,'Label',sprintf('Gain Target'));
        LocalUpdataGainTargetMenu([],[],Editor, h)
        set(h,'UserData', ...
            [handle.listener(Editor.LoopData,'ConfigChanged', ...
            {@LocalUpdataGainTargetMenu Editor h}); ...
            handle.listener(Editor,Editor.findprop('EditedLoop'),'PropertyPostSet', ...
            {@LocalUpdataGainTargetMenu Editor h})]);
end


%----------------------------- Listener callbacks ----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModeChanged(hProp,event,MenuMode,hMenu)
% Update state of right-click menu (check mark)
event.AffectedObject.checkmenu(MenuMode,hMenu);


%%%%%%%%%%%%%%%%%%%%%
%%% GridMenuState %%%
%%%%%%%%%%%%%%%%%%%%%
function GridMenuState(hProp,event,hMenu)
% Updates grid menu state
set(hMenu,'Checked',event.NewValue)


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalZoomOutEnable %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalZoomOutEnable(hProp,event,Editor,hZoomOut)
% Disable Zoom:Out menu when XlimMode=YlimMode=auto
if strcmp(Editor.Axes.XlimMode,'auto') && all(strcmp(Editor.Axes.YlimMode,'auto'))
   set(hZoomOut,'Enable','off')
else
   set(hZoomOut,'Enable','on')
end


%----------------------------- Callback actions ----------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalAddInt %%%
%%%%%%%%%%%%%%%%%%%
function LocalAddInt(hSrc,event,Editor)
% Add integrator
LoopData = Editor.LoopData;
EventMgr = Editor.EventManager;

% Return to idle (aborts global modes)
Editor.EditMode = 'idle';

% Add integrator
if LoopData.Ts ~= 0,
   intvalue = 1;
else
   intvalue = 0;
end

% Determine which Compensator to add PZGroup to
C = addPZDialog(Editor, 'Real', 'Pole');

if isempty(C)
    % No valid compensators to add pzgroup to
    return
end

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Add Integrator',...
   'OperationStore','on','InverseOperationStore','on');

C.addPZ('Real',zeros(0,1),(intvalue));

% Register transaction 
EventMgr.record(T);

% Notify of loop data change
LoopData.dataevent('all');

% Update status and history
Status = sprintf('Added an integrator to the %s.',C.describe(false));
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%%%
%%% LocalAddDiff %%%
%%%%%%%%%%%%%%%%%%%%
function LocalAddDiff(hSrc,event,Editor)
% Add differentiator
LoopData = Editor.LoopData;
EventMgr = Editor.EventManager;

% Return to idle (aborts global modes)
Editor.EditMode = 'idle';


% Add differentiator
if LoopData.Ts ~= 0,
   difvalue = 1;
else
   difvalue = 0;
end

% Determine which Compensator to add PZGroup to
C = addPZDialog(Editor, 'Real', 'Zero');

if isempty(C)
    % No valid compensators to add pzgroup to
    return
end

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Add Differentiator',...
   'OperationStore','on','InverseOperationStore','on');


C.addPZ('Real',(difvalue),zeros(0,1));

% Register transaction 
EventMgr.record(T);

% Notify of loop data change
LoopData.dataevent('all');

% Update status and history
Status = sprintf('Added a differentiator to the %s.',C.describe(false));
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%
%%% LocalAddPZ %%%
%%%%%%%%%%%%%%%%%%
function LocalAddPZ(hSrc,event,Editor,Type,ID)
% Starts Add Pole/Zero operation (hSrc = submenu handle)

AddInfo = struct('Root',ID,'Group',Type); 

% Exiting Add mode? (unchecking menu)
ExitingMode = strcmp(Editor.EditMode,'addpz') & ...
   isequal(Editor.EditModeData,AddInfo);

% Return to idle (properly resets menu and pointer when switching mode, aborts global modes)
Editor.EditMode = 'idle';  

% Enter 'addpz' mode
if ~ExitingMode
   % RE: Updating EditMode triggers menu update and resets pointer
   Editor.EditModeData = AddInfo;
   Editor.EditMode = 'addpz';    
   % Evaluate WBM function once to set correct pointer
   Editor.mouseevent('wbm');
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalDeletePZ %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalDeletePZ(hSrc,event,Editor)
% Starts Delete Pole/Zero operation

% Exiting Delete mode? (unchecking menu)
ExitingMode = strcmp(Editor.EditMode,'deletepz');

% Return to idle (properly resets menu and pointer when switching mode, aborts global modes)
Editor.EditMode = 'idle';  

% Enter 'deletepz' mode
if ~ExitingMode
   % Enter 'delete' mode (triggers menu update and resets pointer)
   Editor.EditMode = 'deletepz';  
   % Evaluate WBM function once to set correct pointer
   Editor.mouseevent('wbm');
end    


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDesignConstr %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDesignConstr(hSrc, event, Editor, ActionType)
% Opens dialogs to add/edit design constraints
switch ActionType
   case 'new'
      % Add new constraint
      editconstr.newdlg.getInstance(Editor, Editor.Axes.Parent);
   case 'edit'
      % Edit constraints in editor if there are constraints to edit.
      if isempty(Editor.findconstr)
         % No constraints to show in this Editor
         warnStr = sprintf('There are no design requirements to edit.');
         warndlg(warnStr,sprintf('Edit Warning'));
      else
         % Point constraint editor to this Editor
         Editor.ConstraintEditor.show(Editor);
      end
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowEditor %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowEditor(hSrc,event,Editor)
% Bring up PZ editor
Editor.TextEditor.show(Editor.LoopData.C,1);


%%%%%%%%%%%%%%%%%%%%
%%% LocalZoomOut %%%
%%%%%%%%%%%%%%%%%%%%
function LocalZoomOut(hSrc,event,Editor)
% Zoom out callback (hSrc = submenu handle)
Editor.zoomout;


%%%%%%%%%%%%%%%%%%%%
%%% LocalSetGrid %%%
%%%%%%%%%%%%%%%%%%%%
function LocalSetGrid(hSrc,event,Editor)
% Grid menu callback (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
   Editor.Axes.Grid = 'off';
else
   Editor.Axes.Grid = 'on';
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenEditor %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalOpenEditor(hSrc,event,Editor)
% Properties menu callback (hSrc = menu handle)
PropEdit = PropEditor(Editor);
PropEdit.setTarget(Editor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetTunedFactor %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetTunedFactor(hSrc,event,Editor, C)

set(hSrc,'Checked','on');
items = get(get(hSrc,'Parent'),'Children');
set(items(find(hSrc~= items)),'Checked','off');

Editor.LoopData.L(Editor.EditedLoop).TunedFactor = C;
Editor.setEditedBlock(C);
Editor.GainTargetBlock = C;
Editor.LoopData.dataevent('all')


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetGainTarget  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetGainTarget(hSrc,event,Editor, C)

set(hSrc,'Checked','on');
items = get(get(hSrc,'Parent'),'Children');
set(items(find(hSrc~= items)),'Checked','off');

Editor.GainTargetBlock = C;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdataGainTargetMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdataGainTargetMenu(hSrc,event,Editor,h)


ValidIdx = [];

if ~isequal(Editor.EditedLoop,-1) % update only if editor has an edited loop 
    % Find list of valid compensators
    TunedFactors = Editor.LoopData.L(Editor.EditedLoop).TunedFactors;
    for ct = 1:length(TunedFactors)
        if TunedFactors(ct).utIsGainTunable;
            ValidIdx = [ValidIdx; ct];
        end
    end

    nC = max(length(ValidIdx),1);

    SubMenus = flipud(get(h,'Children')); %SubMenus(:,:) = [];
    if length(SubMenus)<nC
        % Add submenus
        for ct=length(SubMenus):nC
            uimenu('Parent',h);
        end
        SubMenus = flipud(get(h,'Children')); %SubMenus(1,:) = [];
    end

    if ~isempty(ValidIdx)
        ischecked = false;
        for ct = 1:length(ValidIdx)
            C = TunedFactors(ValidIdx(ct));
            set(SubMenus(ct),'Label',sprintf('%s(%s)',C.Name,C.Identifier),...
                'Callback',{@LocalSetGainTarget Editor C});
            if Editor.GainTargetBlock == C
                set(SubMenus(ct),'Checked','on');
                ischecked = true;
            else 
                set(SubMenus(ct),'Checked','off');
            end
        end
        if ~ischecked
            set(SubMenus(1),'Checked','on');
        end
    else
        set(SubMenus(1),'Label',sprintf('Loop gain is not tunable in current configuration.'),...
            'Callback','','Checked','off');
    end

    % Adjust visibility and labels
    for ct=1:nC
        set(SubMenus(ct),'Visible','on')
    end
    for ct=nC+1:length(SubMenus)
        set(SubMenus(ct),'Visible','off')
    end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdataCompensatorTargetMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdataCompensatorTargetMenu(hSrc,event,Editor,h)

if ~isequal(Editor.EditedLoop,-1) % update only if editor has an edited loop
    % Clear submenus
    ch = get(h,'children');
    delete(ch(ishandle(ch)));
    set(h,'children',[]);
    % Update menus
    C = Editor.LoopData.C;
    for idx = 1:length(C)
        if isa(C(idx),'sisodata.TunedZPK');
            tmpmenu = uimenu(h,'Label',sprintf('%s(%s)',C(idx).Name,C(idx).Identifier),...
                'Callback',{@LocalSetTunedFactor Editor C(idx)});
            if Editor.LoopData.L(Editor.EditedLoop).TunedFactor == C(idx)
                set(tmpmenu,'Checked','on');
            end
        end
    end
end