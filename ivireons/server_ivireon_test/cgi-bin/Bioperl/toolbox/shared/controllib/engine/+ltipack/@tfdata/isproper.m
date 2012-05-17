function [boo,D] = isproper(D,varargin)
% Returns TRUE if model is proper.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:45 $
den = D.den;
boo = true;
for ct=1:numel(den)
   if den{ct}(1)==0,
      boo = false;
      return
   end
end
