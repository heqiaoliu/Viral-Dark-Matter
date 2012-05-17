function refreshgain(Editor,action)
%REFRESHGAIN  Refreshes plot during dynamic edit of feedforward gain.

%   Author(s): P. Gahinet, N. Hickey
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/04/30 00:36:41 $
switch action
    
case 'init'
    % Initialization for dynamic gain update (drag)
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';
    % Get initial Y location of poles/zeros (for normalized edited model)
    hPZ = Editor.HG.Compensator.Magnitude;
    W = get(hPZ,{'Xdata'});
    W = unitconv(cat(1,W{:}),Editor.Axes.XUnits,'rad/sec');
    MagPZ = Editor.interpmag(Editor.Frequency,Editor.Magnitude,W);  % in abs units
    
    % Install listener on filter gain (save it in EditModeData)
    LoopData = Editor.LoopData;
    C = Editor.LoopData.EventData.Component; % edited compensator
    Editor.setEditedBlock(C);
 
    if strcmp(Editor.ClosedLoopVisible,'on')
       % To speed up closed loop update, precompute frequency responses of 
       % 2x2 fixed model P and of normalized C so that Tcl = lft(P,getgain(C,'mag')*C)
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
    GL = handle.listener(C,findprop(C,'Gain'),'PropertyPostSet',{@LocalUpdatePlot C MagPZ hPZ S});
    GL.CallbackTarget = Editor;
    Editor.EditModeData = struct('GainListener',GL);
    
    % Initialize Y limit manager
    Editor.slideframe('init',getZPKGain(C,'mag'));
    
case 'finish'
    % Return editor's RefreshMode to normal
    Editor.RefreshMode = 'normal';
    
    % Delete listener
    delete(Editor.EditModeData.GainListener);
    Editor.EditModeData = [];
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(Editor,event,C,MagPZ,hPZ,S)
% Updates mag curve position
MagUnits = Editor.Axes.YUnits{1};
GainC = getZPKGain(C,'mag'); 

% Update magnitude plot for feedforward compensator C
% RE: Gain sign can't change in drag mode!
set(Editor.HG.BodePlot(1,1),'Ydata',...
    unitconv(Editor.Magnitude * GainC,'abs',MagUnits))
Ypz = unitconv(MagPZ * GainC,'abs',MagUnits);
for ct=1:length(hPZ)
    set(hPZ(ct),'Ydata',Ypz(ct))
end

% Update closed-loop plot
if ~isempty(S)
    % Compute lft(S.P,S.C)
    hC = GainC * S.C;  % S.C is the normalized response of C
    hT = S.P(:,1,1) + S.P(:,1,2) .* (hC ./ (1 - hC .* S.P(:,2,2))) .* S.P(:,2,1);
    set(Editor.HG.BodePlot(1,2),'Ydata', unitconv(abs(hT),'abs',MagUnits));
    set(Editor.HG.BodePlot(2,2),'Ydata', ...
        unitconv(unwrap(angle(hT)),'rad',Editor.Axes.YUnits{2}));
    if ~isempty(S.MultiModelData)
        % Update MultiModel Data
        for ct = length(S.MultiModelData):-1:1
            R = S.MultiModelData(ct);
            RC = GainC * R.C;
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
   
% Update Y limits
Editor.slideframe('update',GainC);
