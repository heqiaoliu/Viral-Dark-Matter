function this = loadobj(this) 
% LOADOBJ  
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/04/25 03:19:53 $

% R2007b move opcond.StateSpecSimMech to opcond.StateSpec objects
if this.Version < 2.0
    states = this.States(:);
    for ct = numel(states):-1:1
        if isa(states(ct),'opcond.StateSpecSimMech')
            newstates = handle(NaN(states(ct).Nx,1));
            for ct2 = 1:states(ct).Nx
                newstates(ct2) = opcond.StateSpec;
                newstates(ct2).Block = opcond.computeSimMechBlockName(states(ct),ct2);
                newstates(ct2).StateName = opcond.computeSimMechStateName(states(ct),ct2);
                newstates(ct2).Nx = 1;
                if isempty(states(ct).Ts)
                    % SimMechanics models are always continuous in R2007b
                    % old versions of state objects did not store all of
                    % this information.  In the past the update method
                    % would take care of filling this in.  This is not
                    % possible with the conversion to SimMechanics models
                    % until the block name is unique.
                    newstates(ct2).Ts = [0 0];
                else
                    newstates(ct2).Ts = states(ct).Ts;
                end
                if isempty(states(ct).SampleType)
                    % SimMechanics models are always continuous in R2007b
                    % old versions of state objects did not store all of
                    % this information.  In the past the update method
                    % would take care of filling this in.  This is not
                    % possible with the conversion to SimMechanics models
                    % until the block name is unique.
                    newstates(ct2).SampleType = 'CSTATE';
                else
                    newstates(ct2).SampleType = states(ct2).SampleType; 
                end
                newstates(ct2).inReferencedModel = states(ct).inReferencedModel;
                newstates(ct2).Description = states(ct).Description;
                newstates(ct2).x = states(ct).x(ct2);
                newstates(ct2).Known = states(ct).Known(ct2);
                newstates(ct2).SteadyState = states(ct).SteadyState(ct2);
                newstates(ct2).Min = states(ct).Min(ct2);
                newstates(ct2).Max = states(ct).Max(ct2);
            end
            states = [states(1:ct-1);newstates;states(ct+1:end)];
        end
    end
    this.Version = opcond.getVersion;
    this.States = states;
end