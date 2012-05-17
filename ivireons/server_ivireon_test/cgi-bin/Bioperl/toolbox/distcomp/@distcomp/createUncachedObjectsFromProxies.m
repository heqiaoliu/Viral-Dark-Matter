function objs = createUncachedObjectsFromProxies(proxies, constructor, search)
; %#ok Undocumented
% This function is used to create a UDD wrapper around a java proxy object
% using the supplied UDD constructor function. Unlike
% createObjectsFromProxies this function does not connect the objects into
% the cached hierarchy if they do not already exist. It is up to the user of
% this function to ensure that if the objects were not previously cached
% then they are cached later.

% Copyright 2006-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/03/31 17:07:09 $ 


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
    objs(i) = obj;
end
