function eml_statop_input_and_index_checks(x, fnname, dimx)%#eml
%EML_STATOP_INPUT_AND_INDEX_CHECKS Internal use only function
%   EML_STATOP_INPUT_AND_INDEX_CHECKS(X, FNNAME, DIMX) validates inputs X
%   and DIMX for statistical function given by 'FNNAME'.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/09/09 21:06:35 $

eml_lib_assert(~(isfi(x)&&isslopebiasscaled(numerictype(x))), ...
    ['fi:' fname ':slopeBiasNotSupported'], ...
    ['Inputs to ''' fnname ''' that are FI objects must have an integer power-'...
    'of-two slope, and a bias of 0.']);

eml_lib_assert(isnumeric(dimx), ['fi:' fname ':dimMustBeNumeric'],...
    ['Dimension input to ''' fnname ''' must be of type ''numeric''.']);

