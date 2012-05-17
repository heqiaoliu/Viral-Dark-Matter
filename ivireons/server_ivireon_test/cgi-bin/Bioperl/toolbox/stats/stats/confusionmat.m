function [cm,gn] = confusionmat(g,ghat,varargin)
% CONFUSIONMAT Confusion matrix for classification algorithms.
%    CM = CONFUSIONMAT(G,GHAT) returns the confusion matrix CM determined
%    by the known group labels G and the predicted group labels GHAT. G and
%    GHAT are grouping variables with the same number of observations. G
%    and GHAT can be categorical, numeric, or logical vectors;
%    single-column cell arrays of strings; or character matrices (each row
%    representing a group label). G and GHAT must be of the same type. CM
%    is a square matrix with size equal to the total number of distinct
%    elements in G and GHAT. CM(I,J) represents the count of instances
%    whose known group labels are group I and whose predicted group labels
%    are group J. CONFUSIONMAT treats NaNs, empty strings or 'undefined'
%    values in G or GHAT as missing values, and the corresponding
%    observations are not counted.
%
%    The sets of groups and the orders of group labels in rows and
%    columns of CM are the same. They include all the groups appearing in
%    GN, and have the same order of group labels as GN, where GN is the
%    second of output of grp2idx([G;GHAT]).
%
%    CM = CONFUSIONMAT(G,GHAT,'ORDER',ORDER) returns the confusion matrix
%    with the order of rows (and columns) specified by ORDER.  ORDER is a
%    vector containing group labels and whose values can be compared to
%    those in G or GHAT using the equality operator. ORDER must contain all
%    the labels appearing in G or GHAT. ORDER can contain labels which do
%    not appear in G and GHAT, and hence CM will have zeros in the
%    corresponding rows and columns.
%
%    [CM, GORDER] = CONFUSIONMAT(G, GHAT) returns the order of group labels
%    for rows and columns of CM. GORDER has the same type as G and GHAT.
%
%   Example:
%      % Compute the resubstitution confusion matrix for applying CLASSIFY
%      % on Fisher iris data.
%      load fisheriris
%      x = meas;
%      y = species;
%      yhat = classify(x,x,y);
%      [cm,order] = confusionmat(y,yhat);
%
%   See also CROSSTAB, GRP2IDX.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:58 $

if nargin < 2
    error('stats:confusionmat:NotEnoughInputs',...
        'At least two inputs are required.');
end

gClass = class(g);
if ~strcmp(gClass,class(ghat))
    error('stats:confusionmat:GTypeMismatch',...
        'G and GHAT need to be the same type.');
end

if ~isnumeric(g) && ~islogical(g) && ~isa(g,'categorical') ...
        && ~iscellstr(g)  && ~ischar(g)
    error('stats:confusionmat:GTypeIncorrect',...
        ['G and GHAT can only be a categorical, numeric, or logical vector;'...
        ' a cell vector of strings; or a character matrix.']);
end

if ischar(g)
    if ndims(g) > 2 || ndims(ghat) > 2
        error('stats:confusionmat:BadGroup', ...
            'G and GHAT must be 2D if they are character arrays.');
    end
    g = cellstr(g);
    ghat = cellstr(ghat);
elseif ~isvector(g) || ~isvector(ghat) 
    error('stats:confusionmat:BadGroup',...
        'G and GHAT need to be vectors or 2D character arrays.');
else
    g = g(:);
    ghat = ghat(:);
end


if size(g,1) ~= size(ghat,1)
    error('stats:confusionmat:GRowNumMismatch',...
        'G and GHAT need to have same number of rows');
end

if isa(g,'ordinal')
    if ~isequal(getlabels(g),getlabels(ghat))
        error('stats:confusionmat:GOrdinalLevelsMismatch',...
            'The levels and their orderings of G and GHAT must be the same.');
    end
end

pnames = {'order'};
dflts =  {[]};
[eid,errmsg, order] = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:confusionmat:%s',eid),errmsg);
end

