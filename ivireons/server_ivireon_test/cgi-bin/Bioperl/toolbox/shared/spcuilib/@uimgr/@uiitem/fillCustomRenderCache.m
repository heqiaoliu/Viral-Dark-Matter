function fillCustomRenderCache(h)
%fillCustomRenderCache Cache custom widget properties
%  during widget unrender, to be restored after rendering.
%
% The typical situation is to set the property cache list,
% and leave the render cache alone (gets managed automatically)
% That is,
%    .CustomPropertyCacheList = {'param1','param2',...}
%
% .CustomRenderCache is not set by user; it is filled during
% unrender with these property names and corresponding values.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/04/27 19:55:07 $

% Custom list of widget properties to cache,
% above and beyond those defined in fillRenderCache
% overload (which usually just caches StateName)

theProps = h.CustomPropertyCacheList;
pv_pairs = {};
if ~isempty(theProps)  % test done just for efficiency
    theWidget = h.hWidget;
    for i = 1:numel(theProps)
        p_i = theProps{i};
        if isprop(theWidget,p_i)
            pv_pairs = [pv_pairs {p_i, theWidget.(p_i)}]; %#ok
        end
    end

end
% Empty the cache
h.CustomRenderCache = pv_pairs;

% [EOF]
