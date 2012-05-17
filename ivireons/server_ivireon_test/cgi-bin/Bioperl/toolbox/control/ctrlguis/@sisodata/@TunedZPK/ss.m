function D = ss(this,NormalizedFlag)
%SS   Get SS model of tunable model.
%
%   D = SS(MODEL) returns the @ssdata representation of MODEL.
% 
%   D = SS(MODEL,'normalized') extracts the normalized @ssdata
%   representation where the ZPK gain has been replaced by its sign.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/05/19 22:43:32 $
if isempty(this.SSData) || isempty(this.SSData.d)
   % Recompute normalized state-space model
   [z,p] = getPZ(this);
   [a,b,c,d,e] = zpkreal(z,p,getZPKGain(this,'sign'));
   this.SSData = ltipack.ssdata(a,b,c,d,e,this.Ts);
end
D = this.SSData;
if nargin==1
   % Return SS of model, balance gain across b and c matrices
   g = getZPKGain(this,'mag');
   D.d = D.d * g;
   D.c = D.c * sqrt(g);
   D.b = D.b * sqrt(g);
end
