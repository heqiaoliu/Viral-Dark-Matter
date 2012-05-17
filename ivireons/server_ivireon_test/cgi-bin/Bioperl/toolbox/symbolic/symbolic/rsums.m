function rsums(f,a,b)
%RSUMS  Interactive evaluation of Riemann sums.
%   RSUMS(f) approximates the integral of f from 0 to 1 by Riemann sums.
%   RSUMS(f,a,b) and RSUMS(f,[a,b]) approximates the integral from a to b.
%   f can be a string, a sym, an inline function, an anonymous function, or
%   a function handle.  RSUMS is often called with the command line form, eg.
%      rsums exp(-5*x^2)

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/02/17 19:10:54 $

if nargin ~= 0
   % Initialization
   % Make sure f can be evaluated.
   if isa(f,'char')
      f = vectorize(inline(f));
   elseif isa(f,'sym')
      f = vectorize(inline(char(f)));
   end
   args.f = f;
   if nargin == 1
      args.a = 0; args.b = 1;
   elseif nargin == 2
      args.a = a(1); args.b = a(2);
   else
      args.a = a; args.b = b;
   end
   clf reset
   set(gcf,'userdata',args)
   set(gca,'position',get(gca,'position')+[0 .05 0 -.05])
   uicontrol('units','normal','style','slider','pos',[.18 .03 .70 .04],...
      'min',2,'max',128,'value',10,'callback','rsums');
end

args = get(gcf,'userdata');
f = args.f;
a = args.a;
b = args.b;
n = round(get(findobj(gcf,'type','uicontrol'),'value'));
x = a + (b-a)*(1/2:1:n-1/2)/n;
if isa(f,'function_handle')
   y = zeros(size(x));
   for k = 1:length(x)
      y(k) = f(x(k));
   end
else
   y = f(x);
end
r = (b-a)*sum(y)/n;
bar(x,y)
if isa(f,'function_handle')
   title(sprintf('%9.6f',r),'interpreter','none')
else
   title([char(f) '  :  ' sprintf('%9.6f',r)],'interpreter','none')
end
xlabel(int2str(n))
axis([a b min(0,min(y)) max(0,max(y))])
