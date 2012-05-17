function r = latex(s)
%LATEX  LaTeX representation of a symbolic expression.
%   LATEX(S) returns the LaTeX representation of the symbolic expression S.
%
%   Examples:
%      syms x
%      f = taylor(log(1+x));
%      latex(f) =
%         \frac{x^5}{5} - \frac{x^4}{4} + \frac{x^3}{3} - \frac{x^2}{2} + x
%
%      H = sym(hilb(3));
%      latex(H) =
%        \left(\begin{array}{ccc} 1 & \frac{1}{2} & \frac{1}{3}\\ 
%        \frac{1}{2} & \frac{1}{3} & \frac{1}{4}\\ \frac{1}{3} & 
%        \frac{1}{4} & \frac{1}{5} \end{array}\right)
%     
%      syms alpha t
%      A = [alpha t alpha*t];
%      latex(A) =
%        \left(\begin{array}{ccc} \mathrm{alpha} & t & \mathrm{alpha}\,
%        t \end{array}\right)
%
%   See also SYM/PRETTY, SYM/CCODE, SYM/FORTRAN.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',s) ~= 1,  s = normalizesym(s);  end
if isa(s.s,'maplesym')
    r = latex(s.s);
else
    r = mupadmex('generate::TeX',s.s,0);
    r = r(2:end-1); % trim enclosing quotes
    r = sprintf(r);
    r = strrep(r,sprintf('\n'),' ');
end
