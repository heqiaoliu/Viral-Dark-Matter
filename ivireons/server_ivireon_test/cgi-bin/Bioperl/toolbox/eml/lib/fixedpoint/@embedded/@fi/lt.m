function c = lt(a0,b0)
% Embedded MATLAB function the @fi/lt (<) operation

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/lt.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.8 $  $Date: 2010/01/25 21:35:46 $

eml_allow_mx_inputs;

eml_lib_assert(eml_scalexp_compatible(a0,b0), 'fixedpoint:fi:dimagree', 'Matrix dimensions must agree.');

if eml_ambiguous_types
    c = eml_lt(a0,b0);
    return;
end

if ( (isfi(a0) && isfixed(a0)) || ...
     (isfi(b0) && isfixed(b0)) )
    % One of the inputs (or both) is FI object with Fixed datatype
    if isfi(a0) && ~isfi(b0) % fi relop non-fi

        eml_assert(eml_is_const(b0),'In fi < non-fi, the non-fi must be a constant.');
        a = a0;
        b = eml_type_relop_const(a0, b0);
        
    elseif ~isfi(a0) && isfi(b0) % non-fi relop fi

        eml_assert(eml_is_const(a0),'In fi < non-fi, the non-fi must be a constant.');
        a = eml_type_relop_const(b0, a0);
        b = b0;
        
    elseif isfi(a0) && isfi(b0) % fi relop fi
        
        eml_check_same_bias(a0, b0);
        a = a0; 
        b = b0;
        
    else % nonfi relop nonfi
        
        a = a0; 
        b = b0;
        
    end

    [a1 b1] = eml_make_same_complexity(a,b);
    c = eml_lt(a1,b1);

elseif ( isfi(a0) && isfloat(a0) ) || ...
        ( isfi(b0) && isfloat(b0) )
    % True Double or True Single FI
    
    % call MATLAB LE directly
    check4constNonFI   = false; % non-FI need not be constant
    check4numericData  = true;  % non-FI must be numeric
    check4sameDatatype = false; % The datatypes of two inputs need not be same
    [a,b] = eml_fi_cast_two_inputs(a0,b0,'<',check4constNonFI,...
                                   check4numericData,check4sameDatatype);

    c = eml_lt(a,b);

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('LT','fixed-point,double, or single');
end

%--------------------------------------------------------------------------
