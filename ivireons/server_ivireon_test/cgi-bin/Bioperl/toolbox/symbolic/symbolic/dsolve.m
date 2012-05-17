function varargout = dsolve(varargin)
%DSOLVE Symbolic solution of ordinary differential equations.
%   DSOLVE('eqn1','eqn2', ...) accepts symbolic equations representing
%   ordinary differential equations and initial conditions.  Several
%   equations or initial conditions may be grouped together, separated
%   by commas, in a single input argument.
%
%   By default, the independent variable is 't'. The independent variable
%   may be changed from 't' to some other symbolic variable by including
%   that variable as the last input argument.
%
%   The letter 'D' denotes differentiation with respect to the independent
%   variable, i.e. usually d/dt.  A "D" followed by a digit denotes
%   repeated differentiation; e.g., D2 is d^2/dt^2.  Any characters
%   immediately following these differentiation operators are taken to be
%   the dependent variables; e.g., D3y denotes the third derivative
%   of y(t). Note that the names of symbolic variables should not contain
%   the letter "D".
%
%   Initial conditions are specified by equations like 'y(a)=b' or
%   'Dy(a) = b' where y is one of the dependent variables and a and b are
%   constants.  If the number of initial conditions given is less than the
%   number of dependent variables, the resulting solutions will obtain
%   arbitrary constants, C1, C2, etc.
%
%   Three different types of output are possible.  For one equation and one
%   output, the resulting solution is returned, with multiple solutions to
%   a nonlinear equation in a symbolic vector.  For several equations and
%   an equal number of outputs, the results are sorted in lexicographic
%   order and assigned to the outputs.  For several equations and a single
%   output, a structure containing the solutions is returned.
%
%   If no closed-form (explicit) solution is found, an implicit solution is
%   attempted.  When an implicit solution is returned, a warning is given.
%   If neither an explicit nor implicit solution can be computed, then a
%   warning is given and the empty sym is returned.  In some cases involving
%   nonlinear equations, the output will be an equivalent lower order
%   differential equation or an integral.
%
%   DSOLVE(...,'IgnoreAnalyticConstraints',VAL) controls the level of 
%   mathematical rigor to use on the analytical constraints of the solution 
%   (branch cuts, division by zero, etc). The options for VAL are 'all' or 
%   'none'. Specify 'none' to use the highest level of mathematical rigor
%   in finding any solutions. The default is 'all'.
%
%   Examples:
%
%      dsolve('Dx = -a*x') returns
%
%        ans = C1/exp(a*t)
%
%      x = dsolve('Dx = -a*x','x(0) = 1','s') returns
%
%        x = 1/exp(a*s)
%
%      S = dsolve('Df = f + g','Dg = -f + g','f(0) = 1','g(0) = 2')
%      returns a structure S with fields
%
%        S.f = (i + 1/2)/exp(t*(i - 1)) - exp(t*(i + 1))*(i - 1/2)
%        S.g = exp(t*(i + 1))*(i/2 + 1) - (i/2 - 1)/exp(t*(i - 1))
%
%      dsolve('Df = f + sin(t)', 'f(pi/2) = 0')
%      dsolve('D2y = -a^2*y', 'y(0) = 1, Dy(pi/a) = 0')
%      S = dsolve('Dx = y', 'Dy = -x', 'x(0)=0', 'y(0)=1')
%      S = dsolve('Du=v, Dv=w, Dw=-u','u(0)=0, v(0)=0, w(0)=1')
%      w = dsolve('D3w = -w','w(0)=1, Dw(0)=0, D2w(0)=0')
%
%   See also SOLVE, SUBS.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/02/09 00:31:09 $

eng = symengine;
if strcmp(eng.kind,'maple')
    varargout = mapleDsolve(nargout,varargin);
    return;
end

narg = nargin;

ignoreConstraints = 'all';
if narg > 2 && ischar(varargin{end}) && strcmp(varargin{end-1},'IgnoreAnalyticConstraints')
    ignoreConstraints = varargin{end};
    if ~any(strcmp(ignoreConstraints,{'all','none'}))
        error('symbolic:dsolve:InvalidAnalyticConstraints',...
              'IgnoreAnalyticConstraints must be ''all'' or ''none''.')
    end
    narg = narg-2;
end

if (narg==0) || all(varargin{narg}==' ')
   warning('symbolic:dsolve:warnmsg3','Empty equation')
   varargout{1} = sym([]);
   return
end

[R,vars] = mupadDsolve(ignoreConstraints,varargin{1:narg});

% If no solution, give up
if isempty(R)
   warning('symbolic:dsolve:warnmsg2','Explicit solution could not be found.');
   varargout = cell(1,nargout);
   varargout{1} = sym([]);
   return
end

varargout = assignOutputs(nargout,R,vars);

function out = assignOutputs(nout,R,vars)
nvars = size(R,2);
out = cell(1,nout);
% If the output contains int, make it a symbolic vector.

if nvars == 1 && nout <= 1

   % One variable and at most one output.
   % Return a single scalar or vector sym.
   out{1} = R;

else

   % Form the output structure
   for j = 1:nvars
       vc = char(vars(j));
       S.(vc) = R(:,j);
   end
   
   if nout <= 1

      % At most one output, return the structure.
      out{1} = S;

   elseif nout == nvars

      % Same number of outputs as variables.
      % Match results in lexicographic order to outputs.
      v = sort(fieldnames(S));
      for j = 1:nvars
         out{j} = S.(v{j});
      end

   else
      error('symbolic:dsolve:errmsg4', ...
         '%d variables does not match %d outputs.',nvars,nout)
   end
end

function out = mapleDsolve(nout,varin)
for k=1:length(varin)
    v = varin{k};
    if isa(v,'sym')
        varin{k} = getMapleObject(v);
    end
end
[S,err] = mapleengine('dsolve',varin{:});
if err ~= 0
    error('symbolic:dsolve:MapleError',S);
end
out = cell(1,nout);
if isa(S,'struct') && (nout > 1 || ...
                       length(fieldnames(S))==1)
    v = sort(fieldnames(S));
    for j = 1:length(v)
        if j <= nout
            out{j} = sym(S.(v{j}));
        end
    end
else
    out{1} = sym(S);
end

    
function [R,var_list] = mupadDsolve(ignoreConstraints,varargin)

narg = nargin-1;

% The default independent variable is t.
x = sym('t');

% Pick up the independent variable, if specified.
if all(varargin{narg} ~= '='),
   x = sym(varargin{narg}); 
   narg = narg-1;
end
% Concatenate equation(s) and initial condition(s) inputs into SYS.
sys = varargin(1:narg);
sys(2,:) = {','};
sys_str = ['[' sys{1:end-1} ']'];
sys = sym(sys_str);
[var_list,R] = mupadmexnout('symobj::dsolve',sys,x,ignoreConstraints);
