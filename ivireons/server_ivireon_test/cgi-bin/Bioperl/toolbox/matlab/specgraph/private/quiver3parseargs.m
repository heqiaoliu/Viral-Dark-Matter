function pvpairs = quiver3parseargs(args)
% identify convenience args for QUIVER3 and return all inputs as a list of PV pairs

%   Copyright 2009 The MathWorks, Inc.

[numericArgs,pvpairs] = parseparams(args);
nargs = length(numericArgs);

if iscell(args{end}) && isempty(args{end})
    error(id('InvalidCellInput'),'An empty cell array is not a valid input argument.');
end

% Check number of numeric inputs    
if ~ismember(nargs,[4 5 6 7])
    % too many numeric input args, nargs must be one of [2,3,4,5]
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
if nargs == 5 || nargs == 7
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

% Deal with quiver(Z,U,V,W) syntax
if nargs == 4
    z = datachk(numericArgs{1});
    u = datachk(numericArgs{2});
    v = datachk(numericArgs{3});
    w = datachk(numericArgs{4});
    
    % argument validation
    if ~isequal(size(z),size(u))
        error(id('ZUSizeMismatch'),'Z and U must be the same size.');
    elseif ~isequal(size(u),size(v))
        error(id('UVSizeMismatch'),'U and V must be the same size.');
    elseif ~isequal(size(v),size(w))
        error(id('VWSizeMismatch'),'V and W must be the same size.');
    end    
    pvpairs = {pvpairs{:},'ZData',z,'UData',u,'VData',v,'WData',w};
    
% quiver(X,Y,Z,U,V,W) syntax   
elseif (nargs == 6)
    x = datachk(args{1});
    y = datachk(args{2});
    z = datachk(args{3});
    u = datachk(args{4});
    v = datachk(args{5});
    w = datachk(args{6});
    
    % argument validation
    if xor(isempty(x), isempty(y))
        error(id('XYMixedEmpty'),'X,Y must both be empty or both non-empty.');
    end
    
    sz = size(z);
    su = size(u);
    sv = size(v);
    sw = size(w);
    if isempty(x)
        sx = sz;
        sy = sz;
    else
        sx = size(x);
        sy = size(y);
    end
    if ~isequal(sz,su)
        error(id('ZUSizeMismatch'),'Z and U must be the same size.');
    elseif ~isequal(su,sv)
        error(id('UVSizeMismatch'),'U and V must be the same size.');
    elseif ~isequal(sv,sw)
        error(id('VWSizeMismatch'),'V and W must be the same size.');
    elseif ~(isequal(sx,sz) || isequal(length(x),sz(2)) )
        error(id('XZSizeMismatch'),'The size of X must match the size of Z or the number of columns of Z.');
    elseif ~(isequal(sy,sz) || isequal(length(y),sz(1)) )
        error(id('YZSizeMismatch'),'The size of Y must match the size of Z or the number of rows of Z.');
    elseif ~(isequal(sx,sy) || (isvector(x) && isvector(y)))
        error(id('XYMixedFormat'),'The sizes of X and Y must match the size of Z, or X and Y must be vectors whos lengths match respectively the number of columns and rows of Z.')
    end
    
    pvpairs = {pvpairs{:},'XData',x,'YData',y,'ZData',z,'UData',u,'VData',v,'WData',w};
end

function str=id(str)
str = ['MATLAB:quiver:' str];
