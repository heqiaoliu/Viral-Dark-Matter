function exportdata(Editor)
%EXPORTDATA  Exports data from compensator dialog to SISOTOOL

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $  $Date: 2006/01/26 01:47:48 $

% just broadcasting loopdata change event
Editor.LoopData.dataevent('all');

% LoopData = Editor.LoopData;
% CompList = Editor.CompList;
% GainList = Editor.GainList;
% EventMgr = Editor.Parent.EventManager;

% disable listener for import data
% OldEditMode = Editor.EditMode;
% Editor.EditMode = 'off';

% Start transaction
% T = ctrluis.transaction(LoopData,'Name','Edit Compensator',...
%    'OperationStore','on','InverseOperationStore','on');

% Export modified pole/zero/gain
% Target = LoopData.C; 
% bool = isGainBlock(LoopData.C);
% indPZ = 1;
% indGain = 1;
% for idxC = 1:length(Target)
%     if bool(idxC)
%         Target(idxC).PZGroup = zeros(0,1);
%         Target(idxC).Gain = GainList(indGain).Gain;
%         indGain = indGain+1;
%     else
%         Target(idxC).PZGroup = CompList(indPZ).PZGroup;
%         Target(idxC).Gain = CompList(indPZ).Gain;
%         indPZ = indPZ+1;
%     end
% end

% Register transaction
% EventMgr.record(T);

% Trigger update
% LoopData.dataevent('all');

% Notify host status and history
% EventMgr.newstatus(sprintf('The compensators have been updated.'));
% EventMgr.recordtxt('history',sprintf('Modified the compensators pole/zero data.'));

% enable listener for import data
% Editor.EditMode = OldEditMode;

