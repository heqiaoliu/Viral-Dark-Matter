function [num,den] = thistf(Hd)
%THISTF  Convert to transfer function.
%   [NUM,DEN] = THISTF(Hd) converts discrete-time filter Hd to numerator and
%   denominator vectors.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:45:11 $

% This should be private

num = Hd.Numerator;
den = 1;
