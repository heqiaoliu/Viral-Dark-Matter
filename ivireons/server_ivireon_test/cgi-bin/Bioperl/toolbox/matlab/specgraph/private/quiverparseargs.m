function pvpairs = quiverparseargs(args)
% identify convenience args for QUIVER and return all inputs as a list of PV pairs

%   Copyright 2009 The MathWorks, Inc.

[numericArgs,pvpairs] = parseparams(args);
nargs = length(numericArgs);

if iscell(args{end}) && isempty(args{end})
    error(id('InvalidCellInput'),'An empty cell array is not a valid input argument.');
end

% Check number of numeric inputs    
if ~ismember(nargs,[2 3 4 5])
    % too many numeric input args, nargs must be one of [2,3,4,5}
    error(id('InvalidNumInputs'),'QUIVER does not support %s leading numeric input(s).', num2str(nargs));    
end

% separate 'filled' or LINESPEC from pvpairs 
n = 1;
extrapv = {};
foundFilled = false;
foundLinespec = false;
while length(pvpairs) >= 1 && n < 3 && ischar(pvpairs{1})
    arg = lower(pvpairs{1});
    
    % check for 'filled'
    if ~foundFilled
        if arg(1) == 'f'
            foundFilled = true;
            pvpairs(1) = [];
            extrapv = {'MarkerFaceColor','auto',extrapv{:}};
        end
    end

    % check for linespec
    if ~foundLinespec
        [l,c,m,msg]=colstyle(pvpairs{1});
        if isempty(msg)
            foundLinespec = true;
            pvpairs(1) = [];
            if ~isempty(l)
                extrapv = {'LineStyle',l,extrapv{:}};
            end
            if ~isempty(c)
                extrapv = {'Color',c,extrapv{:}};
            end
            if ~isempty(m)
                extrapv = {'ShowArrowHead','off',extrapv{:}};
                if ~isequal(m,'.')
                    extrapv = {'Marker',m,extrapv{:}};
                end
            end
        end
    end
    
    if ~(foundFilled || foundLinespec)
        break
    end
    n = n+1;
end

% check for unbalanced pvpairs list
if rem(length(pvpairs),2) ~= 0
    error(id('UnevenPvPairsCount'),'Uneven parameter-value pairs.');
end

pvpairs = [extrapv pvpairs];

% Deal witth quiver(..., AutoScaleFactor) syntax
if nargs == 3 || nargs == 5
    if isa(numericArgs{nargs},'double') && (length(numericArgs{nargs}) == 1) 
        if args{nargs} > 0
            pvpairs = {pvpairs{:},'AutoScale','on',...
                'AutoScaleFactor',numericArgs{nargs}};
        else
            pvpairs = {pvpairs{:},'AutoScale','off'};
        end
        numericArgs = numericArgs(1:end-1);
        nargs = length(numericArgs);
    else
        error(id('InvalidAutoScaleFactor'),'AutoScaleFactor must be a scalar double.');
    end
end

% Deal with quiver(U,V) syntax
if nargs == 2
    u = datachk(numericArgs{1});
    v = datachk(numericArgs{2});
    
    % argument validation
    if ~isequal(size(u),size(v))
        error(id('UVSizeMismatch'),'U and V must be the same size.');
    end    
    pvpairs = {pvpairs{:},'UData',u,'VData',v};
    
% quiver(X,Y,U,V) syntax    
elseif nargs == 4
    x = datachk(numericArgs{1});
    y = datachk(numericArgs{2});
    u = datachk(numericArgs{3});
    v = datachk(numericArgs{4});
    
    if xor(isempty(x), isempty(y))
      error(id('XYMixedEmpty'),'X,Y must both be empty or both non-empty.');
    end

    su = size(u);
    sv = size(v);
    if isempty(x)
        sx = su;
        sy = su;
    else
        sx = size(x);
        sy = size(y);
    end
    if ~isequal(su,sv)
        error(id('UVSizeMismatch'),'U and V must be the same size.');
    elseif ~(isequal(sx,su) || isequal(length(x),su(2)) )
        error(id('XUSizeMismatch'),'The size of X must match the size of U or the number of columns of U.');
    elseif ~(isequal(sy,su) || isequal(length(y),su(1)) )
        error(id('YUSizeMismatch'),'The size of Y must match the size of U or the number of rows of U.');
    elseif ~(isequal(sx,sy) || (isvector(x) && isvector(y)))
        error(id('XYMixedFormat'),'The sizes of X and Y must match the size of U, or X and Y must be vectors whose lengths match respectively the number of columns and rows of U.')
    end
    
    pvpairs = {pvpairs{:},'XData',x,'YData',y,'UData',u,'VData',v};    
end

function str=id(str)
str = ['MATLAB:quiver:' str];
