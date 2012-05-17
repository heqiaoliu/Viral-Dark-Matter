function trackgain(Editor,action)
%TRACKGAIN  Keeps track of gain value while dragging mag curve.
%
%   See also SISOTOOL

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.38.4.5 $  $Date: 2006/06/20 20:02:31 $
persistent FreqData TransAction AbsLinMag AutoY

LoopData = Editor.LoopData;
C = Editor.GainTargetBlock; % edited compensator
Editor.setEditedBlock(C);
MagAx = getaxes(Editor.Axes);  MagAx = MagAx(1);
MagUnits = Editor.Axes.YUnits{1};
EventMgr = Editor.EventManager;

% Process ACTION
switch action 
   
case 'init'
   % Initialize persistent
   FreqData = unitconv(Editor.Frequency,'rad/sec',Editor.Axes.XUnits);
   AbsLinMag = strcmp(MagUnits,'abs') && strcmp(get(MagAx,'Yscale'),'linear');
   
   % Initialize parameters used to adjust mag limits
   AutoY = strcmp(Editor.Axes.YlimMode{1},'auto');
   if AutoY
      % Initialize pointer motion control
      moveptr(MagAx,'init');
   end
   
   % Broadcast MOVEGAIN:init event
   % RE: Sets RefreshMode='quick' and attaches listener to Gain data changes
   LoopData.EventData.Component = C;
   LoopData.EventData.Phase = 'init';
   LoopData.EventData.Editor = Editor;
   LoopData.send('MoveGain')
   EventMgr.poststatus(...
      sprintf('Drag the magnitude curve up or down to change the gain of %s.',lower(C.Name)));
   
   % Start transaction
   TransAction = ctrluis.transaction(LoopData,'Name','Edit Gain',...
      'OperationStore','on','InverseOperationStore','on','Compression','on');
   
case 'acquire'
   % Clear dependent information
   LoopData.reset('gain',C)
   
   % Acquire new gain value during drag.
   % RE: Restrict X position to be in freq. data range 
   CP = get(MagAx,'CurrentPoint');
   X = max(FreqData(1),min(CP(1,1),FreqData(end)));
   Y = CP(1,2);
   if AbsLinMag
      Ylim = get(MagAx,'Ylim');
      Y = max(1e-3*Ylim(2),Y);
   end
   
   % Get new gain value (interpolate in plot units to limit distorsions)
   NewGain = unitconv(Y,MagUnits,'abs') / ...
      Editor.interpmag(FreqData,Editor.Magnitude,X);
   
   % Update loop data (triggers plot update via listeners installed by refreshgain)
   C.setZPKGain(NewGain,'mag');
   
   % Adjust Y limits to keep mouse cursor in focus
   if AutoY
      MovePtr = Editor.reframe(MagAx,'y',[],Y);
      if MovePtr
         % Reposition mouse pointer 
         moveptr(MagAx,'move',X,Y);
      end
   end
   
case 'finish'
   % Button up event.  Commit and stack transaction
   EventMgr.record(TransAction);
   TransAction = [];   % release persistent objects
   
   % Broadcast MOVEGAIN:finish event (exit RefreshMode=quick,...) 
   LoopData.EventData.Phase = 'finish';
   LoopData.send('MoveGain')
   
   % Update status and command history
   Str = sprintf('%s gain changed to %0.3g',C.Name,getFormattedGain(C));
   EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
   EventMgr.recordtxt('history',Str);
   
   % Trigger global update
   LoopData.dataevent('gain',C);
   
end
