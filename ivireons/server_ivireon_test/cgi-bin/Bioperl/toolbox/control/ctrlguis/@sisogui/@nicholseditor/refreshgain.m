function refreshgain(Editor, action)
% Refreshes plot while dynamically modifying the gain of the edited model.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2010/04/30 00:36:51 $

%RE: Do not use persistent variables here (several instance of this 
%    editor may track gain changes in parallel).
switch action
   case 'init'
      % Initialization for dynamic gain update (drag)
      % Switch editor's RefreshMode to quick
      Editor.RefreshMode = 'quick';
      
      C = Editor.LoopData.EventData.Component;
      Editor.setEditedBlock(C);
      
      % Get initial Y location of poles/zeros (for normalized compensator)
      HG = Editor.HG;
      hPZ = [HG.System ; HG.Compensator];
      FreqPZ = get(hPZ, {'UserData'}); % frequency in rad/sec
      FreqPZ = cat(1, FreqPZ{:});
      % Compute interpolated Magnitude locations (in absolute units)
      MagPZ = Editor.interpmag(Editor.Frequency, Editor.Magnitude, FreqPZ);
      
      % Install listener on gain data
      Editor.EditModeData = struct('GainListener', ...
         handle.listener(C, findprop(C, 'Gain'), ...
         'PropertyPostSet', {@LocalUpdatePlot Editor C MagPZ hPZ}));
      
      % Initialize Y limit manager
      Editor.slideframe('init', getZPKGain(C,'mag'));
      
   case 'finish'
      % Return editor's RefreshMode to normal
      Editor.RefreshMode = 'normal';
      
      % Delete listener
      delete(Editor.EditModeData.GainListener);
      Editor.EditModeData = [];
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

function LocalUpdatePlot(hSrc, event, Editor, C, MagPZ, hPZ)
% Updates Nichols plot curve and pole/zero markers' position.

% Gwet new compensator gain
NewGain = getZPKGain(C,'mag');

% Update Nichols plot
% REMARK: Gain sign can't change in drag mode!
set(Editor.HG.NicholsPlot, 'Ydata', mag2db(Editor.Magnitude * NewGain))
set(hPZ,{'Ydata'},num2cell(mag2db(MagPZ * NewGain)))


%%%%%%% Update MultiModel bounds
if Editor.isMultiModelVisible
    Editor.UncertainBounds.setData(NewGain*Editor.UncertainData.Magnitude,...
        Editor.UncertainData.Phase,Editor.UncertainData.Frequency)
end

% Update stability margins (using interpolation)
Editor.refreshmargin

% Update Y limits
Editor.slideframe('update', NewGain)
