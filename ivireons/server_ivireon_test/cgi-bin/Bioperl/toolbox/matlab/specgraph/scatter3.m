function hh = scatter3(varargin)
%SCATTER3 3-D Scatter plot.
%   SCATTER3(X,Y,Z,S,C) displays colored circles at the locations
%   specified by the vectors X,Y,Z (which must all be the same size).  The
%   area of each marker is determined by the values in the vector S (in
%   points^2) and the colors of each marker are based on the values in C.  S
%   can be a scalar, in which case all the markers are drawn the same
%   size, or a vector the same length as X,Y, and Z.
%   
%   When C is a vector the same length as X,Y, and Z, the values in C
%   are linearly mapped to the colors in the current colormap.  
%   When C is a LENGTH(X)-by-3 matrix, the values in C specify the
%   colors of the markers as RGB values.  C can also be a color string.
%
%   SCATTER3(X,Y,Z) draws the markers with the default size and color.
%   SCATTER3(X,Y,Z,S) draws the markers with a single color.
%   SCATTER3(...,M) uses the marker M instead of 'o'.
%   SCATTER3(...,'filled') fills the markers.
%
%   SCATTER3(AX,...) plots into AX instead of GCA.
%
%   H = SCATTER3(...) returns handles to scatter objects created.
%
%   Use PLOT3 for single color, single marker size 3-D scatter plots.
%
%   Example
%      [x,y,z] = sphere(16);
%      X = [x(:)*.5 x(:)*.75 x(:)];
%      Y = [y(:)*.5 y(:)*.75 y(:)];
%      Z = [z(:)*.5 z(:)*.75 z(:)];
%      S = repmat([1 .75 .5]*10,numel(x),1);
%      C = repmat([1 2 3],numel(x),1);
%      scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
%
%   See also SCATTER, PLOT3.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.8.4.13 $ $Date: 2009/10/24 19:18:38 $

% First we check whether Handle Graphics uses MATLAB classes
isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');
  
% Next we check whether to use the V6 Plot API
[v6,args] = usev6plotapi(varargin{:},'-mfilename',mfilename);
 
if isHGUsingMATLABClasses
    h = scatter3HGUsingMATLABClasses(args{:});
else
if v6
  h = Lscatterv6(args{:});
else
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs,'struct'));
  [pvpairs,args,nargs,msg] = parseargs(args);
  if ~isempty(msg), error(msg); end
 
  error(nargchk(3,7,nargs,'struct'));

  dataargs = datachk(args(1:nargs));
  switch (nargs)
    case 3
      [x,y,z] = deal(dataargs{:});
      error(Lxyzchk(x,y,z));
      cax = newplot(cax);
      [ls,c,m] = nextstyle(cax); %#ok<NASGU>
      error(Lcchk(x,c)); 
      s = get(cax,'DefaultLineMarkerSize')^2;
    case 4
      [x,y,z,s] = deal(dataargs{:});
      error(Lxyzchk(x,y,z));  
      error(Lschk(x,s));  
      cax = newplot(cax);
      [ls,c,m] = nextstyle(cax); %#ok<NASGU>
    case 5
      [x,y,z,s,c] = deal(dataargs{:});
      error(Lxyzchk(x,y,z));  
      error(Lschk(x,s));  
      if ischar(args{nargs}), c = args{nargs}; end
      error(Lcchk(x,c));  
      cax = newplot(cax);
    otherwise
      error(id('invalidInput'),'Wrong number of input arguments.');
  end

  if isempty(s), s = 36; end

  h = specgraph.scattergroup('parent',cax,'xdata',x,...
                             'ydata',y,...
                             'zdata',z,...
                             'sizedata',s,...
                             'cdata',c,pvpairs{:});
  set(h,'refreshmode','auto');
  if ~ishold(cax), view(cax,3), grid(cax,'on'), end
  h = double(h);
end
end

if nargout>0, hh = h; end

%--------------------------------------------------
function [hh] = Lscatterv6(varargin)

[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(3,7,nargs,'struct'))

cax = newplot(cax);
filled = 0;
scaled = 0;
marker = 'o';
c = '';

% Parse optional trailing arguments (in any order)
nin = nargs;
while nin > 0 && ischar(args{nin})
    if strcmp(args{nin},'filled'),
        filled = 1;
    else
        [l,ctmp,m,msg] = colstyle(args{nin}); 
        error(msg) 
        if ~isempty(m), marker = m; end
        if ~isempty(ctmp), c = ctmp; end
    end
    nin = nin-1;
end
if isempty(marker), marker = 'o'; end
co = get(cax,'colororder');

switch nin
case 3  % scatter3(x,y,z)
    [x,y,z] = deal(args{1:3});
    if isempty(c),
        c = co(1,:);
    end
    s = get(cax,'DefaultLineMarkerSize')^2;
case 4 % scatter3(x,y,z,s)
    [x,y,z,s] = deal(args{1:4});
    if isempty(c),
        c = co(1,:);
    end
