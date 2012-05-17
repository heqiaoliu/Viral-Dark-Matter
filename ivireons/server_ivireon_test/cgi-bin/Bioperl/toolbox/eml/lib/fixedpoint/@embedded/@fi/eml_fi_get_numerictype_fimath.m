function [t,f] = eml_fi_get_numerictype_fimath(a0,b0)
% Embedded MATLAB library function for casting the two inputs

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/eml_cast_two_inputs.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:42:30 $

eml_transient;
eml_allow_mx_inputs;

if ~isfi(a0) % (non-fi, fi)
    t = eml_typeof(b0);
    f = eml_fimath(b0);
else % (fi, fi) or (fi, non-fi)
    t = eml_typeof(a0);
    f = eml_fimath(a0);
end

%--------------------------------------------------------------------------
