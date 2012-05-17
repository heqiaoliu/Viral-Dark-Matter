function refreshpz(Editor,event,PZGroup)
% Refreshes plot while dynamically modifying poles and zeros of 
% locally edited compensator.

%   Author(s): P. Gahinet
%   Revised:   N. Hickey
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2010/04/30 00:36:42 $

% Process events
switch event 
case 'init'
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Initialization for dynamic gain update (drag).
   LoopData = Editor.LoopData;
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
      'Phase',Editor.Phase);
   
   % Configuration-specific optimizations
   if strcmp(Editor.ClosedLoopVisible,'on')
      % To speed up closed loop update, precompute frequency responses of 
      % 2x2 fixed model P and of normalized C so that Tcl = lft(P,gainC*C)
      CLView = Editor.ClosedLoopView;
      S = pfrespCL(LoopData,Editor.ClosedLoopFrequency,C,CLView.Input,CLView.Output);
      if Editor.isMultiModelVisible
          for ct = numel(LoopData.P.getP):-1:1
              S.MultiModelData(ct) = pfrespCL(LoopData,Editor.MultiModelFrequency,C,CLView.Input,CLView.Output,ct);
          end
      else
          S.MultiModelData = [];
      end
   else 
      S = [];
   end
  
   % Install listener on PZGROUP data and store listener reference 
   % in EditModeData property
   L = handle.listener(PZGroup,'PZDataChanged',...
      {@LocalUpdatePlot Editor C InitData PZView S});
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
function LocalUpdatePlot(PZGroup,event,Editor,C,InitData,PZView,S)
% Update plot
% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)

% Natural and peaking frequencies for new pole/zero locations (in rad/sec)
Ts = C.Ts;
[W0,Zeta] = damp([PZGroup.Zero;PZGroup.Pole],Ts);
if Ts,
   % Keep root freq. below Nyquist freq.
   W0 = min(W0,pi/Ts);
end
t = W0.^2 .* (1 - 2 * Zeta.^2);
Wpeak = sqrt(t(t>0,:));

% Update feedforward compensator's mag and phase data
% RE: Update editor properties (used by INTERPY)
[Editor.Frequency,Editor.Magnitude,Editor.Phase] = ...
   LocalUpdateData(Editor,InitData.Frequency,InitData.Magnitude,InitData.Phase,...
   InitData.PZGroup,PZGroup,[Wpeak;W0]);

% Update the feedforward compensator plot
Editor.redrawpz(PZGroup,PZView,W0);

% Update closed-loop plot
if ~isempty(S)
   % Adjust C's response to reflect modified PZ group
   hC = subspz(Editor, InitData.PZGroup, PZGroup, S.w, S.C);
   % Add gain
   hC = getZPKGain(C,'mag') * hC;
   % Close C loop
   hT = S.P(:,1,1) + S.P(:,1,2) .* (hC ./ (1 - hC .* S.P(:,2,2))) .* S.P(:,2,1);
   
   % Update line data
   FreqCL = unitconv(S.w,'rad/sec',Editor.Axes.XUnits);
   CLMag   = unitconv(abs(hT),'abs',Editor.Axes.YUnits{1});
   CLPhase = unitconv(unwrap(angle(hT)),'rad',Editor.Axes.YUnits{2});
   Zdata = Editor.zlevel('curve',[length(FreqCL) 1]);
   set(Editor.HG.BodePlot(1,2),'Xdata',FreqCL,'Ydata',CLMag,'Zdata',Zdata);
   set(Editor.HG.BodePlot(2,2),'Xdata',FreqCL,'Ydata',CLPhase,'Zdata',Zdata)
   
   % Update MultiModel Data
   if ~isempty(S.MultiModelData)
       for ct = length(S.MultiModelData):-1:1
           R = S.MultiModelData(ct);
           % Adjust C's response to reflect modified PZ group
           RC = subspz(Editor, InitData.PZGroup, PZGroup, R.w, R.C);
           % Add gain
           RC = getZPKGain(C,'mag') * RC;
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
   
   
end


%%%%%%%%%%%%%%%%%%%
% LocalUpdateData %
%%%%%%%%%%%%%%%%%%%
function [w,mag,phase] = LocalUpdateData(Editor,w,mag,phase,PZold,PZnew,wpz)
% Updates mag and phase data by applying multiplicative correction for
% moved PZ group
mag = [mag ; Editor.interpmag(w,mag,wpz)];
phase = [phase ; utInterp1(w,phase,wpz)];
[w,iu] = LocalUniqueWithinTol([w;wpz],1e3*eps);  % sort + unique
[mag,phase] = subspz(Editor,PZold,PZnew,w,mag(iu),phase(iu));


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
