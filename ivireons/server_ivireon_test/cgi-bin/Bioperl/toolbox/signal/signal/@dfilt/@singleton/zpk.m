function [z,p,k] = zpk(Hd)
%ZPK  Discrete-time filter zero-pole-gain conversion.
%   [Z,P,K] = ZPK(Hd) returns the zeros, poles, and gain corresponding to the
%   discrete-time filter Hd in vectors Z, P, and scalar K respectively.
%
%   Example:
%     [b,a] = butter(3,.4);
%     Hd = dfilt.df2t(b,a);
%     [z,p,k] = zpk(Hd)
%
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 15:10:00 $

if ~isequal(size(Hd),[1,1]),
    error(generatemsgid('InvalidDimensions'),'Input must be a DFILT object of length 1.');
end         

[b,a] = tf(Hd);
[z,p,k] = tf2zpk(b,a);
