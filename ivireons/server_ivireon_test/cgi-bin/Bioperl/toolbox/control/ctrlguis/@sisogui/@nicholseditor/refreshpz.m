function refreshpz(Editor,event,PZGroup)
% Refreshes plot while dynamically modifying poles and zeros of edited
% compensator.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2010/04/30 00:36:52 $

%RE: Do not use persistent variables here (several NicholsEditors
%    might track gain changes in parallel).

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Find related PZVIEW objects
   C = PZGroup.Parent;
   pzglist = get(Editor.EditedPZ(:,1),{'GroupData'});
   ig = find(PZGroup == [pzglist{:}]); 
   PZView = Editor.EditedPZ(ig);
   
   % Set EditedBlock to C
   Editor.setEditedBlock(C);
   
   % Save initial data (units = rad/sec, abs, deg)
   InitData = struct(...
      'PZGroup', getTypeZeroPole(PZGroup), ...
      'Frequency', Editor.Frequency, ...
      'Magnitude', Editor.Magnitude, ...
      'Phase',Editor.Phase,...
      'UncertainData',[]);
   % If multimodel display is on set UncertainData
   if Editor.isMultiModelVisible
       InitData.UncertainData = Editor.UncertainData;
   end
   
   % Install listener on PZGROUP data and store listener reference
   % in EditModeData property
   L = handle.listener(PZGroup, 'PZDataChanged', ...
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


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalUpdatePlot
% Updates plot
% ----------------------------------------------------------------------------%
function LocalUpdatePlot(PZGroup, event, Editor, C, InitData, PZView)
% RE:  PZGroup: current PZGROUP data
%      Working units are (rad/sec, abs, deg)
Ts = C.Ts;

% Natural and peaking frequencies for new pole/zero locations (in rad/sec)
[W0, Zeta] = damp([PZGroup.Zero ; PZGroup.Pole], Ts);
if Ts
   % Keep root freq. below Nyquist freq.
   W0 = min(W0, pi/Ts);
end
t = W0.^2 .* (1 - 2 * Zeta.^2);
Wpeak = sqrt(t(t>0, :));

% Update mag and phase data
% RE: Update editor properties (used by INTERPXY and REFRESHMARGIN)
Wxtra = [Wpeak; W0];
InitMag = [InitData.Magnitude ; ...
      Editor.interpmag(InitData.Frequency, InitData.Magnitude, Wxtra)];
InitPhase = [InitData.Phase ; ...
      utInterp1(InitData.Frequency, InitData.Phase, Wxtra)];
[W, iu] = LocalUniqueWithinTol([InitData.Frequency; Wxtra], 1e3*eps);
% sort + unique

[Mag, Pha] = subspz(Editor, InitData.PZGroup, PZGroup,...
   W, InitMag(iu), InitPhase(iu));
Editor.Magnitude = Mag;
Editor.Phase     = Pha;
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
LocalRedraw(Editor, PZGroup, PZView, W0);

% Update stability margins (using interpolation)
Editor.refreshmargin;


% ----------------------------------------------------------------------------%
% Function: LocalUniqueWithinTol
% Eliminates duplicates within RTOL (relative tolerance).
% Helps prevent reintroducing duplicates during unit conversions.
% ----------------------------------------------------------------------------%
function [w, iu] = LocalUniqueWithinTol(w, rtol)
% Sort W
[w, iu] = sort(w);

% Eliminate duplicates
lw = length(w);
dupes = find(w(2:lw) - w(1:lw-1) <= rtol*w(2:lw));
w(dupes,:) = [];
iu(dupes,:) = [];

% ----------------------------------------------------------------------------%
% Function: LocalRedraw
% Refreshes edited Nichols plot during move pole/zero.
% ----------------------------------------------------------------------------%
function LocalRedraw(Editor, PZGroup, PZView, W0)
%   EDITOR.REDRAW(PZGroup,PZView,W0) refreshes the Nichols plot 
%   associated with the moved poles and zeros (equivalently, EDITOR's
%   edited object). The @pzgroup instance PZGROUP specifes the new 
%   pole/zero locations and the vector W0 contains the frequencies 
%   of the new poles and zeros.

% Get handle
HG = Editor.HG;

% Update primary plot using data in current units
[Gain, Magnitude, Phase, Frequency] = nicholsdata(Editor);

% Update Nichols plot
Zdata = Editor.zlevel('curve', [length(Editor.Frequency) 1]);
set(HG.NicholsPlot, 'Xdata', Phase, 'Ydata', Magnitude, 'Zdata', Zdata)

if Editor.isMultiModelVisible
    Editor.UncertainBounds.setData(Gain*Editor.UncertainData.Magnitude,...
        Editor.UncertainData.Phase,Editor.UncertainData.Frequency)
end

% Update X and Y location of moved roots
PZMagPha = [PZView.Zero ; PZView.Pole];

for ct = 1:length(W0)
  set(PZMagPha(ct), 'UserData', W0(ct))
end

% Update location of notch width markers
if strcmp(PZGroup.Type, 'Notch')
  Wm = notchwidth(PZGroup, Editor.LoopData.Ts);

  % Markers
  Extras = PZView.Extra;
  set(Extras(1), 'UserData', Wm(1))
  set(Extras(2), 'UserData', Wm(2))
end

% Interpolate X and Y values
Editor.interpxy(Magnitude, Phase);
