function y = isequal(f1,f2)

% Copyright 2006-2007 The MathWorks, Inc.
%#eml
    eml_prefer_const(f1);
    eml_prefer_const(f2);
    eml_assert(eml_is_const(f1), 'Fimath must be constant');
    eml_assert(eml_is_const(f2), 'Fimath must be constant');
    y = false;
    y = eml_const(feval('isequal',f1,f2));
