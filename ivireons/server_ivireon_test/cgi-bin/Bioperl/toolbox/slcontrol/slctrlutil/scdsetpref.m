function scdsetpref(prefname,prefvalue,varargin)
%SCDSETPREF Set Simulink Control Design preferences.
%   SCDSETPREF(PREFNAME, PREFVALUE) sets Simulink Control Design preference
%   PREFNAME to value PREFVALUE.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2009/08/08 01:19:30 $ $Author: batserve $

if strcmp(prefname,'DefaultLinearizationPlot') && (nargin == 3) && strcmp(varargin{1},'PreferencePanel')
    prefvalue = slctrlguis.label2plotcmd(prefvalue);
end

setpref('SimulinkControlDesign',prefname,prefvalue);
