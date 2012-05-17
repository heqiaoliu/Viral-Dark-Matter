function schema
%  Definition of @hsvplot class (Hankel singular value plot)

%  Author(s): P. Gahinet
%  Copyright 1986-2005 The MathWorks, Inc. 
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:05 $

% Find parent package
pkg = findpackage('resppack');

% Register class (subclass)
c = schema.class(pkg, 'hsvplot', findclass(pkg, 'respplot'));

