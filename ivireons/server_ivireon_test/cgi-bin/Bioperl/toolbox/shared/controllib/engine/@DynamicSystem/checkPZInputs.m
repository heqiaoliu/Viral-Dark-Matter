function sysList = checkPZInputs(sysList,Extras)
% Validates input arguments to PZPLOT/IOPZPLOT.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:36 $
if ~isempty(Extras)
   ctrlMsgUtils.error('Control:analysis:rfinputs01')
end
% Check if pole/zero data is computable for specified systems
for ct=1:length(sysList)
   sysList(ct).System = checkComputability(sysList(ct).System,'pzmap');
end
