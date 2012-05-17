function b = dsgrpstats(a,groupvars,whichstats,varargin)
%GRPSTATS Summary statistics of dataset variables by group.
%   B = DSGRPSTATS(A,GROUPVARS) returns a dataset B that contains the mean,
%   computed by group, for variables in the dataset A.  GROUPVARS specifies
%   the grouping variables in A that define the groups, and is a positive
%   integer, a vector of positive integers, a variable name, a cell array
%   containing one or more variable names, or a logical vector.
%
%   A grouping variable may be a vector of categorical, logical, or numeric
%   values, a character array of strings, or a cell vector of strings. B
%   contains those grouping variables, plus one variable giving the number of
%   observations in A for each group, as well as one variable for each of the
%   remaining dataset variables in A.  These variables must be numeric or
%   logical.  B contains one observation for each group of observations in A.
%   GROUPVARS can be [] or omitted to compute the mean of each variable across
%   the entire dataset without grouping.
%
%   DSGRPSTATS treats NaNs as missing values, and removes them.
%
%   B = DSGRPSTATS(A,GROUPVARS,WHICHSTATS) returns a dataset with variables for
%   each of the statistics specified in WHICHSTATS applied to each of the
%   non-grouping variables in A.  WHICHSTATS can be a single function handle
%   or name, or a cell array containing multiple function handles or names.
%   The names can be chosen from among the following:
%  
%        'mean'     mean
%        'sem'      standard error of the mean
%        'numel'    count, or number of non-NaN elements
%        'gname'    group name
%        'std'      standard deviation
%        'var'      variance
%        'min'      minimum
%        'max'      maximum
%        'range'    maximum - minimum
%        'meanci'   95% confidence interval for the mean
%        'predci'   95% prediction interval for a new observation
%
%   Each function included in WHICHSTATS must accept a subset of the rows of a
%   dataset variable, and compute column-wise descriptive statistics for it.  A
%   function should typically return a value that has one row but is otherwise
%   the same size as its input data.  For example, @median and @skewness are
%   suitable functions to apply to a numeric dataset variable.  A function
%   must return the same size output each time GRPSTATS calls it, even if the
%   input for some groups is empty.
%
%   A summary statistic function may also return values with more than one row,
%   provided the return values have the same number of rows each time DSGRPSTATS
%   applies the function to different subsets of data from a given dataset
%   variable.  For a dataset variable that is NOBS-by-M-by-..., if a summary
%   statistic function returns values that are NVALS-by-M-by-..., then the
%   corresponding summary statistic variable in B is NGROUPS-by-M-by-...-by-NVALS,
%   where NGROUPS is the number of groups in A.
%
%   B = DSGRPSTATS(A,GROUPVARS,WHICHSTATS,...,'DataVars',DATAVARS) specifies the
%   variables in A to which the functions in WHICHSTATS should be applied. The
%   output datasets will contain one summary statistic variable for each of
%   these data variables.  DATAVARS is a positive integer, a vector of
%   positive integers, a variable name, a cell array containing one or more
%   variable names, or a logical vector.
%
%   B = DSGRPSTATS(A,GROUPVARS,WHICHSTATS,...,'VarNames',VARNAMES) specifies the
%   names of the variables in the output dataset.  By default, DSGRPSTATS uses
%   the names from A for the grouping variable names, and constructs names for
%   the summary statistic variables based on the function name and the data
%   variable names from A.  The number of variables in B is
%
%      NGROUPVARS + 1 + NDATAVARS*NFUNS
%
%   where NGROUPVARS is the number of variables specified in GROUPVARS,
%   NDATAVARS is the number of variables specified in DATAVARS, and NFUNS is
%   the number of summary statistics specified in WHICHSTATS.
%
%   See also DATASET/SORTROWS, GRPSTATS.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:29:34 $

[a_nobs,a_nvars] = size(a);
a_varnames = a.Properties.VarNames;
a_data = getvars(a);
a_props_Units = a.Properties.Units;

% Create a cell array of grouping variables, then let mgrp2idx define the
% group and group memberships.
if nargin < 2 || isempty(groupvars)
    groupvars = [];
    group = ones(a_nobs,1);
    glabel = {'All'};
