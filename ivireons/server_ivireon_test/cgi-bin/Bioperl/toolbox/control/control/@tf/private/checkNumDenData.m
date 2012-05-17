function C = checkNumDenData(C,NDstr)
% Checks that num,den data is properly formatted.

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.4 $  $Date: 2010/02/08 22:29:24 $

% Make sure both NUM and DEN are cell arrays
if ~iscell(C)
   % TF([1 0],[2 0]):  NUM should be a row vector
   C = {C};
end
% Check that all elements of NUM and DEN are row vectors
denflag = strcmp(NDstr,'D');
for ct=1:numel(C)
   nd = C{ct};
   if ~(isnumeric(nd) && isvector(nd) && size(nd,1)==1)
      ctrlMsgUtils.error('Control:ltiobject:tfProperties1')
   elseif denflag && all(nd==0),
      ctrlMsgUtils.error('Control:ltiobject:tfProperties3')
   else
      % Convert to full double
      C{ct} = double(full(nd));
   end
end
