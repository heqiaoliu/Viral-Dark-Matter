function c = gsubtract(a,b)
%GSUBTRACT Generalized subtraction.
%
% <a href="matlab:doc gsubtract">gsubtract</a>(a,b) returns a - b, supporting built in data behavior, as well as
% generalized behavior such as element-by-element and recursive subtraction
% of cell arrays and fields, and extending dimensions of size 1 in either
% argument to match the respective dimension of the other argument.
%
% Here are examples of adding with generalized behavior:
%
%   <a href="matlab:doc gsubtract">gsubtract</a>([1 2 3; 4 5 6],[10;20])
%   <a href="matlab:doc gsubtract">gsubtract</a>({1 2; 3 4},{1 3; 5 2})
%   <a href="matlab:doc gsubtract">gsubtract</a>({1 2 3 4},{10;20;30})
%
% See also GADD, GMULTIPLY, GDIVIDE, GNEGATE.

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, nnerr.throw('Not enough input arguments.'); end

if (isnumeric(a) && isnumeric(b))
  if isscalar(a) || isscalar(b)
    c = a - b;
  elseif (ndims(a) == ndims(b)) && (all(size(a) == size(b)))
    c = a - b;
  else
    c = calc_matrix(a,b);
  end
elseif iscell(a) && iscell(b)
  c = calc_cell(a,b);
else
  c = calc_general(a,b);
end

function c = calc_general(a,b)
% Cell
if iscell(a)
  if iscell(b)
    c = calc_cell(a,b);
  else
    c = calc_general(a,{b});
  end
elseif iscell(b)
  c = calc_general({a},b);
%
elseif isinteger(a)
  if isa(b,class(a))
    c = calc_matrix(a,b);
  elseif isdouble(b) && (numel(b)==1)
    c = a-b; % Primitive
  else
    nnerr.throw('Args','Integers can only be combined with integers of the same class, or scalar doubles.');
  end
elseif isinteger(b)
  if isa(a,class(b))
    c = calc_matrix(a,b);
  elseif isdouble(a) && (numel(a)==1)
    c = a-b; % Primitive
  else
    nnerr.throw('Args','Integers can only be combined with integers of the same class, or scalar doubles.');
  end
elseif isnumeric(a) || islogical(a) || ischar(a)
  if isnumeric(b) || islogical(b) || ischar(b)
    c = calc_matrix(a,b);
  else
    c1 = class(a);
    c2 = class(b);
    nnerr.throw('Args',['Arguments have different types, ' c1 ' and ' c2 '.']);
  end
elseif isa(b,class(a))
  c = a + b;
else
  c1 = class(a);
  c2 = class(b);
  nnerr.throw('Args',['Arguments have different types, ' c1 ' and ' c2 '.']);
end

function c = calc_cell(a,b)
  
% Argument with One Element
if numel(b) == 1
  b = b{1};
  c = cell(size(a));
  for i=1:numel(a), c{i} = calc_general(a{i},b); end
  return
elseif numel(a) == 1
  a = a{1};
  c = cell(size(b));
  for i=1:numel(b), c{i} = calc_general(b{i},a); end
  return;
end

% Argument Sizes Match
asize = size(a);
bsize = size(b);
adims = length(asize);
bdims = length(bsize);
if (adims==bdims) && all(asize==bsize)
  c = cell(asize);
  try
    for i=1:prod(asize), c{i} = a{i} - b{i}; end % Primitive
  catch %#ok<CTCH>
    for i=i:prod(asize), c{i} = calc_general(a{i},b{i}); end
  end
  return
end

% Argument Sizes are Incompatible
while (asize(end)==1), asize(end) = []; end
while (bsize(end)==1), bsize(end) = []; end
adims = length(asize);
bdims = length(bsize);
cdims = max([adims bdims]);
if (adims < cdims), asize = [asize ones(1,cdims-adims)]; end
if (bdims < cdims), bsize = [bsize ones(1,cdims-bdims)]; end
match = all((asize==bsize) | (asize==1) | (bsize==1));
if ~match, nnerr.throw('Cell dimensions must agree.'); end

% Allocate C
csize = asize;
i = find(asize==1);
csize(i) = bsize(i);
c = cell([csize 1]);

% Argument Sizes are Compatible, Empty Result
numC = prod(csize);
if (numC == 0), return, end

