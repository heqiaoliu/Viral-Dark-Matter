function numx = numberofelements(x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/isfinite.m $
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.4 $  $Date: 2007/10/15 22:41:54 $

if eml_ambiguous_types
    numx = 0;
    return;
end

eml_assert(isfi(x),['Function ''numberofelements'' is not defined for a first argument of class ',class(x) '.']);

numx = prod(size(x));

