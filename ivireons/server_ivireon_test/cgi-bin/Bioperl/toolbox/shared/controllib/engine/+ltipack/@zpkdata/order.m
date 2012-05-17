function ns = order(D)
% Computes order of ZPK models

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:48 $
[ro,co] = getOrder(D);
ns = min(ro,co);