case 5  % scatter3(x,y,z,s,c)
    [x,y,z,s,c] = deal(args{1:5});
otherwise
 error(id('invalidInput'),'Wrong number of input arguments.');
end

error(Lxyzchk(x,y,z)); 

% Map colors into colormap colors if necessary.
if ischar(c) || isequal(size(c),[1 3]); % string color or scalar rgb
    color = repmat(c,length(x),1);
elseif length(c)==numel(c), % is C a vector?
    scaled = 1;
elseif isequal(size(c),[length(x) 3]), % vector of rgb's
    color = c;
else
     error(id('invalidCData'),...
           ['C must be a single color, a vector the same length as X, ',...
            'or an M-by-3 matrix.'])
end

% Scalar expand the marker size if necessary
if length(s)==1, 
    s = repmat(s,length(x),1); 
elseif length(s)~= numel(s) || length(s)~=length(x)
    error(id('invalidSData'),'S must be a scalar or a vector the same length as X.')
end

% Now draw the plot, one patch per point.
h = [];
% keeping track of scatter groups for legend
if isappdata(cax,'scattergroup');
    scattergroup=getappdata(cax,'scattergroup') + 1;
else
    scattergroup = 1;
end
setappdata(cax,'scattergroup',scattergroup);

for i=1:length(x),
    h = [h;patch('xdata',x(i),'ydata',y(i),'zdata',z(i),...
            'linestyle','none','facecolor','none',...
            'markersize',sqrt(s(i)), ...
            'marker',marker, ...
            'parent',cax)];
    % set scatter group for patch
    setappdata(h(end),'scattergroup',scattergroup); 
    if scaled,
        set(h(end),'cdata',c(i),'edgecolor','flat','markerfacecolor','flat');
    else
        set(h(end),'edgecolor',color(i,:),'markerfacecolor',color(i,:));
    end
    if ~filled,
        set(h(end),'markerfacecolor','none');
    end
    
end
if ~ishold(cax), view(cax,3), grid(cax,'on'), end

if nargout>0, hh = h; end


function [pvpairs,args,nargs,msg] = parseargs(args)
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
n = 1;
extrapv = {};
% check for 'filled' or LINESPEC or ColorSpec
while length(pvpairs) >= 1 && n < 5 && ischar(pvpairs{1})
  arg = lower(pvpairs{1});
  if arg(1) == 'f'
    pvpairs(1) = [];
    extrapv = {'MarkerFaceColor','flat','MarkerEdgeColor','none', ...
               extrapv{:}};
  else
    [l,c,m,tmsg]=colstyle(pvpairs{1});
    if isempty(tmsg)
      pvpairs(1) = [];
      if ~isempty(l) 
        extrapv = {'LineStyle',l,extrapv{:}};
      end
      if ~isempty(c)
        extrapv = {'CData',ColorSpecToRGB(c),extrapv{:}};
      end
      if ~isempty(m)
        extrapv = {'Marker',m,extrapv{:}};
      end
    end
  end
  n = n+1;
end
pvpairs = [extrapv pvpairs];
msg = checkpvpairs(pvpairs);
nargs = length(args);

function [color,msg] = ColorSpecToRGB(s)
color=[];
msg = [];
switch s
 case 'y'
  color = [1 1 0];
 case 'm'
  color = [1 0 1];
 case 'c'
  color = [0 1 1];
 case 'r'
  color = [1 0 0];
 case 'g'
  color = [0 1 0];
 case 'b'
  color = [0 0 1];
 case 'w'
  color = [1 1 1];
 case 'k'
  color = [0 0 0];
 otherwise
  msg = 'unrecognized color string';
end

%--------------------------------------------------------------------------
function msg = Lxyzchk(x,y,z)
msg = [];
% Verify {X,Y,Z) data is correct size
if any([length(x) length(y) length(z) ...
        numel(x) numel(y) numel(z)] ~= length(x))
    msg = struct('identifier',id('invalidData'),...
                 'message','X, Y and Z must be vectors of the same length.');
end

%--------------------------------------------------------------------------
function msg = Lcchk(x,c)
msg = [];
% Verify CData is correct size
if ischar(c) || isequal(size(c),[1 3]); 
    % string color or scalar rgb 
elseif length(c)==numel(c) && length(c)==length(x)
    % C is a vector
elseif isequal(size(c),[length(x) 3]), 
    % vector of rgb's
else
    msg = struct('identifier',id('invalidCData'),...
                 'message',['C must be a single color, a vector the same length as X, ',...
           'or an M-by-3 matrix.']);
end

%--------------------------------------------------------------------------
function msg = Lschk(x,s)
msg = [];
% Verify correct S vector
if length(s) > 1 && ...
              (length(s)~=numel(s) || length(s)~=length(x))
    msg = struct('identifier',id('invalidSData'),...
                 'message','S must be a scalar or a vector the same length as X.');
end

function str = id(str)
str = ['MATLAB:scatter3:' str];
