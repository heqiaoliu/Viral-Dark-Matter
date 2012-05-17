function schema
% SCHEMA Class definition for @SimcomparePlot (the full figure for the
% simcompare command)

% Author(s): Erman Korkut 23-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/10/16 06:46:15 $

% Find parent package
pkg = findpackage('frestviews');
% Register class
c = schema.class(pkg, 'SimcomparePlot', findclass(findpackage('resppack'), 'timeplot'));

