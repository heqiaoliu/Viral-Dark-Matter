function b = repmat(a,m,n) 
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert_valid_size_arg(m);

eml_prefer_const(m);
ONE = ones(eml_index_class);

% Compute a "size" vector for the tilings, padded with ones as necessary so
% that eml_numel(tilesize) >= ndims(a).
if nargin == 3
    eml_prefer_const(n);
    eml_assert_valid_size_arg(n);
    mv = horzcat(m,n);
elseif isscalar(m)
    mv = [m,m];
else
    mv = m;
end
nmv = eml_numel(mv);
nda = eml_ndims(a);

if nda > nmv
    % Pad mv with ones to make it the same length as size(a).
    tilesize = [eml_cast(mv,'double'), ones(1,nda-nmv)];
    origsize = size(a);
else
    % Pad size(a) with ones to make it the same length as mv.
    tilesize = eml_cast(mv,'double');
    origsize = [size(a), ones(1,nmv-nda)];
end

% Compute the output size from size(a) and tilesize.
% outsize = [ size(a,1)*tilesize(1), size(a,2)*tilesize(2), ... ]
outsize = origsize .* tilesize;

if eml_is_const(size(a)) && isscalar(a)
    b = eml_expand(a,outsize);
    return
end

b = eml.nullcopy(eml_expand(eml_scalar_eg(a),outsize));
if isempty(b)
    return
end

if ndims(a) == 2
    % Efficient column-oriented algorithm.
    nrows = size(a,1);
    ncols = size(a,2);
    ntilerows = tilesize(1);
    ntilecols = eml_index_prod(tilesize,2,eml_numel(tilesize));
    ia = ONE;
    ib = ONE;
    % Since b is not empty, all of these loops execute at least once.
    for jtilecol = ONE:ntilecols
        iacol = ONE;
        for jcol = ONE:ncols
            for itilerow = ONE:ntilerows
                ia = iacol;
                for k = ONE:nrows
                    b(ib) = a(ia);
                    ia = eml_index_plus(ia,ONE);
                    ib = eml_index_plus(ib,ONE);
                end
            end
            iacol = ia;
        end
    end
else
    % N-D to N-D case. Use slow algorithm until we have cell arrays.
    asize = cast(padsize(size(a),ndims(b)),eml_index_class);
    bsize = cast(size(b),eml_index_class);
    db = ones(1,ndims(b),eml_index_class);
    da = db;
    for k = ONE:ndims(b)-1
        da(k+1) = eml_index_times(da(k),asize(k));
        db(k+1) = eml_index_times(db(k),bsize(k));
    end
    for ib = ONE:eml_numel(b)
        % Compute ia.  Basically ind2sub on ib, followed by an adjustment
        % to convert to a subscript vector for a, followed by sub2ind to
        % convert to a linear index of a.  The difference is that the
        % ind2sub and sub2ind parts are merged so that no temporary
        % subscript vector is needed.
        ia = ONE;
        ibtmp = ib;
        for k = ndims(b):-1:ONE
            vk = eml_index_plus(1, ...
                eml_index_rem(eml_index_minus(ibtmp,1),db(k)));
            iatmp = eml_index_times(da(k), rem( ...
                eml_index_rdivide(eml_index_minus(ibtmp,vk),db(k)), ...
                asize(k)));
            ia = eml_index_plus(ia,iatmp);
            ibtmp = vk;
        end
        % Copy appropriate element of a.
        b(ib) = a(ia);
    end
end

%--------------------------------------------------------------------------

function r = eml_index_rem(a,b)
eml_must_inline;
r = eml_index_minus(a,eml_index_times(eml_index_rdivide(a,b),b));

%--------------------------------------------------------------------------

function s = padsize(sz,nd)
% Pad size vector sz with ones so that the length is >= nd.
if eml_numel(sz) < nd
    s = [sz,ones(1,nd-eml_numel(sz))];
else
    s = sz;
end

%--------------------------------------------------------------------------
