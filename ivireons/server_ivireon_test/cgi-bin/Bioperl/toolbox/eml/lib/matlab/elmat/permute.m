function b = permute(a,order)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(~eml.isenum(order), ...
    'Enumerations not supported for ORDER input.');
eml_prefer_const(order);
eml_assert(eml_is_const(order) || eml_option('VariableSizing'), ...
    'ORDER must be constant.');
eml_assert(eml_is_const(size(order)), 'ORDER must be fixed-size.');
if ~isreal(order)
    b = permute(a,real(order));
    return
end
% eml_assert(isa(order,'double'), ...
%     'ORDER must contain double-precision indices');
nd = eml_const(cast(eml_ndims(a),eml_index_class));
np = eml_const(cast(eml_numel(order),eml_index_class));
eml_assert(np >= nd, ... %'EmbeddedMATLAB:permute:orderNeedsNElements', ...
    'ORDER must have at least N elements for an N-D array.');
eml_lib_assert(eml_is_permutation(real(order)), ...
    'EmbeddedMATLAB:permute:invalidPermutation', ...
    'ORDER must be a permutation of 1:n, where n >= ndims(A).');
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
if eml_numel(order) == 2 && order(ONE) == TWO && order(TWO) == ONE
    b = a.';
    return
end
if eml_const(np > nd)
    insz = cast([size(a),ones(1,eml_const(eml_index_minus(np,nd)))], ...
        eml_index_class);
else
    insz = size(a);
end
outsz = zeros(1,eml_numel(insz));
for k = eml.unroll(ONE:eml_numel(insz));
    outsz(k) = insz(order(k));
end
b = eml.nullcopy(eml_expand(eml_scalar_eg(a),outsz));
if nomovement(order,a)
    for k = ONE:eml_numel(a)
        b(k) = a(k);
    end
    return
end
iwork = ones(1,np,eml_index_class);
for k = TWO:nd
    iwork(k) = eml_index_times(iwork(k-1),insz(k-1));
end
for k = eml_index_plus(nd,1):np
    iwork(k) = iwork(k-1);
end
inc = iwork(order);
iwork(:) = 0;
idest = ONE;
while true
    isrc = ONE;
    for k = TWO:np
        isrc = eml_index_plus(isrc,eml_index_times(iwork(k),inc(k)));
    end
    for k = ONE:outsz(1)
        b(idest) = a(isrc);
        idest = eml_index_plus(idest,1);
        isrc = eml_index_plus(isrc,inc(1));
    end
    for k = TWO:np
        iwork(k) = eml_index_plus(iwork(k),ONE);
        if iwork(k) < outsz(k)
            break
        elseif k == np
            return
        else
            iwork(k) = 0;
        end
    end
end

%--------------------------------------------------------------------------

function b = nomovement(p,a)
% Returns true if the permute operation will not result in data movement.
eml_allow_enum_inputs;
b = true;
if ~isempty(a)
    % Determine whether the order of nonsingleton dimensions is changed by
    % the permutation.
    plast = zeros(class(p));
    for k = ones(eml_index_class):eml_numel(p) % numel(p) >= eml_ndims(a)
        if size(a,p(k)) ~= 1
            if plast > p(k)
                b = false;
                return
            end
            plast = p(k);
        end
    end
end

%--------------------------------------------------------------------------
