function flg = isfimath(F)
% Embedded MATLAB Library function for isfimath.
%
% ISFIMATH(F) will return true if F is a embedded.fimath.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/isfimath.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2008/11/13 17:53:21 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');


% Return true if T is fimath, false otherwise
flg =  eml_const(isa(F,'embedded.fimath'));
%----------------------------------------------------
