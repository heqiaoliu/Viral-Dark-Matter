function h = ellipbsmin(mode)
%ELLIPBSMIN   Construct an ELLIPBSMIN object.
 
%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:55:28 $

h = fmethod.ellipbsmin;
h.DesignAlgorithm = 'Elliptic';

if nargin > 0,
    h.MatchExactly = mode;
end
% [EOF]