else
    groupvars = getvarindices(a,groupvars,false);
    [group,glabel,groupname] = mgrp2idx(a_data(groupvars),a_nobs);
end

if nargin < 3 || isempty(whichstats)
    whichstats = {};
end

pnames = {'datavars' 'varnames','alpha'};
dflts =  {        []         {}     .05};
[eid,errmsg,datavars,varnames,alpha] ...
                   = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:dataset:grpstats:%s',eid),errmsg);
end

if isempty(whichstats)
    whichstats = {@mean};
elseif ~iscell(whichstats)
    whichstats = {whichstats};
end

% Convert keywords to function handles
gnameStat = false;
nfuns = numel(whichstats);
funNames = cell(1,nfuns);
for j = 1:nfuns
    hfun = whichstats{j};
    
    funNames{j} = char(hfun);
    % Anonymous/nested functions lead to unusable function names, use a default
    if ~isvarname(funNames{j}), funNames{j} = ['Fun' num2str(j,'%d')]; end
    
    if ischar(hfun)
        if size(hfun,1)~=1
            error('stats:dataset:grpstats:InvalidWhichStats', ...
                  'WHICHSTATS must be a function handle or name, or a cell array of function handles or names.');
        end
        
        switch(hfun)
        case 'mean',  hfun = @(x) mean(x,1);
        case 'sem',   hfun = @(x) std(x,0,1) / sqrt(size(x,1));
        case 'std',   hfun = @(x) std(x,0,1);
        case 'var',   hfun = @(x) var(x,0,1);
        case 'min',   hfun = @(x) empty2NaN(min(x,[],1));
        case 'max',   hfun = @(x) empty2NaN(max(x,[],1));
        case 'range', hfun = @(x) empty2NaN(range(x,1));
        case 'meanci',hfun = @meanci;
        case 'predci',hfun = @predci;
        case 'numel', hfun = @(x) size(x,1);
        case 'gname', gnameLocs = j; % locations in whichstats with 'gname'
                      gnameStat = true;
        otherwise, hfun = str2func(hfun);
        end
        whichstats{j} = hfun;
    elseif ~(isscalar(hfun) && isa(hfun,'function_handle'))
        error('stats:dataset:grpstats:InvalidWhichStats', ...
              'WHICHSTATS must be a function handle or name, or a cell array of function handles or names.');
    end
end

% 'gname' is provided to be consistent with the grpstats function, but is of
% less use for the dataset method.  Don't completely ignore it, but treat it
% specially -- only one instance, not per datavar.
if gnameStat
    nfuns = nfuns - length(gnameLocs);
    whichstats(gnameLocs) = [];
    funNames(gnameLocs) = [];
end

makeVarnames = isempty(varnames);

% Use "everything else" if no data variables specified, or use the specified
% ones.
if isempty(datavars)
    if isempty(groupvars)
        datavars = 1:a_nvars;
    else
        datavars = setdiff(1:a_nvars,groupvars);
    end
else
    datavars = getvarindices(a,datavars,false);
end

% Get the first observation in each group, and build a dataset from those,
% consisting of the grouping variables, one count variable, and some space for
% the statistics computed from the data variables.
ngroups = length(glabel);
ngroupvars = length(groupvars);
if gnameStat
    nsummvars = 2;
    gnamevarPosn = ngroupvars + 1;
    countvarPosn = ngroupvars + 2;
    summvarNames = {'gname' 'GroupCount'};
else
    nsummvars = 1;
    countvarPosn = ngroupvars + 1;
    summvarNames = {'GroupCount'};
end
ndatavars = length(datavars);
% these are the var positions in the output for the first datavar, all funs
datavarPosns = countvarPosn + (1:nfuns);
%b = dataset;
b_data = [a_data(groupvars) cell(1,nsummvars+nfuns*ndatavars)];
b_nvars = ngroupvars + nsummvars + nfuns*ndatavars;
b_varnames = [a_varnames(groupvars) summvarNames repmat({''},1,nfuns*ndatavars)];
if ~isempty(a_props_Units)
    b_props_Units = [a_props_Units(groupvars) repmat({''},1,nsummvars+nfuns*ndatavars)];
