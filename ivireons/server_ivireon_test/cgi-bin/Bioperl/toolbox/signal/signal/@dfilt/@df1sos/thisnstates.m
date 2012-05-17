function n = thisnstates(Hd)
%NSTATES  Number of states in discrete-time filter.
%   NSTATES(Hd) returns the number of states in the discrete-time filter
%   Hd.  The number of states depends on the filter structure and the
%   coefficients.
  
%   Author: J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 18:57:23 $

n    = 2*order(Hd);

% [EOF]
