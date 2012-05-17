function trackpz(Editor,event)
%TRACKPZ  Tracks compensator pole or zero during mouse drag.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.31.4.4 $  $Date: 2009/05/23 07:53:23 $

persistent MovedGroup PZID Ts TransAction
persistent AutoScaleOn

LoopData = Editor.LoopData;
C = Editor.EditedBlock;
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;

% Process event
switch event 
   
case 'init'
   % Initialization for compensator pole/zero drag
   % Identify selected root 
   [MovedGroup,PZID,Y] = LocalGetSelection(gcbo);
   C = MovedGroup.Parent;
   Editor.setEditedBlock(C);
   Ts = LoopData.Ts;
   
   % Initialize parameters used to adjust limits/pointer position
   AutoScaleOn = ...
      strcmp(Editor.Axes.XlimMode,'auto') & strcmp(Editor.Axes.YlimMode,'auto');
   if AutoScaleOn,
      moveptr(PlotAxes,'init');
   end
   
   % Track root location in status bar 
   EventMgr.poststatus(LocalTrackStatus(MovedGroup,PZID,Ts,Y,Editor.FrequencyUnits));
   
   % Broadcast MOVEPZ:init event
   % RE: Sets RefreshMode='quick' and installs listeners on Pole/Zero property of selected group
   LoopData.EventData.Component = C;
   LoopData.EventData.Phase = 'init';
   LoopData.EventData.Extra = MovedGroup;
   LoopData.send('MovePZ')
   
   % Start transaction
   TransAction = ctrluis.transaction(LoopData,'Name',sprintf('Move %s',PZID),...
      'OperationStore','on','InverseOperationStore','on','Compression','on');
   
case 'acquire'
   % Acquire new pole/zero position 
   try
       CP = get(PlotAxes,'CurrentPoint');
       % Clear data dependent on modified compensator
       %    LoopData.reset('root',C);
       
       % Get current value
       curval = MovedGroup.getValue(1);
       
       % Update data of moved PZGROUP
       NewLoc = Editor.movepz(MovedGroup,PZID,CP(1,1),CP(1,2),Ts);
       LoopData.reset('root',C);

   catch ME
       % Update Failed revert back to previous value
       MovedGroup.setValue(curval,1)
       LoopData.reset('root',C);
   end
   
   % Broadcast PZDataChanged event (triggers plot updates)
   MovedGroup.send('PZDataChanged');
   
   % Track root location in status bar 
   EventMgr.poststatus(LocalTrackStatus(MovedGroup,PZID,Ts,CP(1,2),Editor.FrequencyUnits));
   
   % Adjust axis limits if dragged pole/zero gets out of focus
   if AutoScaleOn,
      MovePtr = Editor.reframe(PlotAxes,'xy',CP(1,1),CP(1,2));
      if MovePtr
         moveptr(PlotAxes,'move',real(NewLoc(1)),imag(NewLoc(1)))
      end
   end
   
case 'finish'
   % Button up event. Commit and stack transaction
   EventMgr.record(TransAction);
   TransAction = [];   % release persistent objects
   
   % Broadcast MOVEPZ:finish event (exit RefreshMode=quick,...)  
   LoopData.EventData.Phase = 'finish';
   LoopData.send('MovePZ')
   
   % Update status and command history
   Str = MovedGroup.movelog(PZID,Ts);
   EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
   EventMgr.recordtxt('history',Str);
   MovedGroup = [];
   
   % Trigger global update
   LoopData.dataevent('all');
   
end


%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%
% LocalGetSelection %
%%%%%%%%%%%%%%%%%%%%%
function [MovedGroup,PZID,Y] = LocalGetSelection(CurrentObj)
% Identifies selected PZGROUP object (pole/zero group)

% Moved PZVIEW object
MovedPZVIEW = getappdata(CurrentObj,'PZVIEW');
if any(MovedPZVIEW.Zero==CurrentObj)
   PZID = 'Zero';
else
   PZID = 'Pole';
end

% Moved PZGROUP
MovedGroup = MovedPZVIEW.GroupData;
Y = get(CurrentObj,'Ydata');


%%%%%%%%%%%%%%%%%%%%
% LocalTrackStatus %
%%%%%%%%%%%%%%%%%%%%
function Status = LocalTrackStatus(Group,PZID,Ts,Y,FreqUnits)
% Display info about moved pole/zero

% Defs
Spacing = blanks(5);

switch Group.Type
case 'Notch'
   % Custom display for notch filters
   Text = sprintf('Drag this %s to alter the notch location/shape.',...
      lower(PZID));
   [Wn,Zeta] = damp([Group.Zero(1);Group.Pole(1)],Ts);
   Wn = unitconv(Wn,'rad/sec',FreqUnits);
   Status = ...
      sprintf('%s\nNatural Frequency: %0.3g %s%sZero Damping: %0.3g%sPole Damping: %0.3g',...
      Text,Wn(1),FreqUnits,Spacing,Zeta(1),Spacing,Zeta(2));
   
case 'Complex'
   % Complex pair
   Text = sprintf('Drag this %s to the desired location.',lower(PZID));
   R = get(Group,PZID);
   if Y>=0,
      R = R(1); Sign = '+';
   else
      R = R(2); Sign = '-';
   end
   [Wn,Zeta] = damp(R,Ts);
   Wn = unitconv(Wn,'rad/sec',FreqUnits);
   Status = ...
      sprintf('%s\nCurrent location: %0.3g %s %0.3gi%sDamping: %0.3g%sNatural Frequency: %0.3g %s',...
      Text,real(R),Sign,abs(imag(R)),Spacing,Zeta,Spacing,Wn,FreqUnits);
   
otherwise
   % Real pole/zero
   Text = sprintf('Drag this %s to the desired location.',lower(PZID));
   R = get(Group,PZID);
   if Ts
      Wn = unitconv(damp(R,Ts),'rad/sec',FreqUnits);
      Status = sprintf('%s\nCurrent location: %0.3g%sNatural Frequency: %0.3g %s',...
         Text,R,Spacing,Wn,FreqUnits);
   else
      Status = sprintf('%s\nCurrent location: %0.3g',Text,R);
   end
end



