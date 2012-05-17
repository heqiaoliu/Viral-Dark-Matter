function flg = isrow(A)
% Embedded MATLAB Library function for fixedpoint isrow.
%
% ISROW(A) will return true if A is a row vector

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/isrow.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2008/11/13 17:53:25 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

% Return true if A is row, false otherwise
flg = false;
if size(A,1)==1 && ndims(A)==2
    flg = true;
end

%----------------------------------------------------
