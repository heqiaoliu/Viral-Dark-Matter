function schema
%SCHEMA  Definition of @specplot class (frequency spectrum plot).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:17 $

% Register class 
pkg = findpackage('wavepack');
c = schema.class(pkg, 'specplot', findclass(pkg, 'waveplot'));