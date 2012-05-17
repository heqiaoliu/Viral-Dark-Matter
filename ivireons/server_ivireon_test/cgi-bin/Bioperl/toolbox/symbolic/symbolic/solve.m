function varargout = solve(varargin)
%SOLVE  Symbolic solution of algebraic equations.
%   SOLVE('eqn1','eqn2',...,'eqnN')
%   SOLVE('eqn1','eqn2',...,'eqnN','var1,var2,...,varN')
%   SOLVE('eqn1','eqn2',...,'eqnN','var1','var2',...'varN')
%
%   The eqns are symbolic expressions or strings specifying equations.  The
%   vars are symbolic variables or strings specifying the unknown variables.
%   SOLVE seeks zeros of the expressions or solutions of the equations.
%   If not specified, the unknowns in the system are determined by FINDSYM.
%   If no analytical solution is found and the number of equations equals
%   the number of dependent variables, a numeric solution is attempted.
%
%   Three different types of output are possible.  For one equation and one
%   output, the resulting solution is returned, with multiple solutions to
%   a nonlinear equation in a symbolic vector.  For several equations and
%   an equal number of outputs, the results are sorted in lexicographic
%   order and assigned to the outputs.  For several equations and a single
%   output, a structure containing the solutions is returned.
%
%   Examples:
%
%      solve('p*sin(x) = r') chooses 'x' as the unknown and returns
%
%        ans =
%        asin(r/p)
%
%      [x,y] = solve('x^2 + x*y + y = 3','x^2 - 4*x + 3 = 0') returns
%
%        x =
%        [ 1]
%        [ 3]
%
%        y =
%        [    1]
%        [ -3/2]
%
%      S = solve('x^2*y^2 - 2*x - 1 = 0','x^2 - y^2 - 1 = 0') returns
%      the solutions in a structure.
%
%        S =
%          x: [8x1 sym]
%          y: [8x1 sym]
%
%      [u,v] = solve('a*u^2 + v^2 = 0','u - v = 1') regards 'a' as a
%      parameter and solves the two equations for u and v.
%
%      S = solve('a*u^2 + v^2','u - v = 1','a,u') regards 'v' as a
%      parameter, solves the two equations, and returns S.a and S.u.
%
%      [a,u,v] = solve('a*u^2 + v^2','u - v = 1','a^2 - 5*a + 6') solves
%      the three equations for a, u and v.
%
%   See also DSOLVE.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/02/09 00:31:10 $

% Collect input arguments together in either equation or variable lists.

eng = symengine;
if strcmp(eng.kind,'maple')
    varargout = mapleSolve(nargout,varargin);
    return;
end

[eqns,vars] = getEqns(varargin{:});

if isempty(eqns)
   warning('symbolic:solve:warnmsg1','List of equations is empty.')
   varargout = cell(1,nargout);
   varargout{1} = sym([]);
   return
end

[symvars,R] = mupadmexnout('symobj::solvefull',eqns,vars);

% If still no solution, give up.

if isempty(R)
   warning('symbolic:solve:warnmsg3','Explicit solution could not be found.');
   varargout = cell(1,nargout);
   varargout{1} = sym([]);
   return
end

varargout = assignOutputs(nargout,R,symvars);

if isempty(varargout{1})
   warning('symbolic:solve:warnmsg3','Explicit solution could not be found.');
end

% Parse the result.
function out = assignOutputs(nout,R,symvars)
out = cell(1,nout);
if (isscalar(symvars) && nout <= 1) || isscalar(R)

   % One variable and at most one output.
   % Return a single scalar or vector sym.

   out{1} = R;

   if isscalar(R) && ~isscalar(symvars) 
       warning('symbolic:solve:warnmsg4','Could not extract individual solutions. Returning a MuPAD set object.');
   end

else

   % Several variables.
   nvars = length(symvars);

   S = [];
   for j = 1:nvars
       S.(char(symvars(j))) = R(:,j);
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
      error('symbolic:dsolve:errmsg5', ...
         '%d variables does not match %d outputs.',nvars,nout)
   end
end


function out = mapleSolve(nout,varin)
for k=1:length(varin)
    v = varin{k};
    if isa(v,'sym')
        varin{k} = getMapleObject(v);
    end
end
[S,err] = mapleengine('solve',varin{:});
if err ~= 0
    error('symbolic:solve:MapleError',S);
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

%-------------------------

function [eqns,vars] = getEqns(varargin)
eqns = [];
vars = [];
for k = 1:nargin
   v = varargin{k};
   vc = char(v);
   if ~isempty(eqns) && all(isstrprop(vc,'alphanum') ...
                            | vc == '_' | vc == ',' | vc == ' ')
       if isa(v,'sym') && any(strcmp(vc,{'beta','gamma','psi','theta','zeta','D','E','O','Ei','Si','Ci','I'}))
           vc = [vc '_Var']; %#ok<AGROW>
       end
       vc(vc == ' ') = [];
       vars = [vars ',' vc]; %#ok<AGROW>
   elseif isa(v,'sym')
       eqns = [eqns v(:).']; %#ok<AGROW>
   else
       [t,stat] = mupadmex(vc,0);
       if stat
           error('symbolic:solve:errmsg1', ...
                 ''' %s '' is not a valid expression or equation.',v)
       end
       if ~isempty(t)
           % use a set syntax to preserve the list items without
           % causing the string to be parsed as MATLAB arrays [a b]
           t = sym(['{' vc '}']);
           eqns = [eqns t(:).'];  %#ok<AGROW>
       end
   end
end
vars = ['[' vars ']'];
if vars(2)==','
    vars(2)=' ';
end

