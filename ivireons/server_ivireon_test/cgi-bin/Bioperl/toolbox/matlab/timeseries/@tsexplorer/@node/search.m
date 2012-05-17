function node = search(h,pathspec)

% Copyright 2005-2008 The MathWorks, Inc.

%% Use a string or a cellarray based path to search the tree

%% Parsesing based paths to cell arrays
if ischar(pathspec)
    ind = strfind(pathspec,'/');
    if isempty(ind)
        pathspec = {pathspec};
    else
        cellpathspec = cell(length(ind)+1,1);
        cellpathspec{1} = pathspec(1:ind(1)-1);
        for k=1:length(ind)-1
            cellpathspec{k+1} = pathspec(ind(k)+1:ind(k+1)-1);
        end
        cellpathspec{end} = pathspec(ind(end)+1:end);
        pathspec = cellpathspec;
    end
end
  
%% Get child node
child = h.find('label',pathspec{1},'-depth',1);

%% Recursively call the search method on the children
if isempty(child)
    node = [];
elseif length(pathspec) == 1
    node = child;
else
    node = child.search(pathspec(2:end));
end
