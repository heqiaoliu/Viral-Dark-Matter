function settag(h, tag)
%SETTAG Set up the base elements of the object
%   SETTAG(H, TAG)
%
%   Inputs:
%       TAG     - The tag of the object
%
%   If no input is given <package>.<class> is used.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:31:56 $

if nargin < 2, tag = class(h); end
set(h, 'Tag', tag);

% [EOF]
