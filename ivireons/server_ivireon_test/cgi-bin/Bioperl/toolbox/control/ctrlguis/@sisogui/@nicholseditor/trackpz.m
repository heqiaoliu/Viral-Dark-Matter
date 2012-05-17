function trackpz(Editor, event)
% Tracks compensator pole or zero during mouse drag.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.31.4.6 $  $Date: 2007/11/09 19:48:28 $

persistent MovedGroup PZID G0
persistent AutoScaleX AutoScaleY InvalidMove
persistent hline % Pole/zero locus curve
persistent TransAction

% Handles
LoopData   = Editor.LoopData;
C = getC(Editor);
if ~isempty(C);
    Ts = C.Ts;
end

Axes = Editor.Axes;
PlotAxes = getaxes(Axes);
PhaseUnits = Axes.XUnits;
EventMgr   = Editor.EventManager;

% INIT event
switch event
   case 'init'
      % Initialization for compensator pole/zero drag
      % Identify selected marker and selected root properties
      [MovedGroup, PZID, G0] = LocalGetSelection(gcbo);
      C = MovedGroup.Parent;
      Editor.setEditedBlock(C);
      Ts = Editor.EditedBlock.Ts;
      
      if Ts && MovedGroup.beyondnf(PZID, 0.1)
         % Discrete roots beyond Nyquist freq. cannot be moved
         EventMgr.poststatus(sprintf(['Cannot move roots with natural', ...
               'frequency beyond the Nyquist frequency.\n', ...
               'Use the Root Locus Editor to move such poles/zeros.']));
         InvalidMove = 1;
         return
      else
         InvalidMove = 0;
      end
      
      % Initialize parameters used to adjust limits and pointer position
      AutoScaleX = strcmp(Axes.XlimMode, 'auto');
      AutoScaleY = strcmp(Axes.YlimMode, 'auto');
      if (AutoScaleX || AutoScaleY),
         moveptr(PlotAxes,'init');
      end
      
      % Create pole/zero locus curve
      hline = line([1 1], [NaN NaN], ...
         'parent',    PlotAxes, ...
         'HitTest',   'off', ...
         'EraseMode', 'xor', ...
         'Visible',   get(PlotAxes, 'Visible'), ...
         'Color',     Editor.LineStyle.Color.Compensator, ...
         'LineStyle', '--');
      
      % Track root location in status bar 
      EventMgr.poststatus(...
         LocalTrackStatus(MovedGroup, PZID, Ts, Editor.FrequencyUnits));
      
      % Broadcast MOVEPZ:init event
      % REMARK: Sets RefreshMode = 'quick' and installs listeners
      % on Pole/Zero property of selected group
      LoopData.EventData.Component = C;
      LoopData.EventData.Phase = 'init';
      LoopData.EventData.Extra = MovedGroup;
      LoopData.send('MovePZ')
      
      % Start transaction
      TransAction = ctrluis.transaction(LoopData, ...
         'Name', sprintf('Move %s', PZID), 'OperationStore', 'on', ...
         'InverseOperationStore', 'on', 'Compression', 'on');
      
      % Start plotting the tracking curve
      Editor.trackpz('acquire');
      
   case 'acquire'
      % Acquire new pole/zero position. 
      if ~InvalidMove
         CP = get(PlotAxes, 'CurrentPoint');
         
         % Convert mouse coordinates to default units
         X = unitconv(CP(1,1), PhaseUnits, 'rad'); 
         Y = 10^(CP(1,2)/20);
         
         % Clear data dependent on modified compensator
         LoopData.reset('root',C);
         
         % Inputs to MOVEPZ must be in (rad/sec, abs, rad)
         [X,Y] = movepz(Editor, MovedGroup, PZID, G0, X, Y, hline);
         
         % Convert back to current units
         X = unitconv(X, 'rad', PhaseUnits);
         Y = mag2db(Y);
         
         % Broadcast PZDataChanged event (triggers plot updates)
         MovedGroup.send('PZDataChanged');
         
         % Track root location in status bar 
         EventMgr.poststatus(...
            LocalTrackStatus(MovedGroup, PZID, Ts, Editor.FrequencyUnits));
         
         % Adjust axis limits if dragged pole/zero gets out of focus
         if AutoScaleX || AutoScaleY,
            % Adjust limits to track mouse motion
            MovePtr = Editor.reframe(PlotAxes,'xy',X,Y);
            if MovePtr
               % Reposition mouse pointer 
               moveptr(PlotAxes,'move',X,Y);
            end
         end
      end
      
   case 'finish'
      % Delete locus curve
      if ~InvalidMove
         delete(hline(ishandle(hline)));
         
         % Button up event.  Commit and stack transaction
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
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalGetSelection
% Purpose:  Identifies selected PZGROUP object (pole/zero group)
% ----------------------------------------------------------------------------%
function [MovedGroup, PZID, G0] = LocalGetSelection(CurrentObj)
% Moved PZVIEW object
MovedPZVIEW = getappdata(CurrentObj, 'PZVIEW');

if any(MovedPZVIEW.Zero == CurrentObj)
   PZID = 'Zero';
else
   PZID = 'Pole';
end

% Moved PZGROUP
MovedGroup = MovedPZVIEW.GroupData; % pointer to pole/zero values (dynamic)
%G0 = get(MovedGroup);               % initial pole/zero values (fixed)
G0 = getTypeZeroPole(MovedGroup);  % initial pole/zero values (fixed)


% ----------------------------------------------------------------------------%
% Function: LocalTrackStatus
% Display info about moved pole/zero
% ----------------------------------------------------------------------------%
function Status = LocalTrackStatus(PZGroup, PZID, Ts, FreqUnits)
% Definitions
Spacing = blanks(4);

switch PZGroup.Type
   case 'Notch'
      % Custom display for notch filters
      Text = sprintf('Drag this notch to adjust its depth and natural frequency.');
      [Wn, Zeta] = damp([PZGroup.Zero(1) ; PZGroup.Pole(1)], Ts);
      Wn = unitconv(Wn, 'rad/sec', FreqUnits);
      Damping = sprintf('Zero Damping: %0.3g%s Pole Damping: %0.3g', ...
         Zeta(1), Spacing, Zeta(2));
      Status = sprintf('%s\nNatural Frequency: %0.3g %s%s%s', ...
         Text, Wn(1), FreqUnits, Spacing, Damping);
      
   case 'Complex'
      % Complex pair
      Text = sprintf('Drag this %s to the desired location.', lower(PZID));
      R = get(PZGroup, PZID);
      R = R(1);
      [Wn, Zeta] = damp(R, Ts);
      Wn = unitconv(Wn, 'rad/sec', FreqUnits);
      Damping = sprintf('Damping: %0.3g%s Natural Frequency: %0.3g %s', ...
         Zeta, Spacing, Wn, FreqUnits);
      Status = sprintf('%s\nCurrent location: %0.3g %s %0.3gi %s%s',...
         Text, real(R), '+/-', abs(imag(R)), Spacing, Damping);
      
   otherwise
      % Real pole/zero
      Text = sprintf('Drag this %s to the desired location.', lower(PZID));
      R = get(PZGroup, PZID);
      if Ts
         Wn = unitconv(damp(R, Ts), 'rad/sec', FreqUnits);
         NatFreq = sprintf('Natural Frequency: %0.3g %s', Wn, FreqUnits);
         Status = sprintf('%s\nCurrent location: %0.3g %s%s', ...
            Text, R, Spacing, NatFreq);
      else
         Status = sprintf('%s\nCurrent location: %0.3g', Text, R);
      end
end
