function G = subs(F,X,Y,swap)
%SUBS   Symbolic substitution.  Also used to evaluate expressions numerically.
%   SUBS(S) replaces all the variables in the symbolic expression S with
%   values obtained from the calling function, or the MATLAB workspace.
%   
%   SUBS(S,NEW) replaces the free symbolic variable in S with NEW.
%   SUBS(S,OLD,NEW) replaces OLD with NEW in the symbolic expression S.
%   OLD is a symbolic variable, a string representing a variable name, or
%   a string (quoted) expression. NEW is a symbolic or numeric variable
%   or expression.  That is, SUBS(S,OLD,NEW) evaluates S at OLD = NEW.
%   The substitution is first attempted as a MATLAB expression resulting 
%   in the computation being done in double precision arithmetic if all 
%   the values in NEW are double precision. Convert the NEW values to SYM
%   to ensure symbolic or variable precision arithmetic.
%   When substituting for an expression (e.g. OLD = a*b) the substitution
%   is performed only if the expressions matches exactly. For example
%   subs(a*b^2,a*b,5) will not return 5*b.
%
%   If OLD and NEW are vectors or cell arrays of the same size, each element
%   of OLD is replaced by the corresponding element of NEW.  If S and OLD
%   are scalars and NEW is a vector or cell array, the scalars are expanded
%   to produce an array result.  If NEW is a cell array of numeric matrices,
%   the substitutions are performed elementwise.
%
%   Examples:
%     Single input:
%       Suppose a = 980 and C1 = 3 exist in the workspace.
%       The statement
%          y = dsolve('Dy = -a*y')
%       produces
%          y = exp(-a*t)*C1
%       Then the statement
%          subs(y)
%       produces
%          ans = 3*exp(-980*t)
%
%     Single Substitution:
%       subs(a+b,a,4) returns 4+b.
%
%     Multiple Substitutions:
%       subs(cos(a)+sin(b),{a,b},[sym('alpha'),2]) or
%       subs(cos(a)+sin(b),{a,b},{sym('alpha'),2}) returns
%       cos(alpha)+sin(2)
%   
%     Scalar Expansion Case: 
%       subs(exp(a*t),'a',-magic(2)) returns
%
%       [   exp(-t), exp(-3*t)]
%       [ exp(-4*t), exp(-2*t)]
%
%     Multiple Scalar Expansion:
%       subs(x*y,{x,y},{[0 1;-1 0],[1 -1;-2 1]}) returns
%         0  -1
%         2   0
%
%   See also SYM/SUBEXPR.

% Deprecated API:
%   If SUBS(S,OLD,NEW) does not change S, then SUBS(S,NEW,OLD) is tried.
%   This provides backwards compatibility with previous versions and 
%   eliminates the need to remember the order of the arguments.
%   SUBS(S,OLD,NEW,0) does not switch the arguments if S does not change.

%   Copyright 1993-2010 The MathWorks, Inc.

if ~isa(F,'sym'), F = sym(F); end
if builtin('numel',F) ~= 1,  F = normalizesym(F);  end

ismaple = isa(F.s,'maplesym');

% Find the list of symbolic variables in F that do NOT contain pi.
vars = getVars(F);
nvars = length(vars);
if nvars == 0
    G = double(F);
    return;
end

if nargin == 1
    % initialize X and Y from workspace variables
    
    % Determine which variables are in the MATLAB workspace and
    % place them in the cell X.  Similarly, place the values of 
    % variables in the MATLAB workspace into the cell Y.
    eflag = zeros(1,nvars);
    for k = 1:nvars
        str = sprintf('exist(''%s'',''var'')',vars{k});
        eflag(k) = evalin('caller',str);
        if ~eflag(k)
            eflag(k) = 2*evalin('base',str);
        end
    end
    einds = find(eflag);
    X = vars(einds);
    Y = cell(1,length(einds));
    for k = 1:length(einds)
        if eflag(einds(k)) == 1
            Y{k} = evalin('caller',vars{einds(k)});
        else
            Y{k} = evalin('base',vars{einds(k)});
        end
    end
elseif ~ismaple && nargin == 2
    % got Y and use free variable as X
    Y = X;
    X = symvar(F,1);
    if isempty(X), X = sym('x'); end
end

if ismaple
    args = {F.s};
    if isa(X,'sym'), X = X.s; end
    args(end+1) = {X};
    if nargin ~= 2
        if isa(Y,'sym'), Y = Y.s; end
        args(end+1) = {Y};
    end
    if nargin > 3
        args(end+1) = {swap};
    end
    G = sym(subs(args{:}));
    return;
end
if isempty(Y)
    G = F;
else
    G = mupadsubs(F,X,Y);
end

if nargin < 4, swap = 1; end
if ~isempty(G) && ~isa(G,'double') && isequal(G,F) && swap
   G = subs(F,Y,X,0);
end

function G = mupadsubs(F,X,Y)
% Check for appropriate forms of input.
msg = inputchk(X,Y);
if ~isempty(msg), error('symbolic:sym:subs:errmsg1',msg), end

[G,worked] = tryFunctionHandle(F,X,Y);
if worked
    return;
end

% convert X strings to syms and wrap in cell array if needed
[X2,symX] = normalize(X); %#ok

% convert Y to all syms or all numerics, and wrap in cell array if needed
[Y2,symY] = normalize(Y); %#ok

% the evaluation in MATLAB didn't work so send all data to MuPAD for subs
G = mupadmex('symobj::fullsubs',F.s,X2,Y2);

function vars = getVars(F)
vars = findsym(F);
if isa(vars,'sym')
    if builtin('numel',vars) ~= 1,  vars = normalizesym(vars);  end
    if isa(vars.s,'maplesym')
        vars = char(vars);
        k1 = find(vars=='[',1)+1;
        k2 = find(vars==']',1)-1;
        vars = vars(k1:k2);
    end
