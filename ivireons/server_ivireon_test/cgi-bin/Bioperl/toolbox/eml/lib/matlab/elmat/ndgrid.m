function varargout = ndgrid(varargin)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments');
eml_assert(nargin == 1 || nargout <= nargin, 'Too many output arguments.');
if nargin == 1
    szeg = false(repmat(eml_numel(varargin{1}),1,eml_const(max(nargout,2))));
    for dim = eml.unroll(1:eml_const(max(nargout,1)))
        varargout{dim} = replicate_vector(varargin{1},szeg,dim);
    end
else
    szeg = false(ndgrid_size(varargin{:}));
    for dim = eml.unroll(1:eml_const(max(nargout,1)))
        varargout{dim} = replicate_vector(varargin{dim},szeg,dim);
    end
end

%--------------------------------------------------------------------------

function y = replicate_vector(x,szeg,dim)
% Replicate vector X along dimension DIM of a matrix of the size of szeg.
% It is assumed that SZ(DIM) == NUMEL(X).
eml_must_inline;
y = eml.nullcopy(eml_expand(eml_scalar_eg(x),size(szeg)));
vlen = eml_numel(x);
vstride = eml_matrix_vstride(szeg,dim);
npages = eml_matrix_npages(szeg,dim);
iy = zeros(eml_index_class);
for i = 1:npages
    for k = 1:vlen
        for j = 1:vstride
            iy = eml_index_plus(iy,1);
            y(iy) = x(k);
        end
    end
end

%--------------------------------------------------------------------------

function sz = ndgrid_size(varargin)
% Calculate the size of the outputs for NDGRID:
% SZ = [NUMEL(VARARGIN{1}),NUMEL(VARARGIN{2}),...].
sz = zeros(1,nargin);
for k = eml.unroll(1:nargin)
    sz(k) = eml_numel(varargin{k});
end

%--------------------------------------------------------------------------
