function control = hdldefault_sf_control

%   Copyright 2005-2010 The MathWorks, Inc.

control = hdlnewcontrol(mfilename);

%Note: all the block paths mentioned here are made up convention names to
%recognize Stateflow based blocks which are subsystems with no library
%links/referenceBlock properties; the same block type names should be used
%in implementations as well.

control.defaultFor('sflib/Chart', {}, ...
  'hdlstateflow.Stateflow');

control.defaultFor('sflib/Truth Table', {}, ...
  'hdlstateflow.TruthTable');

control.defaultFor('eml_lib/Embedded MATLAB Function', {}, ...
  'hdlstateflow.EmbeddedMATLAB');
