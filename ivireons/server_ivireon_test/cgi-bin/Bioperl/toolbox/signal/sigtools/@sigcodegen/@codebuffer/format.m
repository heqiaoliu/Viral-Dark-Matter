function code = format(this, code, spacetoken, extraspace)
%FORMAT Format the code by wrapping it.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 08:16:53 $

% If Wrap is turned off there is nothing to format.
if strcmpi(this.Wrap, 'Off'), return; end

if nargin < 4, extraspace = 0; end
if nargin < 3, spacetoken = getdefaultspacetoken(this); end

if iscell(code)
    indx = 1;
    while indx <= length(code),
        if ~ischar(code{indx})
            code(indx) = [];
        else
            indx = indx + 1;
        end
    end
    
    for indx = 1:length(code)
        code{indx} = this.format(code{indx}, spacetoken, extraspace);
    end
elseif ~ischar(code)
    code = [];
else
    
    cdx   = findcommentindex(this, code);
    width = this.MaxWidth;
    
    if isempty(cdx),
        comment = [];
    elseif cdx == 1,
        comment = code;
        code = [];
    else
        idx = regexp(code(1:cdx-1), '[^ ]');
        if max(idx) < cdx, cdx = max(idx); end
        
        comment = code(cdx:end);
        code    = code(1:cdx-1);
    end
    
    cwc = getcodewrapchar(this);
    crit = getcodewrapcriteria(this);
    
    % Get the first spacingtoken index
    if ~iscell(spacetoken), spacetoken = {spacetoken}; end
    indx = 1; eqindx = [];
    while isempty(eqindx) && indx <= length(spacetoken),
        eqindx = min(findstr(code, spacetoken{indx}));
        if eqindx > width, eqindx = []; end
        indx = indx + 1;
    end
    if isempty(eqindx), eqindx = 0; end
    eqindx = eqindx + extraspace;
    
    eqspace = repmat(' ', 1, eqindx);
    
    code = {code};
    
    indx = 1;
    while indx <= length(code),
        idx = strfind(code{indx}, char(10));
        if ~isempty(idx),
            code = [code(1:indx-1) {code{indx}(1:idx(1)-1) code{indx}(idx(1)+1:end)} code(indx+1:end)];
        end
        indx = indx + 1;
    end
    
    % Loop over the cell of strings, chop off the extra strings and move them
    % to the next value in the cell.
    while length(code{end}) > width,
        
        indx = regexp(code{end}, crit);
        
        indx = indx(find(indx > length(eqspace)));
        
        if min(indx) >= width-length(cwc),
            indx = min(indx);
        else
            indx = indx(find(indx < width-length(cwc)));
            
            % Find all of the quote characters
            quoteChar = getquotechar(this);
            quoteIndex = regexp(code{end}, ['[' quoteChar ']']);
            
            % Remove all of the indices that lie between the quote indices.
            % Start at 2 so that we ignore the odd ' character.
            for jndx = 1:2:length(quoteIndex)-1
                indx(and(indx > quoteIndex(jndx), indx < quoteIndex(jndx+1))) = [];
            end
                        
            indx = max(indx);
        end
        if isempty(indx), break; end

        % Remove leading spaces
        while strcmpi(code{end}(indx+1), ' '),
            code{end}(indx+1) = [];
        end
        
        % Make sure there is ONE space after the token.
        if strcmpi(code{end}(indx), ','),
            code{end} = [code{end}(1:indx) ' ' code{end}(indx+1:end)];
            indx = indx + 1;
        end
        
        code = {code{1:end-1}, ...
                sprintf('%s%s', code{end}(1:indx), cwc), ...
                sprintf('%s%s', eqspace, code{end}(indx+1:end))};
    end
    
    code{end} = [code{end} comment];
    
    cdx = findcommentindex(this, code{end});
    
    if ~isempty(cdx),
        
        % Find the first nonspace character after the comment.
        edx = regexp(code{end}(cdx+1:end), '^ ')+cdx;
        if isempty(edx), edx = 0; end
        
        cwc = getcommentwrapcriteria(this);
        cc  = getcommentchar(this);
        
        prespace  = repmat(' ', 1, cdx-1);
        postspace = repmat(' ', 1, edx-cdx);
        while length(code{end}) > width
            idx = regexp(code{end}(1:end), cwc);
            
            % Remove all indexes that come before the comment character
            idx(find(idx < edx + 1)) = [];
            
            % If the lowest index exceeds the width, use it anyway (we have no
            % choice).
            if min(idx) > width,
                idx = min(idx);
            else
                
                % Otherwise use the maximum index below the width.
                idx(find(idx>width)) = [];
                idx = max(idx);
            end
            
            % If none of the search criteria are found, we cannot divide
            % the comment.  Break out of the loop.
            if isempty(idx), break; end
            
            % If the index points to a space, we want to use the index
            % before it.  If its anything else, we will use it directly.
            if strcmpi(code{end}(idx), ' '), idx = idx-1; end
            
            code = {code{1:end-1}, ...
                    code{end}(1:idx), ...
                    sprintf('%s%s%s%s', prespace, cc, postspace, ...
                    fliplr(deblank(fliplr(code{end}(idx+1:end)))))};
        end
    end
end

code = this.string(code);

% -------------------------------------------------------------------------
function cdx = findcommentindex(this, c)

% Find the first comment
cdx = strfind(c, getcommentchar(this));

% If there is no comment, do nothing.
if isempty(cdx), return; end

% Get the quote character to determine which of the comment characters,
% if any, are inside quotations.  If they are we ignore them.
qdx = strfind(c, this.getquotechar);

% Go over every other quote because the 2nd will be a closing quote.
for indx = 1:2:length(qdx)-1
    
    % Remove any comment character that is inside of a quotation.
    cdx(find(double((cdx > qdx(indx))).*double((cdx < qdx(indx+1))))) = [];
end

% If there is no comment outside of the quotations, do nothing.
if isempty(cdx), return; end

cdx = min(cdx);

% [EOF]
