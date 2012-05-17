function schema
%SCHEMA  Definition of @timeplot class (time series plot).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:29 $

% Register class 
pkg = findpackage('wavepack');
c = schema.class(pkg, 'timeplot', findclass(pkg, 'waveplot'));