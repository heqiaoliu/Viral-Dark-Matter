function TFData = tf(PID)
% Conversion to @tfdata

%   Author(s): Rong Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:23 $

% Compute numerator and poles based on Ts and discretization methods
[Num Pole] = getTF(PID);
% Compute denominator
Den = poly(Pole);
Den = [zeros(1,length(Num)-length(Den)) Den];
% Return tfdata object (note that tfdata takes cell array)
TFData = ltipack.tfdata({Num},{Den},PID.Ts);
    