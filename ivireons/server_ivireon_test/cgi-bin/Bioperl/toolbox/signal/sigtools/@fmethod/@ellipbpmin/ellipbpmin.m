function h = ellipbpmin(mode)
%ELLIPBPMIN   Construct an ELLIPBPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:54:59 $

h = fmethod.ellipbpmin;
h.DesignAlgorithm = 'Elliptic';

if nargin > 0,
    h.MatchExactly = mode;
end
% [EOF]
