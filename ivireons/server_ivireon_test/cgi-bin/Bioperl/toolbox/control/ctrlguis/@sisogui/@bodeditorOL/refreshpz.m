function refreshpz(Editor,event,PZGroup)
% Refreshes plot while dynamically modifying poles and zeros of
% locally edited compensator.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2010/04/30 00:36:46 $

%RE: Do not use persistent variables here (several bodeeditorOL's
%    might track gain changes in parallel).

% Process events
switch event 
case 'init'
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Find related PZVIEW objects
   C = PZGroup.Parent;
   pzglist = get(Editor.EditedPZ(:,1),{'GroupData'});
   ig = find(PZGroup == [pzglist{:}]); 
   PZView = Editor.EditedPZ(ig,:);  % corresponding @pzview
   Editor.setEditedBlock(C);
      
   % Save initial data (units = rad/sec,abs,deg)
   InitData = struct(...
      'PZGroup',getTypeZeroPole(PZGroup),...
      'Frequency',Editor.Frequency,...
      'Magnitude',Editor.Magnitude,...
      'Phase',Editor.Phase,...
      'UncertainData',[]);
   % If multimodel display is on set UncertainData
   if Editor.isMultiModelVisible
       InitData.UncertainData = Editor.UncertainData;
   end
   
   % Install listener on PZGROUP data and store listener reference 
   % in EditModeData property
   L = handle.listener(PZGroup,'PZDataChanged',...
      {@LocalUpdatePlot Editor C InitData PZView});
   L.CallbackTarget = PZGroup;
   Editor.EditModeData = L;
   
case 'finish'
   % Clean up after dynamic gain update (drag)
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete gain listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(PZGroup,event,Editor,C,InitData,PZView)
% Update plot
% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)
Ts = C.Ts;

% Natural and peaking frequencies for new pole/zero locations (in rad/sec)
[W0,Zeta] = damp([PZGroup.Zero;PZGroup.Pole],Ts);
if Ts,
   % Keep root freq. below Nyquist freq.
   W0 = min(W0,pi/Ts);
end
t = W0.^2 .* (1 - 2 * Zeta.^2);
Wpeak = sqrt(t(t>0,:));

% Update mag and phase data
% RE: Update editor properties (used by INTERPY and REFRESHMARGIN)
Wxtra = [Wpeak;W0];
InitMag = [InitData.Magnitude ; ...
      Editor.interpmag(InitData.Frequency,InitData.Magnitude,Wxtra)];
InitPhase = [InitData.Phase ; ...
      utInterp1(InitData.Frequency,InitData.Phase,Wxtra)];
[W,iu] = LocalUniqueWithinTol([InitData.Frequency;Wxtra],1e3*eps);  % sort + unique

[Editor.Magnitude, Editor.Phase] = ...
   subspz(Editor, InitData.PZGroup, PZGroup, W, InitMag(iu), InitPhase(iu));
Editor.Frequency = W;

%%%%%%% Update uncertainty bounds
if ~isempty(InitData.UncertainData)
    for ct = 1:size(InitData.UncertainData.Magnitude,2)
        
        UInitMag = [InitData.UncertainData.Magnitude(:,ct) ; ...
            Editor.interpmag(InitData.UncertainData.Frequency,...
            InitData.UncertainData.Magnitude(:,ct),Wxtra)];
        
        UInitPhase = [InitData.UncertainData.Phase(:,ct) ; ...
            utInterp1(InitData.UncertainData.Frequency,...
            InitData.UncertainData.Phase(:,ct),Wxtra)];
        
        [UW,iu] = sort([InitData.UncertainData.Frequency;Wxtra]);  % sort + unique
        
        [UMagnitude(:,ct), UPhase(:,ct)] = ...
            subspz(Editor, InitData.PZGroup, PZGroup, UW, UInitMag(iu), UInitPhase(iu));
        
    end
    
    Editor.UncertainData.Magnitude = UMagnitude;
    Editor.UncertainData.Phase = UPhase;
    Editor.UncertainData.Frequency = UW(:);
end



%%%%%%%%%%%%%%


% Update the open-loop plot
Editor.redrawpz(PZGroup,PZView,W0);

% Update stability margins (using interpolation)
Editor.refreshmargin;


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUniqueWithinTol %
%%%%%%%%%%%%%%%%%%%%%%%%
function [w,iu] = LocalUniqueWithinTol(w,rtol)
% Eliminates duplicates within RTOL (relative tolerance)
% Helps prevent reintroducing duplicates during unit conversions

% Sort W
[w,iu] = sort(w);

% Eliminate duplicates
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=rtol*w(2:lw));
w(dupes,:) = [];
iu(dupes,:) = [];
