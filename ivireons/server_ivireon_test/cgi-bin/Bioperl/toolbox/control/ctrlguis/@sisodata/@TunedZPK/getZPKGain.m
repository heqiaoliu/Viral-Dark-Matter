function Gain = getZPKGain(this,flag)
%GETZPKGAIN   Get ZPK model gain.
%
%   GAIN = GETZPKGAIN(MODEL) computes the gain of the ZPK representation of MODEL.
%   GAIN = GETZPKGAIN(MODEL,'sign') computes the sign of the ZPK gain.
%   GAIN = GETZPKGAIN(MODEL,'mag') computes the magnitude of the ZPK gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2006/06/20 20:01:09 $

% Convert gain to zpk format
Gain = this.Gain * formatfactor(this,'z');

if nargin==2
   if strcmpi(flag(1),'m')
      Gain = abs(Gain);
   elseif Gain==0
      Gain = 1;  % beware of compensator set to zero
   else
      Gain = sign(Gain);
   end
end