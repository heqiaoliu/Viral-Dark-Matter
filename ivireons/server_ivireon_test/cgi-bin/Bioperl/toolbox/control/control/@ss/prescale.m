function [scaledsys,Info] = prescale(sys,focus)
%PRESCALE  Optimal scaling of state-space models.
%
%   SCALEDSYS = PRESCALE(SYS) takes a state-space model SYS and scales 
%   the entries of its state vector to maximize the accuracy of subsequent 
%   frequency-domain analysis. The scaled model SCALEDSYS is equivalent to
%   SYS.
%
%   SCALEDSYS = PRESCALE(SYS,FOCUS) specifies a frequency interval
%   FOCUS={FMIN,FMAX} (in rad/s) where to maximize accuracy. This is 
%   useful when SYS has slow/fast dynamics and scaling cannot achieve 
%   high accuracy over the entire dynamic range. By default, PRESCALE 
%   tries to maximize accuracy over the full dynamic range.
%   
%   [SCALEDSYS,INFO] = PRESCALE(...) also returns a structure INFO with 
%   the following fields:
%      SL         Left scaling factors
%      SR         Right scaling factors
%      Freqs      Frequencies used to test accuracy
%      RelAcc     Guaranteed relative accuracy at these frequencies
%   The test frequencies lie in the frequency interval FOCUS when specified. 
%   The scaled state-space matrices are TL*A*TR, TL*B, C*TR, TL*E*TR with 
%   TL=diag(SL) and TR=diag(SR). TL and TR are inverse of each other for 
%   explicit models (E=[]).
%
%   Without output arguments, PRESCALE brings up an interactive GUI for 
%   visualizing accuracy tradeoffs and adjusting the frequency interval 
%   where accuracy is maximized.
%
%   Note: Most frequency-domain analysis commands provide built-in scaling.
%   Scaling is not needed for time-domain simulations and may invalidate 
%   the initial condition X0 used in INITIAL and LSIM simulations.
%
%   See also SS.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/05/10 16:58:19 $
ni = nargin;
no = nargout;
Ts = abs(sys.Ts);
if ni<2
   xfocus = [];
else
   if ~(iscell(focus) && numel(focus)==2 && ...
         localValidateFocus(focus{1}) && localValidateFocus(focus{2}))
      ctrlMsgUtils.error('Control:transformation:prescale1')
   end
   xfocus = [focus{:}];
   if ~(xfocus(1)>0 && xfocus(1)<xfocus(2))
      ctrlMsgUtils.error('Control:transformation:prescale1')
   elseif Ts>0
      nf = pi/Ts;
      if xfocus(1)>=nf
         ctrlMsgUtils.error('Control:transformation:prescale4')
      else
         xfocus(2) = min(xfocus(2),nf);
      end
   end
end

if no>0
   % Scale each system
   Data = sys.Data_;
   Info = struct('SL',cell(size(Data)),'SR',[],'Freqs',[],'RelAcc',[]);
   Warn = false;
   for ct=1:numel(Data)
      % Scale model
      % Note: Make sure PRESCALE preserves state ordering
      D = Data(ct);
      [D.a,D.b,D.c,D.e,sr,~,sl,~,ScalingData] = ...
         xscale(D.a,D.b,D.c,D.d,D.e,Ts,'Warn',false,'Permute',false,'Focus',xfocus);
      D.Scaled = true;
      D.StateUnit = [];   % scaling changes units
      Warn = Warn || any(ScalingData.RelAcc>1);
      Data(ct) = D;
      % Store scaling data
      Info(ct).SL = sl;
      Info(ct).SR = sr;
      Info(ct).Freqs = ScalingData.ValidFreqs;
      Info(ct).RelAcc = ScalingData.RelAcc;
   end
   sys.Data_ = Data;
   if Warn
      % Issue warning that accuracy may be poor in part of the auto-selected
      % or specified frequency range 
      ctrlMsgUtils.warning('Control:transformation:prescale2')
   end
   scaledsys = sys;
   
else
   % Launch GUI
   if ndims(sys)>2
      ctrlMsgUtils.error('Control:transformation:prescale3')
   end
   scalingtool.PreScaleTool(sys,xfocus);
end


%------------------------------------------------------
function boo = localValidateFocus(x)
boo = isnumeric(x) && isscalar(x) && isreal(x);
