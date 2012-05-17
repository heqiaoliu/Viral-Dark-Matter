function D = zpk(this,NormalizedFlag)
%ZPK   Get ZPK model of tunable model.
%
%   D = ZPK(MODEL) returns the @zpkdata representation of MODEL.
% 
%   D = ZPK(MODEL,'normalized') extracts the normalized @zpkdata
%   representation where the ZPK gain has been replaced by its sign.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:46:48 $
[Z,P] = getPZ(this);
if nargin==1
   K = getZPKGain(this);
else
   K = getZPKGain(this,'sign');
end
D = ltipack.zpkdata({Z},{P},K,this.Ts);     
