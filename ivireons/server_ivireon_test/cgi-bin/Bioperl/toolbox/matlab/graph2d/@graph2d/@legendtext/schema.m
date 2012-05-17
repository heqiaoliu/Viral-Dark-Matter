function schema
%SCHEMA defines the LEGENDTEXT schema
%
%  See also LEGEND

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2005/06/21 19:29:29 $ 

pkg   = findpackage('graph2d');
pkgHG = findpackage('hg');

h = schema.class(pkg, 'legendtext' , pkgHG.findclass('text'));
    
