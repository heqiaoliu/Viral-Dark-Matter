function [linkStr, name] = util_sf_link(obj)

%   Copyright 2010 The MathWorks, Inc.

    sfIsa = sldvshareprivate('util_sfisa');
        
    switch sf('get', obj,'.isa')
    case sfIsa.chart,
        name = sf('get', obj,'.name');
    case sfIsa.state,
        name = sf('get', obj,'.name');
    case sfIsa.transition
        name = sf('get', obj, '.labelString');
    case  sfIsa.data,
        name = sf('get', obj,'.name');
    otherwise
            name = '';
    end
    linkStr = sldv_hilite('makelink', obj, name);
end
