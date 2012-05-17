function setxuydx(this,xstruct,u,y,dxstruct)
% SETXUYDX  Set states, inputs, outputs, and state derivatives in an 
% operating point report.  The variables xstruct and dxstruct are data in
% the Simulink state structure format.
%
 
% Author(s): John W. Glass 02-Mar-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2007/10/15 23:28:23 $

if ~isempty(xstruct)
    states = this.States;
    %% Get the state names to match up with in the struct
    statenames = get(states,'Block');
    %% Loop over each element in the structure
    xsignals = xstruct.signals;
    for ct = 1:length(xsignals)
        ind = find(strcmp(xsignals(ct).blockName,statenames));
        if isempty(ind)
            ctrlMsgUtils.error('SLControllib:opcond:InvalidSimulinkState',str,xsignals(ct).blockName);
        else
            for ct2 = 1:length(ind)
                if strcmp(states(ind(ct2)).SampleType,xsignals(ct).label) && ...
                        isequal(states(ind(ct2)).Ts,xsignals(ct).sampleTime) && ...
                        isequal(states(ind(ct2)).StateName,xsignals(ct).stateName)
                    states(ind(ct2)).x = xsignals(ct).values(:);
                    states(ind(ct2)).dx = dxstruct.signals(ct).values(:);
                end
            end
        end
    end
end

% Extract the input levels
offset = 0;
for ct = 1:length(this.Inputs)
    this.Inputs(ct).u = u(offset+1:offset+this.Inputs(ct).PortWidth);
    offset = offset + this.Inputs(ct).PortWidth;
end

% Extract the output levels
offset = 0;
for ct = 1:length(this.Outputs)
    this.Outputs(ct).y = y(offset+1:offset+this.Outputs(ct).PortWidth);
    offset = offset + this.Outputs(ct).PortWidth;
end