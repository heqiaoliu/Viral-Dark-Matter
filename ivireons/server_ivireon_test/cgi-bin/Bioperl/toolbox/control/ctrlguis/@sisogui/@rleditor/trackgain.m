function trackgain(this,event)
% Keeps track of gain value while dragging closed-loop pole.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.35.4.4 $  $Date: 2006/11/17 13:25:49 $
persistent OLz OLp OLk Ts MinGM MaxGM TransAction
persistent SelectedBranch AutoScaleOn

LoopData = this.LoopData;
C = this.GainTargetBlock;
this.setEditedBlock(C);
PlotAxes = getaxes(this.Axes);
EventMgr = this.EventManager;

% Process event
switch event 
   
case 'init'
   % Initialization for closed-loop pole drag
   % Initialize static variables
   Ts = C.Ts;
   RLInfo = this.OpenLoopData;
   if RLInfo.InverseFlag
      OLz = RLInfo.Pole;  OLp = RLInfo.Zero;  OLk = 1/RLInfo.Gain;
   else
      OLz = RLInfo.Zero;  OLp = RLInfo.Pole;  OLk = RLInfo.Gain;
   end
   
   % Find selected closed-loop pole and associated locus branch
   CP = get(PlotAxes,'CurrentPoint');
   [garb,isel] = min(abs(this.ClosedPoles-(CP(1,1)+1i*CP(1,2))));   
   P = this.ClosedPoles(isel);
   SelectedBranch = LocalFindBranch(this.LocusRoots,P);
   isFiniteBranch = isfinite(SelectedBranch([1 end]));
   
   % Bounds for gain magnitude (for numerical stability and to avoid 
   % k=0 or k=Inf (no Bode plot)
   Gains = this.LocusGains;
   if isFiniteBranch(1)
      % Watch for numerical instability for very small k
      MinGM = 1e-3 * Gains(2);
   else
      MinGM = 1e-8 * Gains(2);
   end
   if isFiniteBranch(2)
      % Watch for numerical instability for very large k
      MaxGM = 1e3 * Gains(end-1);
   else
      MaxGM = 1e8 * Gains(end-1);
   end
   
   % Initialize parameters used to adjust limits/pointer position
   AutoScaleOn = ...
      strcmp(this.Axes.XlimMode,'auto') && strcmp(this.Axes.YlimMode,'auto');
   if AutoScaleOn
      moveptr(PlotAxes,'init');
   end
   
   % Display pole location in status bar 
   EventMgr.poststatus(LocalTrackStatus(P,Ts,this.FrequencyUnits));
   
   % Broadcast MOVEGAIN:init event
   % RE: Sets RefreshMode='quick' and attaches listener to Gain data changes
   LoopData.EventData.Component = C;
   LoopData.EventData.Phase = 'init';
   LoopData.EventData.Editor = this;
   LoopData.send('MoveGain')
   
   % Start transaction
   TransAction = ctrluis.transaction(LoopData,'Name','Edit Gain',...
      'OperationStore','on','InverseOperationStore','on','Compression','on');
   
case 'acquire'
   % Clear dependent information
   LoopData.reset('gain',C)
   
   % Acquire new gain value during drag 
   CP = get(PlotAxes,'CurrentPoint');
   
   % Project pointer on selected branch and get new location P of selected pole
   % RE: 1) Guarantees the moved square won't jump to a different branch
   %        if the pointer strays away from original branch
   %     2) Move pointer when traversing infinity along a finite-escape asymptote
   [P,MovePtr] = LocalProjectOnBranch(CP(1,1:2),SelectedBranch,PlotAxes);
   
   % Compute new gain value
   NumP = OLk * prod(P-OLz);  % evaluate numerator at P
   DenP = prod(P-OLp);        % evaluate denominator at P
   if (NumP == 0)
      NewGainMag = MaxGM;
   else
      NewGainMag = min(max(MinGM,abs(DenP/NumP)),MaxGM);
   end
   
   % Update loop data (triggers plot update through gain listener installed by refreshgain)
   C.setZPKGain(NewGainMag,'mag');
   
   % Adjust pointer and axis limits if necessary
   if ~MovePtr && AutoScaleOn
      MovePtr = this.reframe(PlotAxes,'xy',CP(1,1),CP(1,2));
   end
   if MovePtr
      % Reposition mouse pointer 
      moveptr(PlotAxes,'move',real(P),imag(P))
   end
   
   % Track pole location in status bar 
   EventMgr.poststatus(LocalTrackStatus(P,Ts,this.FrequencyUnits,this.ClosedPoles));
   
