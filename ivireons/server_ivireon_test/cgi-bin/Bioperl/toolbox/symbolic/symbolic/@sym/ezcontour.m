function ezcontour(f,varargin)
%EZCONTOUR General surface contour plotter.
%   EZCONTOUR(f) plots the contour lines of f(x,y) using CONTOUR where
%   f is a string or symbolic expression representing a mathematical
%   function of two variables, say 'x' and 'y'.  The function f is 
%   plotted over the default domain -2*pi < x < 2*pi, -2*pi < y <
%   2*pi.  The computational grid is chosen according to the amount
%   of variation that occurs.
%
%   EZCONTOUR(f,DOMAIN) plots f over the specified DOMAIN instead of the
%   default DOMAIN = [-2*pi,2*pi,-2*pi,2*pi].  The DOMAIN can be the
%   4-by-1 vector [xmin,xmax,ymin,ymax] or the 2-by-1 vector [a,b] (to
%   plot over a < x < b, a < y < b).
%
%   If f is a function of the variables u and v (rather than x and y),
%   then the domain endpoints umin, umax, vmin, and vmax are sorted
%   alphabetically.  Thus, EZCONTOUR(u^2 - v^3,[0,1],[3,6]) plots the
%   contour lines for u^2 - v^3 over 0 < u < 1, 3 < v < 6.
%
%   EZCONTOUR(...,fig) plots f over the default domain in the figure window
%   fig.
%
%   Examples:
%    syms x y z t u v
%    f = 3*(1-x)^2*exp(-(x^2) - (y+1)^2) ... 
%       - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ... 
%       - 1/3*exp(-(x+1)^2 - y^2);
%    ezcontour(f,[-pi,pi])
%    ezcontour(sin(sqrt(x^2+y^2))/sqrt(x^2+y^2),[-6*pi,6*pi])
%    ezcontour(x*exp(-x^2 - y^2))
%    ezcontour(-3*z/(1 + t^2 - z^2),[-4,4],120)
%    ezcontour(sin(u)*sin(v),[-2*pi,2*pi])
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZCONTOURF, EZSURF, EZMESH,
%            EZSURFC, EZMESHC, CONTOUR.

%   Copyright 1993-2010 The MathWorks, Inc.

eng = symengine;
if strcmp(eng.kind,'maple')
    F = makeinline(f);
else
    F = matlabFunction(f);
    checkNoSyms(varargin);
end
ezcontour(F,varargin{:});

function checkNoSyms(args)
    if any(cellfun(@(arg)isa(arg,'sym'),args))
        error('symbolic:ezhelper:TooManySyms','Too many sym objects to plot.');
    end
