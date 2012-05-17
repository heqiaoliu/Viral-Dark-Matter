function [D,SingularFlag] = connect(D,K,feedin,feedout,extin,extout)
% Closes the loop U(FEEDIN) = K*Y(FEEDOUT) and selects 
% channel EXTIN and EXTOUT as external I/Os. The
% structurally nonminimal dynamics wrt the selected
% external I/Os are discarded.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:47 $

% Close feedback loops
if isempty(K)
   SingularFlag = false;
else
   [nr,nc] = size(K);
   DK = ltipack.ssdata([],zeros(0,nc),zeros(nr,0),K,[],D.Ts);
   [D,SingularFlag] = feedback(D,DK,feedin,feedout,+1);
end

% Select external I/Os and discard dynamics that are disconnected
% from these inputs or outputs
D = getsubsys(D,extout,extin,'smin');
