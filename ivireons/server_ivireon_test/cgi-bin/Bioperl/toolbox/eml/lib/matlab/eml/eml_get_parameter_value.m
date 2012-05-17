function y = eml_get_parameter_value(k,default,varargin)
%Embedded MATLAB Private Function

%   Retrieves parameter values from a varargin list using a lookup value K
%   computed by EML_PARSE_PARAMETER_INPUTS.  See the help for that function
%   for example usage.

%   Copyright 2009 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_prefer_const(k);
if eml_const(k == zeros('uint32'))
    y = default;
elseif eml_const(k <= uint32(intmax('uint16')))
    y = varargin{k};
else
    vidx = eml_rshift(k,int8(16));
    s = varargin{vidx};
    fidx = eml_bitand(k,uint32(intmax('uint16')));
    fname = eml_getfieldname(s,fidx);
    y = eml_getfield(s,fname);
end
