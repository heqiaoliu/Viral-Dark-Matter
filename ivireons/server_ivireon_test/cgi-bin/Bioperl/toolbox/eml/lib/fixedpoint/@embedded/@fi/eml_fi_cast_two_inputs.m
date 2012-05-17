function [aOut,bOut] = eml_fi_cast_two_inputs(a0,b0,operation,check4constNonFI,...
                                              check4numericData,check4sameDatatype)
% Embedded MATLAB library function for casting the two inputs

% Copyright 2007-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2009/04/21 03:12:21 $

eml.extrinsic('sprintf');
eml.extrinsic('eml_fi_math_with_same_types');

eml_allow_mx_inputs;

if (length(operation) > 2) % assuming this will be a function form
                           % rather than an operator
                           % for example operation might be conv() 
			               % in that case the message structure needs to be
			               % slightly different
    assertMsg_constNonFi = eml_const(sprintf(['In %s(fi,non-fi), the non-fi must be a constant.'],operation));
else
    assertMsg_constNonFi  = eml_const(sprintf(['In fi %s non-fi, the non-fi must be a constant.'],operation));
end
assertMsg_numericData = eml_const('Data must be numeric.');

if ~isfi(b0) % (fi, non-fi)
    if check4constNonFI
        eml_assert(eml_is_const(b0),assertMsg_constNonFi);
    end        
    if check4numericData
        eml_assert(isnumeric(b0),assertMsg_numericData);
    end        
    dType = eml_fi_getDType(a0);
elseif ~isfi(a0) % (non-fi, fi)
    if check4constNonFI
        eml_assert(eml_is_const(a0),assertMsg_constNonFi);
    end        
    if check4numericData
        eml_assert(isnumeric(a0),assertMsg_numericData);
    end        
    dType = eml_fi_getDType(b0);
else % (fi, fi)
    ta = eml_typeof(a0); tb = eml_typeof(b0);
    if check4sameDatatype
        % Verify that the datatypes are the same
        % - Single with Double not allowed
        [ERR,a2SD,b2SD,Tsd] = eml_const(eml_fi_math_with_same_types(ta,tb));
        eml_assert(isempty(ERR),ERR);
    end
    % The two datatypes are same
    dType = eml_fi_getDType(a0);
end

aOut = eml_cast(a0,dType);
bOut = eml_cast(b0,dType);

%--------------------------------------------------------------------------
