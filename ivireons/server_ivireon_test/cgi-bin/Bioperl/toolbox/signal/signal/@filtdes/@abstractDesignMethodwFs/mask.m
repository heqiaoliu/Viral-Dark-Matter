function varargout = mask(d, hax)
%MASK Draws the mask to an axes.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/07/01 20:07:39 $

if nargin < 2, hax = gca; end

h = info2mask(maskinfo(d), hax);

if nargout, varargout = {h}; end

% [EOF]
