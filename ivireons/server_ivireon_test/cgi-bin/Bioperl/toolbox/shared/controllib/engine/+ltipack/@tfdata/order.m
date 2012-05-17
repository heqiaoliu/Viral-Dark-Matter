function ns = order(D)
% Computes order of TF models

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:53 $
[ro,co] = getOrder(D);
ns = min(ro,co);