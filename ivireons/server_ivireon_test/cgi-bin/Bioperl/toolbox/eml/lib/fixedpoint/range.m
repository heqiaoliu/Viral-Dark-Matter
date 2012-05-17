function [rangexfi1,rangexfi2] = range(xfi)
% Embedded MATLAB Library function for range.
%
% RANGE(A) will return the range of A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/range.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2007/10/15 22:41:56 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

if eml_ambiguous_types
    if nargout == 1
        rangexfi1 = [0,0];
        rangexfi2 = [];
    elseif nargout == 2
        rangexfi1 = 0;
        rangexfi2 = 0;
    end
    return;
end

eml_assert(isfi(xfi),['Function ''range'' is not defined for a first argument of class ',class(xfi)]);
rangexfi1 = 0;
rangexfi2 = 0;

%----------------------------------------------------
