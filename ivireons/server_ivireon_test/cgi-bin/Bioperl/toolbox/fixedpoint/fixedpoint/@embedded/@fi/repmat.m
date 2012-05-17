function B = repmat(A,M,N)
%REPMAT Replicate and tile an array
%   Refer to the MATLAB REPMAT reference page for more details. 
%
%   See also REPMAT

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/10 21:33:07 $

if nargin < 2
  error('FI:repmat:NotEnoughInputs', 'Requires at least 2 inputs.')
end

if nargin == 2
  if isscalar(M)
    siz = [M M];
  else
    siz = M;
  end
else
  siz = [M N];
end

siz = floor(double(siz));  % To handle size arguments that are not integer
                           % doubles (e.g. prod is not defined for builtin
                           % integers)
if isscalar(A)
  nelems = prod(siz);
  if nelems>0
    % Since B doesn't exist, the first statement creates a B with
    % the right size and type, scalar expanded to fill the array. 
    % Finally reshape to the specified size.
    B = subscriptedgrowassignment(A,ones(nelems,1),A);
    B = reshape(B,siz);
  else
    I = 0;
    I = I(ones(siz));
    B = subscriptedreference(A,I);
  end
elseif ndims(A) == 2 && prod(size(siz)) == 2
  I = reshape(0:numberofelements(A)-1,size(A));
  [m,n] = size(A);
  if (m == 1 && siz(2) == 1)
    I = I(ones(siz(1), 1), :);
  elseif (n == 1 && siz(1) == 1)
    I = I(:, ones(siz(2), 1));
  else
    mind = (1:m)';
    nind = (1:n)';
    mind = mind(:,ones(1,siz(1)));
    nind = nind(:,ones(1,siz(2)));
    I = I(mind,nind);
  end
  B = subscriptedreference(A,I);
else
  Asiz = size(A);
  Asiz = [Asiz ones(1,length(siz)-length(Asiz))];
  siz = [siz ones(1,length(Asiz)-length(siz))];
  for i=length(Asiz):-1:1
    ind = (1:Asiz(i))';
    subs{i} = ind(:,ones(1,siz(i)));
  end
  I = reshape(0:numberofelements(A)-1,size(A));
  I = I(subs{:});
  B = subscriptedreference(A,I);
end
