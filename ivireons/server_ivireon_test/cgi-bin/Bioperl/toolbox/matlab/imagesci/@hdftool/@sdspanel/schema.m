function schema
%SCHEMA Define the SDSPANEL Class

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/15 20:14:47 $

    ppkg = findpackage('hdftool');
    pcls = ppkg.findclass('hdfpanel');

    pkg = findpackage('hdftool');
    cls = schema.class(pkg,'sdspanel',pcls);

    prop(1) = schema.prop(cls,'table','MATLAB array');
    prop(2) = schema.prop(cls,'tableApi','MATLAB array');
    prop(3) = schema.prop(cls,'tableContainer','MATLAB array');
    set(prop,'AccessFlags.PrivateGet','on',...
        'AccessFlags.PrivateSet','on',...
        'AccessFlags.PublicGet','on',...
        'AccessFlags.PublicSet','on');

end
