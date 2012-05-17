function flg = isnumerictype(T)
% Embedded MATLAB Library function for isnumerictype.
%
% ISNUMERICTYPE(T) will return true if T is a embedded.numerictype.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/isnumerictype.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2008/11/13 17:53:24 $

% Return true if T is numerictype, false otherwise
eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

flg =  eml_const(isa(T,'embedded.numerictype'));
%----------------------------------------------------
