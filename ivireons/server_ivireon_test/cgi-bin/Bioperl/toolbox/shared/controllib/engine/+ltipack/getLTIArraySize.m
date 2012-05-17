function ArraySize = getLTIArraySize(DimOffset,varargin)
% Determines LTI array size from system parameters.
%
% Example: ArraySize = getLTIArraySize(2,A,B,C,D) uses the dimensions > 2
% of A,B,C,D to determine the LTI array sizes. Arrays with only two dimensions 
% are ignored and all arrays with more than two dimensions should have
% matching sizes.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:37 $
ArraySize = [1 1];
for ct=1:nargin-1
   s = size(varargin{ct});
   nd = length(s);
   s = [s(DimOffset+1:nd) , ones(1,2-nd+DimOffset)];
   if any(s~=1)
      if all(ArraySize==1)
         ArraySize = s;
      elseif ~isequal(s,ArraySize)
         ArraySize = [];   return
      end
   end
end
