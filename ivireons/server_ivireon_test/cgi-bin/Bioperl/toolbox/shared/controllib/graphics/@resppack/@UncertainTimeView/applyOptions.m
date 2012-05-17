function applyOptions(this, Options)
% APPLYOPTIONS  Synchronizes plot options with those of characteristics
 
%  Author(s): Craig Buhr
%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2010/04/11 20:36:21 $

% Set new preferences
if isfield(Options, 'MultiModelDisplayType')
    this.UncertainType = Options.MultiModelDisplayType;
end