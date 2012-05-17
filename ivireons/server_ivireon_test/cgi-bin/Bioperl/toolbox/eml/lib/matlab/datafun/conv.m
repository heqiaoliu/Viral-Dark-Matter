function C = conv(A,B,shape)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(eml_is_const(isvector(A) && isvector(B)), ...
    ['Inputs must be vectors with at most one variable-length ', ...
    'dimension, the first dimension or the second. All other ', ...
    'dimensions must have a fixed length of 1.']);
eml_assert(isvector(A) && isvector(B), ... % 'MATLAB:conv:AorBNotVector', ...
    'A and B must be vectors.');
eml_assert(isa(A,'float'), ...
    ['Function ''conv'' is not defined for values of class ''' ...
    class(A) '''.']);
eml_assert(isa(B,'float'), ...
    ['Function ''conv'' is not defined for values of class ''' ...
    class(B) '''.']);
nA = cast(eml_numel(A),eml_index_class);
nB = cast(eml_numel(B),eml_index_class);
nApnB = eml_index_plus(nA,nB);
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
if nargin < 3
    shape = 'full';
else
    eml_assert(ischar(shape), ...
        'SHAPE must be ''full'', ''same'', or ''valid''.');
end
switch shape
    case 'full'
        if nA == ZERO || nB == ZERO
            nC = nApnB;
        else
            nC = eml_index_minus(nApnB,ONE);
        end
        joffset = ZERO;
        if eml_is_const(size(A)) && eml_is_const(size(B)) 
            if eml_numel(A) > eml_numel(B)
                isRow = size(A,1) == 1;
            else
                isRow = size(B,1) == 1;
            end
        else
            if eml_is_const(size(A)) && eml_numel(A) <= 1
                isRow = eml_is_const(size(B,1)) && size(B,1) == 1;
                matched = true;
            else
                isRow = eml_is_const(size(A,1)) && size(A,1) == 1;
                matched = isRow == (eml_is_const(size(B,1)) && size(B,1) == 1);
            end
            eml_lib_assert(matched || nC == 1 || eml_numel(A) > eml_numel(B), ...
                'EmbeddedMATLAB:conv:dynamicVectorOrientation', ...
                ['The output vector orientation cannot change. ', ...
                'To avoid this error, ensure that both input ', ...
                'vectors have the same orientation.']);
        end 
        assert(nC <= nApnB); %<HINT>
    case 'same'
        nC = nA;
        if nB < ONE
            joffset = ZERO;
        else
            joffset = eml_index_minus(nB,ONE)/2;
        end
        isRow = eml_is_const(size(A,1)) && size(A,1) == 1;
    case 'valid'
        if nB == 0
            joffset = nB;
        else
            joffset = eml_index_minus(nB,ONE);
        end
        if nA < joffset
            nC = ZERO;
        else
            nC = eml_index_minus(nA,joffset);
        end
        isRow = eml_is_const(size(A,1)) && size(A,1) == 1;
        assert(nC <= nA); %<HINT>
    otherwise
        eml_assert(false, ...
            'SHAPE must be ''full'', ''same'', or ''valid''.');
end
% Determine the output type.
abzero = eml_scalar_eg(A,B);
% Choose the orientation of C.
if isRow
    C = eml.nullcopy(eml_expand(abzero,[1,nC]));
else
    C = eml.nullcopy(eml_expand(abzero,[nC,1]));
end
% Quick return for the empty cases.
if isempty(A) || isempty(B) || nC == 0
    C(:) = abzero;
    return
end
% Do the convolution.
for jC = ONE:nC
    j = eml_index_plus(jC,joffset);
    jp1 = eml_index_plus(j,ONE);
    if nB < jp1 % ja1 = max(1,jp1-nB);
        jA1 = eml_index_minus(jp1,nB);
    else
        jA1 = ONE;
    end
    if nA < j % ja2 = min(nA,j);
        jA2 = nA;
    else
        jA2 = j;
    end
    s = abzero;
    for k = jA1:jA2
        s = s + A(k)*B(eml_index_minus(jp1,k));
    end
    C(jC) = s;
end
