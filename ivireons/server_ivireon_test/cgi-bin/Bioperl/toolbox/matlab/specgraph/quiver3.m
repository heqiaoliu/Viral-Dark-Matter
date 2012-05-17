function hh = quiver3(varargin)
%QUIVER3 3-D quiver plot.
%   QUIVER3(X,Y,Z,U,V,W) plots velocity vectors as arrows with components
%   (u,v,w) at the points (x,y,z).  The matrices X,Y,Z,U,V,W must all be
%   the same size and contain the corresponding position and velocity
%   components.  QUIVER3 automatically scales the arrows to fit.
%
%   QUIVER3(Z,U,V,W) plots velocity vectors at the equally spaced
%   surface points specified by the matrix Z.
%
%   QUIVER3(Z,U,V,W,S) or QUIVER3(X,Y,Z,U,V,W,S) automatically
%   scales the arrows to fit and then stretches them by S.
%   Use S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER3(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER3(...,'filled') fills any markers specified.
%
%   QUIVER3(AX,...) plots into AX instead of GCA.
%
%   H = QUIVER3(...) returns a quiver object.
%
%   Example:
%       [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%       z = x .* exp(-x.^2 - y.^2);
%       [u,v,w] = surfnorm(x,y,z);
%       quiver3(x,y,z,u,v,w); hold on, surf(x,y,z), hold off
%
%   See also QUIVER, PLOT, PLOT3, SCATTER.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.23.4.13 $  $Date: 2009/03/05 18:50:59 $

% First we check whether Handle Graphics uses MATLAB classes
isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');

% Next we check whether to use the V6 Plot API
[v6,args] = usev6plotapi(varargin{:},'-mfilename',mfilename);

if isHGUsingMATLABClasses
    h = quiver3HGUsingMATLABClasses(args{:});
else
    % old implementation
    if v6
        h = Lquiver3v6(args{:});
        
        % create quiver object
    else
        error(nargchk(4,inf,nargin,'struct'));
        % Parse possible axes input
        [cax,args] = axescheck(args{:});
        % Parse remaining args
        try
            pvpairs = quiver3parseargs(args);
        catch ME
            throw(ME)
        end
        
        if isempty(cax) || isa(handle(cax),'hg.axes')
            cax = newplot(cax);
            parax = cax;
            hold_state = ishold(cax);
        else
            parax = cax;
            cax = ancestor(cax,'Axes');
            hold_state = true;
        end
        [ls,c] = nextstyle(cax);
        
        h = specgraph.quivergroup('Color',c,'LineStyle',ls,...
            'parent',parax,pvpairs{:});
        
        if ~hold_state, view(cax,3); grid(cax,'on'); end
        
        if ~any(strcmpi('color',pvpairs(1:2:end)))
            set(h,'CodeGenColorMode','auto');
        end
        set(h,'refreshmode','auto');
        h = double(h);
        
    end
end

if nargout>0, hh = h; end

%----------------------------------------------%
function hh = Lquiver3v6(varargin)
[cax,args,nargs] = axescheck(varargin{:});

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1;

filled = 0;
ls = '-';
ms = '';
col = '';

nin = nargs;
% Parse the string inputs
while ischar(args{nin}),
    vv = args{nin};
    if ~isempty(vv) && strcmpi(vv(1),'f')
        filled = 1;
        nin = nin-1;
    else
        [l,c,m,msg] = colstyle(vv);
        if ~isempty(msg),
            error(id('UnknownOption'),'Unknown option "%s".',vv);
        end
        if ~isempty(l), ls = l; end
        if ~isempty(c), col = c; end
        if ~isempty(m), ms = m; plotarrows = 0; end
        if isequal(m,'.'), ms = ''; end % Don't plot '.'
        nin = nin-1;
    end
end

error(nargchk(4,7,nin,'struct'));

% Check numeric input arguments
if nin<6, % quiver3(z,u,v,w) or quiver3(z,u,v,w,s)
    [msg,x,y,z] = xyzchk(args{1});
    u = args{2};
    v = args{3};
    w = args{4};
else % quiver3(x,y,z,u,v,w) or quiver3(x,y,z,u,v,w,s)
    [msg,x,y,z] = xyzchk(args{1:3});
    u = args{4};
    v = args{5};
    w = args{6};
end
if ~isempty(msg), error(msg); end

% Scalar expand u,v,w.
if numel(u)==1, u = u(ones(size(x))); end
if numel(v)==1, v = v(ones(size(u))); end
if numel(w)==1, w = w(ones(size(v))); end

% Check sizes
if ~isequal(size(x),size(y),size(z),size(u),size(v),size(w))
    error(id('DataSizeMismatch'),'The sizes of X,Y,Z,U,V, and W must all be the same.');
end

% Get autoscale value if present
if nin==5 || nin==7, % quiver3(z,u,v,w,s) or quiver3(x,y,z,u,v,w,s)
    autoscale = args{nin};
end

if length(autoscale)>1,
    error(id('NonScalarFactor'),'S must be a scalar.');
end

if autoscale,
    % Base autoscale value on average spacing in the x and y
    % directions.  Estimate number of points in each direction as
    % either the size of the input arrays or the effective square
    % spacing if x and y are vectors.
    if min(size(x))==1, n=sqrt(numel(x)); m=n; else [m,n]=size(x); end
    delx = diff([min(x(:)) max(x(:))])/n;
    dely = diff([min(y(:)) max(y(:))])/m;
    delz = diff([min(z(:)) max(z(:))])/max(m,n);
    del = sqrt(delx.^2 + dely.^2 + delz.^2);
    if del>0
        len = sqrt((u/del).^2 + (v/del).^2 + (w/del).^2);
        maxlen = max(len(:));
    else
        maxlen = 0;
    end
    
    if maxlen>0
        autoscale = autoscale*0.9 / maxlen;
    else
        autoscale = autoscale*0.9;
    end
    u = u*autoscale; v = v*autoscale; w = w*autoscale;
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

% Make velocity vectors
x = x(:).'; y = y(:).'; z = z(:).';
u = u(:).'; v = v(:).'; w = w(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];
ww = [z;z+w;repmat(NaN,size(u))];

% QUIVER3 calls the 'v6' version of PLOT3, and temporarily modifies global
% state by turning the MATLAB:plot3:DeprecatedV6Argument and
% MATLAB:plot3:IgnoringV6Argument warnings off and on again.
oldWarn(1) = warning('off','MATLAB:plot3:DeprecatedV6Argument');
oldWarn(2) = warning('off','MATLAB:plot3:IgnoringV6Argument');
try
    h1 = plot3('v6',uu(:),vv(:),ww(:),[col ls],'parent',cax);
catch err
    warning(oldWarn); %#ok<WNTAG>
    rethrow(err);
end
warning(oldWarn); %#ok<WNTAG>

if plotarrows,
    beta = beta * sqrt(u.*u + v.*v + w.*w) ./ (sqrt(u.*u + v.*v) + eps);
    
    % Make arrow heads and plot them
    hu = [x+u-alpha*(u+beta.*(v+eps));x+u; ...
        x+u-alpha*(u-beta.*(v+eps));repmat(NaN,size(u))];
    hv = [y+v-alpha*(v-beta.*(u+eps));y+v; ...
        y+v-alpha*(v+beta.*(u+eps));repmat(NaN,size(v))];
    hw = [z+w-alpha*w;z+w;z+w-alpha*w;repmat(NaN,size(w))];
    
    hold(cax,'on')
    h2 = plot3(hu(:),hv(:),hw(:),[col ls],'parent',cax);
else
    h2 = [];
end

if ~isempty(ms), % Plot marker on base
    hu = x; hv = y; hw = z;
    hold(cax,'on')
    h3 = plot3(hu(:),hv(:),hw(:),[col ms],'parent',cax);
    if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
    h3 = [];
end

if ~hold_state, hold(cax,'off'), view(cax,3); grid(cax,'on'), set(cax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end

function str=id(str)
str = ['MATLAB:quiver3:' str];
