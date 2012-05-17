function c = bitcmp(a,bit)
% Embedded MATLAB Library function.
%
% BITCMP Complement bit.
%    C = BITCMP(A) returns a fi object whose stored-integer is the bit-wise complement 
%    over the stored-integer of fi objects a. 
%    A must be a fi object matrix, array, or a scalar fi object (signed or unsigned)
%
% The following cases will not be handled by this function:
%    a is not a fi object
%
% The following cases will error out:
%
% Note: Difference from the MATLAB Toolbox BITCMP:
%   When a is non-fi, the MATLAB Toolbox BITCMP restricts a to be unsigned 
%   (uint8, uint16, uint32, ...). Here we loose the restriction 
%   because the Fixed-Point Toolbox BITSET accepts the signed case.
%
%   The MATLAB Toolbox version allows both bitcmp(a)and bitcmp(a,N) 
%   The eML Fixed-Point version only allows bitcmp(a) format which is 
%   consistent with the Fixed-Point Toolbox version. 
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2009/03/30 23:29:52 $

% To make sure the number of the input arguments is right
eml_assert(nargin >= 1, 'Not enough input arguments.');

if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)), size(a)));
    return;
end

eml_assert(isfi(a), 'Input must be fi object.');

if isfixed(a)
    % Fixed FI

    % Extract the numerictype info
    Ta = eml_typeof(a);
    Fa = fimath(a);

    % If the input is slope-bias scaled, then it cannot be passed to eml_bitnot directly
    % And it is also not possible to pass in the signed stored-integer because only usigned
    % intgers can be passed directly to the eml_bitnot. However the stored-int can be passed
    % as a fi with the same signedness & word-length as Ta, but with slope = 1.0 & Bias = 0
    if isslopebiasscaled(Ta)
        Ta1 = numerictype(Ta.Signed,Ta.WordLength,0);
        a1 = eml_reinterpret(a,Ta1,Fa);
        c1_r = eml_bitnot(real(a1));
        c1int_r = eml_reinterpret(c1_r);
        
        % xxx Complex slope-bias fis will not be allowed in R2008b
        if ~isreal(a) 
            c1_i = eml_bitnot(imag(a1));
            c1int_i = eml_reinterpret(c1_i);
            
            c = eml_fimathislocal(eml_dress(complex(c1int_r,c1int_i),Ta,Fa),eml_fimathislocal(a));
        else
            c = eml_fimathislocal(eml_dress(c1int_r,Ta,Fa),eml_fimathislocal(a));
        end
    else % if binary-point scaled fi
        c_r = eml_bitnot(real(a));
        if ~isreal(a)
            c_i = eml_bitnot(imag(a));
            % The final result need to have the same numeric type as the inputs
            c = complex(c_r, c_i);
        else
            c = c_r;
        end
    end
    
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('BITCMP','fixed-point');
end

%-----------------------------------------------------------------------------------
