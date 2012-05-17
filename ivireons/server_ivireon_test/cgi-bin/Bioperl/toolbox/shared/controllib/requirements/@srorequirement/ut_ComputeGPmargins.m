function out = ut_ComputeGPmargins(sys,FeedbackSign) 
% UT_COMPUTEGPMARGINS a function to estimate gain and phase margins of 
% a system 
%
% Inputs:
%          sys          - An LTI object.
%          FeedbackSign - +1 or -1 indicating sign of feedback
% Outputs: 
%          dgm - a vector of doubles giving the loop at a time gain
%                margin.
%          dpm - a vector of doubles giving the loop at a time phase
%                margin.
 
% Author(s): A. Stothert 04-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:22 $

[nu,ny] = size(sys);    %System size
if nu~=ny
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errGPMarginNonSquare')
end

%Compute loop-at-a-time margins for MIMO systems
dpm = cell(nu,1);
dgm = cell(nu,1);
for ct = 1:nu
   S = allmargin(-1*FeedbackSign*sys(ct,ct));
   if ~isempty(S.GainMargin)
      dgm{ct} = S.GainMargin;
   else
      %No gain margin, i.e. phase crossover, so set GM to inf
      dgm{ct} = inf;
   end
   if ~isempty(S.PhaseMargin)
      dpm{ct} = S.PhaseMargin;
   else
      %No phase margin, i.e., gain crossover, so set PM to inf
      dpm{ct} = inf;
   end
   %Modify margin sign based on stability, needed as we want the 
   %requirement to always be pm >= x. Also means we can use the 
   %margin as an indicator of stability.
   if isnan(S.Stable)
      %No way to tell if the system is stable (frd, internal delay) so, use 
      %abs value of margin for requirement 
      dpm{ct} = abs(dpm{ct}); 
   elseif S.Stable,
      dpm{ct} = abs(dpm{ct}); 
   else
      %Unstable system return negative margin 
      dpm{ct} = -abs(dpm{ct}); 
   end
end

out = struct('dgm',dgm,'dpm',dpm,'Stable',S.Stable);
