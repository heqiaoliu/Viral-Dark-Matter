function propVal = get(a,propName)
% GEF(A,PROPNAME) Embedded MATLAB Library function that gets the value of the 
% embedded.fi (A) property specified by PROPNAME      

% This is a dummy function that returns a 0 for ambiguoous types

% Copyright 2006-2010 The MathWorks, Inc.
%#eml
eml.extrinsic('eml_scompget');
% This function accepts mxArray input argument
eml_allow_mx_inputs;

% Error if incorrect number of inputs
eml_assert(nargin == 2,['Incorrect number of inputs. The syntax ' ...
                    'get(a) is not supported.']);

if isa(a, 'function_handle')
    propVal = a('get',propName);
elseif eml_const(isa(a,'matlab.system.SystemBase'))
    eml_transient;
    eml_must_inline;
    comp = eml_sea_get_obj(a);
    [propVal,err] = eml_const(eml_scompget(comp,propName));
    if ~isempty(err)
        eml_assert(0,err);
    end  
else
    if eml_ambiguous_types
        propVal = 0;
    else
        eml_assert(0,['Function ''get'' is resolved in the MATLAB workspace.',...
                      'Please call this function using eml.extrinsic(''get'') ' ...
                      'or feval when the input is not a fi, numerictype ' ...
                      'or a fimath.']);
        %propVal = feval('get',a,propName);
    end
end
%------------------------------------------------------------------------------
