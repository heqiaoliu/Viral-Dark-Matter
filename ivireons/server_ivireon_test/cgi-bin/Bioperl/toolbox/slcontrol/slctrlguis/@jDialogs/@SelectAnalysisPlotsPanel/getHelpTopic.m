function [mapPath, topicKey] = getHelpTopic(this)
% GETHELPTOPIC Returns the map file path and the help topic key for this node.
%
% MAPPATH  map file path containing the topic key, relative to DOCROOT.
%          Use forward slashes as file separators.
% TOPICKEY the topic key that maps to the HTML filename.

% Author(s): John Glass
% Revised:
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:28:38 $

mapPath  = fullfile(docroot,'toolbox','slcontrol','slcontrol.map');
topicKey = 'control_design_wizard_analysis_plots';
