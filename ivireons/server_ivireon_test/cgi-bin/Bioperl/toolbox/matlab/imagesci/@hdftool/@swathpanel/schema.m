function schema
%SCHEMA Define the SWATHPANEL Class.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/15 20:14:59 $

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('eospanel');
    cls = schema.class(pkg,'swathpanel',superCls);

end
