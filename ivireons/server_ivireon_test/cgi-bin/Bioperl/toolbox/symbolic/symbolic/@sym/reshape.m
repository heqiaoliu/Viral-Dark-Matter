function y = reshape(x,varargin)
%RESHAPE Change size of symbolic array.
%    RESHAPE(X,M,N) returns the M-by-N matrix whose elements
%    are taken columnwise from X.  An error results if X does
%    not have M*N elements.
%
%    RESHAPE(X,M,N,P,...) returns an N-D array with the same
%    elements as X but reshaped to have the size M-by-N-by-P-by-...
%    M*N*P*... must be the same as PROD(SIZE(X)).
%
%    RESHAPE(X,[M N P ...]) is the same thing.
%
%    RESHAPE(X,...,[],...) calculates the length of the dimension
%    represented by [], such that the product of the dimensions
%    equals PROD(SIZE(X)). PROD(SIZE(X)) must be evenly divisible
%    by the product of the known dimensions. You can use only one
%    occurrence of [].
%
%    In general, RESHAPE(X,SIZ) returns an N-D array with the same
%    elements as X but reshaped to the size SIZ.  PROD(SIZ) must be
%    the same as PROD(SIZE(X)).
%
%    See also SQUEEZE, SHIFTDIM, COLON.

%   Copyright 2009 The MathWorks, Inc. 

    if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
    if isa(x.s,'maplesym')
        y = sym(reshape(x.s,varargin{:}));
        return;
    end
    
    args = varargin;
    for k=1:nargin-1
        arg = args{k};
        if isempty(arg)
            arg = '#COLON';
        elseif isnumeric(arg)
            if isscalar(arg)
                arg = int2str(arg);
            else
                arg = num2str(arg(:).','%d,');
                arg = ['[' arg(1:end-1) ']'];
            end
        end
        args{k} = arg;
    end
    y = mupadmex('symobj::reshape',x.s,args{:});
