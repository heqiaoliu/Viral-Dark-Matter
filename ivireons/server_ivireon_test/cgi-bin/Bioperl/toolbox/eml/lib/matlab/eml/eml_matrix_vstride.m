function vstride = eml_matrix_vstride(x,dim)
%Embedded MATLAB Private Function

%    EML_MATRIX_VSTRIDE is part of a strategy for looping through each 
%    vector in an N-D matrix of size(X) along dimension DIM without 
%    permuting the matrix.  The output VSTRIDE is the distance between 
%    consecutive vector elements along dimension DIM.  See also
%    EML_MATRIX_NPAGES.
%
%    TEMPLATE FOR GENERAL VECTOR PROCESSING
%      vlen    = size(x,dim);
%      vwork = eml.nullcopy(eml_expand(eml_scalar_eg(x),[vlen,1]));
%      vstride = eml_matrix_vstride(x,dim);
%      vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
%      npages  = eml_matrix_npages(x,dim);
%      i2      = zeros(eml_index_class);
%      for i = 1:npages
%          i1 = i2;
%          i2 = eml_index_plus(i2,vspread);
%          for j = 1:vstride
%              i1 = eml_index_plus(i1,1);
%              i2 = eml_index_plus(i2,1);
%              % Copy x(i1:vstride:i2) to vwork;
%              ix = i1;
%              for k = 1:vlen
%                  vwork(k) = x(ix);
%                  ix = eml_index_plus(ix,vstride);
%              end
%              % Do something with vwork here.
%          end
%      end
%
%    TEMPLATE FOR DIMENSION-COLLAPSING OPERATIONS (e.g. SUM, ALL, ANY)
%      vlen    = size(x,dim);
%      vwork = eml.nullcopy(eml_expand(eml_scalar_eg(x),[vlen,1]));
%      vstride = eml_matrix_vstride(x,dim);
%      vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
%      npages  = eml_matrix_npages(x,dim);
%      i2      = zeros(eml_index_class);
%      iy      = zeros(eml_index_class);
%      for i = 1:npages
%          i1 = i2;
%          i2 = eml_index_plus(i2,vspread);
%          for j = 1:vstride
%              i1 = eml_index_plus(i1,1);
%              i2 = eml_index_plus(i2,1);
%              % Copy x(i1:vstride:i2) to vwork;
%              ix = i1;
%              for k = 1:vlen
%                  vwork(k) = x(ix);
%                  ix = eml_index_plus(ix,vstride);
%              end
%              % Apply some vector to scalar operation and store to y.
%              iy = eml_index_plus(iy,1);
%              y(iy) = foo(vwork);
%          end
%      end
%
%    TYPICAL SIMPLIFIED USE (PROD)
%      vlen = size(x,dim);
%      vstride = eml_matrix_vstride(x,dim);
%      npages = eml_matrix_npages(x,dim);
%      ix = zeros(eml_index_class);
%      iy = zeros(eml_index_class);
%      for i = 1:npages
%          ixstart = ix;
%          for j = 1:vstride
%              ixstart = eml_index_plus(ixstart,1);
%              ix = ixstart;
%              p = x(ix);
%              for k = 2:vlen
%                  ix = eml_index_plus(ix,vstride);
%                  p = p * x(ix);
%              end
%              iy = eml_index_plus(iy,1);
%              y(iy) = p;
%          end
%      end

%    Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_allow_enum_inputs;
eml_prefer_const(dim);
if dim <= eml_ndims(x)
    n = eml_index_minus(dim,1);
else
    n = cast(eml_ndims(x),eml_index_class);
end
vstride = eml_size_prod(x,ones(eml_index_class),n);
