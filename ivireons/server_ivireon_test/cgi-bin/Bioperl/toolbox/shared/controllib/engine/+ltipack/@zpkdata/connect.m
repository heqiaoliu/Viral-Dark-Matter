function [D,SingularFlag] = connect(D,K,feedin,feedout,extin,extout)
% Closes the loop U(FEEDIN) = K*Y(FEEDOUT) and selects 
% channel EXTIN and EXTOUT as external I/Os. The
% structurally nonminimal dynamics wrt the selected
% external I/Os are discarded.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:23 $

% Go to state-space
[Dss,SingularFlag] = connect(ss(D),K,feedin,feedout,extin,extout);
% Try converting back
try
   D = zpk(Dss);
catch %#ok<CTCH>
    ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
end
