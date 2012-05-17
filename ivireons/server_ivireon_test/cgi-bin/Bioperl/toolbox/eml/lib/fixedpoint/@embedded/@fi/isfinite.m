function b = isfinite(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/isfinite.m $
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.3 $  $Date: 2007/10/15 22:42:50 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');

b = ~isinf(x) & ~isnan(x);

