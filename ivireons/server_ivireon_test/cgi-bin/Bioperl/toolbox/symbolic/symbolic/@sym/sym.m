classdef sym < handle
    %SYM    Construct symbolic numbers, variables and objects.
    %   S = SYM(A) constructs an object S, of class 'sym', from A.
    %   If the input argument is a string, the result is a symbolic number
    %   or variable.  If the input argument is a numeric scalar or matrix,
    %   the result is a symbolic representation of the given numeric values.
    %   If the input is a function handle the result is the symbolic form
    %   of the body of the function handle.
    %
    %   x = sym('x') creates the symbolic variable with name 'x' and stores the
    %   result in x.  x = sym('x','real') also assumes that x is real, so that
    %   conj(x) is equal to x.  alpha = sym('alpha') and r = sym('Rho','real')
    %   are other examples.  Similarly, k = sym('k','positive') makes k a
    %   positive (real) variable.  x = sym('x','clear') restores x to a
    %   formal variable with no additional properties (i.e., insures that x
    %   is NEITHER real NOR positive). Defining the symbol 'i' will use 
    %   sqrt(-1) in place of the imaginary i until 'clear' is used.
    %   See also: SYMS.
    %
    %    A = sym('A',[M N]) creates M-by-N vectors or matrices of symbolic scalar 
    %   variables. Elements of vectors have names of the form Ak and elements
    %   of matrices have names of the form Ai_j where k,i or j range over 1:M
    %   or 1:N. The form can be controlled exactly by using '%d' in the first
    %   input (eg 'A%d%d' will make names Aij).
    %   A = sym('A',N) creates an N-by-N matrix.
    %   sym(A,ASSUMPTION) makes or clears assumptions on A as described in
    %   the previous paragraph.
    %
    %   Statements like pi = sym('pi') and delta = sym('1/10') create symbolic
    %   numbers which avoid the floating point approximations inherent in the
    %   values of pi and 1/10.  The pi created in this way temporarily replaces
    %   the built-in numeric function with the same name.
    %
    %   S = sym(A,flag) converts a numeric scalar or matrix to symbolic form.
    %   The technique for converting floating point numbers is specified by
    %   the optional second argument, which may be 'f', 'r', 'e' or 'd'.
    %   The default is 'r'.
    %
    %   'f' stands for 'floating point'.  All values are transformed from
    %   double precision to exact numeric values N*2^e for integers N and e.
    %
    %   'r' stands for 'rational'.  Floating point numbers obtained by
    %   evaluating expressions of the form p/q, p*pi/q, sqrt(p), 2^q and 10^q
    %   for modest sized integers p and q are converted to the corresponding
    %   symbolic form.  This effectively compensates for the roundoff error
    %   involved in the original evaluation, but may not represent the floating
    %   point value precisely.  If no simple rational approximation can be
    %   found, the 'f' form is used.
    %
    %   'e' stands for 'estimate error'.  The 'r' form is supplemented by a
    %   term involving the variable 'eps' which estimates the difference
    %   between the theoretical rational expression and its actual floating
    %   point value.  For example, sym(3*pi/4,'e') is 3*pi/4-103*eps/249.
    %
    %   'd' stands for 'decimal'.  The number of digits is taken from the
    %   current setting of DIGITS used by VPA.  Using fewer than 16 digits
    %   reduces accuracy, while more than 16 digits may not be warranted.
    %   For example, with digits(10), sym(4/3,'d') is 1.333333333, while
    %   with digits(20), sym(4/3,'d') is 1.3333333333333332593,
    %   which does not end in a string of 3's, but is an accurate decimal
    %   representation of the double-precision floating point number nearest
    %   to 4/3.
    %
    %   See also SYMS, CLASS, DIGITS, VPA.
    
    %   The flag 'unreal' is the same as 'clear'.
    
    %   Copyright 1993-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.9.2.1 $  $Date: 2010/07/06 15:22:10 $
    
    properties (Access=private)
        s
    end
    methods(Static)
        function y = loadobj(x)
        %LOADOBJ    Load symbolic object
        %   Y = LOADOBJ(X) is called when loading symbolic objects
        
        eng = symengine;
        if strcmp(eng.kind,'maple')
            y = sym(maplesym(x));
        elseif isa(x,'struct')
            if isscalar(x)
                cx = {x.s};
            else
                cx = reshape({x.s},size(x));
            end
            y = sym(cx);
        else
            n = builtin('numel',x);
            if n > 1
                % x is an ndim sym
                cx = reshape({x.s},size(x));
                y = sym(cx);
            elseif n == 0
                y = reshape(sym([]),size(x));
            else
                y = x;
            end
        end
        end
    end
    methods
        function S = sym(x,a)
        
        eng = symengine;
        if nargin == 1
            if strcmp(eng.kind,'maple')
                S.s = maplesym(x);
            else
                S.s = tomupad(x,'');
            end
        elseif nargin == 0
            % Default constructor
            if strcmp(eng.kind,'maple')
                S.s = maplesym();
            else
                S.s = '0';
            end
        elseif strcmp(eng.kind,'maple')
            S.s = maplesym(x,a);
        else
            S.s = tomupad(x,a);
        end
        end % sym constructor
        
        function delete(h)
        if builtin('numel',h)==1 && inmem('-isloaded','mupadmex') && ~isa(h.s,'maplesym')
            mupadmex(h.s,1);
        end
        end
        
        function y = length(x)
        %LENGTH   Length of symbolic vector.
        %   LENGTH(X) returns the length of vector X.  It is equivalent
        %   to MAX(SIZE(X)) for non-empty arrays and 0 for empty ones.
        %
        %   See also NUMEL.
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        sz = size(x);
        if prod(sz)==0
            y = 0;
        else
            y = max(sz);
        end
        end
        
        %---------------   Arithmetic  -----------------
        function Y = uminus(X)
        %UMINUS Symbolic negation.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(-X.s);
        else
            Y = mupadmex('_negate',X.s);
        end
        end
        
        function Y = uplus(X)
        %UPLUS Unary plus.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        Y = X;
        end
        
        function X = times(A, B)
        %TIMES  Symbolic array multiplication.
        %   TIMES(A,B) overloads symbolic A .* B.
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(B,'sym'), B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = sym(times(A.s,B.s));
        else
            X = mupadmex('symobj::zip',A.s,B.s,'_mult');
        end
        end
        
        function X = mtimes(A, B)
        %TIMES  Symbolic matrix multiplication.
        %   MTIMES(A,B) overloads symbolic A * B.
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(B,'sym'), B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = sym(mtimes(A.s,B.s));
        else
            X = mupadmex('symobj::mtimes',A.s,B.s);
        end
        end
        
        function B = mpower(A,p)
        %POWER  Symbolic matrix power.
        %   POWER(A,p) overloads symbolic A^p.
        %
        %   Example;
        %      A = [x y; alpha 2]
        %      A^2 returns [x^2+alpha*y  x*y+2*y; alpha*x+2*alpha  alpha*y+4].
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(p,'sym'), p = sym(p); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',p) ~= 1,  p = normalizesym(p);  end
        if isa(A.s,'maplesym')
            B = sym(mpower(A.s,p.s));
        else
            B = mupadmex('symobj::mpower',A.s,p.s);
        end
        end
        
        function B = power(A,p)
        %POWER  Symbolic array power.
        %   POWER(A,p) overloads symbolic A.^p.
        %
        %   Examples:
        %      A = [x 10 y; alpha 2 5];
        %      A .^ 2 returns [x^2 100 y^2; alpha^2 4 25].
        %      A .^ x returns [x^x 10^x y^x; alpha^x 2^x 5^x].
        %      A .^ A returns [x^x 1.0000e+10 y^y; alpha^alpha 4 3125].
        %      A .^ [1 2 3; 4 5 6] returns [x 100 y^3; alpha^4 32 15625].
        %      A .^ magic(3) is an error.
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(p,'sym'), p = sym(p); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',p) ~= 1,  p = normalizesym(p);  end
        if isa(A.s,'maplesym')
            B = sym(power(A.s,p.s));
        else
            B = mupadmex('symobj::zip',A.s,p.s,'_power');
        end
        end
        
        function X = rdivide(A, B)
        %RDIVIDE Symbolic array right division.
        %   RDIVIDE(A,B) overloads symbolic A ./ B.
        %
        %   See also SYM/LDIVIDE, SYM/MRDIVIDE, SYM/MLDIVIDE, SYM/QUOREM.
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(B,'sym'), B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = sym(rdivide(A.s,B.s));
        else
            X = mupadmex('symobj::zip',A.s,B.s,'symobj::divide');
        end
        end
        
        function X = ldivide(A, B)
        %LDIVIDE Symbolic array left division.
        %   LDIVIDE(A,B) overloads symbolic A .\ B.
        %
        %   See also SYM/RDIVIDE, SYM/MRDIVIDE, SYM/MLDIVIDE, SYM/QUOREM.
        if ~isa(A,'sym'),  A = sym(A); end
        if ~isa(B,'sym'),  B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = sym(A.s .\ B.s);
        else
            X = mupadmex('symobj::zip',B.s,A.s,'symobj::divide');
        end
        end
        
        function X = mrdivide(A, B)
        %/  Slash or symbolic right matrix divide.
        %   A/B is the matrix division of B into A, which is roughly the
        %   same as A*INV(B) , except it is computed in a different way.
        %   More precisely, A/B = (B'\A')'. See SYM/MLDIVIDE for details.
        %   Warning messages are produced if X does not exist or is not unique.
        %   Rectangular matrices A are allowed, but the equations must be
        %   consistent; a least squares solution is not computed.
        %
        %   See also SYM/MLDIVIDE, SYM/RDIVIDE, SYM/LDIVIDE, SYM/QUOREM.
        if ~isa(A,'sym'),  A = sym(A); end
        if ~isa(B,'sym'),  B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = sym(mrdivide(A.s,B.s));
        else
            X = mupadmex('symobj::mrdivide',A.s,B.s);
        end
        end
        
        function X = mldivide(A, B)
        %MLDIVIDE Symbolic matrix left division.
        %   MLDIVIDE(A,B) overloads symbolic A \ B.
        %   X = A\B solves the symbolic linear equations A*X = B.
        %   Warning messages are produced if X does not exist or is not unique.
        %   Rectangular matrices A are allowed, but the equations must be
        %   consistent; a least squares solution is not computed.
        %
        %   See also SYM/MRDIVIDE, SYM/LDIVIDE, SYM/RDIVIDE, SYM/QUOREM.
        if ~isa(A,'sym'),  A = sym(A); end
        if ~isa(B,'sym'),  B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = sym(mldivide(A.s,B.s));
        else
            X = mupadmex('symobj::mldivide',A.s,B.s);
        end
        end
        
        %---------------   Trig  -----------------
        
        function Y = cos(X)
        %COS    Symbolic cosine function.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(cos(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'cos');
        end
        end
        
        function Y = sin(X)
        %SIN    Symbolic sine function.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(sin(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'sin');
        end
        end
        
        function Y = tan(X)
        %TAN    Symbolic tangent function.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(tan(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'tan','infinity');
        end
        end
        
        function Y = csc(X)
        %CSC    Symbolic cosecant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(csc(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'csc','infinity');
        end
        end
        
        function Y = cot(X)
        %COT    Symbolic cotangent.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(cot(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'cot','infinity');
        end
        end
        
        function Y = sec(X)
        %SEC    Symbolic secant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(sec(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'sec','infinity');
        end
        end
        
        %---------------   Inverse Trig  -----------------
        
        function Y = acos(X)
        %ACOS   Symbolic inverse cosine.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(acos(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'acos');
        end
        end
        
        function Y = asin(X)
        %ASIN   Symbolic inverse sine.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(asin(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'asin');
        end
        end
        
        function Z = atan(Y,X)
        %ATAN   Symbolic inverse tangent.
        %       With two arguments, ATAN(Y,X) is the symbolic form of ATAN2(Y,X).
        if nargin == 1
            if builtin('numel',Y) ~= 1,  Y = normalizesym(Y);  end
            if isa(Y.s,'maplesym')
                Z = sym(atan(Y.s));
            else
                Z = mupadmex('symobj::mapFloatCheck',Y.s,'atan');
            end
        else
            Y = sym(Y);
            if builtin('numel',Y) ~= 1,  Y = normalizesym(Y);  end
            X = sym(X);
            if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
            if isa(X.s,'maplesym')
                Z = sym(atan(Y.s,X.s));
            else
                Z = mupadmex('symobj::atan2',Y.s,X.s);
            end
        end
        end
        
        function Y = acsc(X)
        %ACSC   Symbolic inverse cosecant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(acsc(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'acsc','infinity');
        end
        end
        
        function Y = acot(X)
        %ACOT   Symbolic inverse cotangent.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(acot(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'acot');
        end
        end
        
        function Y = asec(X)
        %ASEC   Symbolic inverse secant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(asec(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'asec','infinity');
        end
        end
        
        %---------------   Hyperbolic Trig  -----------------
        
        function Y = cosh(X)
        %COSH   Symbolic hyperbolic cosine.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(cosh(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'cosh');
        end
        end
        
        function Y = sinh(X)
        %SINH   Symbolic hyperbolic sine.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(sinh(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'sinh');
        end
        end
        
        function Y = tanh(X)
        %TANH   Symbolic hyperbolic tangent.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(tanh(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'tanh');
        end
        end
        
        function Y = csch(X)
        %CSCH   Symbolic hyperbolic cosecant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(csch(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'csch','infinity');
        end
        end
        
        function Y = coth(X)
        %COTH   Symbolic hyperbolic cotangent.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(coth(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'coth','infinity');
        end
        end
        
        function Y = sech(X)
        %SECH   Symbolic hyperbolic secant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(sech(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'sech','infinity');
        end
        end
        
        %---------------   Inverse Hyperbolic Trig  -----------------
        
        function Y = acosh(X)
        %ACOSH  Symbolic inverse hyperbolic cosine.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(acosh(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'acosh');
        end
        end
        
        function Y = asinh(X)
        %ASINH  Symbolic inverse hyperbolic sine.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(asinh(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'asinh');
        end
        end
        
        function Y = atanh(X)
        %ATANH  Symbolic inverse hyperbolic tangent.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(atanh(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'atanh');
        end
        end
        
        function Y = acsch(X)
        %ACSCH  Symbolic inverse hyperbolic cosecant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(acsch(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'acsch','infinity');
        end
        end
        
        function Y = acoth(X)
        %ACOTH  Symbolic inverse hyperbolic cotangent.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(acoth(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'acoth','infinity');
        end
        end
        
        function Y = asech(X)
        %ASECH  Symbolic inverse hyperbolic secant.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(asech(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'asech','infinity');
        end
        end
        
        %---------------   Elementary Functions  -----------------
        
        function X = conj(Z)
        %CONJ   Symbolic conjugate.
        %   CONJ(Z) is the conjugate of a symbolic Z.
        if builtin('numel',Z) ~= 1,  Z = normalizesym(Z);  end
        if isa(Z.s,'maplesym')
            X = sym(conj(Z.s));
        else
            X = mupadmex('conjugate',Z.s);
        end
        end
        
        function Y = imag(Z)
        %IMAG   Symbolic imaginary part.
        %   IMAG(Z) is the imaginary part of a symbolic Z.
        Y = (Z - conj(Z))/2i;
        end
        
        function X = real(Z)
        %REAL   Symbolic real part.
        %   REAL(Z) is the real part of a symbolic Z.
        X = (Z + conj(Z))/2;
        end
        
        function Y = abs(X1,X2)
        %ABS    Absolute value.
        %   ABS(X) is the absolute value of the elements of X. When
        %   X is complex, ABS(X) is the complex modulus (magnitude) of
        %   the elements of X.
        if nargin == 1
            if builtin('numel',X1) ~= 1,  X1 = normalizesym(X1);  end
            if isa(X1.s,'maplesym')
                Y = sym(abs(X1.s));
            else
                Y = mupadmex('symobj::map',X1.s,'abs');
            end
        else
            Y = ['sign(' char(X2) ')'];
        end
        end
        
        function Y = ceil(X)
        %CEIL   Symbolic matrix element-wise ceiling.
        %   Y = CEIL(X) is the matrix of the smallest integers >= X.
        %   Example:
        %      x = sym(-5/2)
        %      [fix(x) floor(x) round(x) ceil(x) frac(x)]
        %      = [ -2, -3, -3, -2, -1/2]
        %
        %   See also SYM/ROUND, SYM/FLOOR, SYM/FIX, SYM/FRAC.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(ceil(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'ceil');
        end
        end
        
        function Y = floor(X)
        %FLOOR  Symbolic matrix element-wise floor.
        %   Y = FLOOR(X) is the matrix of the greatest integers <= X.
        %   Example:
        %      x = sym(-5/2)
        %      [fix(x) floor(x) round(x) ceil(x) frac(x)]
        %      = [ -2, -3, -3, -2, -1/2]
        %
        %   See also SYM/ROUND, SYM/CEIL, SYM/FIX, SYM/FRAC.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(floor(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'floor');
        end
        end
        
        function Y = fix(X)
        %FIX    Symbolic matrix element-wise integer part.
        %   Y = FIX(X) is the matrix of the integer parts of X.
        %   FIX(X) = FLOOR(X) if X is positive and CEIL(X) if X is negative.
        %
        %   See also SYM/ROUND, SYM/CEIL, SYM/FLOOR, SYM/FRAC.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(fix(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'trunc');
        end
        end
        
        function Y = round(X)
        %ROUND  Symbolic matrix element-wise round.
        %   Y = ROUND(X) rounds the elements of X to the nearest integers.
        %   Values halfway between two integers are rounded away from zero.
        %   Example:
        %      x = sym(-5/2)
        %      [fix(x) floor(x) round(x) ceil(x) frac(x)]
        %      = [ -2, -3, -3, -2, -1/2]
        %
        %   See also SYM/FLOOR, SYM/CEIL, SYM/FIX, SYM/FRAC.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(round(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'symobj::round');
        end
        end
        
        function Y = frac(X)
        %FRAC  Symbolic matrix element-wise fractional part.
        %   Y = FRAC(X) is the matrix of the fractional part of the elements of X.
        %   FRAC(X) = X - FIX(X).
        %   Example:
        %      x = sym(-5/2)
        %      [fix(x) floor(x) round(x) ceil(x) frac(x)]
        %      = [ -2, -3, -3, -2, -1/2]
        %
        %   See also SYM/ROUND, SYM/CEIL, SYM/FLOOR, SYM/FIX.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(frac(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'symobj::frac');
        end
        end
        
        function p = prod(A,dim)
        %PROD   Product of the elements.
        %   For vectors, PROD(X) is the product of the elements of X.
        %   For matrices, PROD(X) or PROD(X,1) is a row vector of column products
        %   and PROD(X,2) is a column vector of row products.
        %
        %   See also SYM/SUM.
        
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if nargin == 1
            if isa(A.s,'maplesym')
                p = sym(prod(A.s));
            else
                p = mupadmex('symobj::prodsum',A.s,'_mult');
            end
        else
            if isa(A.s,'maplesym')
                p = sym(prod(A.s,dim));
            else
                p = mupadmex('symobj::prodsumdim',A.s,num2str(dim),'_mult');
            end
        end
        end
        
        function s = sum(A,dim)
        %SUM    Sum of the elements.
        %   For vectors, SUM(X) is the sum of the elements of X.
        %   For matrices, SUM(X) or SUM(X,1) is a row vector of column sums
        %   and SUM(X,2) is a column vector of row sums.
        %
        %   See also SYM/PROD.
        
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if nargin == 1
            if isa(A.s,'maplesym')
                s = sym(sum(A.s));
            else
                s = mupadmex('symobj::prodsum',A.s,'_plus');
            end
        else
            if isa(A.s,'maplesym')
                s = sym(sum(A.s,dim));
            else
                s = mupadmex('symobj::prodsumdim',A.s,num2str(dim),'_plus');
            end
        end
        end
        
        %---------------   Logical Operators    -----------------
        function X = eq(A, B)
        %EQ     Symbolic equality test.
        %   EQ(A,B) overloads symbolic A == B.  The result is true where the
        %   elements of A and B test equal according to the symengine engine.
        %   EQ does not expand or simplify the expressions before making the 
        %   comparison. For a mathematical equality test use SIMPLIFY(A-B)==0.
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(B,'sym'), B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = A.s == B.s;
        else
            X = mupadmex('symobj::eq',A.s,B.s,9);
        end
        end
        
        function X = ne(A, B)
        %NE     Symbolic inequality test.
        %   NE(A,B) overloads symbolic A ~= B.  The result is true if A and B do
        %   not have the same string representation.  NE does not expand or simplify
        %   the string expressions before making the comparison.
        if ~isa(A,'sym'), A = sym(A); end
        if ~isa(B,'sym'), B = sym(B); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
        if isa(A.s,'maplesym')
            X = A.s ~= B.s;
        else
            X = ~mupadmex('symobj::eq',A.s,B.s,9);
        end
        end
        
        function c = isequal(a,b)
        %ISEQUAL     Symbolic isequal test.
        %   ISEQUAL(A,B) returns true iff A and B are identical.
        if ~isa(a,'sym'), a = sym(a); end
        if ~isa(b,'sym'), b = sym(b); end
        if builtin('numel',a) ~= 1,  a = normalizesym(a);  end
        if builtin('numel',b) ~= 1,  b = normalizesym(b);  end
        if isa(a.s,'maplesym')
            c = false;
            if isequal(size(a.s),size(b.s))
                eq = a.s==b.s;
                c = all(eq(:));
            end
        else
            mupc = mupadmex('symobj::isequal', a.s, b.s, 0);
            c = strcmp(mupc,'TRUE');
        end
        end
        
        function X = gt(A,B)
        %GT     Symbolic greater-than.
        A = sym(A);
        B = sym(B);
        if isa(A.s,'maplesym')
            X = A.s > B.s;
        else
            notimplemented('gt');
        end
        end
        
        function X = lt(A,B)
        %LT     Symbolic less-than.
        A = sym(A);
        B = sym(B);
        if isa(A.s,'maplesym')
            X = A.s < B.s;
        else
            notimplemented('lt');
        end
        end
        
        function X = ge(A,B)
        %GE     Symbolic greater-than-or-equal.
        A = sym(A);
        B = sym(B);
        if isa(A.s,'maplesym')
            X = A.s >= B.s;
        else
            notimplemented('ge');
        end
        end
        
        function X = le(A,B)
        %LE     Symbolic less-than-or-equal.
        A = sym(A);
        B = sym(B);
        if isa(A.s,'maplesym')
            X = A.s <= B.s;
        else
            notimplemented('le');
        end
        end
        
        function X = and(A,B)
        %AND     Symbolic & (and).
        A = sym(A);
        B = sym(B);
        if isa(A.s,'maplesym')
            X = A.s & B.s;
        else
            notimplemented('and');
        end
        end
        
        function X = or(A,B)
        %OR     Symbolic | (or).
        A = sym(A);
        B = sym(B);
        if isa(A.s,'maplesym')
            X = A.s | B.s;
        else
            notimplemented('or');
        end
        end
        
        function X = not(A)
        %NOT     Symbolic ~ (not).
        A = sym(A);
        if isa(A.s,'maplesym')
            X = ~A.s;
        else
            notimplemented('not');
        end
        end
        
        function r = isreal(x)
        %ISREAL True for real symbolic array
        %   ISREAL(X) returns true if X equals conj(X) and false otherwise.
        r = isequal(x,conj(x));
        end
        
        function y = isscalar(x)
        %ISSCALAR True if symbolic array is a scalar
        %   ISSCALAR(S) returns logical true (1) if S is a 1 x 1 symbolic matrix
        %   and logical false (0) otherwise.
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        if isa(x.s,'maplesym')
            y = isscalar(x.s);
        else
            y = numel(x)==1;
        end
        end
        
        function y = isempty(x)
        %ISEMPTY True for empty symbolic array
        %   ISEMPTY(X) returns 1 if X is an empty array and 0 otherwise. An
        %   empty array has no elements, that is prod(size(X))==0.
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        if isa(x.s,'maplesym')
            y = isempty(x.s);
        else
            y = numel(x)==0;
        end
        end
        
        function y = isNullObj(x)
        %isNullObj Test for null object
        %   isNullObj(X) returns true if X is a sym object for the MuPAD null object.
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        str = mupadmex('type', x.s, 0);
        y = strcmp(str,'') || strcmp(str,'DOM_NULL');
        end
        
        function y = isnan(x)
        %ISNAN  True for Not-a-Number for symbolic arrays.
        %   ISNAN(X) returns an array that contains 1's where
        %   the elements of X are symbolic NaN's and 0's where they are not.
        %   For example, ISNAN(sym([pi NaN Inf -Inf])) is [0 1 0 0].
        
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        if isa(x.s,'maplesym')
            y = isnan(x.s);
        else
            y = mupadmex('symobj::isnan',x.s,9);
        end
        end

        %---------------   Conversions  -----------------
        
        function X = double(S)
        %DOUBLE Converts symbolic matrix to MATLAB double.
        %   DOUBLE(S) converts the symbolic matrix S to a matrix of double
        %   precision floating point numbers.  S must not contain any symbolic
        %   variables, except 'eps'.
        %
        %   See also SYM, VPA.
        if builtin('numel',S) ~= 1,  S = normalizesym(S);  end
        if isa(S.s,'maplesym')
            X = double(S.s);
        else
            siz = size(S);
            Xstr = mupadmex('symobj::double', S.s, 0);
            X = eval(Xstr);
            if prod(siz) ~= 1
                X = reshape(X,siz);
            end
        end
        end
        
        function digits(d)
        %DIGITS Set digits of variable precision arithmetic.
        %
        %   See also VPA.
        digits(double(d));
        end
        
        function g = inline(f,varargin)
        %INLINE Generate an inline object from a sym object
        %     G = INLINE(F) generates an inline object G from the symbolic
        %     expression F using the matlabFunction sym method.
        %
        %     See also: matlabFunction

        f = sym(f);
        if builtin('numel',f) ~= 1,  f = normalizesym(f);  end
        func = matlabFunction(f);
        c = func2str(func);
        paren = find(c==')',1);
        g = inline(c(paren+1:end),varargin{:});
        end
        
        function S = single(X)
        %SINGLE Converts symbolic matrix to single precision.
        %   SINGLE(S) converts the symbolic matrix S to a matrix of single
        %   precision floating point numbers.  S must not contain any symbolic
        %   variables, except 'eps'.
        %
        %   See also SYM, SYM/VPA, SYM/DOUBLE.
        S = single(double(X));
        end
        
        function Y = int8(X)
        %INT8 Converts symbolic matrix to signed 8-bit integers.
        %   INT8(S) converts a symbolic matrix S to a matrix of
        %   signed 8-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT16, INT32, INT64, UINT8, UINT16, UINT32, UINT64.
        Y = int8(double(X));
        end
        
        function Y = int16(X)
        %INT16 Converts symbolic matrix to signed 16-bit integers.
        %   INT16(S) converts a symbolic matrix S to a matrix of
        %   signed 16-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT32, INT64, UINT8, UINT16, UINT32, UINT64.
        Y = int16(double(X));
        end
        
        function Y = int32(X)
        %INT32 Converts symbolic matrix to signed 32-bit integers.
        %   INT32(S) converts a symbolic matrix S to a matrix of
        %   signed 32-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT16, INT64, UINT8, UINT16, UINT32, UINT64.
        Y = int32(double(X));
        end
        
        function Y = int64(X)
        %INT64 Converts symbolic matrix to signed 64-bit integers.
        %   INT64(S) converts a symbolic matrix S to a matrix of
        %   signed 64-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT16, INT32, UINT8, UINT16, UINT32, UINT64.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = int64(X.s);
        else
            Y = int64(double(X));
        end
        end
        
        function Y = uint8(X)
        %UINT8 Converts symbolic matrix to unsigned 8-bit integers.
        %   UINT8(S) converts a symbolic matrix S to a matrix of
        %   unsigned 8-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT16, INT32, INT64, UINT16, UINT32, UINT64.
        Y = uint8(double(X));
        end
        
        function Y = uint16(X)
        %UINT16 Converts symbolic matrix to unsigned 16-bit integers.
        %   UINT16(S) converts a symbolic matrix S to a matrix of
        %   unsigned 16-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT16, INT32, INT64, UINT8, UINT32, UINT64.
        Y = uint16(double(X));
        end
        
        function Y = uint32(X)
        %UINT32 Converts symbolic matrix to unsigned 32-bit integers.
        %   UINT32(S) converts a symbolic matrix S to a matrix of
        %   unsigned 32-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT16, INT32, INT64, UINT8, UINT16, UINT64.
        Y = uint32(double(X));
        end
        
        function Y = uint64(X)
        %UINT64 Converts symbolic matrix to unsigned 64-bit integers.
        %   UINT64(S) converts a symbolic matrix S to a matrix of
        %   unsigned 64-bit integers.
        %
        %   See also SYM, VPA, SINGLE, DOUBLE,
        %   INT8, INT16, INT32, INT64, UINT8, UINT16, UINT32.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = uint64(X.s);
        else
            Y = uint64(double(X));
        end
        end

        function Y = full(X)
        %FULL Create non-sparse array
        %   Y = FULL(X) creates a full symbolic array from X.
        Y = X;
        end
        
        function y = getMapleObject(x)
        %getMapleObject Get the maplesym object from a sym object
        %    This is an undocumented function that may be removed in a future release.
        y = x.s;
        end
        
        
        
        %---------------   Special Functions  -----------------
        
        function Y = sqrt(X)
        %SQRT   Symbolic matrix element-wise square root.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(sqrt(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'sqrt');
        end
        end
        
        function Y = log(X)
        %LOG    Symbolic matrix element-wise natural logarithm.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(log(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'log','-infinity');
        end
        end
        
        function Y = log10(X)
        %LOG10  Symbolic matrix element-wise common logarithm.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(log10(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'symobj::log10','-infinity');
        end
        end
        
        function Y = log2(X)
        %LOG2   Symbolic matrix element-wise base-2 logarithm.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(log2(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'symobj::log2','-infinity');
        end
        end
        
        function Y = exp(X)
        %EXP    Symbolic matrix element-wise exponentiation.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(exp(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'exp');
        end
        end
        
        function Y = heaviside(X)
        %HEAVISIDE    Symbolic step function.
        %    HEAVISIDE(X) is 0 for X < 0, 1 for X > 0, and NaN for X == 0.
        %    HEAVISIDE(X) is not a function in the strict sense, but rather
        %    a distribution with diff(heaviside(x)) = dirac(x).
        %
        %    See also SYM/DIRAC.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(heaviside(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'heaviside');
        end
        end
        
        function Y = dirac(X)
        %DIRAC  Symbolic delta function.
        %    DIRAC(X) is zero for all X, except X == 0 where it is infinite.
        %    DIRAC(X) is not a function in the strict sense, but rather a
        %    distribution with int(dirac(x-a)*f(x),-inf,inf) = f(a) and
        %    diff(heaviside(x),x) = dirac(x).
        %
        %    See also SYM/HEAVISIDE.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(dirac(X.s));
        else
            Y = mupadmex('symobj::map',X.s,'dirac');
        end
        end
        
        
        function I = besseli(nu,Z)
        %BESSELI Symbolic Bessel function, I(nu,z).
        nu = sym(nu);
        Z = sym(Z);
        if builtin('numel',nu) ~= 1,  nu = normalizesym(nu);  end
        if builtin('numel',Z) ~= 1,  Z = normalizesym(Z);  end
        if isa(Z.s,'maplesym')
            I = sym(besseli(nu.s,Z.s));
        else
            I = mupadmex('symobj::bessel',nu.s,Z.s,'besseli');
        end
        end
        
        function J = besselj(nu,Z)
        %BESSELJ Symbolic Bessel function, J(nu,z).
        nu = sym(nu);
        Z = sym(Z);
        if builtin('numel',nu) ~= 1,  nu = normalizesym(nu);  end
        if builtin('numel',Z) ~= 1,  Z = normalizesym(Z);  end
        if isa(Z.s,'maplesym')
            J = sym(besselj(nu.s,Z.s));
        else
            J = mupadmex('symobj::bessel',nu.s,Z.s,'besselj');
        end
        end
        
        function K = besselk(nu,Z)
        %BESSELK Symbolic Bessel function, K(nu,z).
        nu = sym(nu);
        Z = sym(Z);
        if builtin('numel',nu) ~= 1,  nu = normalizesym(nu);  end
        if builtin('numel',Z) ~= 1,  Z = normalizesym(Z);  end
        if isa(Z.s,'maplesym')
            K = sym(besselk(nu.s,Z.s));
        else
            K = mupadmex('symobj::bessel',nu.s,Z.s,'besselk');
        end
        end
        
        function Y = bessely(nu,Z)
        %BESSELY Symbolic Bessel function, Y(nu,z).
        nu = sym(nu);
        Z = sym(Z);
        if builtin('numel',nu) ~= 1,  nu = normalizesym(nu);  end
        if builtin('numel',Z) ~= 1,  Z = normalizesym(Z);  end
        if isa(Z.s,'maplesym')
            Y = sym(bessely(nu.s,Z.s));
        else
            Y = mupadmex('symobj::bessel',nu.s,Z.s,'bessely');
        end
        end
        
        function Z = zeta(n,X)
        %ZETA   Symbolic Riemann zeta function.
        %   ZETA(z) = sum(1/k^z,k,1,inf).
        %   ZETA(n,z) = n-th derivative of ZETA(z)

        if nargin == 1
            X = n;
            n = sym(0);
        else
            X = sym(X);
            n = sym(n);
        end
        if builtin('numel',n) ~= 1,  n = normalizesym(n);  end
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Z = sym(zeta(n.s,X.s));
        else
            Z = mupadmex('symobj::bessel',n.s,X.s,'symobj::zeta');
        end
        end
        
        function W = lambertw(k,X)
        %LAMBERTW Lambert's W function.
        %   W = LAMBERTW(X) is the solution to w*exp(w) = x.
        %   W = LAMBERTW(K,X) is the K-th branch of this multi-valued function.
        %   Reference: Robert M. Corless, G. H. Gonnet, D. E. G. Hare,
        %   D. J. Jeffrey, and D. E. Knuth, "On the Lambert W Function",
        %   Advances in Computational Mathematics, volume 5, 1996, pp. 329-359.
        
        %   More information available from:
        %   http://www.apmaths.uwo.ca/~rcorless/frames/PAPERS/LambertW
        if nargin == 1
            X = k;
            k = sym(0);
        else
            X = sym(X);
            k = sym(k);
        end
        if builtin('numel',k) ~= 1,  k = normalizesym(k);  end
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            W = sym(lambertw(k.s,X.s));
        else
            W = mupadmex('symobj::bessel',k.s,X.s,'lambertw');
        end
        end
        
        function Z = cosint(X)
        %COSINT Cosine integral function.
        %  COSINT(x) = Gamma + log(x) + int((cos(t)-1)/t,t,0,x)
        %  where Gamma is Euler's constant, .57721566490153286060651209...
        %  Euler's constant can be evaluated with vpa('eulergamma').
        %
        %   See also SYM/SININT.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Z = sym(cosint(X.s));
        else
            Z = mupadmex('symobj::mapcatch',X.s,'Ci','-infinity');
        end
        end
        
        function Z = sinint(X)
        %SININT Sine integral function.
        %   SININT(x) = int(sin(t)/t,t,0,x).
        %
        %   See also SYM/COSINT.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Z = sym(sinint(X.s));
        else
            Z = mupadmex('symobj::mapcatch',X.s,'Si','infinity');
        end
        end
        
        function Y = erf(X)
        %ERF    Symbolic error function.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(erf(X.s));
        else
            Y = mupadmex('symobj::mapFloatCheck',X.s,'erf');
        end
        end
        
        function h = hypergeom(n,d,z)
        % HYPERGEOM  Generalized hypergeometric function.
        % HYPERGEOM(N, D, Z) is the generalized hypergeometric function F(N, D, Z),
        % also known as the Barnes extended hypergeometric function and denoted by
        % jFk where j = length(N) and k = length(D).   For scalar a, b and c,
        % HYPERGEOM([a,b],c,z) is the Gauss hypergeometric function 2F1(a,b;c;z).
        %
        % The definition by a formal power series is
        %    hypergeom(N,D,z) = sum(k=0:inf, (C(N,k)/C(D,k))*z^k/k!) where
        %    C(V,k) = prod(i=1:length(V), gamma(V(i)+k)/gamma(V(i)))
        % Either of the first two arguments may be a vector providing the coefficient
        % parameters for a single function evaluation.  If the third argument is a
        % vector, the function is evaluated pointwise.  The result is numeric if all
        % the arguments are numeric and symbolic if any of the arguments is symbolic.
        % See Abramowitz and Stegun, Handbook of Mathematical Functions, chapter 15.
        %
        % Examples:
        %    syms a z
        %    hypergeom([],[],z)             returns   exp(z)
        %    hypergeom(1,[],z)              returns   -1/(-1+z)
        %    hypergeom(1,2,z)               returns   (exp(z)-1)/z
        %    hypergeom([1,2],[2,3],z)       returns   -2*(-exp(z)+1+z)/z^2
        %    hypergeom(a,[],z)              returns   (1-z)^(-a)
        %    hypergeom([],1,-z^2/4)         returns   besselj(0,z)
        %    hypergeom([-n, n],1/2,(1-z)/2) returns   T(n,z)    where
        %    T(n,z) = expand(cos(n*acos(z))) is the n-th Chebyshev polynomial.
        
        if ~isa(n,'sym'), n = sym(n); end
        if ~isa(d,'sym'), d = sym(d); end
        if ~isa(z,'sym'), z = sym(z); end
        if builtin('numel',z) ~= 1,  z = normalizesym(z);  end
        if builtin('numel',n) ~= 1,  n = normalizesym(n);  end
        if builtin('numel',d) ~= 1,  d = normalizesym(d);  end
        if isa(z.s,'maplesym')
            h = sym(hypergeom(n.s,d.s,z.s));
        else
            h = mupadmex('symobj::mapFloatCheck',z.s,'symobj::hypergeom',n.s,d.s);
        end
        end
        
        function Y = gamma(X)
        %GAMMA  Symbolic gamma function.
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(gamma(X.s));
        else
            Y = mupadmex('symobj::mapcatch',X.s,'gamma','infinity');
        end
        end
        
        %---------------   Indexing  -----------------
        
        function X = subsindex(A)
        %SUBSINDEX Symbolic subsindex function
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            X = subsindex(A.s);
        else
            notimplemented('subsindex');
        end
        end
        
        function B = subsref(A,S)
        %SUBSREF Subscripted reference for a sym array. 
        %     B = SUBSREF(A,S) is called for the syntax A(I).  S is a structure array
        %     with the fields:
        %         type -- string containing '()' specifying the subscript type.
        %                 Only parenthesis subscripting is allowed.
        %         subs -- Cell array or string containing the actual subscripts.
        %
        %   See also SYM.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            B = sym(subsref(A.s,S));
        else
            inds = S.subs;
            refs = cell(length(inds),1);
            for k=1:length(inds)
                [inds{k},refs{k}] = privformat(inds{k});
            end
            B = mupadmex('symobj::subsref',A.s,inds{:});
        end
        end
        
        function y = end(x,varargin)
        %END Last index in an indexing expression for a sym array.
        %   END(A,K,N) is called for indexing expressions involving the sym
        %   array A when END is part of the K-th index out of N indices.  For example,
        %   the expression A(end-1,:) calls A's END method with END(A,1,2).
        %
        %   See also SYM.
        if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
        if isa(x.s,'maplesym')
            y = feval('end',x.s,varargin{:});
        else
            sz = size(x);
            k = varargin{1};
            n = varargin{2};
            if n < length(sz) && k==n
                sz(n) = prod(sz(n:end));
            end
            y = sz(k);
        end
        end
        
        function C = subsasgn(A,S,B)
        %SUBSASGN Subscripted assignment for a sym array.
        %     A = SUBSASGN(A,S,B) is called for the syntax A(I)=B.  S is a structure
        %     array with the fields:
        %         type -- string containing '()' specifying the subscript type.
        %                 Only parenthesis subscripting is allowed.
        %         subs -- Cell array or string containing the actual subscripts.
        %
        %   See also SYM.
        if ~isa(A,'sym')
            A = sym(A);
        end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            if ~isa(B,'sym') && isequal(B,[])
                % deleting elements from A
                C = sym(subsasgn(A.s,S,[]));
            else
                if isa(B,'sym'),  B = B.s; end
                C = sym(subsasgn(A.s,S,B));
            end
        else
            if ~isa(B,'sym'),  B = sym(B); end
            if builtin('numel',B) ~= 1,  B = normalizesym(B);  end
            inds = S.subs;
            refs = cell(length(inds),1);
            for k=1:length(inds)
                [inds{k},refs{k}] = privformat(inds{k});
            end
            C = mupadmex('symobj::subsasgn',A.s,B.s,inds{:});
        end
        end
        
        
        %---------------   Basic Linear Algebra  -----------------
        
        function d = det(A)
        %DET    Symbolic matrix determinant.
        %   DET(A) is the determinant of the symbolic matrix A.
        %
        %   Examples:
        %       det([a b;c d]) is a*d-b*c.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            d = sym(det(A.s));
        else
            d = mupadmex('symobj::det',A.s);
        end
        end
        
        function r = rank(A)
        %RANK   Symbolic matrix rank.
        %   RANK(A) is the rank of the symbolic matrix A.
        %
        %   Example:
        %       rank([a b;c d]) is 2.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            r = rank(A.s);
            if isa(r,'maplesym')
                r = sym(r);
            end
        else
            r = mupadmex('symobj::rank', A.s);
        end
        end
        
        function X = inv(A)
        %INV    Symbolic matrix inverse.
        %   INV(A) computes the symbolic inverse of A
        %   INV(VPA(A)) uses variable precision arithmetic.
        %
        %   Examples:
        %      Suppose B is
        %         [ 1/(2-t), 1/(3-t) ]
        %         [ 1/(3-t), 1/(4-t) ]
        %
        %      Then inv(B) is
        %         [     -(-3+t)^2*(-2+t), (-3+t)*(-2+t)*(-4+t) ]
        %         [ (-3+t)*(-2+t)*(-4+t),     -(-3+t)^2*(-4+t) ]
        %
        %      digits(10);
        %      inv(vpa(sym(hilb(3))));
        %
        %   See also VPA.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            X = sym(inv(A.s));
        else
            X = mupadmex('symobj::inv',A.s);
        end
        end
        
        function r = rref(A)
        %RREF   Reduced row echelon form.
        %   RREF(A) is the reduced row echelon form of the symbolic matrix A.
        %
        %   Example:
        %       rref(sym(magic(4))) is not the identity.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            r = sym(rref(A.s));
        else
            r = mupadmex('symobj::rref',A.s);
        end
        end
        
        function Y = expm(X)
        %EXPM   Symbolic matrix exponential.
        %   EXPM(A) is the matrix exponential of the symbolic matrix A.
        %
        %   Examples:
        %      syms t
        %      A = [0 1; -1 0]
        %      expm(t*A)
        %
        %      A = sym(gallery(5))
        %      expm(t*A)
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(expm(X.s));
        else
            Y = mupadmex('symobj::expm',X.s);
        end
        end
        
        function B = colspace(A)
        %COLSPACE Basis for column space.
        %   The columns of B = COLSPACE(A) form a basis for the column space of A.
        %   SIZE(B,2) is the rank of A.
        %
        %   Example:
        %
        %     colspace(sym(magic(4))) is
        %
        %     [ 1, 0,  0]
        %     [ 0, 1,  0]
        %     [ 0, 0,  1]
        %     [ 1, 3, -3]
        %
        %   See also SYM/NULL.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            B = sym(colspace(A.s));
        else
            B = mupadmex('symobj::colspace',A.s);
        end
        end
        
        function D = diag(A,offset)
        %DIAG   Create or extract symbolic diagonals.
        %   DIAG(V,K), where V is a row or column vector with N components,
        %   returns a square sym matrix of order N+ABS(K) with the
        %   elements of V on the K-th diagonal. K = 0 is the main
        %   diagonal, K > 0 is above the main diagonal and K < 0 is
        %   below the main diagonal.
        %   DIAG(V) simply puts V on the main diagonal.
        %
        %   DIAG(X,K), where X is a sym matrix, returns a column vector
        %   formed from the elements of the K-th diagonal of X.
        %   DIAG(X) is the main diagonal of X.
        %
        %   Examples:
        %
        %      v = [a b c]
        %
        %      Both diag(v) and diag(v,0) return
        %         [ a, 0, 0 ]
        %         [ 0, b, 0 ]
        %         [ 0, 0, c ]
        %
        %      diag(v,-2) returns
        %         [ 0, 0, 0, 0, 0 ]
        %         [ 0, 0, 0, 0, 0 ]
        %         [ a, 0, 0, 0, 0 ]
        %         [ 0, b, 0, 0, 0 ]
        %         [ 0, 0, c, 0, 0 ]
        %
        %      A =
        %         [ a, b, c ]
        %         [ 1, 2, 3 ]
        %         [ x, y, z ]
        %
        %      diag(A) returns
        %         [ a ]
        %         [ 2 ]
        %         [ z ]
        %
        %      diag(A,1) returns
        %         [ b ]
        %         [ 3 ]
        if nargin == 1,   offset = 0; end;
        if ~isa(A,'sym'), A = sym(A); end
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            D = sym(diag(A.s,offset));
        else
            D = mupadmex('symobj::diag',A.s,num2str(offset));
        end
        end
        
        function Y = triu(X,offset)
        %TRIU   Symbolic upper triangle.
        %   TRIU(X) is the upper triangular part of X.
        %   TRIU(X,K) is the elements on and above the K-th diagonal of
        %   X.  K = 0 is the main diagonal, K > 0 is above the main
        %   diagonal and K < 0 is below the main diagonal.
        %
        %   Examples:
        %
        %      Suppose
        %         A =
        %            [   a,   b,   c ]
        %            [   1,   2,   3 ]
        %            [ a+1, b+2, c+3 ]
        %
        %      then
        %         triu(A) returns
        %            [   a,   b,   c ]
        %            [   0,   2,   3 ]
        %            [   0,   0, c+3 ]
        %
        %         triu(A,1) returns
        %            [ 0, b, c ]
        %            [ 0, 0, 3 ]
        %            [ 0, 0, 0 ]
        %
        %         triu(A,-1) returns
        %            [   a,   b,   c ]
        %            [   1,   2,   3 ]
        %            [   0, b+2, c+3 ]
        %
        %   See also SYM/TRIL.
        if nargin == 1, offset = 0; end;
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(triu(X.s,offset));
        else
            Y = mupadmex('symobj::triu',X.s,num2str(offset));
        end
        end
        
        function Y = tril(X,offset)
        %TRIL   Symbolic lower triangle.
        %   TRIL(X) is the lower triangular part of X.
        %   TRIL(X,K) is the elements on and below the K-th diagonal
        %   of X .  K = 0 is the main diagonal, K > 0 is above the
        %   main diagonal and K < 0 is below the main diagonal.
        %
        %   Examples:
        %
        %      Suppose
        %      A =
        %         [   a,   b,   c ]
        %         [   1,   2,   3 ]
        %         [ a+1, b+2, c+3 ]
        %
        %      then
        %      tril(A) returns
        %         [   a,   0,   0 ]
        %         [   1,   2,   0 ]
        %         [ a+1, b+2, c+3 ]
        %
        %      tril(A,1) returns
        %         [   a,   b,   0 ]
        %         [   1,   2,   3 ]
        %         [ a+1, b+2, c+3 ]
        %
        %      tril(A,-1) returns
        %         [   0,   0,   0 ]
        %         [   1,   0,   0 ]
        %         [ a+1, b+2,   0 ]
        %
        %   See also SYM/TRIU.
        if nargin == 1, offset = 0; end;
        if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
        if isa(X.s,'maplesym')
            Y = sym(tril(X.s,offset));
        else
            Y = mupadmex('symobj::tril',X.s,num2str(offset));
        end
        end
        
        function B = transpose(A)
        %TRANSPOSE Symbolic matrix transpose.
        %   TRANSPOSE(A) overloads symbolic A.' .
        %
        %   Example:
        %      [a b; 1-i c].' returns [a 1-i; b c].
        %
        %   See also SYM/CTRANSPOSE.
        
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            B = sym(transpose(A.s));
        else
            B = mupadmex('symobj::transpose',A.s);
        end
        end
        
        function B = ctranspose(A)
        %CTRANSPOSE Symbolic matrix complex conjugate transpose.
        %   CTRANSPOSE(A) overloads symbolic A' .
        %
        %   Example:
        %      [a b; 1-i c]' returns  [ conj(a),     1+i]
        %                             [ conj(b), conj(c)].
        %
        %   See also SYM/TRANSPOSE.
        
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        if isa(A.s,'maplesym')
            B = sym(ctranspose(A.s));
        else
            B = mupadmex('symobj::ctranspose',A.s);
        end
        end
        
        function n = ndims(x)
        %NDIMS   Number of dimensions in symbolic array.
        %    N = NDIMS(X) returns the number of dimensions in the sym array X.
        %    The number of dimensions in an array is always greater than
        %    or equal to 2.  Trailing singleton dimensions are ignored.
        %    Put simply, it is LENGTH(SIZE(X)).
        %
        %    See also SIZE, SYM.
        
        n = length(size(x));
        end
        
        %---------------   Integral Transforms  -----------------
        
        
        function F = fourier(f,varargin)
        %FOURIER Fourier integral transform.
        %   F = FOURIER(f) is the Fourier transform of the sym scalar f
        %   with default independent variable x.  The default return is
        %   a function of w.
        %   If f = f(w), then FOURIER returns a function of t:  F = F(t).
        %   By definition, F(w) = int(f(x)*exp(-i*w*x),x,-inf,inf), where
        %   the integration above proceeds with respect to x (the symbolic
        %   variable in f as determined by SYMVAR).
        %
        %   F = FOURIER(f,v) makes F a function of the sym v instead of
        %       the default w:
        %   FOURIER(f,v) <=> F(v) = int(f(x)*exp(-i*v*x),x,-inf,inf).
        %
        %   FOURIER(f,u,v) makes f a function of u instead of the
        %       default x. The integration is then with respect to u.
        %   FOURIER(f,u,v) <=> F(v) = int(f(u)*exp(-i*v*u),u,-inf,inf).
        %
        %   Examples:
        %    syms t v w x
        %    fourier(1/t)   returns   pi*i*(2*heaviside(-w) - 1)
        %    fourier(exp(-x^2),x,t)   returns  pi^(1/2)/exp(t^2/4)
        %    fourier(exp(-t)*sym('heaviside(t)'),v)   returns  1/(i*v + 1)
        %    fourier(diff(sym('F(x)')),x,w)   returns
        %          i*w*transform::fourier(F(x),x,-w)
        %
        %   See also SYM/IFOURIER, SYM/LAPLACE, SYM/ZTRANS.
        
        if ~isa(f,'sym'), f = sym(f); end
        if builtin('numel',f) ~= 1, f = normalizesym(f);  end
        args = varargin;
        for k = 1:length(args)
            if ~isa(args{k},'sym')
                args{k} = sym(args{k});
            end
            args{k} = args{k}.s;
        end
        if isa(f.s,'maplesym')
            F = sym(fourier(f.s,args{:}));
        else
            F = mupadmex('symobj::symtransform','symobj::fourier',f.s,'x','w','v',args{:});
        end
        end
        
        function f = ifourier(F,varargin)
        %IFOURIER Inverse Fourier integral transform.
        %   f = IFOURIER(F) is the inverse Fourier transform of the scalar sym F
        %   with default independent variable w.  The default return is a
        %   function of x.  The inverse Fourier transform is applied to a
        %   function of w and returns a function of x: F = F(w) => f = f(x).
        %   If F = F(x), then IFOURIER returns a function of t: f = f(t). By
        %   definition, f(x) = 1/(2*pi) * int(F(w)*exp(i*w*x),w,-inf,inf) and the
        %   integration is taken with respect to w.
        %
        %   f = IFOURIER(F,u) makes f a function of u instead of the default x:
        %   IFOURIER(F,u) <=> f(u) = 1/(2*pi) * int(F(w)*exp(i*w*u,w,-inf,inf).
        %   Here u is a scalar sym (integration with respect to w).
        %
        %   f = IFOURIER(F,v,u) takes F to be a function of v instead of the
        %   default w:  IFOURIER(F,v,u) <=>
        %   f(u) = 1/(2*pi) * int(F(v)*exp(i*v*u,v,-inf,inf),
        %   integration with respect to v.
        %
        %   Examples:
        %    syms t u w x
        %    ifourier(w*exp(-3*w)*sym('heaviside(w)')) returns 1/(2*pi*(i*x - 3)^2)
        %
        %    ifourier(1/(1 + w^2),u)   returns
        %        ((pi*heaviside(u))/exp(u) + pi*heaviside(-u)*exp(u))/(2*pi)
        %
        %    ifourier(v/(1 + w^2),v,u) returns -(i*dirac(u, 1))/(w^2 + 1)
        %
        %    ifourier(fourier(sym('f(x)'),x,w),w,x)   returns   f(x)
        %
        %   See also SYM/FOURIER, SYM/ILAPLACE, SYM/IZTRANS.
        
        if ~isa(F,'sym'),  F = sym(F); end
        if builtin('numel',F) ~= 1,  F = normalizesym(F);  end
        args = varargin;
        for k = 1:length(args)
            if ~isa(args{k},'sym')
                args{k} = sym(args{k});
            end
            args{k} = args{k}.s;
        end
        if isa(F.s,'maplesym')
            f = sym(ifourier(F.s,args{:}));
        else
            f = mupadmex('symobj::symtransform','symobj::ifourier',F.s,'w','x','t',args{:});
        end
        end
        
        function L = laplace(F,varargin)
        %LAPLACE Laplace transform.
        %   L = LAPLACE(F) is the Laplace transform of the scalar sym F with
        %   default independent variable t.  The default return is a function
        %   of s.  If F = F(s), then LAPLACE returns a function of t:  L = L(t).
        %   By definition L(s) = int(F(t)*exp(-s*t),0,inf), where integration
        %   occurs with respect to t.
        %
        %   L = LAPLACE(F,t) makes L a function of t instead of the default s:
        %   LAPLACE(F,t) <=> L(t) = int(F(x)*exp(-t*x),0,inf).
        %
        %   L = LAPLACE(F,w,z) makes L a function of z instead of the
        %   default s (integration with respect to w).
        %   LAPLACE(F,w,z) <=> L(z) = int(F(w)*exp(-z*w),0,inf).
        %
        %   Examples:
        %      syms a s t w x
        %      laplace(t^5)           returns   120/s^6
        %      laplace(exp(a*s))      returns   1/(t-a)
        %      laplace(sin(w*x),t)    returns   w/(t^2+w^2)
        %      laplace(cos(x*w),w,t)  returns   t/(t^2+x^2)
        %      laplace(x^sym(3/2),t)  returns   3/4*pi^(1/2)/t^(5/2)
        %      laplace(diff(sym('F(t)')))   returns   laplace(F(t),t,s)*s-F(0)
        %
        %   See also SYM/ILAPLACE, SYM/FOURIER, SYM/ZTRANS.
        
        if ~isa(F,'sym'),  F = sym(F); end
        if builtin('numel',F) ~= 1, F = normalizesym(F);  end
        args = varargin;
        for k = 1:length(args)
            if ~isa(args{k},'sym')
                args{k} = sym(args{k});
            end
            args{k} = args{k}.s;
        end
        if isa(F.s,'maplesym')
            L = sym(laplace(F.s,args{:}));
        else
            L = mupadmex('symobj::symtransform','laplace',F.s,'t','s','t',args{:});
        end
        end
        
        function F = ilaplace(L,varargin)
        %ILAPLACE Inverse Laplace transform.
        %   F = ILAPLACE(L) is the inverse Laplace transform of the scalar sym L
        %   with default independent variable s.  The default return is a
        %   function of t.  If L = L(t), then ILAPLACE returns a function of x:
        %   F = F(x).
        %   By definition, F(t) = int(L(s)*exp(s*t),s,c-i*inf,c+i*inf)
        %   where c is a real number selected so that all singularities
        %   of L(s) are to the left of the line s = c, i = sqrt(-1), and
        %   the integration is taken with respect to s.
        %
        %   F = ILAPLACE(L,y) makes F a function of y instead of the default t:
        %       ILAPLACE(L,y) <=> F(y) = int(L(y)*exp(s*y),s,c-i*inf,c+i*inf).
        %   Here y is a scalar sym.
        %
        %   F = ILAPLACE(L,y,x) makes F a function of x instead of the default t:
        %   ILAPLACE(L,y,x) <=> F(y) = int(L(y)*exp(x*y),y,c-i*inf,c+i*inf),
        %   integration is taken with respect to y.
        %
        %   Examples:
        %      syms s t w x y
        %      ilaplace(1/(s-1))              returns   exp(t)
        %      ilaplace(1/(t^2+1))            returns   sin(x)
        %      ilaplace(t^(-sym(5/2)),x)      returns   4/3/pi^(1/2)*x^(3/2)
        %      ilaplace(y/(y^2 + w^2),y,x)    returns   cos(w*x)
        %      ilaplace(sym('laplace(F(x),x,s)'),s,x)   returns   F(x)
        %
        %   See also SYM/LAPLACE, SYM/IFOURIER, SYM/IZTRANS.
        
        if ~isa(L,'sym'),  L = sym(L); end
        if builtin('numel',L) ~= 1,  L = normalizesym(L);  end
        args = varargin;
        for k = 1:length(args)
            if ~isa(args{k},'sym')
                args{k} = sym(args{k});
            end
            args{k} = args{k}.s;
        end
        if isa(L.s,'maplesym')
            F = sym(ilaplace(L.s,args{:}));
        else
            F = mupadmex('symobj::symtransform','ilaplace',L.s,'s','t','x',args{:});
        end
        end
        
        function F = ztrans(f,varargin)
        %ZTRANS Z-transform.
        %   F = ZTRANS(f) is the Z-transform of the scalar sym f with default
        %   independent variable n.  The default return is a function of z:
        %   f = f(n) => F = F(z).  The Z-transform of f is defined as:
        %      F(z) = symsum(f(n)/z^n, n, 0, inf),
        %   where n is f's symbolic variable as determined by SYMVAR.  If
        %   f = f(z), then ZTRANS(f) returns a function of w:  F = F(w).
        %
        %   F = ZTRANS(f,w) makes F a function of the sym w instead of the
        %   default z:  ZTRANS(f,w) <=> F(w) = symsum(f(n)/w^n, n, 0, inf).
        %
        %   F = ZTRANS(f,k,w) takes f to be a function of the sym variable k:
        %   ZTRANS(f,k,w) <=> F(w) = symsum(f(k)/w^k, k, 0, inf).
        %
        %   Examples:
        %      syms k n w z
        %      ztrans(2^n)           returns  z/(z-2)
        %      ztrans(sin(k*n),w)    returns  (w*sin(k))/(w^2 - 2*cos(k)*w + 1)
        %      ztrans(cos(n*k),k,z)  returns  (z*(z - cos(n)))/(z^2 - 2*cos(n)*z + 1)
        %      ztrans(cos(n*k),n,w)  returns  (w*(w - cos(k)))/(w^2 - 2*cos(k)*w + 1)
        %      ztrans(sym('f(n+1)')) returns  z*ztrans(f(n), n, z) - z*f(0)
        %
        %   See also SYM/IZTRANS, SYM/LAPLACE, SYM/FOURIER.
        
        %   Copyright 1993-2010 The MathWorks, Inc.
        
        if ~isa(f,'sym'),  f = sym(f);  end
        if builtin('numel',f) ~= 1,  f = normalizesym(f);  end
        args = varargin;
        for k = 1:length(args)
            if ~isa(args{k},'sym')
                args{k} = sym(args{k});
            end
            args{k} = args{k}.s;
        end
        if isa(f.s,'maplesym')
            F = sym(ztrans(f.s,args{:}));
        else
            F = mupadmex('symobj::symtransform','ztrans',f.s,'n','z','w',args{:});
        end
        end
        
        function f = iztrans(F,varargin)
        %IZTRANS Inverse Z-transform.
        %   f = IZTRANS(F) is the inverse Z-transform of the scalar sym F with
        %   default independent variable z.  The default return is a function
        %   of n:  F = F(z) => f = f(n).  If F = F(n), then IZTRANS returns a
        %   function of k: f = f(k).
        %   f = IZTRANS(F,k) makes f a function of k instead of the default n.
        %   Here m is a scalar sym.
        %   f = IZTRANS(F,w,k) takes F to be a function of w instead of the
        %   default symvar(F) and returns a function of k:  F = F(w) & f = f(k).
        %
        %   Examples:
        %      iztrans(z/(z-2))        returns   2^n
        %      iztrans(exp(x/z),z,k)   returns   x^k/k!
        %
        %   See also SYM/ZTRANS, SYM/LAPLACE, SYM/FOURIER.
        
        %   Copyright 1993-2010 The MathWorks, Inc.
        
        if ~isa(F,'sym'), F = sym(F); end
        if builtin('numel',F) ~= 1,  F = normalizesym(F);  end
        args = varargin;
        for k = 1:length(args)
            if ~isa(args{k},'sym')
                args{k} = sym(args{k});
            end
            args{k} = args{k}.s;
        end
        if isa(F.s,'maplesym')
            f = sym(iztrans(F.s,args{:}));
        else
            f = mupadmex('symobj::symtransform','iztrans',F.s,'z','n','k',args{:});
        end
        end
        
    end % public methods
    
    methods (Hidden=true)

        function M = charcmd(A)
        %CHARCMD   Convert scalar or array sym to string command form
        %   CHARCMD(A) converts A to its string representation for sending commands
        %   to the symbolic engine.
        if builtin('numel',A) ~= 1,  A = normalizesym(A);  end
        M = A.s;
        end
        
        function varargout = mupadmexnout(fcn,varargin)
        %MUPADMEXNOUT
        %    This is an undocumented function that may be removed in a future release.
        args = varargin;
        for k=1:nargin-1
            arg = args{k};
            if isa(arg,'sym')
                args{k} = arg.s;
            end
        end
        out = mupadmex(fcn,args{:});
        for k=1:nargout
            varargout{k} = mupadmex(sprintf('%s[%d]',out.s,k));
        end
        end
    end % hidden methods
    
    methods (Access=private)
        
        function F = makeinline(f)
        % MAKEINLINE Makes an inline function out of the input sym f.
        % Find all variables in f except 'pi'.
        % These functions are only used for Maple gateway plotting functions.
        vars = findsym(f);
        % Deblank vars.
        vars(vars==' ') = [];
        % Find the commas in the string list vars.
        ind = find(vars==',');
        % Place the symbols between the commas into a cell array V.
        nvars = length(ind) + 1;
        if nvars == 1
            V{1} = vars;
        else
            V{1} = vars(1:ind(1)-1); V{nvars} = vars(ind(nvars-1)+1:end);
            for j = 2:nvars-1
                V{j} = vars(ind(j-1)+1:ind(j)-1);
            end
        end
        F = inline(char(f),V{:});
        end
        
        function y = privsubsref(x,varargin)
        %PRIVSUBSREF Private access to subsref
        %   Y = PRIVSUBSREF(X,I1,I2,...) returns the subsref X(I1,I2,..). Methods
        %   in the sym class can call this to avoid calling the builtin subsref.
        refs = cell(length(varargin),1);
        for k=1:length(varargin)
            [varargin{k},refs{k}] = privformat(varargin{k});
        end
        y = mupadmex('symobj::subsref',x.s,varargin{:});
        end
        
        function y = privsubsasgn(x,b,varargin)
        %PRIVSUBSASGN Private access to subsasgn
        %   Y = PRIVSUBSASGN(X,B,I1,I2,...) returns the subsasgn X(I1,I2,..)=B. Methods
        %   in the sym class can call this to avoid calling the builtin subsasgn.
        refs = cell(length(varargin),1);
        for k=1:length(varargin)
            [varargin{k},refs{k}] = privformat(varargin{k});
        end
        y = mupadmex('symobj::subsasgn',x.s,b.s,varargin{:});
        end
        
        function y = normalizesym(x)
        %NORMALIZESYM Normalize an n-dim array sym to 9b semantics
        %   Y = NORMALIZESYM(X) checks if X is an n-dim array loaded
        %   from 9a mat file and converts it to a scalar ptr-to-array
        %   value used in 9b.
        sz = builtin('size',x);
        if prod(sz) == 0
            y = reshape(sym([]),sz);
        else
            c = cell(sz);
            for k=1:prod(sz)
                c{k} = x(k).s;
            end
            y = sym(c);
        end
        end
        
        function ezhelper(fcn,f,varargin)
        %EZHELPER Helper function for ezmesh, ezmeshc and ezsurf
        %   EZHELPER(FCN,F,...) turns sym object F into a function handle
        %   and calls the regular ez-function FCN.
        %   EZHELPER(FCN,X,Y,Z,...) turns sym objects X,Y,Z into a function handle
        %   and calls the regular ez-function FCN.
        eng = symengine;
        if strcmp(eng.kind,'maple')
            F = makeinline(f);
            if (length(varargin) >= 2) && (isa(varargin{1},'sym') || isa(varargin{2},'sym'))
                y = makeinline(varargin{1}); z = makeinline(varargin{2});
                fcn(F,y,z,varargin{3:end});
            else
                fcn(F,varargin{:});
            end
        elseif (length(varargin) >= 2) && (isa(varargin{1},'sym') || isa(varargin{2},'sym'))
            y = varargin{1};
            z = varargin{2};
            vars = unique([symvar(f) symvar(y) symvar(z)]);
            F = matlabFunction(f,'vars',vars);
            y = matlabFunction(y,'vars',vars);
            z = matlabFunction(z,'vars',vars);
            checkNoSyms(varargin(3:end));
            fcn(F,y,z,varargin{3:end});
        else
            F = matlabFunction(f);
            checkNoSyms(varargin);
            fcn(F,varargin{:});
        end
        end
        
        function generateCode(t,lang,opts)
        %generateCode Helper function for code generation
        %   generateCode(t,lang,opts) generates code for lang for the expression
        %   with name t and options opts.
        
        if nargout > 0
            error('symbolic:generateCode:NoOutput',...
                'Cannot specify a file name and output variable together.');
        end
        gent = mupadmex('symobj::optimize',t.s);
        file = opts.file;
        [fid,msg] = fopen(file,'wt');
        if fid == -1
            error('symbolic:sym:generateCode:FileError',...
                'Could not create file %s: %s',file,msg);
        end
        tmp = onCleanup(@()fclose(fid));
        for k = 1:length(gent)
            expr = sprintf('%s[%d]',gent.s, k);
            tk = mupadmex(['generate::' lang], expr, 0);
            str = strtrim(sprintf(tk));
            str(str == '"') = [];
            fprintf(fid,'%s',str);
        end
        end
        
    end    % private methods
    
end % classdef

%---------------   Subfunctions   -----------------

function S = tomupad(x,a)
%TOMUPAD    Convert input to sym reference string
% Called by sym constructor to take 'x' (just about anything) and possible
% assumption 'a' and return the reference string S. This function is recursive
% since it calls mupadmex and it can call back into sym with _symansNNN.
% The reference string for simple variable names like 'x' or 'foo' is
% the variable name (with possible _Var appended). If 'a' is a size vector
% then a vector or matrix symbolic variable is constructed.
if isa(x,'char')
    if ~isempty(x) && x(1)=='_'
        % answer from mupadmex _symansNNN
        S = x;
    else
        S = convertCharWithOption(x,a);
    end
elseif isnumeric(x) || islogical(x)
    if isempty(a), a = 'r'; end
    S = cell2ref(numeric2cellstr(x,a));
elseif isa(x,'sym')
    if builtin('numel',x) ~= 1,  x = normalizesym(x);  end
    S = mupadmex(x.s,11);  % make a new reference
    assumptions(S,x.s,a);
elseif iscell(x)
    S = cell2ref(x);
elseif isa(x,'function_handle')
    S = funchandle2ref(x);
else
    error('symbolic:sym:sym:errmsg7',...
        'Conversion to ''sym'' from ''%s'' is not possible.',class(x))
end
end

function assumptions(x,name,a)
%ASSUMPTIONS   Handle assumptions on names
%   Does error checking and checking for 'i' and then makes 
%   real/unreal/clear/positive assumption on sym object or string x
if strcmp(x,'i')
    if assumeI(a)
        return;
    end
end
if isempty(a)
    return;
end
if ~strcmp(a,'real') && ~strcmp(a,'unreal') && ~strcmp(a,'positive') && ~strcmp(a,'clear')
    error('symbolic:sym:sym:errmsg1','Second argument %s not recognized.',a);
elseif ~isempty(name) && name(1)=='_'
    assumeAll(name,a);
elseif ~isvarname(name)
    error('symbolic:sym:sym:errmsg2',...
        'Real/Clear/Positive assumption applies only to symbolic variables.')
else
    assume(x,a);
end
end

function assumeAll(x,a)
%assumeAll make assumptions on a vector or matrix sym object.
  sz = eval(mupadmex('symobj::size',x,0));
  total = prod(sz);
  for k=1:total
      name = mupadmex('symobj::subsref',x,num2str(k),0);
      assume(name,a);
  end
end

function assume(x,a)
%ASSUME   Makes or clears assumptions about x
if x(1)=='_'
    x = mupadmex(x,0);
end
if ~isvarname(x)
    error('symbolic:sym:VariableExpected','Can only make assumptions on variable names, not ''%s''.',x);
end
switch a
    case 'real'
        mupadmex('assume', x, 'Type::Real');
    case {'unreal','clear'}
        mupadmex('unassume', x);
        mupadmex('unalias', x);
    case 'positive'
        mupadmex(['assume(' x ' > 0):']);
end
end

function skip = assumeI(a)
%assumeI makes or clears assumptions about sqrt(-1).
mupadmex('unalias(i,sqrtmone):');
skip = strcmp(a,'clear') || strcmp(a,'unreal');
if skip
    mupadmex('alias(i=I):');
    mupadmex('i',8);
else
    mupadmex('alias(sqrtmone=I):');
    mupadmex('sqrtmone',8);
end
end

function S = numeric2cellstr(x,a)
%NUMERIC2CELLSTR  Convert numeric array to cell of strings.
%    converts a numeric array x into a cell string array of
%    the same size but with each element the string form of the corresponding
%    numeric element. The input 'a' determines the form of the conversion.
S = cell(size(x));
if strcmp(a,'d')
    digs = digits;
end
for k = 1:numel(x)
    switch a
        case 'f'
            S{k} = symf(double(x(k)));
        case 'r'
            S{k} = symr(double(x(k)));
        case 'e'
            S{k} = syme(double(x(k)));
        case 'd'
            S{k} = symd(double(x(k)),digs);
        otherwise
            error('symbolic:sym:sym:errmsg6','Second argument %s not recognized.',a);
    end
end;
end

function S = cell2ref(x)
%CELL2REF  Convert cell array x into a MuPAD reference string S
% x can be a cell array of strings or sym objects
y = x;
if ~iscellstr(x)
    y = tocellstr(x);
end
S = mupadmex(y);
end

function y = tocellstr(x)
%TOCELLSTR   Convert sym objects in cell array x into reference string.
y = x;
for k=1:numel(x)
    if isa(x{k},'sym')
        y{k} = x{k}.s;
    end
end
end

function S = funchandle2ref(x)
%FUNCHANDLE2REF convert func handle x to string form
str = char(x);
ind = find(str == ')',1);
str = str(ind+1:end);
str = strrep(str,'.*','*');
str = strrep(str,'./','/');
str = strrep(str,'.^','^');
S = str;
end

function S = symf(x)
%SYMF   Hexadecimal symbolic representation of floating point numbers.

if imag(x) > 0
    S = ['(' symf(real(x)) ')+(' symf(imag(x)) ')*' cplxunit];
elseif imag(x) < 0
    S = ['(' symf(real(x)) ')-(' symf(abs(imag(x))) ')*' cplxunit];
elseif isinf(x)
    if x > 0
        S = 'Inf';
    else
        S = '-Inf';
    end
elseif isnan(x)
    S = 'NaN';
elseif x == 0
    S = '0';
else
    S = symfl(x);
end
end

function [S,err] = symr(x)
%SYMR   Rational symbolic representation.
[S,err] = mupadmex(' ',x,3);
end

function S = syme(x)
%SYME   Symbolic representation with error estimate.

if imag(x) > 0
    S = ['(' syme(real(x)) ')+(' syme(imag(x)) ')*' cplxunit];
elseif imag(x) < 0
    S = ['(' syme(real(x)) ')-(' syme(abs(imag(x))) ')*' cplxunit];
elseif isinf(x)
    if x > 0
        S = 'Inf';
    else
        S = '-Inf';
    end
elseif isnan(x)
    S = 'NaN';
else
    [S,err] = symr(x);
    if err ~= 0
        err = eval(tofloat(['(' symfl(x) ')-(' S ')'],'32'))/eps;
    end
    if err ~= 0
        [n,d] = rat(err,1.e-5);
        if n == 0 || abs(n) > 100000
            [n,d] = rat(err/x,1.e-3);
            if n > 0
                S = [S '*(1+' int2str(n) '*eps/' int2str(d) ')'];
            else
                S = [S '*(1' int2str(n) '*eps/' int2str(d) ')'];
            end
            return
        end
        if n == 1
            S = [S '+eps'];
        elseif n == -1
            S = [S '-eps'];
        elseif n > 0
            S = [S '+' int2str(n) '*eps'];
        else
            S = [S int2str(n) '*eps'];
        end
        if d ~= 1
            S = [S '/' int2str(d)];
        end
    end
end
end

function S = symd(x,d)
%SYMD   Decimal symbolic representation.

if imag(x) > 0
    S = ['(' symd(real(x),d) ')+(' symd(imag(x),d) ')*' cplxunit];
elseif imag(x) < 0
    S = ['(' symd(real(x),d) ')-(' symd(abs(imag(x)),d) ')*' cplxunit];
elseif isinf(x)
    if x > 0
        S = 'Inf';
    else
        S = '-Inf';
    end
elseif isnan(x)
    S = 'NaN';
else
    S = tofloat(symfl(x),int2str(d));
end
end

function f = symfl(x)
%SYMFL  Exact representation of floating point number.
f = mupadmex(' ',double(x),4);
end

function s = convertCharWithOption(x,a)
%CHAR2REF Convert the string x to a reference with possible 
% size or assumption modifications.
    if isnumeric(a)
        s = createCharMatrix(x,a);
    elseif isa(a,'char') 
        s = convertChar(x);
        assumptions(x,x,a);
    else
        error('symbolic:sym:SecondInputClass','Second input must be an assumption or a size vector.');
    end
end

function s = convertChar(x)
%CHAR2REFBASIC Convert a string, including MuPAD array output, to a reference
% Also checks for MATLAB array syntax for backwards compatibility.
% Variable names are checked for overlap with MuPAD names and appends
% _Var to the name and returns a reference if the name is used by MuPAD.
x = strtrim(x);
if isvarname(x)
    s = convertName(x);
else
    s = convertExpression(x);
end
end

function s = createCharMatrix(x,a)
% Create a symbolic vector or matrix from the variable name x and size vector a.
    a = double(a);
    a(a<0) = 0;
    if any(~isfinite(a))
        error('symbolic:sym:InvalidSize','Symbolic matrices must have finite size.');
    end
    if any(fix(a)~=a)
        error('symbolic:sym:NonIntegerSize','Size vector must have integer entries.');
    end
    if ~isvarname(strrep(x,'%d',''))
        error('symbolic:sym:SimpleVariable','Symbolic matrix base name must be a simple variable name.');
    end
    if numel(a) == 1
        s = createCharMatrixChecked(x,[a a]);
    elseif numel(a) == 2
        s = createCharMatrixChecked(x,a);
    else
        error('symbolic:sym:MatrixArray','Matrix syntax can only create vectors and matrices.');
    end
end

function x = appendDefaultVectorFormat(x)
% Append the default vector format string if needed
    if ~any(x == '%')
        x = [x '%d'];
    end
end

function x = appendDefaultMatrixFormat(x,formats)
% Append the default matrix format string if needed
    if formats == 0
        x = [x '%d_%d'];
    elseif formats == 1
        error('symbolic:sym:FormatTooShort','Format string for a matrix must use %%d twice.');
    end
end

function s = createCharMatrixChecked(x,a)
% Create a symbolic matrix from x and size a with total elements n
    total = prod(a);
    a = a(:).';
    formats = length(find(x == '%'));
    if any(a==1) && formats < 2
        x = appendDefaultVectorFormat(x);
        s = cellfun(@(k)sprintf(x,k),num2cell(1:total),'UniformOutput',false); 
    else
        x = appendDefaultMatrixFormat(x,formats);
        s = cellfun(@(k)createCharMatrixElement(x,a,k),num2cell(1:total),'UniformOutput',false); 
    end
    s = reshape(s,a);
    s = mupadmex(s);
end

function s = createCharMatrixElement(x,a,k)
    [m,n] = ind2sub(a,k);
    s = sprintf(x,m,n);
end

function s = convertName(x)
%VARNAME2REF converts a variable name x into a MuPAD name s.
% The MuPAD name may have _Var appended to distinguish it from 
% a predefined MuPAD symbol (like beta or D).
s = x;
if ~strcmp(x,'pi') && (length(x)>1 || any(x=='DIOE'))
    % ask MuPAD to check if the name is defined and if so append _Var
    s = mupadmex('symobj::fixupVar',x,0);
end
% Remove aliases for complex unit if 'i'
if isequal(x,'i')
    mupadmex('unalias(i,sqrtmone):');
end
end

function s = convertExpression(x)
%EXPRESSION2REF converts the string expression x into a string ref s.
% The output x is the modified string expression in MuPAD syntax.
if isempty(x)
    x = 'matrix(0,0)';
end
if x(1) == '['
    x = convertMATLABsyntax(x);
end
[s,err] = mupadmex({x});
if err
    error('symbolic:sym:sym:errmsg9',s)
end
end

function x = convertMATLABsyntax(x)
%convertMATLABsyntax rewrites a MATLAB-style array into a MuPAD array.
x = convertSpaces(x);
% String contains square brackets, so it is not a scalar.
if x(1) == '['
    x = convertBrackets(x);
end
x = ['matrix([' x '])'];
end

function x = convertSpaces(x)
%convertSpaces makes the space-separated array syntax into MuPAD syntax
% If the string is of the form, M = '[x - 1 x + 2;x * 3 x / 4]'
% then find all of the alpha-numeric chararacters (id), the
% arithmetic operators (+ - / * ^) (op), and spaces (sp) and
% combine them into a vector V = 3*sp + 2*op + id.  That is,
% id = isalphanum(M); op = isop(M); sp = find(M == ' ').  Let
% spaces receive the value 3, operators 2, and alpha-numeric
% characters 1.  Whenever the sequence 1 3 1 occurs, replace it
% with 1 4 1.  Insert a comma whenever the number 4 occurs.
% First remove all multiple blanks to create at most one blank.
sp = (x == ' ');  % Location of all the spaces.
b = findrun(sp); % Beginning (b) indices.
sp(b) = 0;  % Mark the beginning of multiple blanks.
x(sp) = []; % Set multiple blanks to empty string.
V = isalphanum(x) + 2*isop(x) + 3*(x == ' ');
if length(V) >= 3
    d = V(2:end-1)==3 & V(1:end-2)==1 & V(3:end)==1;
    V(find(d)+1) = 4;
end
x(V == 4) = ',';
end

function x = convertBrackets(x)
%convertBrackets makes MATLAB brackets look like MuPAD array.
% Make '[a11 a12 ...; a21 a22 ...; ... ]' look like MuPAD array.
% Version 1 compatibility.  Possibly useful elsewhere.
% Replace multiple blanks with single blanks.
k = findstr(x,'  ');
while ~isempty(k);
    x(k) = [];
    k = findstr(x,'  ');
end
% Replace blanks surrounded by letters, digits or parens with commas.
for k = findstr(x,' ');
    if (isalphanum(x(k-1)) || x(k-1) == ')') && ...
            (isalphanum(x(k+1)) || x(k+1) == '(')
        x(k) = ',';
    end
end
% Replace semicolons with '],['.
for k = fliplr(findstr(';',x))
    x = [x(1:k-1) '],[' x(k+1:end)];
end
end

function b = findrun(x)
%FINDRUN Finds the runs of like elements in a vector.
%   FINDRUN(V) returns the beginning (b)
%   indices of the runs of like elements in the vector V.

d = diff([0 x 0]);
b = find(d == 1);
end

function B = isalphanum(S)
%ISALPHANUM is True for alpha-numeric characters.
%   ISALPHANUM(S) returns 1 for alpha-numeric characters or
%   underscores and 0 otherwise.
%
%   Example:  S = 'x*exp(x - y) + cosh(x*s^2)'
%             isalphanum(S)   returns
%            (1,0,1,1,1,0,1,0,0,0,1,0,0,0,0,1,1,1,1,0,1,0,1,0,1,0)

B = isletter(S) | (S >= '0' & S <= '9') | (S == '_');
end

function B = isop(S)
%ISOP is True for + - * / or ^.
%   ISOP(S) returns 1 for plus, minus, times, divide, or
%   exponentiation operators and 0 otherwise.

B = (S == '+') | (S == '-') | (S == '*') | ...
    (S == '/') | (S == '^');
end

function s = cplxunit
%CPLXUNIT  Return the current name for sqrt(-1)
s = mupadmex('I',0);
if isequal(s,'sqrtmone')
    s = 'sqrt(-1)';
end
end

function y = tofloat(x,d)
%TOFLOAT   Convert expression to vpa
%    Y = TOFLOAT(X,D) converts expression in string X to vpa with digits D.
y = mupadmex('symobj::float', x, d, 0);
end

function notimplemented(str)
%NOTIMPLEMENTED   Error for functions that sym does not implement
error('symbolic:sym:NotImplemented','Function ''%s'' is not implemented for MuPAD symbolic objects.',str);
end

function [s,refs] = privformat(x)
%PRIVFORMAT   Format array into MuPAD indexing string
%   [S,REFS] = PRIVFORMAT(X) turns X into a string S tailored for calling
%   MuPAD's indexing code. REFS is the array of any sym objects needed
%   to hold references needed by S (to prevent early garbage collection).
refs = [];
if isscalar(x)
    s = privformatscalar(x);
elseif ndims(x) == 2
    s = privformatmatrix(x);
else
    [s,refs] = privformatarray(x);
end
end

function s = privformatscalar(x)
%PRIVFORMATSCALAR  Format scalar object for indexing
if ischar(x) && strcmp(x,':')
    s = '#COLON';
elseif islogical(x)
    s = logical2str(x);
else
    x = double(x);
    checkindex(x);
    s = int2str(x);
end
end

function s  = privformatmatrix(x)
%PRIVFORMATMATRIX  Format matrix object for indexing
d = size(x);
s = sprintf('matrix(%d,%d,[',d(1),d(2));
if isnumeric(x) || ischar(x)
    x = double(x);
    checkindex(x);
    s = [s sprintf('%d,',x.')];
elseif islogical(x)
    x2 = num2cell(x);
    x2 = cellfun(@logical2str,x2,'UniformOutput',false);
    x2 = x2.';
    x2 = x2(:).';
    x2(2,:) = {','};
    s = [s x2{:}];
else
    error('sym:subscript:InvalidIndex','Indexing input must be numeric, logical or '':''.');
end
s = [s(1:end-1) '])'];
end

function [s,refs]  = privformatarray(x)
%PRIVFORMATARRAY  Format n-d array object for indexing
if isnumeric(x) || ischar(x)
    x = double(x);
    checkindex(x);
    x2 = num2cell(x);
    refs = sym(cellfun(@num2str,x2,'UniformOutput',false));
    s = charcmd(refs);
elseif islogical(x)
    x2 = num2cell(x);
    refs = sym(cellfun(@logical2str,x2,'UniformOutput',false));
    s = charcmd(refs);
else
    error('sym:subscript:InvalidIndex','Indexing input must be numeric, logical or '':''.');
end
end

function checkindex(x)
%CHECKINDEX   Error check for valid indexing expression
%   CHECKINDEX(X) errors if X is not a valid indexing expression
fin = isfinite(x);
flint = fix(x)==x;
pos = x>0;
if ~all(fin(:)) || ~all(flint(:)) || ~isreal(x) || ~all(pos(:))
    error('symbolic:badsubscript','Index must be a positive integer or logical.');
end
end

function y=logical2str(x)
%LOGICAL2STR  Convert logical value to MuPAD string equivalent
if x
    y = 'TRUE';
else
    y = 'FALSE';
end
end

function checkNoSyms(args)
    if any(cellfun(@(arg)isa(arg,'sym'),args))
        error('symbolic:ezhelper:TooManySyms','Too many sym objects to plot.');
    end
end
