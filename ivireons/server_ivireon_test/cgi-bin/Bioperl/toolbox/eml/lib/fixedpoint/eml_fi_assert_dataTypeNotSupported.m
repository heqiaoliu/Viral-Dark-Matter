function eml_fi_assert_dataTypeNotSupported(fcnName,dataTypes)
% Embedded MATLAB Library function for @fi/eps.
%
% EML_FI_ASSERT_DATATYPENOTSUPPORTED(A) will throw assertion

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/eml_fi_assert_dataTypeNotSupported.m $
% Copyright 2007-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2008/08/08 12:52:13 $

eml.extrinsic('sprintf');
eml.extrinsic('upper');
 
eml_assert(false,eml_const(sprintf(['The %s function can only be used with fi objects that have a %s data type.'],upper(fcnName),dataTypes)));

%----------------------------------------------------