end
[~,firsts] = unique(group,'first');
firsts = firsts(1:ngroups); % trim off any NaNs from missing data in the grouping variables
b_nobs = length(firsts);
for j = 1:ngroupvars
    var_j = b_data{j};
    szOut = size(var_j); szOut(1) = b_nobs;
    b_data{j} = reshape(var_j(firsts,:),szOut);
end
% Set up observation names for the output dataset based on the groups.
b_obsnames = strrep(glabel,sprintf('\n'),'_');

if gnameStat
    b_data{gnamevarPosn} = groupname; % an ngroups-by-ngroupvars cell array of strings
end

if makeVarnames
    % If no var names were specified, start out with the partially filled-in
    % names from b, then fill in for each var/fun combination.
    varnames = b_varnames;
    for j = 1:ndatavars
        jb = datavarPosns + (j-1)*nfuns;
        varnames(jb) = genvarname(strcat(funNames,{'_'},a_varnames(datavars(j))));
    end
end

% Apply each function to an entire matrix, or column-by-column?
applyToMatrix = true(nfuns,ndatavars);

% Need to keep track of the size we expect from the values computed by the fun
% on each data variable.
valSizes = cell(nfuns,ndatavars);

% Process each function for each data variable, by group
for i = 1:max(ngroups,1)  % at least once
    if ngroups > 0
        ib = i;
        mbrs = find(group==i);
        gnameErrtext = sprintf('for group %s ',b_obsnames{i});
    else
        % We need to go through the data vars and functions just to get the
        % correct widths of the output vars.
        ib = [];
        mbrs = [];
        gnameErrtext = '';
    end
    if i == 1  % first group
        b_data{countvarPosn} = repmat(length(mbrs),ngroups,1);
    else
        b_data{countvarPosn}(ib) = length(mbrs);
    end

    % Compute the statistic in this group for each data variable.
    for j = 1:ndatavars
        ja = datavars(j);
        jb = datavarPosns + (j-1)*nfuns;
        szIn = size(a_data{ja}); szIn(1) = length(mbrs);
        var_ij = reshape(a_data{ja}(mbrs,:), szIn);
        sz_ij = size(var_ij);
        
        % Apply each function column-by-column if any missing values
        if i == 1  % first time through for this var
            if ~(isnumeric(var_ij) || islogical(var_ij))
                error('stats:dataset:grpstats:BadData', 'Data variables must numeric or logical.');
            end
            applyToMatrix(:,j) = ~any(isnan(var_ij(:)));
        end
        
        for stat = 1:nfuns
            fun = whichstats{stat};
            
            if applyToMatrix(stat,j)
                try
                    val_ij = fun(var_ij);
                catch ME
                    if i == 1  % first time through for this var/stat
                        applyToMatrix(stat,j) = false;
                    else
                        error('stats:dataset:grptats:FunFailed', ...
                              ['The function ''%s'' returned the following error when evaluating data ' ...
                               '%sin dataset variable ''%s'':\n\n%s'], ...
                               char(fun),gnameErrtext,a_varnames{datavars(j)},ME.message);
                    end
                end
            end
            if applyToMatrix(stat,j)
                szOut = size(val_ij);
                if i == 1  % first time through for this var/stat
                    if isequal(szOut(2:end),sz_ij(2:end));
                        valSizes{stat,j} = szOut;
                    else
                        applyToMatrix(stat,j) = false;
                    end
                elseif ~isequal(szOut,valSizes{stat,j})
                    error('stats:dataset:grpstats:InvalidFunOutputSize', ...
                          ['The function ''%s'' returned a result of size [%s] when evaluating data ' ...
                           '%sin dataset variable ''%s'', expected size [%s].'], ...
                           char(fun),num2str(szOut),gnameErrtext,a_varnames{datavars(j)},num2str(valSizes{stat,j}));
                end
            end
            
            if ~applyToMatrix(stat,j)
                for k = 1:prod(sz_ij(2:end))
                    var_ijk = var_ij(:,k);
                    try
                        val_ijk = fun(var_ijk(~isnan(var_ijk)));
                    catch ME
                        error('stats:dataset:grptats:FunFailed', ...
                              ['The function ''%s'' returned the following error when evaluating data ' ...
                               '%sin dataset variable ''%s'':\n\n%s'], ...
                               char(fun),gnameErrtext,a_varnames{datavars(j)},ME.message);
                    end
                    szOut = size(val_ijk);
                    if k == 1
                        val_ij = repmat(val_ijk,[1,sz_ij(2:end)]);
                        if i == 1  % first time through for this var/stat
                            if isvector(val_ijk) && (szOut(2) == 1);
                                valSizes{stat,j} = szOut;
                            else
                                error('stats:dataset:grpstats:InvalidFunOutputSize', ...
                                      ['The function ''%s'' returned a result of size [%s] when evaluating data ' ...
                                       '%sin dataset variable ''%s'', expected a scalar or column vector.'], ...
                                       char(fun),num2str(szOut),gnameErrtext,a_varnames{datavars(j)});
                            end
                        end
                    elseif isequal(szOut,valSizes{stat,j})
                        val_ij(:,k) = val_ijk;
                    else
                        error('stats:dataset:grpstats:InvalidFunOutputSize', ...
                              ['The function ''%s'' returned a result of size [%s] when evaluating data ' ...
                               '%sin dataset variable ''%s'', expected size [%s].'], ...
                               char(fun),num2str(szOut),gnameErrtext,a_varnames{datavars(j)},num2str(valSizes{stat,j}));
                    end
                end
            end
            
            % Move "multiple values" to trailing dimension
            szOut = size(val_ij);
            if szOut(1) > 1
                val_ij = permuteToTrailing(val_ij,size(val_ij));
            end
            
            if i == 1  % first time through for this var/stat
                b_data{jb(stat)} = repmat(val_ij,[ngroups,1]);
            else
                b_data{jb(stat)}(ib,:) = val_ij(:);
            end
        end % stat = 1:nfuns
    end  % j = 1:ndatavars
