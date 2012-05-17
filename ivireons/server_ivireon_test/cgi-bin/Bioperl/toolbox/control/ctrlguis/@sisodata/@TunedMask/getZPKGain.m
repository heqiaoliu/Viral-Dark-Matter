function Gain = getZPKGain(this,flag)
%GETZPKGAIN   Get ZPK model gain.
%
%   GAIN = GETZPKGAIN(MODEL) computes the gain of the ZPK representation of MODEL.
%   GAIN = GETZPKGAIN(MODEL,'sign') computes the sign of the ZPK gain.
%   GAIN = GETZPKGAIN(MODEL,'mag') computes the magnitude of the ZPK gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:08 $

if nargin==1
   Gain = this.ZPKData.k;
elseif strcmpi(flag(1),'m')
   Gain = abs(this.ZPKData.k);
else
   Gain = sign(this.ZPKData.k);
end