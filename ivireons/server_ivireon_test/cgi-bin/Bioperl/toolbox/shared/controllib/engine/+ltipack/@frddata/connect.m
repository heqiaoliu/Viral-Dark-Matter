function [D,SingularFlag] = connect(D,K,feedin,feedout,extin,extout)
% Closes the loop U(FEEDIN) = K*Y(FEEDOUT) and selects 
% channel EXTIN and EXTOUT as external I/Os. The
% structurally nonminimal dynamics wrt the selected
% external I/Os are discarded.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:14 $

% Close feedback loops
if isempty(K)
   SingularFlag = false;
else
   DK = ltipack.frddata(repmat(K,[1 1 length(D.Frequency)]),...
      D.Frequency,D.Ts);
   DK.FreqUnits = D.FreqUnits;
   [D,SingularFlag] = feedback(D,DK,feedin,feedout,+1);
end

% Select external I/Os
D = getsubsys(D,extout,extin);
