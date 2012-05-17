function [y idx] = sort(varargin)
%SORT   Sort elements of real-valued fi object in ascending or descending order 
%   Refer to the MATLAB SORT reference page for more information.
%
%   See also SORT

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/03/15 22:33:35 $

args = parseinputs(varargin{:});

x = args.x;
% xxx Workaround for problem where UDD always attaches a fimath
% xxx for subasgn (dot notation) calls in MATLAB-file fi methods. 
% This is assuming that varargin{1} is a fi (it must be anyway)
% otherwise this function would have errored out already.
x.fimathislocal = isfimathlocal(varargin{1});

dim = args.dim;

mode = args.mode;

dim = double(dim);
szx = size(x);

% unspecified 'dim'; sort along the first non-singleton dimension
if (dim == 0)
    dim = find(szx>1,1);
end
        
if isempty(x)
    
    y = x;
    idx = [];

elseif numberofelements(x) == 1
    
    y = x;
    idx = 1;
    
elseif (isfloat(x) || isscaleddouble(x))
    
    [yd idx] = sort(double(x),dim,mode);
    y = fi(yd,numerictype(x));
    y.fimathislocal = false;
    
elseif dim > ndims(x)
    
    y = x;
    idx = ones(size(x));
    
else
    
    % compute stride - spacing between elements that are 'consecutive'
    % along the sort dimension
    if dim == 1
        stride = 1;
    else
        stride = prod(szx(1:dim-1));
    end
    
    % number of elements along the sort dimension
    nToSort = szx(dim);  

    % increasing order if mode is 'ascend'
    % reverse-ordering required if mode is 'descend'
    isup = strcmpi(mode,'ascend');

    if nargout == 1    
        y = stridesort(x,isup,stride,nToSort);
    else
        [y idx] = stridesort2(x,isup,stride,nToSort);
    end

end

%-----------------------------------

function args = parseinputs(varargin)

p = inputParser;

p.addRequired('x',@validate_ip);

if ((nargin == 2)&&(ischar(varargin{2})))
    % accommodate the syntax sort(x, 'mode')
    p.addOptional('mode','ascend',@validate_mode);    
    p.addOptional('dim',0,@validate_dim);
    
else
    % accommodate the syntaxes sort(x), sort(x,'dim'), sort(x,'dim','mode')
    p.addOptional('dim',0,@validate_dim);
    p.addOptional('mode','ascend',@validate_mode);

end

p.parse(varargin{:});

args = p.Results;

%-----------------------------------

function val_ip = validate_ip(u)
val_ip = true;

if ~isreal(u)
    error('fi:sort:supportForRealOnly','Input array to be sorted must be real.');
end

%-----------------------------------

function val_dim = validate_dim(v)
val_dim = true;

if isfi(v)
    error('fi:sort:incorrectFiDimInput','DIM and MODE argument to SORT cannot be FI objects.')
end
isintvalued = ~isempty(v)&&(isinteger(v)||(v == floor(v)));
if (~isintvalued)||(v < 1)||(~isreal(v))
    error('fi:sort:incorrectDimInput','Dimension must be a real positive integer scalar.')
end

%-----------------------------------

function val_mode = validate_mode(w)
val_mode = true;

if isfi(w)
    error('fi:sort:incorrectFiModeInput','DIM and MODE argument to SORT cannot be FI objects.')    
end
if ~strcmpi(w,'ascend')&&~strcmpi(w,'descend')
    error('fi:sort:incorrectsortMode','Sorting direction must be ''ascend'' or ''descend''.')
end
