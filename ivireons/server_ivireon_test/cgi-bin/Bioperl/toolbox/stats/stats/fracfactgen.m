function [gens,resfound] = fracfactgen(effects,k,resneeded,basic,dispopt,doall)
%FRACFACTGEN Fractional factorial design generators.
%   GENS = FRACFACTGEN(MODEL,K) finds a set of fractional factorial design
%   generators suitable for fitting a specified model.  MODEL specifies the
%   model, and is either a text string or a matrix of 0's and 1's as
%   accepted as the MODEL argument by the X2FX function.  The design will
%   have 2^K runs.  The output GENS is a cell array that specifies the
%   confounding of the design, and that is suitable for use as input to the
%   FRACFACT function. The FRACFACT function can generate the design and
%   display the confounding pattern for the generators.  If K is not given,
%   FRACFACTGEN will try to find the smallest possible value.
%
%   If MODEL is a text string, then MODEL must consist of a sequence of
%   words separated by spaces, each word representing a term that must be
%   estimable in the design.  The jth letter of the alphabet represents the
%   jth factor.  For example, 'a b c d ac' defines a model that includes
%   the main effects for factors a-d, and the interaction between factors a
%   and c.
%
%   FRACFACTGEN uses the Franklin-Bailey algorithm to find the generators
%   of a design that is capable of fitting the specified model.  MODEL must
%   not specify more than 32 factors.
%
%   GENS = FRACFACTGEN(MODEL,K,RES) tries to find a design with resolution
%   RES (default 3).  If FRACFACTGEN is unable to find the requested
%   resolution, it will either display an error, or if it located a
%   lower-resolution design capable of fitting the model, it will return
%   the generators for that design along with a warning.  If the result is
%   an error, it may still be possible to call FRACFACTGEN with a lower
%   value of RES and find a set of design generators.
%
%   GENS = FRACFACTGEN(MODEL,K,RES,BASIC) also accepts a vector BASIC with
%   K elements specifying the numbers of the factors that are to be treated
%   as basic factors.  These factors will receive single-letter generators,
%   and other factors will be confounded with interactions among the basic
%   factors.  The default is chosen to include factors that are part of the
%   highest-order interaction in MODEL.
%
%   Example:  Find the generators for a design with four factors and 2^3=8
%             runs so that we can estimate the interaction between the
%             first and third factors.
%
%       fracfactgen('a b c d ac',3)
%
%       m = [1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1;1 0 1 0];
%       fracfactgen(m,3)
%
%   See also FRACFACT.

% The following undocumented arguments are not supported and may change
% in a future release:
%   GENS = FRACFACTGEN(MODEL,K,RES,BASIC,DISPOPT) displays diagnostic output if
%   DISPOPT is true or omits it if DISPOPT is false (default).
%
%   GENS = FRACFACTGEN(MODEL,K,RES,BASIC,DISPOPT,DOALL) finds all possible
%   generators if DOALL is true, or only one set if DISPOPT is false (default).
%
%   [GENS,RESFOUND] = FRACFACTGEN(...) returns the resolution of the design
%   produced by these generators.  However, if the requested resolution is
%   3 (indicating that confounding with interactions is acceptable), the
%   RESFOUND value is set to 3 and the FRACFACTGEN function does not
%   attempt to determine if the resolution of the output generators is
%   actually higher than 3.

% Reference:
%   Franklin, M.F., and R. A. Bailey (1977), "Selection of defining
%   contrasts and confounded effects in two-level experiments," Applied
%   Statistics, 26, pp. 321-326. 

%   Copyright 2005-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:13:51 $

% On input model may be a string such as 'a b c abc', or a matrix as
% accepted by x2fx.  Convert to a model matrix and an effects vector.
alpha = 'a':'z';
if ischar(effects)
    effects = lower(effects);
    effchars = effects(effects~=' ');
    if ~all(ismember(effchars,alpha))
        error('stats:fracfactgen:BadModel',...
              'The MODEL string must consist of letters a-z and spaces.');
    end
    n = max(1 + (effchars-'a'));
    effects = strread(effects,'%s');
    
    model = zeros(length(effects),n);
    for j=1:length(effects)
        model(j,:) = ismember(alpha(1:n),effects{j});
    end
elseif isnumeric(effects) && all(ismember(effects(:),0:1))
    model = effects;
else
    error('stats:fracfactgen:BadModel',...
          'MODEL must be a character string of model terms, or a matrix of 0''s and 1''s.');
end
t = all(model==0,2);  % remove constant term, if any
model(t,:) = [];
n = size(model,2);
if n>32
    error('stats:fracfactgen:BadModel',...
          'Model must include no more than 32 factors.');
end
effects = model * (2.^(0:n-1))';
if nargin<2 || isempty(k)
    k = [];
elseif(~isscalar(k) || ~isnumeric(k) || k~=round(k) || k<2)
    error('stats:fracfactgen:BadK',...
          'The K argument must be a scalar specifying a design with 2^K runs.')