end
vars(vars == ' ') = [];
% Compute the number of symbolic variables (excluding pi).
vars = regexp(vars,'\w+','match');

% convert input X to cell array of sym objects
function [X2,X] = normalize(X)
if iscell(X)
    X = cellfun(@(x)sym(x),X,'UniformOutput',false);
elseif ischar(X) || isnumeric(X)
    X = {sym(X)};
elseif isa(X,'sym')
    X = {X};
else
    error('symbolic:subs:InvalidXClass','Substitution expression X must be a symbolic, cell or numeric array.');
end
% we need to keep X alive so that the reference is not collected
X2 = tolist(X); 

function [G,worked] = tryFunctionHandle(F,X,Y)
G = [];
worked = false;

% only proceed if Y is numeric or cell of numeric or empty
if ~evalableY(Y)
    return;
end

% pick out those X that are simple variable names
xvarnames = getNames(X);
xvarnames(xvarnames==' ') = [];
xcellname = regexp(xvarnames,',','split');
xvars = cellfun(@(x)isvarname(x),xcellname);

% if X is made of variable names (identifiers) then try MATLAB evaluation
if ~isempty(xvars) && all(xvars) && isValidBody(F,xcellname)
    body = map2mat(char(F));
    
    if ~isempty(body)
        Y = getValues(xcellname,Y);
        try
            Fhandle = makeFhandle(xvarnames,body);
            G = Fhandle(Y{:});
            worked = true;
        catch me %#ok - ignore all exceptions and have it try the slow method
        end
    end
end

% return true if F is a valid matlab function and will not try to
% eval unknown symbols that are not inputs
function ok = isValidBody(F,xvars)
fvars = mupadmex('symobj::indets',F.s,0);
fvars(fvars==' ') = [];
fvars = strrep(fvars,'_Var','');
fvars = regexp(fvars(2:end-1),',','split');
fvars = setdiff(fvars,xvars);
ok = isempty(fvars);

% return true if Y has the right type to be passed to an anon function
function s = evalableY(Y)
s = isnumeric(Y) || (iscell(Y) && all(cellfun(@(y)isnumeric(y)||isempty(y),Y)));

% convert Y into cell array of values to pass to anon function
function Y = getValues(names,Y)
if isnumeric(Y)
    if numel(names) == 1
        Y = {Y};
    else
        Y = num2cell(Y);
    end
elseif iscell(Y)
    Y = cellfun(@subsEmptyDoubleForEmpty,Y,'UniformOutput',false);
end

% make sure empty objects are [] for anon function evaluation
function x = subsEmptyDoubleForEmpty(x)
if isempty(x)
    x = [];
end

% Convert X into a list of names to try to use as inputs for anon function
% s is a string of names separated by commas
function s = getNames(X)
if iscell(X)
    s = cellfun(@(x)[char(x) ','],X,'UniformOutput',false);
    s = [s{:}];
    s(end) = [];
elseif isa(X,'sym')
    s = X.s;
    if s(1)=='_' % look for matrices of names
        s = mupadmex('symobj::getvarnames',s,0);
    end
    s = strrep(s,'_Var','');
elseif isnumeric(X)
    s = '';
elseif ischar(X)
    s = X;
else
    error('symbolic:subs:InvalidXClass','OLD must be symbolic, strings, cell arrays or numeric.');
end

%-------------------------
function SUBS_Fhandle = makeFhandle(SUBS_xvarnames,SUBS_body)
SUBS_Fhandle = eval(['@(' SUBS_xvarnames ')' vectorize(SUBS_body)]);

%-------------------------
function msg = inputchk(x,y)
%INPUTCHK Generate error message for invalid cases

msg = '';

if isa(x,'sym') && length(x)==1
  if ischar(y) && size(y,1)~=1,
    msg = 'String substitutions require 1-by-m strings.';
  end
elseif ischar(x) && ischar(y) && ...
      (length(sym(x))~=1 || length(sym(y))~=1) && isvarname(char(x))
  msg = 'String substitutions require 1-by-m strings.';
elseif (ischar(x) || isa(x,'sym')) && isvarname(char(x))
  if ischar(y) && size(y,1)~=1,
    msg = 'String substitutions require 1-by-m strings.';
  end
end

%-------------------------
function r = map2mat(r)
% MAP2MAT MuPAD to MATLAB string conversion.
%   MAP2MAT(r) converts the MuPAD string r containing
%   matrix, vector, or array to a valid MATLAB string.
%
%   Examples: map2mat(matrix([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(array([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(vector([[a,b,c,d]])  returns
%             [a,b,c,d]

% Deblank.
r(r == ' ') = [];
% Special case of the empty matrix or vector
if strcmp(r,'vector([])') || strcmp(r,'matrix([])') || ...
   strcmp(r,'array([])')
   r = '';
else
   % Remove matrix, vector, or array from the string.
   r = strrep(r,'matrix([[','['); r = strrep(r,'array([[','[');
   r = strrep(r,'vector([','['); r = strrep(r,'],[',';');
   r = strrep(r,']])',']'); r = strrep(r,'])',']');
end

% given expression x to subs for, find string form for x in order to
% be used by anon function
function c = getchar(x)
if isa(x,'sym')
    c = x.s;
elseif ischar(x)
    c = x;
else
    c = '?'; % need any symbol that is not a variable name
end

% convert A to a MuPAD list
function s = tolist(A)
s = cellfun(@(x)[getchar(x) ','],A,'UniformOutput',false);
s = [s{:}];
s = ['[' s(1:end-1) ']'];

