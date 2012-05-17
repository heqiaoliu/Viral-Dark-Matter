function [z,p,k] = zpk(Hd)
%ZPK  Discrete-time filter zero-pole-gain conversion.
%   [Z,P,K] = ZPK(Hd) returns the zeros, poles, and gain corresponding to the
%   discrete-time filter Hd in vectors Z, P, and scalar K respectively.
%
%   See also DFILT.

%   Author: Thomas A. Bryan
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2006/06/27 23:34:54 $

% Check if all stages have the same overall rate change factor
checkvalidparallel(Hd);

[b,a] = tf(Hd);
[z,pnotused,k] = tf2zpk(b,a);

p = [];
for n = 1:nstages(Hd),
    [znotused,p1,knotused] = zpk(Hd.Stage(n)); % Use this to get the poles only
    p = [p;p1];
end
