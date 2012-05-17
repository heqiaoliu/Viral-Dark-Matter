function w = bitsra(u, v)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.5 $  $Date: 2009/12/28 04:10:41 $

eml_assert((nargin > 1), 'Not enough input arguments.');
if eml_ambiguous_types
    if isscalar(u)
        w = eml_not_const(reshape(zeros(size(v)),size(v)));
    else
        w = eml_not_const(reshape(zeros(size(u)),size(u)));
    end
else
    eml_prefer_const(v);
    if eml_is_const(v)
        eml_assert(...
            (isnumeric(v) && isscalar(v) && isequal(floor(v), v) && (v >= 0)), ...
            'K must be a scalar, integer-valued, and greater than or equal to zero in BITSRA(A,K).');
    end
    if isfloat(u)
        % Using EML_LDEXP avoids extra generated saturation code.
        % Also, note that EML_LDEXP only handles REAL SCALAR inputs.
        w = eml.nullcopy(u);
        for idx = 1:numel(u)
            if isreal(u)
                w(idx) = eml_ldexp(u(idx), -v);
            else
                wRe    = eml_ldexp(real(u(idx)), -v);
                wIm    = eml_ldexp(imag(u(idx)), -v);
                w(idx) = complex(wRe, wIm);
            end
        end
    elseif isinteger(u)
        switch class(u)
          case 'int8'
            temp = fi(u,1,8,0);
          case 'int16'
            temp = fi(u,1,16,0);
          case 'int32'
            temp = fi(u,1,32,0);
          case 'int64'
            temp = fi(u,1,64,0);
          case 'uint8'
            temp = fi(u,0,8,0);
          case 'uint16'
            temp = fi(u,0,16,0);
          case 'uint32'
            temp = fi(u,0,32,0);
          case 'uint64'
            temp = fi(u,0,64,0);
          otherwise
            eml_lib_assert(0,'fi:eml:bitsra:UnrecognizedInteger','Unrecognized integer type.');
        end
        w  = int(bitsra(temp, v));
    else
        eml_assert(false,['Function ''bitsra'' is not defined for a first argument of class ',class(u) '.']);
        w = 0;
    end
end
