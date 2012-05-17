function h = elliplpmin(mode)
%ELLIPLPMIN   Construct an ELLIPLPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:56:20 $

h = fmethod.elliplpmin;

h.DesignAlgorithm = 'Elliptic';

if nargin > 0,
    h.MatchExactly = mode;
end
% [EOF]
