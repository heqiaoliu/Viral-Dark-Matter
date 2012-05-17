function [x0,y0] = fplot(varargin)
%FPLOT   Plot function
%   FPLOT(FUN,LIMS) plots the function FUN between the x-axis limits
%   specified by LIMS = [XMIN XMAX]. Using LIMS = [XMIN XMAX YMIN YMAX]
%   also controls the y-axis limits. FUN(x) must return a row vector for
%   each element of vector x. For example, if FUN returns
%   [f1(x),f2(x),f3(x)] then for input [x1;x2] FUN should return
%
%      [f1(x1) f2(x1) f3(x1);
%       f1(x2) f2(x2) f3(x2)]
%
%   FPLOT(FUN,LIMS,TOL) with TOL < 1 specifies the relative error
%   tolerance. The default TOL is 2e-3, i.e. 0.2 percent accuracy.
%
%   FPLOT(FUN,LIMS,N) with N >= 1 plots the function with a minimum of N+1
%   points. The default N is 1. The maximum step size is restricted to be
%   (1/N)*(XMAX-XMIN).
%
%   FPLOT(FUN,LIMS,'LineSpec') plots with the given line specification.
%
%   FPLOT(FUN,LIMS,...) accepts combinations of the optional arguments
%   TOL, N, and 'LineSpec', in any order.
%   
%   [X,Y] = FPLOT(FUN,LIMS,...) returns X and Y such that Y = FUN(X). No
%   plot is drawn on the screen.
%
%   FPLOT(AX,...) plots into AX instead of GCA.
%
%   Examples:
%       fplot(@humps,[0 1])
%       fplot(@(x)[tan(x),sin(x),cos(x)], 2*pi*[-1 1 -1 1])
%       fplot(@(x) sin(1./x), [0.01 0.1], 1e-3)
%       f = @(x,n)abs(exp(-1j*x*(0:n-1))*ones(n,1));
%       fplot(@(x)f(x,10),[0 2*pi])
%
%   See also PLOT, EZPLOT, FUNCTION_HANDLE.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.22.4.5 $  $Date: 2005/04/28 19:56:28 $

%   The FPLOT function begins with a minimum step of size (XMAX-XMIN)*TOL.
%   The step size is subsequently doubled whenever the relative error
%   between the linearly predicted value and the actual function value is
%   less than TOL.  The maximum number of x steps is (1/TOL)+1.


%fun,lims,

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

error(nargchk(2,inf,nargs,'struct'));

fun  = args{1};
lims = args{2};
args = args(3:end);

if (isvarname(fun))
   fun = ezfcnchk(fun);
else
   fun = fcnchk(fun);
end

marker = '-';
tol = 2e-3;
N = 1;
if nargs >= 3 && ~isempty(args{1})
  if ischar(args{1})
    marker = args{1};
  elseif args{1} < 1
    tol = args{1};
  else
    N = args{1};
  end
end
if nargs >= 4 && ~isempty(args{2})
  if ischar(args{2})
    marker = args{2};
  elseif args{2} < 1
    tol = args{2};
  else 
    N = args{2};
  end
end
if nargin >= 5 && ~isempty(args{3})
  if ischar(args{3})
    marker = args{3};
  elseif args{3} < 1
    tol = args{3};
  else
    N = args{3};
  end
end

% compute the x duration and minimum and maximum x step
xmin = min(lims(1:2)); xmax = max(lims(1:2));
maxstep = (xmax - xmin) / N;
minstep = min(maxstep,(xmax - xmin) * tol);
tryVal = minstep;

% compute the first two points
x = xmin; y = feval(fun,x,args{4:end});

xx = x;
x = xmin+minstep; y(2,:) = feval(fun,x,args{4:end});
xx(2) = x;

% compute a constant ytol if y limits are given
if length(lims) == 4
  ymin = min(lims(3:4)); ymax = max(lims(3:4));
  ylims = 1;
else
  J = find(isfinite(y));
  if isempty(J)
    ymin = 0; ymax = 0;
  else
    ymin = min(y(J)); ymax = max(y(J));
  end
  ylims = 0;
end
ytol = (ymax - ymin) * tol;

I = 2;
while xx(I) < xmax
  I = I+1;

  tryVal = min(maxstep,min(2*tryVal, xmax-xx(I-1)));
  x = xx(I-1) + tryVal;
  y(I,:) = feval(fun,x,args{4:end});

  ylin = y(I-1,:) + (x-xx(I-1)) * (y(I-1,:)-y(I-2,:)) / (xx(I-1)-xx(I-2));

  while any(abs(y(I,:) - ylin) > ytol) && (tryVal > minstep)
    tryVal = max(minstep,0.5*tryVal);
    x = xx(I-1) + tryVal;
    y(I,:) = feval(fun,x,args{4:end});
    ylin = y(I-1,:) + (x-xx(I-1)) * (y(I-1,:)-y(I-2,:)) / (xx(I-1)-xx(I-2));
  end

  if ~ylims
    J = find(isfinite(y(I,:)));
    if ~isempty(J)
      ymin = min(ymin,min(y(I,J))); ymax = max(ymax,max(y(I,J)));
      ytol = (ymax - ymin) * tol;
    end
  end

  xx(I) = x;
end

if nargout == 0
  cax = newplot(cax);
  plot(xx,y,marker,'parent',cax)
  set(cax,'XLim',[xmin xmax]);
  if ylims
    set(cax,'YLim',[ymin ymax]);
  end
else
  x0 = xx.'; y0 = y;
end
