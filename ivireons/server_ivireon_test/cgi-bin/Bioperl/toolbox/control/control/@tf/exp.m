function sys = exp(sys)
%EXP  Creates pure continuous-time delays.
%
%   The transfer function of a pure delay TAU is 
%      d(s) = exp(-tau*s)
%   You can specify this transfer function using EXP:
%      s = zpk('s')
%      d = exp(-tau*s)
%
%   More generally, given a 2D array M,
%      s = zpk('s')
%      D = exp(-M*s)
%   creates an array D of pure delays where 
%      D(i,j) = exp(-M(i,j)*s) .
%   All entries of M should be non negative for causality.
%
%   See also TF, ZPK.

%   Author(s):  P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2010/02/08 22:29:11 $
if ~isct(sys)
   ctrlMsgUtils.error('Control:transformation:exp4')
end
D = sys.Data_;
try
   for ct=1:numel(D)
      D(ct) = exp(D(ct));
   end
catch E
   throw(E)
end
sys.Data_ = D;
