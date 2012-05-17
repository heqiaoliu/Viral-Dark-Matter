function div=divergence(varargin)
%DIVERGENCE  Divergence of a vector field.
%   DIV = DIVERGENCE(X,Y,Z,U,V,W) computes the divergence of a 3-D
%   vector field U,V,W. The arrays X,Y,Z define the coordinates for
%   U,V,W and must be monotonic and 3-D plaid (as if produced by
%   MESHGRID).
%   
%   DIV = DIVERGENCE(U,V,W) assumes 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) where [M,N,P]=SIZE(U). 
%
%   DIV = DIVERGENCE(X,Y,U,V) computes the divergence of a 2-D
%   vector field U,V. The arrays X,Y define the coordinates for U,V
%   and must be monotonic and 2-D plaid (as if produced by
%   MESHGRID). 
%   
%   DIV = DIVERGENCE(U,V) assumes 
%         [X Y] = meshgrid(1:N, 1:M) where [M,N]=SIZE(U). 
%   
%   Example:
%      load wind
%      div = divergence(x,y,z,u,v,w);
%      slice(x,y,z,div,[90 134],[59],[0]); shading interp
%      daspect([1 1 1])
%      camlight
%
%   See also STREAMTUBE, CURL, ISOSURFACE.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2009/05/18 20:49:56 $

error(nargchk(2,6,nargin,'struct'));
[x y z u v w] = parseargs(nargin,varargin);

% Take this out when other data types are handled
u = double(u);
v = double(v);
w = double(w);

if isempty(w)  % 2D

  [msg x y] = xyuvcheck(x,y,u,v);  error(msg) 
  if isempty(x)
    [px junk] = gradient(u); %#ok
    [junk qy] = gradient(v); %#ok
  else
    hx = x(1,:); 
    hy = y(:,1); 
    [px junk] = gradient(u, hx, hy); %#ok
    [junk qy] = gradient(v, hx, hy); %#ok
  end
  div = px+qy;
  
else   %3D
  
  [msg x y z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg) 
  if isempty(x)
    [px junk junk] = gradient(u); %#ok
    [junk qy junk] = gradient(v); %#ok
    [junk junk rz] = gradient(w); %#ok
  else
    hx = x(1,:,1); 
    hy = y(:,1,1); 
    hz = z(1,1,:); 
    [px junk junk] = gradient(u, hx, hy, hz); %#ok
    [junk qy junk] = gradient(v, hx, hy, hz); %#ok
    [junk junk rz] = gradient(w, hx, hy, hz); %#ok
  end
  
  div = px+qy+rz;
  
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
w = [];

if nin==2         % divergence(u,v)
  u = vargin{1};
  v = vargin{2};
elseif nin==3     % divergence(u,v,w)
  u = vargin{1};
  v = vargin{2};
  w = vargin{3};
elseif nin==4     % divergence(x,y,u,v)
  x = vargin{1};
  y = vargin{2};
  u = vargin{3};
  v = vargin{4};
elseif nin==6     % divergence(x,y,z,u,v,w)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  u = vargin{4};
  v = vargin{5};
  w = vargin{6};
else
  error('MATLAB:divergence:WrongNumberOfInputs',...
        'Wrong number of input arguments.'); 
end
