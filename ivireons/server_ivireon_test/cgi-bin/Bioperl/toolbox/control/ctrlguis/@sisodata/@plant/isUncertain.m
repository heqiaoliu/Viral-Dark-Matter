function boo = isUncertain(this)
% Checks if the plant is uncertain (e.g. an array)

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:22:24 $
boo = numel(this.getP)>1;
   