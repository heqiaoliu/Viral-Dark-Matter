function flg = isfi(A)
% Embedded MATLAB Library function for isfi.
%
% ISFI(A) will return true if A is of type embedded.numerictype.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/isfi.m $
% Copyright 2002-2010 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2010/04/05 22:15:12 $

% Check for nargin and assert if not 2
eml_assert(nargin==1,'Not enough input arguments.');


% Return true if A is fi, false otherwise
flg =  eml_const(isnumerictype(eml_typeof(A)));
%----------------------------------------------------
