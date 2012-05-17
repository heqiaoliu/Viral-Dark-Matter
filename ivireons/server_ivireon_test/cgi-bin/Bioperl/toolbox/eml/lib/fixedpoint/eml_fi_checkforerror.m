function hfi = eml_fi_checkforerror(val,T,F,ERR,isfimathlocal)
% Embedded MATLAB private Library function helper for fi the fixed-point value constructor.
%
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2009/02/18 02:05:57 $
  
  
% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

eml_prefer_const(val);
eml_prefer_const(T);
eml_prefer_const(F);
eml_prefer_const(ERR);
eml_prefer_const(isfimathlocal);

eml_assert(isempty(ERR),ERR);      

hfi = eml_fimathislocal(eml_cast(val,T,F),isfimathlocal);


