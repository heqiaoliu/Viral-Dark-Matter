function [iswrl, plugin, pluginver] =wrlcheck
%WRLCHECK Checks for presence of a VRML viewer.
%
%   [ISWRL, PLUGIN, PLUGINVER] = WRLCHECK checks if a VRML viewer is installed.
%   ISWRL returns 1 if the viewer is installed and 0 if it is not.
%   PLUGIN returns the VRML plugin name or "Unknown" if it is not detected.
%   PLUGINVER returns the VRML plugin version as a string.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:11:21 $  $Author: batserve $

% implemented as MEX-file, this is just empty stub for Unix

iswrl = false;
plugin = '';
pluginver = '';
