function D = ss(this,NormalizedFlag)
%SS   Get SS model of tunable model.
%
%   D = SS(MODEL) returns the @ssdata representation of MODEL.
% 
%   D = SS(MODEL,'normalized') extracts the normalized @ssdata
%   representation where the ZPK gain has been replaced by its sign.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/05/19 22:43:30 $
if isempty(this.SSData.d)
   % Recompute normalized state-space model
   [z,p] = getPZ(this);
   [a,b,c,d] = zpkreal(z,p,getZPKGain(this,'sign'));
   this.SSData = ltipack.ssdata(a,b,c,d,[],this.Ts);
end
D = this.SSData;
if nargin==1
   g = getZPKGain(this,'mag');
   D.d = D.d * g;
   D.c = D.c * g;
end
