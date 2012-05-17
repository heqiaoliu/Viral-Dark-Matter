function [gidx,gnames,glevels] = grp2idx(s)
% GRP2IDX  Create index vector from a grouping variable.
%   [G,GN] = GRP2IDX(S) creates an index vector G from the grouping variable
%   S. S can be a categorical, numeric, or logical vector; a cell vector of
%   strings; or a character matrix with each row representing a group label.
%   The result G is a vector taking integer values from 1 up to the number K
%   of distinct groups. GN is a cell array of strings representing group
%   labels. GN(G) reproduces S (aside from any differences in type).
%
%   Type "help groupingvariable" for more information about grouping
%   variables.
%
%   [G,GN,GL] = GRP2IDX(S) returns a column vector GL representing the
%   group levels. The set of groups and their order in GL and GN are the
%   same, except that GL has the same type as S. If S is a character
%   matrix, GL(G,:) reproduces S, otherwise GL(G) reproduces S.
%
%   GRP2IDX treats NaNs (numeric or logical), empty strings (char or cell
%   array of strings), or <undefined> values (categorical) in S as missing
%   values and returns NaNs in the corresponding rows of G. GN and GL don't
%   include entries for missing values.
%
%   See also GROUPINGVARIABLE, GRPSTATS, GSCATTER.

%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:32 $

charFlag = ischar(s);
if charFlag
    charWidth = size(s,2);
    if isempty(s)
        s = cell(0,1);
    else
        s = cellstr(s);
    end
end

if ~isvector(s)
    error('stats:grp2idx:BadGroup',...
          'Grouping variable must be a vector or a character array.');
end
s = s(:);

if isnumeric(s) || islogical(s)
    [glevels,dum,gidx] = unique(s,'first');
    
    % Handle NaN missing values: return NaN group indices
    if ~isempty(glevels) && isnan(glevels(end)) % NaNs are sorted to end
        glevels = glevels(~isnan(glevels));
        gidx(gidx > length(glevels)) = NaN;
    end
    if nargout > 1
        gnames = sprintfc('%g',full(glevels));
    end
    
elseif isa(s,'categorical')
    gidx = double(s); % converts <undefined> to NaN
    if nargout > 1
        gnames = getlabels(s)';
        glevels = getlevels(s)';
    end
    
elseif iscell(s)
    try
        [glevels,ord,gidx] = unique(s,'first');
    catch ME
        if isequal(ME.identifier,'MATLAB:CELL:UNIQUE:InputClass')
            error('stats:grp2idx:GroupTypeIncorrect',...
                  ['A grouping variable must be a categorical, numeric, or logical '....
                   'vector, a cell vector of strings, or a 2D character array.']);
        else
            rethrow(ME);
        end
    end
    
    % Get the "first seen" order of the levels
    [dum,reord] = sort(ord);
    ireord(reord) = 1:length(reord); ireord = ireord(:);
    
    % Handle empty string missing values: return NaN group indices
    if ~isempty(glevels) && strcmp('',glevels(1)) % '' is sorted to beginning
        reord(reord==1) = [];
        ireord = ireord - (ireord > ireord(1));
        ireord(1) = NaN;
    end
    
    % Put the levels back into "first seen" order
    gidx = ireord(gidx(:)); % force a col, even for 0x0
    if nargout > 1
        glevels = glevels(reord(:)); % force a col, even for 0x0
        gnames = glevels;
        if charFlag
            if isempty(s)
                glevels = char(zeros(0,charWidth));
            else
                glevels = char(glevels);
            end
        end
    end
    
else
    error('stats:grp2idx:GroupTypeIncorrect',...
          ['A grouping variable must be a categorical, numeric, or logical '....
           'vector, a cell vector of strings, or a 2D character array.']);
end
