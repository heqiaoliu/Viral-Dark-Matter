function schema
%SCHEMA Define the RASTERPANEL Class.
  
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/15 20:14:46 $

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('hdfpanel');
    cls = schema.class(pkg,'rasterpanel',superCls);

    prop(1) = schema.prop(cls,'editHandle','MATLAB array');
    prop(2) = schema.prop(cls,'textHandle','MATLAB array');

    set(prop,'AccessFlags.PrivateGet','on',...
             'AccessFlags.PrivateSet','on',...
             'AccessFlags.PublicGet','on',...
             'AccessFlags.PublicSet','on');

end
