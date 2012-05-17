function varargout = zpk(Hb)
%ZPK  Discrete-time filter zero-pole-gain conversion.
%   [Z,P,K] = ZP(Hb) returns the zeros, poles, and gain corresponding to the
%   discrete-time filter Hb in vectors Z, P, and scalar K respectively.
%
%   See also DFILT.   
  
%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2007/12/14 15:07:41 $

if length(Hb) > 1,
    error(generatemsgid('InvalidDimensions'),'ZPK does not support vector inputs.');
end

Hd = dispatch(Hb);
[z,p,k] = zpk(Hd);

if nargout
    varargout = {z,p,k};
else
    zplaneplot(z,p);

    title('Pole/Zero Plot');

    % Turn on the grid.
    grid on;
end