end

nterms = length(effects);
effects = uint32(effects);

% Defaults for optional arguments
if nargin<3 || isempty(resneeded)
    resneeded = 3;
elseif ~isscalar(resneeded) || resneeded~=floor(resneeded) || resneeded<3
    error('stats:fracfactgen:BadRes','Resolution must be an integer 3 or larger.');
end
if nargin<4
    basic = [];
end
if nargin<5 || isempty(dispopt)
    dispopt = false;
elseif ~isequal(dispopt,true) && ~isequal(dispopt,false)
    error('stats:fracfactgen:BadDispopt','DISPOPT must be TRUE or FALSE.');
end
if nargin<6 || isempty(doall)
    doall = false;
elseif ~isequal(doall,true) && ~isequal(doall,false)
    error('stats:fracfactgen:BadDoall','DOALL must be TRUE or FALSE.');
end

if dispopt
    fprintf(1,'Input effects:\n');
    fprintf(1,'%s\n',showterms(effects));
end

% Step 1.  Define ineligible effects set, ies
ies = zeros(1,nterms*(nterms+1)/2,'uint32');
ies(1:nterms) = effects;
base = nterms;

for i=1:nterms-1
    j = nterms-i;
    ies(base+(1:j)) = bitor(effects(i),effects(i+1:end));
    base = base+j;
end

ies = sort(ies);
ies(diff(ies)==0) = [];
if dispopt
    fprintf(1,'Ineligible effects set:\n');
    fprintf(1,'%s\n',showterms(ies));
end

% Step 2.  Choose smallest possible sample size
termsize = bitcount(effects);
maxtermsize = max(termsize);
kmin = max(ceil(log2(nterms+1)),maxtermsize);
if resneeded>3
    if resneeded==4
        % For res 4, must be at least as large as a res 3 foldover
        kmin = max(kmin, ceil(log2(2*n)));
    else
        % For res 5, must be able to fit all terms up to 2-factor interactions
        kmin = max(kmin, ceil(log2(1+n+n*(n-1)/2)));
    end
end
if isempty(k)
    k = kmin;
elseif k<kmin
    error('stats:fracfactgen:BadK',...
          'K must be at least %d for the specified model and resolution.',kmin);
