function schema
%SCHEMA Define the GRIDPANEL Class.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/15 20:14:33 $

    pkg = findpackage('hdftool');

    superCls = pkg.findclass('eospanel');
    schema.class(pkg,'gridpanel',superCls);

end
