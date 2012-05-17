function propVal = get(a,propName)
% GET(A,PROPNAME) Embedded MATLAB Library function that gets the value of the 
% embedded.fi (A) property specified by PROPNAME      

% Copyright 2006-2009 The MathWorks, Inc.
%#eml

eml.extrinsic('eml_getfiprop_helper');
eml_prefer_const(propName);

% This function accepts mxArray input argument
eml_allow_mx_inputs;

% Error if incorrect number of inputs
eml_assert(nargin == 2,['Incorrect number of inputs.',...
                    ' The syntax get(a) is not supported.']);              
ain = eml_scalar_eg(a);

% Call the eml_getfimathprop_helper function in toolbox/fixedpoint
[propValScalar,errmsg,pseudoData] = eml_const(eml_getfiprop_helper(ain, propName, ~eml_is_const(a) , true));
if pseudoData
  propVal = double(a);
else
  propVal = propValScalar;
end
eml_assert(isempty(errmsg),errmsg);

%------------------------------------------------------------------------------

