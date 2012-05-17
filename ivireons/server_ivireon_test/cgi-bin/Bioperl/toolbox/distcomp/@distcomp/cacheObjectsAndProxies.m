function cacheObjectsAndProxies(objs, proxies, parent, search)
; %#ok Undocumented
% This function is used to add UDD objects to the cacheing tree under the
% objected parent

% Copyright 2004-2008 The MathWorks, Inc.


% The default search type is to look in the root hashtable for pre-existing
% UDD wrappers for these objects. If, however, it is known that these are
% new proxies (for example from createTask or createJob) then we can safely
% ignore the search.
if nargin < 4
    search = 'rootsearch';
end

root = distcomp.getdistcompobjectroot;

% The two types of search are : 
% searchroot : which tries to find the objects in the hash table and then
% return the relevant UDD object
% norootsearch
switch lower(search)
    case 'rootsearch'
        found = root.findObjectInHashtable(proxies);
    case 'norootsearch'
        found = false(numel(proxies), 1);
    otherwise        
        error('distcomp:objectroot:InvalidArgument', 'You must supply rootsearch or norootsearch as arguments to createObjectFromProxies');
end

indexToCreate = find(~found);

for i = indexToCreate(:)'    
    parent.connect(objs(i), 'down');
end

if any(~found)
    root.putObjectInHashtable(proxies(~found), objs(~found));
end
