function a = circshift(a,p)
%Embedded MATLAB Library Function

%   Notes:
%   Elements of P must be between -intmax and intmax.
%   P can belong to any float or integer class (not just 'double').

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin == 2, 'Not enough input arguments.');
eml_prefer_const(p);
eml_lib_assert(~eml.isenum(p) && isa(p,'numeric') &&  ...
    isreal(p) && isvector(p) && inrange(p), ...
    'EmbeddedMATLAB:circshift:InvalidShiftType', ...
    ['Invalid shift argument: must be a finite, real, integer vector ', ...
    'with entries between -intmax(''' eml_index_class ''') and ', ...
    'intmax(''' eml_index_class ''').']);
% Dispense with the degnerate cases.
if isempty(a) || isscalar(a)
    return
end
ONE = ones(eml_index_class);
atmp = eml.nullcopy(eml_expand(eml_scalar_eg(a),[1,max(size(a))]));
% Since we're looping through the dimensions sequentially, it turns out
% that we can save some arithmetic by computing vstride and npages as we
% go, rather than call eml_matrix_vstride and eml_matrix_npages.
vstride = ONE;
npages = cast(eml_numel(a),eml_index_class);
for dim = ONE:min(ndims(a),eml_numel(p))
    vlen = cast(size(a,dim),eml_index_class);
    npages = eml_index_rdivide(npages,vlen);
    if vlen > 1
        % Convert shift to a starting index.
        abspdim = cast(abs(p(dim)),eml_index_class);
        rm1 = eml_index_rdivide(abspdim,vlen);
        rm1 = eml_index_times(rm1,vlen);
        rm1 = eml_index_minus(abspdim,rm1);
        if rm1 > 0
            if p(dim) > 0
                rm1 = eml_index_minus(vlen,rm1);
            end
            r = eml_index_plus(rm1,1);
            % vstride = eml_matrix_vstride(a,dim);
            % npages = eml_matrix_npages(a,dim);
            vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
            i2 = zeros(eml_index_class);
            for i = 1:npages
                i1 = i2;
                i2 = eml_index_plus(i2,vspread);
                for j = 1:vstride
                    i1 = eml_index_plus(i1,1);
                    i2 = eml_index_plus(i2,1);
                    % Copy a(i1:vstride:i2) to atmp.
                    ia = i1;
                    for k = 1:vlen
                        atmp(k) = a(ia);
                        ia = eml_index_plus(ia,vstride);
                    end
                    % Copy shifted atmp back into a.
                    ia = i1;
                    for k = r:vlen
                        a(ia) = atmp(k);
                        ia = eml_index_plus(ia,vstride);
                    end
                    for k = 1:rm1
                        a(ia) = atmp(k);
                        ia = eml_index_plus(ia,vstride);
                    end
                end
            end
        end
    end
    % Update vstride for the next dimension.
    vstride = eml_index_times(vstride,vlen);
end

%--------------------------------------------------------------------------

function pok = inrange(p)
% Return true if the input vector p contains all integers from
% -intmax(eml_index_class) to intmax(eml_index_class).
pok = true;
for k = 1:eml_numel(p)
    pk = p(k);
    abspk = abs(pk);
    if pk ~= floor(pk) || abspk > intmax(eml_index_class) || ...
            (pk < 0 && pk ~= -abspk) % abs(pk) saturated.
        pok = false;
        break
    end
end

%--------------------------------------------------------------------------
