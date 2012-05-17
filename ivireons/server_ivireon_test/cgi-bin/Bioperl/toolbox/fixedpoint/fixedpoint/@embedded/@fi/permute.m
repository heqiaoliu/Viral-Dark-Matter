function B = permute(A,P)
%PERMUTE Permute array dimensions
%   Refer to the MATLAB PERMUTE reference page for more information.
%
%   See also PERMUTE

%   Thomas A. Bryan, 19 January 2004
%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/06/20 07:53:43 $

% If trivial permutation, then B=A
if numberofelements(A)==1 || isequal(P,1:ndims(A))
  B = copy(A);
  return
end

% Nontrivial permutation of 2D array is the transpose.
if ndims(A)==2 && isequal([2 1],P)
  B = A.';
  return
end

% Nontrivial permutation of ND array.
% Use builtin PERMUTE on the intarray.
[I,numchunks] = intarray(A);
if numchunks==1
  I = permute(I,double(P));
else
  I = reshape(I,[numchunks size(A)]);
  siz0 = size(I);
  I = permute(I,double([1,P+1]));
  siz = size(I);
  if length(siz) < length(siz0)
      % The permutation has squeezed a trailing singleton dimension.
      % Add it back in.  The following reshape will do the right thing
      % with respect to this added trailing singleton dimension.
      siz = [siz 1];
  end
  I = reshape(I,[(siz(1)*siz(2)) siz(3:end)]);
end
B = copy(A);
B.intarray = I;
