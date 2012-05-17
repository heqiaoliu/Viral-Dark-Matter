function [dSys, dParam] = getdominantsystem(h, param)
%GETDOMINANTSYSTEM   get the dominant system for H.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/21 03:18:56 $

dSys = [];
dParam = [];
if(~isa(h, 'DAStudio.Object'))
	return;
end


%throw an error if an invalid param is passed in
%initialize the output args with the current system and param value
dSys = h.daobject;
dParam = h.daobject.(param);
%get this systems parent
parent = h.daobject.getParent;
%loop until the model root is reached, we want to find the highest system
%with a dominant setting (ie: anything but UseLocalSettings)
while ~isempty(parent)
    if isa(parent,'Stateflow.Chart') || isa(parent,'Stateflow.TruthTableChart') || isa(parent,'Stateflow.LinkChart')
        % we want the Simulink.Subsystem object which wraps the chart in a model.
        parent = get_param(parent.Path,'Object');
    end
    %if this parent doesn't have a dominant setting get the next parent
    if ~isa(parent, 'Stateflow.Object') && ~strcmp('UseLocalSettings', parent.(param))
        %this parent contains dominant setting, hold on to it
        dSys =   parent;
        dParam = parent.(param);
    end
    parent = parent.getParent;
end

% [EOF]
