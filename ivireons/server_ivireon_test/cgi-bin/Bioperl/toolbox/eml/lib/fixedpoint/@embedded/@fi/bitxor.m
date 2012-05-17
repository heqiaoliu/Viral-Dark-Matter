function c = bitxor(a,b)
% Embedded MATLAB Library function.
%
% BITXOR Returns bitwise AND
% C = bitxor(a,b) returns the bitwise XOR of argument a and b, 
% where a and b are:
% 1. both fi object matrices 
% 2. or a is a fi object matix and b is a scalar fi object, or vice versa
% with the following conditions:
%    i)   a and b must have the same "WordLength"
%    ii)  a and b must have the same "FractionLength"
%    iii) a and b must be the same dimension or a or b is a scalar fi 
%    iv)  c = bitxor(int(a), int(b))
%    
% The following cases will not be handled by this function:
%    a and b are non-fi objects
%
% The following cases will error out:
% 1. a is fi but b is non-fi, or vice versa
% 2. a and b have different dimensions
% 3. a and b have different numeric types
% 4. a and b have different fimath
% 5. None of the two inputs has fixed-point or scaled double datatype 
%
% Note: Difference from the MATLAB Toolbox BITXOR:
%   When a and b are both non-fi, the MATLAB Toolbox BITXOR restricts a and b 
%   to be unsigned (uint8, uint16, uint32, ...). Here we loose the restriction 
%   because the Fixed-Point Toolbox BITXOR accepts the signed case.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.7 $  $Date: 2009/03/05 18:46:57 $  

eml_assert(nargin == 2, 'Not enough input arguments.');

if eml_ambiguous_types
    if isscalar(a)
        c = eml_not_const(reshape(zeros(size(b)),size(b)));
    else
        c = eml_not_const(reshape(zeros(size(a)),size(a)));
    end
    return;
end

eml_assert(isfi(a)&&isfi(b), 'The inputs must be fi objects.');

% eml_bitand has restrictions on slope-bias scale fis.
eml_assert(~eml_isslopebiasscaled(a) && ~eml_isslopebiasscaled(b),...
           'Bit AND/OR/XOR operations do not support slope-bias scaled fis.');

if isfixed(a) || isfixed(b)
    % Fixed FI

    Ta = eml_typeof(a);
    Tb = eml_typeof(b);
    eml_assert(eml_const(isequal(Ta,Tb)), 'Bit AND/OR/XOR must have matching operand types. ');

    [F,cHasLocalFimath] = eml_checkfimathforbinaryops(a,b);
    
    eml_lib_assert(eml_scalexp_compatible(a,b), 'fixedpoint:fi:dimagree','Matrix dimensions must agree.');

    if isreal(a) && isreal(b)
        c_uint = eml_bitxor(a,b);
        c = eml_fimathislocal(eml_dress(c_uint, Ta, F),cHasLocalFimath);
        %if ~cHasLocalFimath
        %    c = eml_fimathislocal(c1,false);
        %else
        %    c = c1;
        %end
    else
        c_uint_r = eml_bitxor(real(a),real(b));
        c_uint_i = eml_bitxor(imag(a),imag(b));
        c_r = eml_dress(c_uint_r, Ta, F);
        c_i = eml_dress(c_uint_i, Ta, F);
        c  = eml_fimathislocal(complex(c_r, c_i),cHasLocalFimath);
        %if ~cHasLocalFimath
        %    c = eml_fimathislocal(c1,false);
        %else
        %    c = c1;
        %end
    end

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('BITXOR','fixed-point');
end

%-----------------------------------------------------------------------------------
