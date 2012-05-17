function refresh(Editor,event,C,PZGroup)
% Refreshes plot during dynamic edit of some other compensator 
% than the locally edited compensator.

%   Author(s): N. Hickey, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/04/30 00:36:44 $

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   Editor.RefreshMode = 'quick';
   
   % Externally edited compensator C
   LoopData = Editor.LoopData;
     
   % Include frequencies of C's poles & zeros in freq. vector for fast update
   % of the compensator x and o markers
   hPZ  = [Editor.HG.Compensator.Magnitude; Editor.HG.Compensator.Phase]; 
   Wpz = get(hPZ,{'Xdata'});    
   Wpz = unitconv(cat(1,Wpz{:}),Editor.Axes.XUnits,'rad/sec');   
   W = [Editor.Frequency; Wpz]; 
   [junk,is] = sort(W);  % sorting needed to unwrap phase
   
   % For fast update, precompute normalized open-loop frequency response
   % parameterized by C
   L = LoopData.L(Editor.EditedLoop);
   S = pfrespOL(L,W,C,Editor.EditedBlock);
   S.fsort = is;
   
   % Keep track of phase at first frequency to avoid 360 phase jumps  
   S.InitPhase = Editor.Phase(1);  % in deg
   
   % Add multimodel info
   if Editor.isMultiModelVisible
       for ct = numel(L.TunedLFT.IC):-1:1
           % For fast update, precompute normalized open-loop frequency response
           % parameterized by C
           TempStruct = pfrespOL(L,Editor.UncertainData.Frequency,C,Editor.EditedBlock,ct);
           % Keep track of phase at first frequency to avoid 360 phase jumps
           TempStruct.InitPhase = Editor.UncertainData.Phase(1,ct);  % in deg
           S.MultiModelData(ct) = TempStruct;
       end
   else
       S.MultiModelData =[];
   end
   
   
   % Loop gain
   LoopGain = getZPKGain(Editor.EditedBlock,'mag');

   % Install listener to change in data
   if nargin==3
      % Gain editing
      Editor.EditModeData = ...
         handle.listener(C,findprop(C,'Gain'),'PropertyPostSet',@(x,y) LocalUpdate(Editor,C,S,LoopGain));
   else
      InitPZ = getTypeZeroPole(PZGroup);
      Editor.EditModeData = ...
         handle.listener(PZGroup,'PZDataChanged',@(x,y) LocalUpdate(Editor,C,S,LoopGain,InitPZ,PZGroup));
   end

   % Hide "fixed" poles and zeros (their number may change with F)
   set([Editor.HG.System.Magnitude;Editor.HG.System.Phase],'Visible','off')
   
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
function LocalUpdate(Editor,C,S,LoopGain,InitPZ,PZGroup)
% Update closed-loop plot when editing external compensator
% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)
%      * S.w contains Editor.Frequency plus the frequencies of the
%        compensator's poles and zeros
if nargin==4
   % Gain editing: incorporate new gain value of externally edited compensator
   hC = getZPKGain(C,'mag') * S.C;
else
   % Update PZ group's contribution to C's frequency response and 
   % incorporate gain
   hC = getZPKGain(C,'mag') * subspz(Editor, InitPZ, PZGroup, S.w, S.C);
end

% Close C loop to get uptodate open-loop response
hOL = S.P(:,1,1) + S.P(:,1,2) .* (hC ./ (1 - hC .* S.P(:,2,2))) .* S.P(:,2,1);

% Update editor properties (used by INTERPY)
% RE: First NF frequencies of S.w are the open-loop plot frequencies
nf = length(Editor.Frequency);
isort = S.fsort;  % permutation for sorting frequencies
OLMag = abs(hOL);
OLPhase(isort,:) = unitconv(unwrap(angle(hOL(isort))),'rad','deg');
% Prevent 360 jumps in phase
OLPhase = OLPhase + 360*round((S.InitPhase - OLPhase(1))/360);
Editor.Magnitude = OLMag(1:nf);   % normalized open-loop gain
Editor.Phase = OLPhase(1:nf);     % open-loop phase in deg

% Update open-loop mag and phase plot
OLMag   = unitconv(LoopGain*OLMag,'abs',Editor.Axes.YUnits{1});
OLPhase = unitconv(OLPhase,'deg',Editor.Axes.YUnits{2});
set(Editor.HG.BodePlot(1),'Ydata',OLMag(1:nf));
set(Editor.HG.BodePlot(2),'Ydata',OLPhase(1:nf));

% Update MultiModel Data
if ~isempty(S.MultiModelData)
    for ct = length(S.MultiModelData):-1:1
        R = S.MultiModelData(ct);
        if nargin==4
            % Gain editing: incorporate new gain value of externally edited compensator
            RC = getZPKGain(C,'mag') * R.C;
        else
            % Update PZ group's contribution to C's frequency response and
            % incorporate gain
            RC = getZPKGain(C,'mag') * subspz(Editor, InitPZ, PZGroup, R.w, R.C);
        end
        
        UResp = R.P(:,1,1) + R.P(:,1,2) .* (RC ./ (1 - RC .* R.P(:,2,2))) .* R.P(:,2,1);
        UMagnitude(:,ct) = LoopGain*abs(UResp);
        UPhase(:,ct) = unitconv(unwrap(angle(UResp)),'rad','deg');
        UPhase(:,ct) = UPhase(:,ct) + 360*round((R.InitPhase - UPhase(1,ct))/360);
    end
    Editor.UncertainBounds.setData(UMagnitude,UPhase,Editor.MultiModelFrequency(:))
    Editor.UncertainData = struct(...
        'Magnitude',UMagnitude,...
        'Phase', UPhase, ...
        'Frequency',Editor.MultiModelFrequency);
end


% Update Y coordinate of x and o of compensator C
hPZmag = Editor.HG.Compensator.Magnitude;
for ct=1:length(hPZmag)
   set(hPZmag(ct),'Ydata',OLMag(nf+ct))
end
nf = nf + length(hPZmag);
hPZphase = Editor.HG.Compensator.Phase;
for ct=1:length(hPZphase)
   set(hPZphase(ct),'Ydata',OLPhase(nf+ct))
end

% Update stability margins (using interpolation)
refreshmargin(Editor)
