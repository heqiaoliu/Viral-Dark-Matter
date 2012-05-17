function y = cat(dim, varargin)
%CAT Concatenation for sym arrays.
%   C = CAT(DIM, A, B, ...) concatenates the sym arrays A,
%   B, etc. along the dimension DIM. 
%
%   See also HORZCAT, VERTCAT.

%   Copyright 2010 The MathWorks, Inc.

args = varargin;
for k=1:length(args)
  if ~isa(args{k},'sym')
    args{k} = sym(args{k});
  end
  if builtin('numel',args{k}) ~= 1,  args{k} = normalizesym(args{k});  end
end
dim = double(dim);
if ~isscalar(dim) || fix(dim)~=dim || dim < 0 || ~isfinite(dim)
    error('symbolic:catenate:invalidDimension','Dimension must be a finite integer.');
end
if dim == 0, dim = 1; end
strs = cellfun(@(x)x.s,args,'UniformOutput',false);
% catenate the arguments in strs (if any) along dim
if isempty(strs)
    y = sym([]);
elseif length(strs) == 1
    y = args{1};
else
    y = catMany(dim, strs);
end

function y = catMany(dim,strs)
% catenate multiple arrays
n = length(strs);
sz = cell(1,n);
for k=1:n
  sz{k} = eval(mupadmex('symobj::size',strs{k},0)); % from sym/size
end
[resz, ranges] = checkDimensions(sz,dim);
resNDims = length(resz);
subs = cell(1,resNDims);
subs(:) = {'#COLON'};
y = sym(zeros(resz));
y = reshape(y,resz);
for k=1:n
    if prod(sz{k})>0
        range = ranges(k):ranges(k+1)-1;
        str = sprintf('%d,',range);
        subs(dim) = {['[' str(1:end-1) ']']};
        y = mupadmex('symobj::subsasgn',y.s,strs{k},subs{:});
    end
end

function [resz,ranges] = checkDimensions(sz,dim)
% validate and compute the output dimensions. Also compute the indexing ranges for each slice.
n = length(sz);
bigdim = max(cellfun(@length,sz));
allsz = ones(n,max(dim,bigdim));
pureempty = findPureEmpty(sz,n);
if all(pureempty)
    allsz(:,:) = 0;
    if dim>2
        allsz(:,dim) = 1;
    end
else
    allsz = mixedDimensions(sz,n,allsz,pureempty);
end
resz = max(allsz);
resz(dim) = sum(allsz(:,dim));
ranges = cumsum([1;allsz(:,dim)]);
% now check that all the non-dim sizes match (except pure empties)
allsz(pureempty,:) = [];
allsz(:,dim) = resz(dim);
ok = bsxfun(@eq,allsz,resz);
if ~all(ok(:))
    error('symbolic:catenate:dimensionMismatch','CAT arguments dimensions are not consistent.');
end
resz = stripTrailingOnes(resz);

function pureempty = findPureEmpty(sz,n)
% return true if all the sizes are 0-by-0
pureempty = false(1,n);
for k=1:n
    szk = sz{k};
    pureempty(k) = all(szk==0) && length(szk)==2;
end

function allsz = mixedDimensions(sz,n,allsz,pureempty)
% compute the resulting sizes if the input sizes are mixed
for k=1:n
    if pureempty(k)
        allsz(k,:) = 0;
    else
        szk = sz{k};
        allsz(k,1:length(szk)) = szk;
    end
end

function resz = stripTrailingOnes(resz)
% remove any trailing single dimensions
n = find(fliplr(resz)~=1,1);
if length(resz)>2 && n > 1
    n = max(3,length(resz)-n+2);
    resz(n:end) = [];
end