end
m = n - k;
if m <= 0
    warning('stats:fracfactgen:NotFractional',...
           'Requested design is a full factorial of resolution 5 or greater.');
    gens = cellstr(char('a'+(0:min(k,n)-1)'));
    resfound = 5;
    return
end

% Step 3.  Select basic factors
if ~isempty(basic)
    basic = sort(basic(:));
    if any(~ismember(basic,1:n)) || any(diff(basic)==0) || length(basic)~=k
        error('stats:fracfactgen:BadBasic',...
              'BASIC must be a vector of %d distinct integers in the range 1 to %d.',k,n);
    end
else
    % Start with one of the largest terms (highest level of interaction)
    inter = find(termsize==maxtermsize,1);
    basic = zeros(1,n);
    for j=1:n
        if bitget(effects(inter),j)
            basic(j) = 1;
        end
    end
    j = 1;
    nbasic = sum(basic);
    while(nbasic<k && j<n)        % select more factors if more are needed
        if ~basic(j)
            basic(j) = 1;
            nbasic = nbasic+1;
        end
        j = j+1;
    end
    basic = find(basic);
end
added = find(~ismember(1:n,basic));    % get added (non-basic) factors

if dispopt
    fprintf(1,'Basic factor set:\n');
    fprintf(1,'%s ',alpha(basic));
    fprintf(1,'\n');
end

% Form basic effects group (all products of them), omitting 0th and 1st
% order effects, as well as other effects depending on the required
% resolution.
indexbe = (3:2^k-1)';
indexbitcount = bitcount(indexbe);
minbitcount = resneeded-1;
indexbe(indexbitcount<minbitcount) = [];
basicgroup = zeros(numel(indexbe),1);
for j=1:k
    basicgroup = bitset(basicgroup,basic(j),bitget(indexbe,j));
end
basicgroup(ismember(basicgroup,effects)) = [];
addedterms = model(:,added);

% The rest of this step does not appear in the F&B paper.  First, determine
% if the model is symmetric.  Then we will reduce our search by requiring
% the row numbers in cursel to be decreasing, since we don't need to
% consider permutations of the cursel vectors we've already examined.
mainonly = all(sum(addedterms,1)==1);
symmetric = mainonly && all(sum(addedterms,2)<=1);

% We don't need to form all identities if we need just resolution 3 and
% there are no added term interactions
skipidcheck = (resneeded<=3 && symmetric);
if ~skipidcheck && resneeded==4 && m>10 && mainonly
    % If m is large, try a trick to avoid allocating a big array.  If we
    % restrict the basic group to values with bit counts that are all even
    % or all odd, we insure resolution 4 without having to create the
    % identity relations, so long as there are no interactions among the
    % added factors.
    t = mod(bitcount(basicgroup),2)==1;
    if sum(t)<length(t)/2
        t = ~t;
    end
    basicgroup = basicgroup(t);
    skipidcheck = true;
end
if ~skipidcheck
    identities = zeros(2^m-1,1); % current defining contrasts
    bitcounts = zeros(2^m-1,1);  % number of bits in each defining contrast
end

% Step 4.  Create table of eligible effects
table = zeros(numel(basicgroup),m);
for j=1:m
    table(:,j) = bitset(basicgroup,added(j),1);
end
table(ismember(table,ies)) = 0;
t = all(table==0,2);
if any(t)
    table(t,:) = [];
end
nrows = size(table,1);

% Step 5.  Initialize for search through table
cursel = zeros(1,m);             % current selection of generators from table
col = 0;                         % current column
fwd = true;                      % moving forward through columns
resfound = 0;                    % best resolution found so far
gens = cell(n,1);                % generators
tablebc = bitcount(table);       % length of each potential generator

% Step 6.  Move to next column
while(doall || resfound<resneeded)
    if fwd
        col = col+1;
        if symmetric && col>1 && ~doall
            cursel(col) = max(1, min(cursel(1:col-1)));
        else
            cursel(col) = nrows+1;
        end
    else
        col = col-1;
        fwd = true;
    end
    nident = 2^(col-1) - 1;
    while cursel(col)>1 && (doall || resfound<resneeded)

        % Step 7.  Select the next available effect in this column
        cursel(col) = cursel(col)-1;
        if dispopt>=2
            idx = sub2ind(size(table),cursel(1:col),1:col);
            disp(showterms(table(idx)));
        end
        if any(cursel(1:col-1) == cursel(col))
            continue   % already selected
        end
        if ~doall && tablebc(cursel(col),col) <= resfound-1
            continue   % no better than generators already found
        end
        gen = table(cursel(col),col);
        if gen==0
            continue   % not eligible
        end

        % Step 8.  Make sure product of this with identities is eligible
        if ~skipidcheck
            identities(nident+1) = gen;
            for j=1:nident
                identities(nident+j+1) = bitxor(identities(j),gen);
            end
            newrows = nident + (1:nident+1);
            bitcounts(newrows) = bitcount(identities(newrows));
            if ~doall && min(bitcounts(newrows))<=resfound
                continue
            end
            if any(ismember(identities(nident+(1:nident+1)),ies))
                continue
            end
        end

        % Step 9.  Extend the defining contrasts group
        if col==m
            if ~skipidcheck
                resfound = min(bitcounts);
            else
                resfound = resneeded;
            end
            gens(basic) = cellstr(alpha(basic)');
            for j=1:length(added)
                gens{added(j)} = showterms(bitset(table(cursel(j),j),added(j),0));
            end

            if dispopt
                 fprintf(1,'res %d, ',resfound);
                fprintf(1,'    ');
                for j=1:n
                    fprintf(1,'%s ',gens{j});
                end
                fprintf(1,'\n');
            end
            
            % May need to back up to beat the best resolution so far
            if ~doall && ~skipidcheck
                % Find the first col that fails to improve upon our best
                % design so far.  If the current design is already
                % adequate, we won't actually back up
                firstbad = find(bitcounts<=resfound,1,'first');
                badcol = 1 + ceil(sqrt(2*firstbad+.25) - .5 - 100*eps);
                if badcol<col
                    col = badcol;
                    fwd = false;
                    break
                end
            end
        else
            break
        end
    end

    if cursel(col) > 1
        continue
    end

    % Step 10.  Back to earlier column
    if col==1
        break
    end
    fwd = false;
end

if resfound==0
    error('stats:fracfactgen:NoDesign',...
          'No design with %d runs found to fit specified model.', 2^k);
elseif resfound<resneeded
    warning('stats:fracfactgen:LowResolution',...
            ['Failed to find a design of resolution %d,\n' ...
             'returning generators for a resolution %d design.'],...
            resneeded,resfound);
end

% ----------------------
function t=showterms(v)
% Represent terms in vector v as a character string
alpha = 'a':'z';
t = '';
for i=1:length(v)
    t = [t ' '];
    vi = v(i);
    j = 1;
    if vi==0
        t = [t '1'];
    else
        while(vi)
            if bitget(vi,j)
                t = [t alpha(j)];
                vi = bitset(vi,j,0);
            end
            j = j+1;
        end
    end
end
t = t(2:end);

% -----------------------
function c = bitcount(v)
% Count the number of bits set in each element of v
c = zeros(size(v));
t = find(v~=0);
j = 1;
while(~isempty(t))
    mask = bitget(v(t),j)==1;
    c(t(mask)) = c(t(mask))+1;
    v(t) = bitset(v(t),j,0);
    t = t(v(t)~=0);
    j = j+1;
end