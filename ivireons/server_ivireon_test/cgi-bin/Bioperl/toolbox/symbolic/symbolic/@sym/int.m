function r = int(f,x,a,b)
%INT    Integrate
%   INT(S) is the indefinite integral of S with respect to its symbolic
%     variable as defined by SYMVAR. S is a SYM (matrix or scalar).
%     If S is a constant, the integral is with respect to 'x'.
%   INT(S,v) is the indefinite integral of S with respect to v. v is a
%     scalar SYM.
%   INT(S,a,b) is the definite integral of S with respect to its
%     symbolic variable from a to b. a and b are each double or
%     symbolic scalars.
%   INT(S,v,a,b) is the definite integral of S with respect to v
%     from a to b.
%
%   Examples:
%     syms x x1 alpha u t;
%     A = [cos(x*t),sin(x*t);-sin(x*t),cos(x*t)];
%     int(1/(1+x^2))           returns     atan(x)
%     int(sin(alpha*u),alpha)  returns     -cos(alpha*u)/u
%     int(besselj(1,x),x)      returns     -besselj(0,x)
%     int(x1*log(1+x1),0,1)    returns     1/4
%     int(4*x*t,x,2,sin(t))    returns     -2*t*cos(t)^2 - 6*t
%     int([exp(t),exp(alpha*t)])  returns  [ exp(t), exp(alpha*t)/alpha]
%     int(A,t)                 returns      [sin(t*x)/x, -cos(t*x)/x]
%                                           [cos(t*x)/x,  sin(t*x)/x]

%   Copyright 1993-2010 The MathWorks, Inc.

f = sym(f);
if builtin('numel',f) ~= 1,  f = normalizesym(f);  end
if nargin <= 2
   % Indefinite integral
   if nargin < 2
      x = symvar(f,1);
      if isempty(x), x = sym('x'); end
   end
   if ischar(x), x = sym(x); end
   if isa(f.s,'maplesym')
       r = sym(int(f.s,x.s));
   else
       r = mupadmex('symobj::intindef',f.s,x.s);
   end
else
   % Definite integral
   if nargin < 4
      b = a;
      a = x;
      x = symvar(f,1);
      if isempty(x), x = sym('x'); end
   end
   b = sym(b);
   a = sym(a);
   if ischar(x), x = sym(x); end
   if isa(f.s,'maplesym')
       r = sym(int(f.s,x.s,a.s,b.s));
   else
       r = mupadmex('symobj::intdef',f.s,x.s,a.s,b.s);
   end
end
