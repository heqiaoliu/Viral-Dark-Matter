function hfi = eml_fi_checkforntype(var1,T,F,ERR,isautoscaled,isfimathlocal)
% EML_FI_CHECKFORNTYPE Private libarary function that errors if var1 (input to fi) 
% is not a constant and var2 to varN do not specify a numerictype.

% Copyright 2005-2009 The MathWorks, Inc.
%#eml
    
% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  
    
eml_prefer_const(var1);
eml_prefer_const(T);
eml_prefer_const(F);
eml_prefer_const(ERR);
eml_prefer_const(isautoscaled);
eml_prefer_const(isfimathlocal);

eml_assert(isempty(ERR),ERR);
eml_assert(~isautoscaled,['In fi(var1,var2,...varN) if var1 is not a constant ',...
                    'then var2 to varN must be or specify a complete numerictype.']);

hfi = eml_fimathislocal(eml_cast(var1,T,F),isfimathlocal);
%if eml_const(isfimathlocal)
%    hfi = eml_cast(var1,T,F);
%else
%    hfi = eml_fimathislocal(eml_cast(var1,T,F),false);
%end
    

%-------------------------------------------------------------------------------------
