function [z,p,k] = zpk(this)
%ZPK  Discrete-time filter zero-pole-gain conversion.
%   [Z,P,K] = ZP(this) returns the zeros, poles, and gain corresponding to the
%   discrete-time filter this in vectors Z, P, and scalar K respectively.
%
%   See also DFILT.   
  
%   Author: R. Losada, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:45:15 $

sosm = get(this, 'sosMatrix');

msgid = 'signal:dfilt:scalevalues';
msg = [];
nsecs = size(sosm, 1);

if length(this.ScaleValues) > nsecs + 1,
    msg = sprintf('Too many scale values, only using the first %d.',nsecs+1);
    warning(msgid, msg);
end

z = [];
p = [];
k = prod(this.ScaleValues);
for indx = 1:size(sosm,1)
  [z1,p1,k1] = sos2zp(sosm(indx,:));
  z = [z;z1];
  p = [p;p1];
  k = k*k1;
end

% [EOF]
