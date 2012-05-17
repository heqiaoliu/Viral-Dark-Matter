function boo = isstatic(D)
% True for static gains

%      Copyright 1986-2005 The MathWorks, Inc.
%      $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:47 $
boo = (all(cellfun('length',D.num(:))<=1) && ...
   all(cellfun('length',D.den(:))<=1) && ~hasdelay(D));
