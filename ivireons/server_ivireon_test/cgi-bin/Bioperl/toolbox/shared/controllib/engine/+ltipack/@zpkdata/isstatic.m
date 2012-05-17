function boo = isstatic(D)
% True for static gains

%      Copyright 1986-2005 The MathWorks, Inc.
%      $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:42 $
Mask = D.k==0 | (cellfun('isempty',D.z) & cellfun('isempty',D.p));
boo = (all(Mask(:)) && ~hasdelay(D));