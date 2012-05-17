function schema
% SCHEMA Class definition for @fftplot 

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:39 $

% Find parent package
pkg = findpackage('resppack');
c = schema.class(pkg, 'fftplot', findclass(pkg, 'respplot'));
% schema.prop(c, 'FreqIndices', 'MATLAB array');
% schema.prop(c, 'RespIndices', 'MATLAB array');
% schema.prop(c, 'RespAvailable', 'MATLAB array');
p = schema.prop(c, 'FreqFocus', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
