function addlisteners(sisodb)
%ADDLISTENERS  Add GUI-wide listeners.

%   Author: P. Gahinet  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.17.4.4 $  $Date: 2009/05/23 07:53:27 $
HG = sisodb.HG;
LoopData = sisodb.LoopData;
PlotEditors = sisodb.PlotEditors;

% Listeners to @sisotool properties
Listeners = handle.listener(sisodb,sisodb.findprop('GlobalMode'),...
    'PropertyPostSet',@GlobalModeChanged);

% Listeners to @loopdata properties
%   1) FirstImport: side effects of first import
%   2) Name: update figure name
Listeners = [Listeners ; ...
      handle.listener(LoopData,'FirstImport',@activate) ; ...
      handle.listener(LoopData,'SingularInnerLoop',@LocalAlgLoopWarning) ; ...
      handle.listener(LoopData,LoopData.findprop('Name'),...
      'PropertyPostSet',@SystemNameCB); ...
      handle.listener(LoopData,'ConfigChanged',@LocalConfigChanged)];

% Listeners to editor properties and events
Listeners = [Listeners ; ...
      handle.listener(sisodb,sisodb.findprop('PlotEditors'),...
      'PropertyPostSet',@NewEditorsCB)];
  

% Target listener callbacks
set(Listeners,'CallbackTarget',sisodb)

% Make listeners persistent
sisodb.Listeners = Listeners;


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%
%%% SystemNameCB %%%
%%%%%%%%%%%%%%%%%%%%
function SystemNameCB(sisodb,eventdata)
% Side-effects of first import
% Update figure title
set(sisodb.Figure,'Name',sprintf('SISO Design for %s',eventdata.NewValue));


%%%%%%%%%%%%%%%%%%%%
%%% NewEditorsCB %%%
%%%%%%%%%%%%%%%%%%%%
function NewEditorsCB(sisodb,eventdata)
% Callback for PlotEditors change
% Update editor listeners
addEditorListeners(sisodb)
% Update tooldlg's container list
sisodb.TextEditors(2).ContainerList = eventdata.NewValue;


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GlobalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function GlobalModeChanged(sisodb,event)
% Called when GlobalMode is changed
if strcmp(event.NewValue,'off') && ~isoff(sisodb)
    % Revert to idle mode locally
    set(sisodb.PlotEditors,'EditMode','idle');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAlgLoopWarning %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAlgLoopWarning(sisodb,event)
% Called when inner loop is singular
if ~isoff(sisodb) && all(strcmp(get(sisodb.PlotEditors,'RefreshMode'),'normal'))
   % Issue warning
   warndlg('Algebraic loop in inner loop G-H-F.','SISO Tool Warning','modal')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalConfigChanged  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalConfigChanged(this,event)

% Update Pade approximation of configuration change
if this.Preferences.PadeOrderSelectionData.UseBandwidth
    this.Preferences.PadeOrder = utComputePadeOrder(this, ...
        this.Preferences.PadeOrderSelectionData.Bandwidth);
end

% Determine if any compensator is feedback or feedforward
hasfb = hasFeedback(this.LoopData);

% Hide editors whose target's nature has changed (feedback vs. feedforward)
if ~isempty(this.PlotEditors)
   Editors = find(this.PlotEditors,'Visible','on');
   for ct=1:length(Editors)
      isff = isa(Editors(ct),'sisogui.bodeditorF');
      idxL = Editors(ct).EditedLoop;
      if idxL>length(hasfb) || xor(isff,~hasfb(idxL))
         Editors(ct).Visible = 'off';
         Editors(ct).EditedLoop = -1; % detarget editor
      end
   end
end
