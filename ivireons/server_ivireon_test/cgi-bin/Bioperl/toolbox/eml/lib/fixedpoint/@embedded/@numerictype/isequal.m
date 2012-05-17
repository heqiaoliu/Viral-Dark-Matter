function y = isequal(t1,t2)

% Copyright 2006-2007 The MathWorks, Inc.
%#eml

    eml_assert(eml_is_const(t1), 'Numerictype must be constant');
    eml_assert(eml_is_const(t2), 'Numerictype must be constant');
    y = false;
    y = eml_const(feval('isequal',t1,t2));
