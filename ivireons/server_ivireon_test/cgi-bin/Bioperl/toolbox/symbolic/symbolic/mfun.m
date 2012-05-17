function y = mfun(fun,varargin)
%MFUN   Numeric evaluation of a special function.
%   MFUN('function',p1,p2,...,pk) numerically evaluates one of
%   the symbolic engine's special mathematical functions. The 'function'
%   input is the name of the function to evaluate and the p's are numeric 
%   inputs to 'function'. The function MFUNLIST displays the allowed
%   function names and their inputs.
%   The last parameter specified may be a matrix.
%
%   Example:
%      x = 0:0.1:5.0;
%      y = mfun('FresnelC',x)
%
%   See also MFUNLIST, SYMENGINE.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/05 18:21:14 $

eng = symengine;
ismupad = strcmp(eng.kind,'mupad');
if ~ismupad
    for k=1:length(varargin)
        v = varargin{k};
        if isa(v,'sym')
            varargin{k} = getMapleObject(v);
        end
    end
    y = mapleengine('mfun',fun,varargin{:});
    return
end

if isequal(lower(fun),'hypergeom')
   y = hypergeom(varargin{:});
   return
end

currd = digits;
d = 16;
digits(d);
[fun,varargin] = map2mupfun(fun,varargin);

a = computeA(varargin{:});
[x,siz,nans] = computeX(varargin{:});
y = formatY(x,d);
[r,st] = evalFun(y,a,fun);
if st == 0
    y = processResult(r,siz,nans);
else
    y = processSingularity(r,siz,nans,fun,y,a);
end
digits(currd);


function a = computeA(varargin)
a = [];
for k = 1:length(varargin)-1
   t = varargin{k};
   if ~isnumeric(t)
      t = str2num(t); %#ok
      if isempty(t)
         error('symbolic:mfun:errmsg1', ...
            'Parameters must represent numeric quantities.')
      end
   end
   a = [a ',' char(sym(t))]; %#ok<AGROW>
end;
if ~isempty(a), a = [a(2:end) ',']; end;

function [x,siz,nans] = computeX(varargin)
x = varargin{length(varargin)};
if ~isnumeric(x)
   x = str2num(x); %#ok
   if isempty(x)
      error('symbolic:mfun:errmsg1', ...
         'Parameters must represent numeric quantities.')
   end
end

siz = size(x);
x = x(:).';
nans = isnan(x);
x(nans) = 0;

function y = formatY(x,d)
% format arguments for integer and real x
if all(imag(x) == 0)
   if all(x == fix(x))
      form = ['%' int2str(d) '.0f,'];
   else
      form = ['%' int2str(d+6) '.' int2str(d) 'e,'];
   end
   y = sprintf(form,x);

% format arguments for complex x
else
   form = ['%' int2str(d+6) '.' int2str(d) 'e'];
   y = sprintf([form '#' form '*i,'],[real(x); abs(imag(x))]);
   p = find(y == '#');

   % add the correct signs for imaginary parts
   s = find(imag(x) >= 0);
   if any(s)
      y(p(s)) = char('+'*ones(1,length(s)));
   end
   s = find(imag(x) < 0);
   if ~isempty(s) && any(s)
      y(p(s)) = char('-'*ones(1,length(s)));
   end
end

% additional format for the MEX file
y(length(y)) = [];
y = ['[' y ']'];


function [r,st] = evalFun(y,a,fun)
[r,st] = evalin(symengine,['float(eval(map(' y ', s->' fun '(' a 's))))']); 

function y = processResult(r,siz,nans)
r = double(r);
if isempty(r)
    error('symbolic:mfun:errmsg4','Cannot evaluate Maple result.')
end
r(nans) = NaN;
y = reshape(r,siz);

function y = processSingularity(r,siz,nans,fun,y,a)
   % singularities in r
   if ~isempty(strfind(r,'division by zero')) || ~isempty(strfind(r,'NaN')) || ~isempty(strfind(r,'singularity'))
      y = [',' y(2:length(y)-1) ','];  % use commas as delimiters for ALL elements
      c = find(y == ',');
      u = NaN*ones(1,prod(siz));

      for k = 2:length(c)
         r = y( c(k-1)+1 : c(k)-1 );
         [r,st] = evalin(symengine,['float(' fun '(' a r '))']);
         if st == 0
            u(k-1) = double(r);
         end
      end

      u(nans) = NaN;
      y = reshape(u,siz);

   % Overflow
   elseif findstr(r,'too large')
      y = [',' y(2:length(y)-1) ','];  % use commas as delimiters for ALL elements
      c = find(y == ',');
      u = Inf*ones(1,prod(siz));

      for k = 2:length(c)
         r = y( c(k-1)+1 : c(k)-1 );
         [r,st] = evalin(symengine,['float(' fun '(' a r '))']);
         %         [r,st] = maple(['evalf(' fun '(' a r '))']);
         if st==0, u(k-1) = double(r); end
      end

      u(nans) = NaN;
      y = reshape(u,siz);

   else
      error('symbolic:mfun:errmsg2',r)
   end



% Change function names and argument order or normalization for MuPAD
function [fun,args] = map2mupfun(fun,args)
fun(1) = lower(fun(1));
switch fun
  case 'ellipticF'
    args{1} = asin(args{1});
    args{2} = args{2}.^2;
  case {'ellipticK','ellipticCK','ellipticCE'}
    args{1} = args{1}.^2;        
  case 'ellipticE'
    if length(args) == 1
        args{1} = args{1}.^2;
    else
        args{1} = asin(args{1});
        args{2} = args{2}.^2;
    end
  case 'ellipticPi'
    if length(args) == 3
        args = {args{2},asin(args{1}),args{3}.^2};
    else
        args{2} = args{2}.^2;
    end
  case 'ellipticCPi'
    args{2} = args{2}.^2;
  case {'psi','erfc'}
    if length(args) == 2
        args = fliplr(args);
    end
  case 'ei'
    fun = 'Ei';
  case 'li'
     fun = '((z)->Ei(ln(z)))';
  case 'ci'
    fun = 'cosint';
  case 'si'
    fun = 'sinint';
  case 'chi'
    fun = 'Chi';
  case 'shi'
    fun = 'Shi';
  case 'w'
    fun = 'lambertW';
  case 'gAMMA'
    if length(args) == 1
        fun = 'gamma';
    else
        fun = 'igamma';
    end
  case 'harmonic'
    fun = '((z)->psi(z+1)+eulergamma)';
  case 'lnGAMMA'
    fun = '((z)->ln(gamma(z)))';
  case 'ssi'
    fun = '((z)->sinint(z)-PI/2)';
  case 'zeta'
    if length(args) == 3
         error('symbolic:mfun:ZetavNotSupported',...
          'MuPAD does not support the three-argument form of zeta');
    else
        args=fliplr(args);
    end
    % polynomials
  case 't'
    fun = 'orthpoly::chebyshev1';
  case 'u'
    fun = 'orthpoly::chebyshev2';
  case 'g'
    fun = 'orthpoly::gegenbauer';
  case 'h'
    fun = 'orthpoly::hermite';
  case 'p'
    if length(args)==2
        fun = 'orthpoly::legendre';
    else
        fun = 'orthpoly::jacobi';
    end
  case 'l'
    fun = 'orthpoly::laguerre';
    if length(args)==2
        args = [args(1) 0 args(2)];
    end
  otherwise
    % assume matches MuPAD
end