end % i = 1:ngroups

% Set the output var names, making sure no duplicates.
b = dataset(b_data{:},'varnames',varnames,'obsnames',b_obsnames);
%b = setvarnames(b,varnames);
if ~isempty(a_props_Units)
    b.Properties.Units = b_props_Units;
end



% Nested functions below here; they use alpha from caller
    % ----------------------------
    function ci = meanci(y)
    n = size(y,1);
    m = mean(y,1);
    s = std(y,0,1) ./ sqrt(n);
    d = s .* -tinv(alpha/2, max(0,n-1));
    ci = [m-d;m+d];
    end

    % ----------------------------
    function ci = predci(y)
    n = size(y,1);
    m = mean(y,1);
    s = std(y,0,1) .* sqrt(1 + 1./n);
    d = s .* -tinv(alpha/2, max(0,n-1));
    ci = [m-d;m+d];
    end

    % ----------------------------
    function m = empty2NaN(m) % convert 0xm empty to NaN(1,m)
    if size(m,1) == 0
        m = NaN(1,size(m,2));
    end
    end
end

% -----------------------------------------
% Permute the row dimension to the end
function val = permuteToTrailing(val,sz)
if prod(sz(2:end)) == 1
    % transpose a column vector
    val = val';
else
    % or do a genuine permute for a matrix or N-D array
    d = ndims(val);
    val = permute(val,[d+1 2:d 1]);
end
end


function varIndices = getvarindices(a,varIndices,~)
if islogical(varIndices)
    varIndices = find(varIndices);
elseif ischar(varIndices) || iscellstr(varIndices)
    if ischar(varIndices)
        varNames = cellstr(varIndices);
    else
        varNames = varIndices;
    end
    [~,varIndices] = ismember(varNames,get(a,'VarNames'));
    if any(varIndices==0)
        j = find(varIndices==0,1,'first');
        error('stats:dataset:getvarindices:UnrecognizedVarName', ...
              'Unrecognized variable name ''%s''.',varNames{j});
    end
%     varIndices = zeros(1,numel(varNames));
%     for j = 1:numel(varIndices)
%         varIndex = find(strcmp(varNames{j},get(a,'VarNames')));
%         if isempty(varIndex)
%             error('stats:dataset:getvarindices:UnrecognizedVarName', ...
%                   'Unrecognized variable name ''%s''.',varNames{j});
%         end
%         varIndices(j) = varIndex;
%     end
end
end

function vars = getvars(a)
names = a.Properties.VarNames;
vars = cell(1,length(names));
for i = 1:length(vars)
    vars{i} = a.(names{i});
end
end
