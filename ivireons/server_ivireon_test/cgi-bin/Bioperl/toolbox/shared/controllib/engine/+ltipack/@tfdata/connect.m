function [D,SingularFlag] = connect(D,K,feedin,feedout,extin,extout)
% Closes the loop U(FEEDIN) = K*Y(FEEDOUT) and selects 
% channel EXTIN and EXTOUT as external I/Os. The
% structurally nonminimal dynamics wrt the selected
% external I/Os are discarded.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:28 $
SingularFlag = false;
nios = numel(K);

% Close feedback loops
if nios>1
   % Go to state-space (CONNECT closes loop with FEEDBACK and performs
   % structural reduction we convert back to tf)
   [Dss,SingularFlag] = connect(ss(D),K,feedin,feedout,extin,extout);
   % Try converting back
   try
      D = tf(Dss);
   catch %#ok<CTCH>
       ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
   end
else
   % Stick with TF
   if nios==1 % siso loop
      DK = ltipack.tfdata({K},{1},D.Ts);
      D = feedback(D,DK,feedin,feedout,+1);
   end
   % Select external I/Os
   D = getsubsys(D,extout,extin);
end
