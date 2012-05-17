function indices = array_indices(sizes)
%

% ARRAY_INDICES Constructs the sequence of indexing coordinates
% for an array of size SIZES.
%
% modelpack.array_indices([1 2 3])
%
% ans =
%
%   1  1  1
%   1  2  1
%   1  1  2
%   1  2  2
%   1  1  3
%   1  2  3

% Author(s): P. Gahinet
% Revised: Bora Eryilmaz
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:02 $

num = prod(sizes);
indices = zeros(num, length(sizes));
for k = 1:length(sizes)
  range = 1:sizes(k);
  base = repmat(range, prod(sizes(1:k-1)), 1);
  indices(:,k) = repmat(base(:), num/numel(base), 1);
end
