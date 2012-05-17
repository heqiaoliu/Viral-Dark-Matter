function ic = getinitialconditions(Hd)
%GETINITIALCONDITIONS Get the initial conditions.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/14 04:01:19 $

s = Hd.States;
ic.Num = double(s.Numerator);
ic.Den = double(s.Denominator);

% [EOF]
