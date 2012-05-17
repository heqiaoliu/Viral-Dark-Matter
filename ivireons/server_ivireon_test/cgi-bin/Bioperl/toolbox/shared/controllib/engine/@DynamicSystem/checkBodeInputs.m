function [sysList,w] = checkBodeInputs(sysList,Extras)
% Validates input arguments to BODE/NYQUIST/NICHOLS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:33 $

% Check optional inputs EXTRAS
nopt = length(Extras);
switch nopt
   case 0
      w = [];
   case 1
      w = checkFreqSpec(Extras{1});
   otherwise
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
end
