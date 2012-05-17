function refresh(Editor,event,C,PZGroup)
% Refreshes plot during dynamic edit of some other compensator 
% than locally edited compensator.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2010/04/30 00:36:40 $

% Nothing to do if closed-loop plot is not shown
if strcmp(Editor.ClosedLoopVisible,'off')
   return
end

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   Editor.RefreshMode = 'quick';
   
   % Externally edited compensator
   LoopData = Editor.LoopData;
      
   % Precompute parameterized frequency response for fast update
   CLView = Editor.ClosedLoopView;
   S = pfrespCL(LoopData,Editor.ClosedLoopFrequency,C,CLView.Input,CLView.Output);
   
   % Add multimodel info
   if Editor.isMultiModelVisible
       for ct = numel(LoopData.P.getP):-1:1
           S.MultiModelData(ct) = pfrespCL(LoopData,Editor.MultiModelFrequency,C,CLView.Input,CLView.Output,ct);
       end
   else
       S.MultiModelData = [];
   end
   
   % Install listener to change in data
   if nargin==3
      % Gain editing
      Editor.EditModeData = ...
         handle.listener(C,findprop(C,'Gain'),'PropertyPostSet',{@LocalUpdate Editor C S});
   else
      InitPZ = getTypeZeroPole(PZGroup);
      Editor.EditModeData = ...
         handle.listener(PZGroup,'PZDataChanged',{@LocalUpdate Editor C S InitPZ PZGroup});
   end   
   
case 'finish'
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
   
end

%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalUpdate %%%
%%%%%%%%%%%%%%%%%%%
function LocalUpdate(eventsrc,eventdata,Editor,C,S,InitPZ,PZGroup)
% Update closed-loop plot when editing external compensator

% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)
if nargin==5
   % Gain editing: incorporate new gain value of externally edited compensator
   hC = getZPKGain(C,'mag') * S.C;
else
   % Update PZ group's contribution to C's frequency response and 
   % incorporate gain
   hC = getZPKGain(C,'mag') * subspz(Editor, InitPZ, PZGroup, S.w, S.C);
end

% Close C loop
hT = S.P(:,1,1) + S.P(:,1,2) .* (hC ./ (1 - hC .* S.P(:,2,2))) .* S.P(:,2,1);

% Update closed-loop plot
set(Editor.HG.BodePlot(1,2),'Ydata',...
   unitconv(abs(hT),'abs',Editor.Axes.YUnits{1}))
set(Editor.HG.BodePlot(2,2),'Ydata',...
   unitconv(unwrap(angle(hT)),'rad',Editor.Axes.YUnits{2}))

% Update MultiModel Data
if ~isempty(S.MultiModelData)
    for ct = length(S.MultiModelData):-1:1
        R = S.MultiModelData(ct);
        if nargin==5
            % Gain editing: incorporate new gain value of externally edited compensator
            RC = getZPKGain(C,'mag') * R.C;
        else
            % Update PZ group's contribution to C's frequency response and
            % incorporate gain
            RC = getZPKGain(C,'mag') * subspz(Editor, InitPZ, PZGroup, R.w, R.C);
        end
        
        UResp = R.P(:,1,1) + R.P(:,1,2) .* (RC ./ (1 - RC .* R.P(:,2,2))) .* R.P(:,2,1);
        UMagnitude(:,ct) = abs(UResp);
        UPhase(:,ct) = unitconv(unwrap(angle(UResp)),'rad','deg');
    end
    Editor.UncertainBounds.setData(UMagnitude,UPhase,Editor.MultiModelFrequency(:))
    Editor.UncertainData = struct(...
        'Magnitude',UMagnitude,...
        'Phase', UPhase, ...
        'Frequency',Editor.MultiModelFrequency);
end

