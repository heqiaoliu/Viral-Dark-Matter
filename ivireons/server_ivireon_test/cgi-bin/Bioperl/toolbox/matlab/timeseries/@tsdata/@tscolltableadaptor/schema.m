function schema

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/06/27 23:09:36 $

% Register class (subclass)
p = findpackage('tsdata');
c = schema.class(p,'tscolltableadaptor',findclass(p, 'tstableadaptor'));