case 'finish'
   % Button up event. Commit and stack transaction
   EventMgr.record(TransAction);
   TransAction = [];   % release persistent object
   
   % Broadcast MOVEGAIN:finish event (exit RefreshMode=quick,...) 
   LoopData.EventData.Phase = 'finish';
   LoopData.send('MoveGain')
   
   % Update status and command history
   Str = sprintf('Loop gain changed to %0.3g',C.getFormattedGain);
   EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
   EventMgr.recordtxt('history',Str);
   
   % Trigger global update
   LoopData.dataevent('gain',C);
   
end


%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%%%%
% LocalFindBranch %
%%%%%%%%%%%%%%%%%%%
function Branch = LocalFindBranch(Locus,Pole)
%  Find locus branch containing a given pole

nbranch = size(Locus,1);
dist = zeros(1,nbranch);
x = real(Pole);
y = imag(Pole);

% Project on each branch (in true coordinates) and save min distance
for i=1:nbranch
   branch = Locus(i,:);
   [xp,yp] = lproject(x,y,real(branch),imag(branch));
   dist(i) = (xp-x)^2+(yp-y)^2;
end

% Keep branch with min distance
[garb,isel] = min(dist);
Branch = Locus(isel,:);


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalProjectOnBranch %
%%%%%%%%%%%%%%%%%%%%%%%%
function [P,MovePtrFlag] = LocalProjectOnBranch(CP,Branch,Axes)
%  Project current cursor position 

NearInfTresh = 0.25;
MovePtrFlag = 0;

% Project pointer loc. on branch
% ip = relative index of projection in vector Branch
[Xp,Yp,ip] = lproject(CP(1),CP(2),real(Branch),imag(Branch),Axes);
P = Xp + i * Yp;

% Look for infinite pole (one at most)
kinf = find(isinf(Branch));
if ~isempty(kinf)
   % NEARINF = 1 if previous branch point is at infinity
   %         = -1 if next branch point is at infinity
   %         = 0 otherwise
   nearinf = (abs(kinf-ip)<1+NearInfTresh) * ((ip>kinf) - (ip<kinf));
   if nearinf~=0
      % End of asymptote
      if (nearinf>0 && kinf==1) || (nearinf<0 && kinf==length(Branch))
         % Asymptote for gain->0 or Inf: project on asymptote 
         % P = A + (AM.AB) AB/|AB|^2
         A = Branch(kinf+2*nearinf);
         AB = Branch(kinf+nearinf) - A;
         u = AB/abs(AB);
         P = A + real((CP(1)+i*CP(2)-A)'*u) * u;
      else
         % Finite escape: traverse infinity
         % RE: get out of NearInfTresh jump zone to avoid going back and forth
         NearInfTresh = 1.5 * NearInfTresh;   
         P = (1-NearInfTresh) * Branch(kinf-nearinf) + NearInfTresh * Branch(kinf-2*nearinf);
         MovePtrFlag = 1;
      end
   end     
end


%%%%%%%%%%%%%%%%%%%%
% LocalTrackStatus %
%%%%%%%%%%%%%%%%%%%%
function StatusText = LocalTrackStatus(P,Ts,FreqUnits,CurrentPoles)
%  Display current pole data on status bar

if nargin==4
   % P = position of (projected) pointer
   % Get true location of closed-loop pole nearest to P
   [garb,imin] = min(abs(CurrentPoles-P));
   P = CurrentPoles(imin);
end
Y = imag(P);

% Display string
Text = sprintf('Drag this closed-loop pole along the locus to adjust the loop gain.');
if Y, % Complex pole
   [Wn,Zeta] = damp(P,Ts);
   Wn = unitconv(Wn,'rad/sec',FreqUnits);
   % Don't trust
   if Y>0, Sign = '+'; else Sign = '-'; end
   StatusText = ...
      sprintf('%s\nCurrent location: %0.3g %s %0.3gi%sDamping: %0.3g%sNatural Frequency: %0.3g %s',...
      Text,real(P),Sign,abs(Y),blanks(5),Zeta,blanks(5),Wn,FreqUnits);
else
   StatusText = sprintf('%s\nCurrent location: %0.3g',Text,real(P));
end
