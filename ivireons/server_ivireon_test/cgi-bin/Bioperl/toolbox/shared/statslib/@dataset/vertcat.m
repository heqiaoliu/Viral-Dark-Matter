function a = vertcat(varargin)
%VERTCAT Vertical concatenation for dataset arrays.
%   DS = VERTCAT(DS1, DS2, ...) vertically concatenates the dataset arrays
%   DS1, DS2, ... .  Observation names, when present, must be unique across
%   datasets.  VERTCAT fills in default observation names for the output when
%   some of the inputs have names and some do not.
%
%   Variable names for all dataset arrays must be identical except for order.
%   VERTCAT concatenates by matching variable names.  VERTCAT assigns values
%   for the "per-variable" properties (e.g., Units and VarDescription) in DS
%   from the corresponding property values in DS1.
%
%   See also DATASET/CAT, DATASET/HORZCAT.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2009/10/10 20:11:01 $

b = varargin{1};
if isequal(b,[]) % accept this as a valid "identity element"
    b = dataset;
elseif ~isa(b,'dataset')
    error('stats:dataset:vertcat:InvalidInput', ...
          'All input arguments must be datasets.');
end
a = b;
[a_varnames,a_varord] = sort(b.varnames);
for i = 2:nargin
    b = varargin{i};
    if isequal(b,[]) % accept this as a valid "identity element"
        b = dataset;
    elseif ~isa(b,'dataset')
        error('stats:dataset:vertcat:InvalidInput', ...
              'All input arguments must be datasets.');
    end
    
    % some special cases to mimic built-in behavior
    if a.nvars==0 && a.nobs==0
        a = b;
        [a_varnames,a_varord] = sort(b.varnames);
        continue;
    elseif b.nvars==0 && b.nobs==0
        % do nothing
        continue;
    elseif a.nvars ~= b.nvars
        error('stats:dataset:vertcat:SizeMismatch', ...
              'All datasets in the bracketed expression must have the same number of variables.');
    end
    
    [b_varnames,b_varord] = sort(b.varnames);
    if ~all(strcmp(a_varnames,b_varnames))
        error('stats:dataset:vertcat:UnequalVarNames', ...
              'All datasets in the bracketed expression must have the same variable names.');
    end
    
    if ~isempty(a.obsnames) && ~isempty(b.obsnames)
        if checkduplicatenames(b.obsnames,a.obsnames)
            error('stats:dataset:vertcat:DuplicateObsnames', ...
                  'Duplicate observation names.');
        end
        a.obsnames = vertcat(a.obsnames, b.obsnames);
    elseif ~isempty(b.obsnames) % && isempty(a.obsnames)
        a.obsnames = vertcat(strcat({'Obs'},num2str((1:a.nobs)','%d')), b.obsnames);
        a.obsnames = genuniquenames(a.obsnames,a.nobs+1);
    elseif ~isempty(a.obsnames) % && isempty(b.obsnames)
        a.obsnames = vertcat(a.obsnames, strcat({'Obs'},num2str(a.nobs+(1:b.nobs)','%d')));
        a.obsnames = genuniquenames(a.obsnames,a.nobs+1);
    end

    b_reord(a_varord) = b_varord;
    a.nobs = a.nobs + b.nobs;
    for i = 1:a.nvars
        % Prevent concatenation of a cell variable with a non-cell variable, which
        % would add only a single cell to the former, containing the latter.
        if iscell(a.data{i}) && ~iscell(b.data{b_reord(i)})
            error('stats:dataset:vertcat:VertcatCellAndNonCell', ...
                  ['Cannot concatenate the dataset variable ''%s'' because it is a cell in ' ...
                   'one dataset array and a non-cell in another.'],a.varnames{i});
        end
        try
            a.data{i} = vertcat(a.data{i}, b.data{b_reord(i)});
        catch ME
            throw(addCause(MException('stats:dataset:vertcat:VertcatMethodFailed', ...
                  'Could not concatenate the dataset variable ''%s'' using VERTCAT.',a.varnames{i}),ME));
        end
        % Something is badly wrong with whatever vertcat method has been called.
        if size(a.data{i},1) ~= a.nobs
            error('stats:dataset:vertcat:VertcatWrongLength', ...
                  ['Concatenating the dataset variable ''%s'' using VERTCAT resulted in ' ...
                   'a variable of the wrong length.'],a.varnames{i});
        end
    end
end

