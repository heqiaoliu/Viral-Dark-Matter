function proposal_option = getproposaloptionpanel(h) %#ok
%GETSCLPANEL   Get the Proposal options group

%   Author(s): V. Srinivasan
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 03:18:58 $

r=1;
appdata = [];
me = fxptui.getexplorer;
if(isempty(me))
 isenabled = false;
else
  action = me.getaction('SCALE_PROPOSE');
  isenabled = isequal('on', action.Enabled);
  appdata = SimulinkFixedPoint.getApplicationData(me.getRoot.daobject.getFullName);
end

% Use Sim Min/Max checkbox
chk_scl.Type = 'checkbox';
chk_scl.Tag = 'chk_scl';
% make the variable persistent to improve performance.
persistent min_max_label;
if isempty(min_max_label)
    min_max_label = DAStudio.message('FixedPoint:fixedPointTool:labelIsUsingSimMinMax');
end
chk_scl.Name = min_max_label;
if(~isempty(appdata))
    chk_scl.Source = appdata;
else
    % We provide a default Application Data to work around the issue gecked in G496760. This can be removed
    % once the geck is fixed.
    chk_scl.Source = SimulinkFixedPoint.ApplicationData([]);   
end
chk_scl.ObjectProperty = 'isUsingSimMinMax';
chk_scl.RowSpan = [r r];r=r+1;
chk_scl.ColSpan = [1 3];
chk_scl.Enabled = isenabled;
chk_scl.DialogRefresh = true; % refresh the dialog when this property changes.
chk_scl.Mode = 1; % Apply the changes to the ApplicationData object immediately.

txt_sm_sim.Type = 'text';
txt_sm_sim.Tag = 'txt_sm_sim';
% make the variable persistent to improve performance.
persistent sfmargin_sim_name;
if isempty(sfmargin_sim_name)
    sfmargin_sim_name = DAStudio.message('FixedPoint:fixedPointTool:labelSafetyMarginSimMinMax');
end
txt_sm_sim.Name = sfmargin_sim_name;
txt_sm_sim.RowSpan = [r r];
txt_sm_sim.ColSpan = [1 1];
txt_sm_sim.Buddy = 'edit_sm_sim';

% Safety margin for Sim Min/Max
edit_sm_sim.Type = 'edit';
edit_sm_sim.Tag = 'edit_sm_sim';
if(~isempty(me))
    edit_sm_sim.Source = SimulinkFixedPoint.getApplicationData(me.getRoot.daobject.getFullName);
end
edit_sm_sim.ObjectProperty = 'SafetyMarginForSimMinMax';
edit_sm_sim.RowSpan = [r r];r=r+1;
edit_sm_sim.ColSpan = [2 2];
if ~isempty(appdata) && appdata.isUsingSimMinMax
    edit_sm_sim.Enabled = isenabled;  
else
    edit_sm_sim.Enabled = false;
end

txt_sm_dsgn.Type = 'text';
txt_sm_dsgn.Tag = 'txt_sm_dsgn';
% make the variable persistent to improve performance.
persistent sfmargin_dsgn_name;
if isempty(sfmargin_dsgn_name)
    sfmargin_dsgn_name = DAStudio.message('FixedPoint:fixedPointTool:labelSafetyMarginDesignMinMax');
end
txt_sm_dsgn.Name = sfmargin_dsgn_name;
txt_sm_dsgn.RowSpan = [r r];
txt_sm_dsgn.ColSpan = [1 1];
txt_sm_dsgn.Buddy = 'edit_sm_dsgn';

% Safety margin for Design Min/Max
edit_sm_dsgn.Type = 'edit';
edit_sm_dsgn.Tag = 'edit_sm_dsgn';
if(~isempty(me))
    edit_sm_dsgn.Source = SimulinkFixedPoint.getApplicationData(me.getRoot.daobject.getFullName);
end
edit_sm_dsgn.ObjectProperty = 'SafetyMarginForDesignMinMax';
edit_sm_dsgn.RowSpan = [r r];
edit_sm_dsgn.ColSpan = [2 2];
edit_sm_dsgn.Enabled = isenabled;

%create spacer panel
spacer2.Type = 'panel';
spacer2.RowSpan = [r r];r=r+1;
spacer2.ColSpan = [3 4];
spacer2.LayoutGrid = [r-1 4];

% Group for proposal options
persistent propose_options;
if isempty(propose_options)
    propose_options = DAStudio.message('FixedPoint:fixedPointTool:labelProposalOptions');
end
proposal_option.Name = propose_options;
proposal_option.Type = 'group';
proposal_option.Items = {chk_scl, txt_sm_sim, edit_sm_sim, txt_sm_dsgn, edit_sm_dsgn, spacer2};
proposal_option.LayoutGrid = [r-1 4];
proposal_option.ColStretch = [0 0 0 1];
proposal_option.Enabled = isenabled;

