function trackgain(Editor, action, varargin)
%  TRACKGAIN  Keeps track of gain value while dragging Nichols curve.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.22.4.5 $ $Date: 2009/05/23 07:53:17 $

persistent TransAction InitFreq AutoY
persistent InitMag Phase Frequency 

LoopData = Editor.LoopData;
C = Editor.GainTargetBlock;
Editor.setEditedBlock(C);
PlotAxes = getaxes(Editor.Axes); 
EventMgr = Editor.EventManager;

% Process ACTION
switch action
   case 'init'
      % Nichols plot data in current units
      [OldGain, Magnitude, Phase, Frequency] = nicholsdata(Editor);
      
      % Initialize parameters used to adjust mag limits
      AutoY = strcmp(Editor.Axes.YlimMode{1},'auto');
      if AutoY
         % Initialize pointer motion control
         moveptr(PlotAxes,'init');
      end
      
      % Initial mouse position
      CP = get(PlotAxes, 'CurrentPoint');
      X = max(min(Phase), min(CP(1,1), max(Phase)));
      Y = CP(1,2);
      
      % Initial freq. at the point closest to the mouse position, in current units.
      InitFreq = Editor.project(X, Y, Phase, Magnitude, Frequency);
      InitMag  = 20*log10(Editor.interpmag(Frequency, Editor.Magnitude, InitFreq));
            
      % Display pole location in status bar 
      EventMgr.poststatus(sprintf(...
         'Drag the Nichols curve up or down to to adjust the loop gain.\n%s.', ...
         Editor.pointerlocation))
      
      % Broadcast MOVEGAIN:init event
      % RE: Sets RefreshMode='quick' and attaches listener to Gain data changes
      LoopData.EventData.Component = C;
      LoopData.EventData.Phase = 'init';
      LoopData.EventData.Editor = Editor;
      LoopData.send('MoveGain')
      
      % Start transaction
      TransAction = ctrluis.transaction(LoopData,'Name','Edit Gain',...
         'OperationStore','on','InverseOperationStore','on','Compression','on');
      
   case 'acquire'
      % Clear dependent information
      LoopData.reset('gain',C)
      
      % Acquire new gain value during drag.
      CP = get(PlotAxes, 'CurrentPoint');
      X = max(min(Phase), min(CP(1,1), max(Phase))); % Range of X motion
      Y = CP(1,2);
      
      % Interpolate mouse X-position using phase data
      [index, alpha] = interppha(Editor, Phase, X);
      
      % Get the frequency data
      Freq = alpha .* Frequency(index+1) + (1-alpha) .* Frequency(index);
      [junk,I] = min(abs(Freq - InitFreq));
      
      % Get new gain value (interpolate in plot units to limit distortions)
      NewMag = 20*log10(Editor.interpmag(Frequency, Editor.Magnitude, Freq(I)));
      Jump = 10; % Limit maximum jump/change in dB in a single step
      if abs(NewMag-InitMag) > Jump;
         InitMag = InitMag + Jump * sign(NewMag-InitMag);
         NewGain = 10.^((Y-InitMag)/20);
      else
         NewGain = 10.^((Y-NewMag)/20);
      end
            
      % Update loop data (triggers plot update via listeners by refreshgain)
      C.setZPKGain(NewGain, 'mag');
      
      % Adjust Y limits to keep mouse cursor in focus
      if AutoY
         MovePtr = Editor.reframe(PlotAxes,'y',[],Y);
         if MovePtr
            % Reposition mouse pointer 
            moveptr(PlotAxes,'move',X,Y);
         end
      end
      
      % Update status
      EventMgr.poststatus(sprintf(...
         'Drag the Nichols curve up or down to to adjust the loop gain.\n%s.', ...
         Editor.pointerlocation))

   case 'finish'
      % Button up event.  Commit and stack transaction
      EventMgr.record(TransAction);
      TransAction = [];   % release persistent objects
      
      % Broadcast MOVEGAIN:finish event (exit RefreshMode = quick, ...) 
      LoopData.EventData.Phase = 'finish';
      LoopData.send('MoveGain')
      
      % Update status and command history
      Str = sprintf('Loop gain changed to %0.3g',C.getFormattedGain);
      EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
      EventMgr.recordtxt('history',Str);
      
      % Trigger global update
      LoopData.dataevent('gain',C);
end
