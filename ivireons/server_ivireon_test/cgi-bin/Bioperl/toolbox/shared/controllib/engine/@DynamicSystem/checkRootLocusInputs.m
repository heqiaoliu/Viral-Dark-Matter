function [sysList,k] = checkRootLocusInputs(sysList,Extras)
% Validates input arguments to RLOCUS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:37 $

% Check optional inputs EXTRAS
nopt = length(Extras);
switch nopt
   case 0
      k = [];
   case 1
      k = Extras{1};
   otherwise
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
end
   
% Map delays to poles at z=0 in discrete-time case and check if root locus
% is computable for specified systems
for ct=1:length(sysList)
   sys = sysList(ct).System;
   if isdt(sys) && hasdelay(sys)
      sys = delay2z(sys);
   end
   sysList(ct).System = checkComputability(sys,'rlocus');
end

