function c = simscapeEquation(lhs,rhs)
%simscapeEquation  generate a Simscape equation from a sym
%   simscapeEquation(S) generates a string containing the Simscape equation defining S.
%   Any derivative with respect to the variable 't' is converted to the
%   Simscape notation X.der where X is the time-dependent variable. Any other
%   use of the variable 't' is replaced with 'time'.
%
%   simscapeEquation(LHS,RHS) returns a Simscape equation LHS == RHS. 
%   
%   Examples:
%      syms t
%      x = sym('x(t)');
%      y = sym('y(t)');
%      phi = diff(x)+5*y + sin(t);
%      simscapeEquation(phi)
%         phi == x.der + sin(time) + 5*y;
%      simscapeEquation(diff(y),phi)
%         y.der == x.der + sin(time) + 5*y;
%
%   See also sym/matlabFunction, ssc_new.

%   Copyright 2009 The MathWorks, Inc.

if nargin == 1
    rhs = lhs;
    lhs = inputname(1);
    if isempty(lhs), lhs = 'T'; end
end
c = [convert(lhs) ' == ' convert(rhs)];

function c = convert(s)
if isa(s,'sym')
  c = convertsym(s);
elseif isa(s,'char')
  c = s;
else
  c = convertsym(sym(s));
end

function c = convertsym(s)
% convert sym s to string c
if builtin('numel',s) ~= 1,  s = normalizesym(s);  end
symbols = getsymbols(s);
c = char(s);
c = deblank(c);
% replace diff(x(t),t) -> x.der
c = regexprep(c,'diff\((\w+)\(t\), t\)','$1.der');
% replace x(t) -> x
for v=symbols
    cv = char(v);
    c = regexprep(c,['\<' cv '\(t\)'],cv);
end
% replace t -> time
c = regexprep(c,'\<t\>','time');
c = convertAllPiecewise(c);
 
function symbols = getsymbols(s)
% get the user variables in the expression
symbols = feval(symengine,'indets',s,'All');
symbols = feval(symengine,'select',symbols,'_not @ prog::isGlobal');
 
function c = convertAllPiecewise(c)
% get the nesting of parens
parens = double(c=='(') - double(c==')');
depth = cumsum(parens);
% look for and handle piecewise
p = strfind(c,'piecewise');
for k=fliplr(p)
    c = convertpiecewise(c,depth,k);
end

function c = convertpiecewise(c,depth,k)
    % convert an individual piecewise expression and return modified string
    pdepth = depth(k);
    endk = find(depth(k+10:end)==pdepth,1)+k+10;
    pw = c(k:endk-1);
    pw = strrep(pw,'piecewise([','if ');
    pw = strrep(pw,'])',' end');
    pw = strrep(pw,'], [Otherwise,', ' else ');
    pw = strrep(pw,'], [', ' elseif ');
    pw = strrep(pw,' or ',' || ');
    pw = strrep(pw,' and ',' && ');
    pw = strrep(pw,' not ',' ~ ');
    pw = strrep(pw,' = ',' == ');
    pw = strrep(pw,' <> ',' ~= ');
    pw = regexprep(pw,'\<(\w+) in Dom::Interval\(([^,]+), ([^,]+)\)',...
        '(($1 > $2) && ($1 < $3))');
    c = [c(1:k-1) pw c(endk:end)];
