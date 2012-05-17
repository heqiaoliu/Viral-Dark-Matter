function npages = eml_matrix_npages(x,dim)
%Embedded MATLAB Private Function

%   EML_MATRIX_NPAGES computes the number of pages of vectors when looping
%   through a matrix of size(X) along dimension DIM.  A "page" of
%   vectors is a set of vectors which begin on consecutive matrix
%   elements.  See EML_MATRIX_VSTRIDE for templates that illustrate the
%   the use of EML_MATRIX_NPAGES and EML_MATRIX_VSTRIDE.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_must_inline;
eml_allow_enum_inputs;
eml_prefer_const(dim);
npages = eml_size_prod(x, ...
    eml_index_plus(dim,1), ...
    cast(eml_ndims(x),eml_index_class));
