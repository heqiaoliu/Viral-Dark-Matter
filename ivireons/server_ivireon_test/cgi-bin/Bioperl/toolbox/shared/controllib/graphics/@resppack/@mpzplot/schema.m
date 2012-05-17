function schema
%SCHEMA  Defines properties for @mpzplot class (multivariable pole/zero plot).

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:52 $

% Find parent package
pkg = findpackage('resppack');

% Register class (subclass)
c = schema.class(pkg, 'mpzplot', findclass(pkg, 'pzplot'));

% REVISIT: should hide Input*, Output*, and I/Ogrouping props