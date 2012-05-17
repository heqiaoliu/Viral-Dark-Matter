function tsList = getts(h,pathlist)

% Copyright 2004-2005 The MathWorks, Inc.

%% Returns a list of the @timeseries stored in the viewer. The second 
%% argument is a cell array of paths, which restricts the @timeseries
%% returned to those timeseries conforming to the specified paths.

tsList = {};
if iscell(pathlist)
    for k=1:length(pathlist)
        tsnode = h.search(pathlist{k});
        if ~isempty(tsnode) && isa(tsnode(1),'tsguis.tsnode')
            tsList = [tsList; {tsnode(1).Timeseries}];
        end
    end
elseif ischar(pathlist)
    tsnode = h.search(pathlist);
    if ~isempty(tsnode) && isa(tsnode(1),'tsguis.tsnode')
        tsList = {tsnode(1).Timeseries};
    end
end