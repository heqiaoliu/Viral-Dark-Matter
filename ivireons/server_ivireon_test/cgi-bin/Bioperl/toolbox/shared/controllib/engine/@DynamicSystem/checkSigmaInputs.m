function [sysList,wspec,type] = checkSigmaInputs(sysList,Extras)
% Validates input arguments to SIGMA.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:38 $

% Check optional inputs EXTRAS
nopt = length(Extras);
switch nopt
   case 0
      wspec = [];  type = 0;
   case 1
      if ischar(Extras{1}) % 'inv'
         type = Extras{1};  wspec = [];  
      else
         wspec = checkFreqSpec(Extras{1});  type = 0;
      end
   case 2
      wspec = checkFreqSpec(Extras{1});
      type = Extras{2};
   otherwise
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
end

% Validate TYPE
if ~isequal(size(type),[1 1]) || ~any(type==[0 1 2 3])
    ctrlMsgUtils.error('Control:analysis:rfinputs07')
elseif type>0
   % Check systems are square for TYPE 1,2,3
   for ct=1:length(sysList),
      [ny,nu] = iosize(sysList(ct).System);
      if ny~=nu,
         ctrlMsgUtils.error('Control:analysis:rfinputs07')
      end
   end
end
