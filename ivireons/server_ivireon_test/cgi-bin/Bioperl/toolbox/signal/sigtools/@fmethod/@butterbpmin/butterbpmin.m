function h = butterbpmin(matchExactly)
%BUTTERBPMIN   Construct a BUTTERBPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:50:17 $

h = fmethod.butterbpmin;
h.DesignAlgorithm = 'Butterworth';

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
