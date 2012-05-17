function w = checkFreqSpec(w)
% Checks frequency input is valid vector or frequency range.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:30 $

% Error checking
if isempty(w)
   w = [];
elseif iscell(w)
   % W = {WMIN , WMAX}
   if ~(numel(w)==2 && isscalar(w{1}) && isscalar(w{2}))
      ctrlMsgUtils.error('Control:analysis:rfinputs11')
   end
   wmin = w{1}(1);
   wmax = w{2}(1);
   if ~(isnumeric(wmin) && isreal(wmin) && isnumeric(wmax) && isreal(wmax) && wmin>0 && wmax>wmin)
      ctrlMsgUtils.error('Control:analysis:rfinputs11')
   end
   w = {full(double(wmin)),full(double(wmax))};
else
   if ~(isnumeric(w) && isreal(w) && isvector(w) && all(w>=0) && ~any(isnan(w)))
      ctrlMsgUtils.error('Control:analysis:rfinputs12')
   end
   w = full(double(w(:)));
end
