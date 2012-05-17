function yfi = uplus(xfi)
% Embedded MATLAB Library function for @fi/uplus.
%
% UPLUS(A) will return the unary plus of A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/uplus.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2007/10/15 22:43:24 $

% Get the numerictype and fimath of xfi and call eml_uplus
tx = eml_typeof(xfi);
fx = eml_fimath(xfi);
yfi = eml_uplus(xfi,tx,fx);
%----------------------------------------------------