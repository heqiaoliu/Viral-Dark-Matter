function objs = createObjectsFromProxies(proxies, constructor, parent, search)
; %#ok Undocumented
% This function is used to create a UDD wrapper around a java proxy object
% using the supplied UDD constructor function. To maintain the relevant
% data structure the parent of the UDD object must also be supplied so that
% the correct connectedness can be maintained.

% Copyright 2004-2008 The MathWorks, Inc.


% The default search type is to look in the root hashtable for pre-existing
% UDD wrappers for these objects. If, however, it is known that these are
% new proxies (for example from createTask or createJob) then we can safely
% ignore the search.
if nargin < 4
    search = 'rootsearch';
end

SINGLETON_CONSTRUCTOR = isa(constructor, 'function_handle');

root = distcomp.getdistcompobjectroot;

% The two types of search are : 
% searchroot : which tries to find the objects in the hash table and then
% return the relevant UDD object
% norootsearch
switch lower(search)
    case 'rootsearch'
        [found, objs] = root.findObjectInHashtable(proxies);
    case 'norootsearch'
        found = false(numel(proxies), 1);
        objs = handle(-ones(numel(proxies), 1));
    otherwise        
        error('distcomp:objectroot:InvalidArgument', 'You must supply rootsearch or norootsearch as arguments to createObjectFromProxies');
end

indexToCreate = find(~found);

for i = indexToCreate(:)'    
    if SINGLETON_CONSTRUCTOR
        obj = constructor(proxies(i));
    else
        obj = constructor{i}(proxies(i));
    end
    parent.connect(obj, 'down');
    objs(i) = obj;
end

if any(~found)
    root.putObjectInHashtable(proxies(~found), objs(~found));
end

if any(found)
    objs(found).pUpdateProxyObject(proxies(found));
end
