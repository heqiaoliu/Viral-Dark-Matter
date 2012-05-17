function hh = ribbon(varargin)
%RIBBON Draw 2-D lines as ribbons in 3-D.
%   RIBBON(X,Y) is the same as PLOT(X,Y) except that the columns of
%   Y are plotted as separated ribbons in 3-D.  RIBBON(Y) uses the
%   default value of X=1:SIZE(Y,1).
%
%   RIBBON(X,Y,WIDTH) specifies the width of the ribbons to be
%   WIDTH.  The default value is WIDTH = 0.75;  
%
%   RIBBON(AX,...) plots into AX instead of GCA.
%
%   H = RIBBON(...) returns a vector of handles to surface objects.
%
%   See also PLOT.

%   Clay M. Thompson 2-8-94
%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.17.4.2 $  $Date: 2005/04/28 19:56:52 $

error(nargchk(1,inf,nargin,'struct'));
[cax,args,nargs] = axescheck(varargin{:});

% Parse input arguments.
if nargs<3, 
  width = .75;
  [msg,x,y] = xychk(args{1:nargs},'plot');
else
  width = args{3};
  [msg,x,y] = xychk(args{1:2},'plot');
end

if ~isempty(msg), error(msg); end %#ok
if isscalar(x) || isscalar(y)
  error('MATLAB:ribbon:ScalarInputs','Data inputs must not be scalar.');
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

m = size(y,1);
zz = [-ones(m,1) ones(m,1)]/2;
h = [];
cc = ones(size(y,1),2);
for n=1:size(y,2),
  h = [h;surface(zz*width+n,[x(:,n) x(:,n)],[y(:,n) y(:,n)],n*cc,'parent',cax)];
end

if ~hold_state, view(cax,3); grid(cax,'on'), set(cax,'NextPlot',next); end

if nargout>0, hh = h; end

