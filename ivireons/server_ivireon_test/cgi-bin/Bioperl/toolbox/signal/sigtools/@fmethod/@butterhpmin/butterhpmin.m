function h = butterhpmin(matchExactly)
%BUTTERHPMIN   Construct a BUTTERHPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:51:08 $

h = fmethod.butterhpmin;

h.DesignAlgorithm = 'Butterworth';

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]