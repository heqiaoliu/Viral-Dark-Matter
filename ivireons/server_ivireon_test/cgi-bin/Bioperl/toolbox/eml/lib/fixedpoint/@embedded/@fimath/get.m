function propVal = get(F,propName)
% GET(F,PROPNAME) Embedded MATLAB Library function that gets the value of the 
% embedded.fimath (F) property specified by PROPNAME      

% Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml.extrinsic('eml_getfimathprop_helper');
eml_prefer_const(F);
eml_prefer_const(propName);

% This function accepts mxArray input argument
eml_allow_mx_inputs;

% Error if incorrect number of inputs
eml_assert(nargin == 2,['Incorrect number of inputs.',...
                    ' The syntax get(F) is not supported.']);
eml_assert(eml_is_const(F), 'First argument to ''get'' must be constant'); 
% Call the eml_getfimathprop_helper function in toolbox/fixedpoint
[propVal,errmsg] = eml_const(eml_getfimathprop_helper(F,propName));
eml_assert(isempty(errmsg),errmsg);

%------------------------------------------------------------------------------