% Argument Sizes are Compatible, Non-Empty Result
aMask = asize > 1;
bMask = bsize > 1;
aBase = [1 cumprod(asize(1:(end-1)))]';
bBase = [1 cumprod(bsize(1:(end-1)))]';
cBase = [1 cumprod(csize(1:(end-1)))]';
cSizeMinus1 = csize-1;
ic = [-1 zeros(1,cdims-1)];
for i=1:numC
  ic = inc_complex_num0(ic,cSizeMinus1);
  iic = 1 + ic * cBase;
  iia = 1 + (ic .* aMask) * aBase;
  iib = 1 + (ic .* bMask) * bBase;
  c{iic} = calc_general(a{iia},b{iib});
end

function c = calc_matrix(a,b)

% Argument with One Element
if (numel(b) == 1) || (numel(a)==1)
  c = a-b; % Primitive
  return
end

% Argument Sizes Match
asize = size(a);
bsize = size(b);
adims = length(asize);
bdims = length(bsize);
if (adims==bdims) && all(asize==bsize)
  c = a-b; % Primitive
  return;
end

% Argument Sizes are Incompatible
while (asize(end)==1), asize(end) = []; end
while (bsize(end)==1), bsize(end) = []; end
adims = length(asize);
bdims = length(bsize);
cdims = max([adims bdims]);
if (adims < cdims), asize = [asize ones(1,cdims-adims)]; end
if (bdims < cdims), bsize = [bsize ones(1,cdims-bdims)]; end
match = all((asize==bsize) | (asize==1) | (bsize==1));
if ~match, nnerr.throw('Matrix dimensions must agree.'); end

% Allocate C
csize = asize;
i = find(asize==1);
csize(i) = bsize(i);
csize2 = [csize 1];
sp = false;
sparseChoice = (cdims <= 2) && (issparse(a) && issparse(b));
if isinteger(a)
  if isa(b,class(a)) || (isdouble(b) && isscalar(b))
    type = class(a);
  else nnerr.throw('Integers can only be combined with integers of the same type or scalar doubles.')
  end
elseif isinteger(b)
  if isa(a,class(b)) || (isdouble(a) && isscalar(a))
    type = class(b);
  else nnerr.throw('Integers can only be combined with integers of the same type or scalar doubles.')
  end
elseif isa(a,'logical')
  if isa(b,'logical')
    type = 'logical'; sp = sparseChoice;
  elseif isa(b,'single')
    type = 'single';
  else
    type = 'double'; sp = sparseChoice;
  end
elseif isa(b,'logical')
  if isa(b,'single')
    type = 'single';
  else
    type = 'double'; sp = sparseChoice;
  end
elseif isa(a,'single') || isa(b,'single')
  type = 'single';
else
  type = 'double'; sp = sparseChoice;
end
if sp
  c = sp([],[],zeros([],[],type,0,0),csize2(1),csize2(2));
else
  c = zeros(csize2,type);
end

% Argument Sizes are Compatible, Empty Result
numC = prod(csize);
if (numC == 0), return, end

% Argument Sizes are Compatible, Non-Empty Result
mRange = (asize == bsize);
aRange = (asize > 1) & ~mRange;
bRange = (bsize > 1) & ~mRange;
aRangeInd = find(aRange);
bRangeInd = find(bRange);
mRangeInd = find(mRange);
aRangeSize = asize(aRangeInd);
bRangeSize = bsize(bRangeInd);
mRangeSize = csize(mRangeInd);
a_range_dim = length(aRangeSize);
bRangeDim = length(bRangeSize);
aRangeNum = prod(aRangeSize);
bRangeNum = prod(bRangeSize);
mind = num2cell(ones(1,cdims));
for i=mRangeInd
  mind{i} = 1:mRangeSize;
end
aind = mind;
bind = mind;
cind = mind;
aii = [1 ones(1,a_range_dim-1)];
biistart = [1 ones(1,bRangeDim-1)];
for ia = 1:aRangeNum
  if ia > 1, aii = inc_complex_num(aii,aRangeSize); end
  aind(aRangeInd) = num2cell(aii);
  aa = a(aind{:});
  bii = biistart;
  for ib = 1:bRangeNum
    if ib > 1, bii = inc_complex_num(bii,bRangeSize); end
    cind(aRangeInd) = num2cell(aii);
    cind(bRangeInd) = num2cell(bii);   
    bind(bRangeInd) = num2cell(bii);
    bb = b(bind{:});
    c(cind{:}) = aa-bb; % Primitive
  end
end

function n = inc_complex_num0(n,baseMinus1)
i = 1;
while n(i) == baseMinus1(i)
  n(i) = 0;
  i = i + 1;
end
n(i) = n(i) + 1;

function n = inc_complex_num(n,b)
i = 1;
while n(i) == b(i)
  n(i) = 1;
  i = i + 1;
end
n(i) = n(i) + 1;
