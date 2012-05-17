function propVal = get(T,propName)
% GET(T,PROPNAME) Embedded MATLAB Library function that gets the value of the 
% embedded.NumericType (T) property specified by PROPNAME      

% Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml.extrinsic('eml_getnumerictypeprop_helper');
eml_prefer_const(T);
eml_prefer_const(propName);
    
% This function accepts mxArray input argument
eml_allow_mx_inputs;

% Error if incorrect number of inputs
eml_assert(nargin == 2,'Incorrect number of inputs');
eml_assert(eml_is_const(T), 'First argument to ''get'' must be constant'); 
% Call the eml_getnumerictypeprop_helper function in toolbox/fixedpoint
[propVal,errmsg] = eml_const(eml_getnumerictypeprop_helper(T,propName));
eml_assert(isempty(errmsg),errmsg);

%------------------------------------------------------------------------------

