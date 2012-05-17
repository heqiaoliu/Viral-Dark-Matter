function schema
%SCHEMA Define the eospanel class.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:08:57 $

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('hdfpanel');
    cls = schema.class(pkg,'eospanel',superCls);

    prop(1) = schema.prop(cls, 'subsetFrame', 'MATLAB array');
    prop(2) = schema.prop(cls, 'subsetFrameContainer','MATLAB array');
    prop(3) = schema.prop(cls, 'subsetApi', 'MATLAB array');
    prop(4) = schema.prop(cls, 'subsetSelectionApi', 'MATLAB array');
    
    set(prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on');

end
