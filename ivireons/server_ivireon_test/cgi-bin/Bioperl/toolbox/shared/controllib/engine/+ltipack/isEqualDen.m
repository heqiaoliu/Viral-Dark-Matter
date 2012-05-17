function tf = isEqualDen(varargin)
% Checks if a set of denominator vectors are all equal up to 
% leading zeros.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:51 $

% Remove leading zeros
for ct=1:nargin
   den = varargin{ct};
   if den(1)==0
      varargin{ct} = den(find(den~=0,1):end);
   end
end

% Compare denominators
tf = isequal(varargin{:});
      