if ~isempty(order)
    if ischar(order)
        if ndims(order) > 2
            error('stats:confusionmat:NDCharArrayORDER', ...
                'ORDER must be 2D if it is a character array.');
        end
        order = cellstr(order);
    elseif ~isvector(order)
        error('stats:confusionmat:NonVectorORDER', ...
            'ORDER must be a vector or a 2D array of character.');
    end

    if isa(g,'categorical')
        if iscellstr(order)
            if any(strcmp('',strtrim(order)))
                error('stats:confusionmat:OrderHasEmptyString',...
                    'ORDER can''t have empty strings.');
            end
        elseif isa(order,'categorical')
            if any(isundefined(order))
                error('stats:confusionmat:OrderHasUndefined',...
                    'ORDER can''t have undefined elements.');
            end
        end
        %turn off the warning for stats:categorical:categorical:ExtraLevels
        s = warning('off', 'stats:categorical:categorical:ExtraLevels');
        try
            if isa(g,'nominal')
                lastwarn('');
                g = nominal(g,{},order);
                [wmsg1, wid1] = lastwarn;
                lastwarn('');
                ghat = nominal(ghat,{},order);
                [wmsg2, wid2] = lastwarn;
            elseif isa(g,'ordinal')
                lastwarn('');
                g = ordinal(g,{},order);
                [wmsg1, wid1] = lastwarn;
                lastwarn('');
                ghat = ordinal(ghat,{},order);
                [wmsg2, wid2] = lastwarn;
            end
        catch ME
            warning(s);
            rethrow (ME);
        end
        % restore the previous state
        warning(s);
        if ~isempty(wmsg1)
            if strcmp(wid1, 'stats:categorical:categorical:ExtraLevels')
                error('stats:confusionmat:OrderInsufficientLabels', ...
                    'ORDER should contain all the labels appearing in G or GHAT.');
            end
        end

        if ~isempty(wmsg2)
            if strcmp(wid2, 'stats:categorical:categorical:ExtraLevels')
                error('stats:confusionmat:OrderInsufficientLabels', ...
                    'ORDER should contain all the labels appearing in G or GHAT.');
            end
        end
    else % g is not categorical vector

        if isnumeric(g)
            if ~isnumeric(order)
                error('stats:confusionmat:TypeMismatchOrder', ...
                    'ORDER must be the same class as G and GHAT..');
            end
            if any(isnan(order))
                error('stats:confusionmat:OrderHasNaN',...
                    'ORDER can''t have NaN values.');
            end

        elseif islogical(g)
            if islogical(order)
                %OK. do nothing
            elseif isnumeric(order)
                if any(isnan(order))
                    error('stats:confusionmat:OrderHasNaN',...
                        'ORDER can''t have NaN values.');
                end

                order = logical(order);
                
            else
                error('stats:confusionmat:TypeMismatchOrder', ...
                    'ORDER must be the same class as G and GHAT.');
            end

        elseif iscellstr(g)
            if ~iscellstr(order)
                error('stats:confusionmat:TypeMismatchLevels', ...
                    'ORDER should contain all the labels appearing in G or GHAT.');
            end
            if any(strcmp('',strtrim(order)))
                error('stats:confusionmat:OrderHasEmptyString',...
                    'ORDER can''t have empty strings.');
            end
        end

        try
            uorder = unique(order);
        catch ME
            error('stats:confusionmat:UniqueMethodFailedOrder', ...
                'ORDER must have a UNIQUE method.');
        end

        if length(uorder) < length(order)
            error('stats:confusionmat:DuplicatedOrder', ...
                'ORDER can''t contain duplicated values.');
        end

        order = order(:);
    end
end

gLen = size(g,1);
[idx,gn] =grp2idx([g;ghat]);
gidx = idx(1:gLen);
ghatidx = idx(gLen+1:gLen*2);

%ignore NaN values in GIDX and GHATIDX
nanrows = isnan(gidx) | isnan(ghatidx);
if any(nanrows)
    gidx(nanrows) = [];
    ghatidx(nanrows) = [];
end

gLen = size(gidx,1);
gnLen =length(gn);

cm = accumarray([gidx,ghatidx], ones(gLen,1),[gnLen, gnLen]);

%convert gn to the same type as g
if isnumeric(g)
    gn = str2num(char(gn));
else
    switch gClass
        case 'nominal'
            gn = nominal(gn);
        case 'ordinal'
            gn = ordinal(gn);
        case 'logical'
            gn = logical(str2num(char(gn)));
    end
end

if ~isempty(order)
    %get the map from the default order to the given order
    [hasAllLabel,map] = ismember(gn,order);

    if ~isa(g,'categorical')
        if ~all(hasAllLabel)
            error('stats:confusionmat:OrderInsufficientLabels', ...
                'ORDER should contain all the labels appearing in G or GHAT.');
        end
        orderLen = length(order);
        cm2 = zeros(orderLen, orderLen);
        cm2(map,map) = cm(:,:);
        cm = cm2;
    end

    if nargout > 1
        gn = order;
        % convert gn to categorical if g is categorical
        if isa(g,'nominal')
            gn = nominal(gn);
            gn = gn(:);
        elseif isa(g, 'ordinal')
            gn = ordinal(gn);
            gn = gn(:);
        elseif strcmp(gClass,'char')
            gn = char(gn);
        end
    end
elseif strcmp(gClass,'char')
    gn = char(gn);
end



