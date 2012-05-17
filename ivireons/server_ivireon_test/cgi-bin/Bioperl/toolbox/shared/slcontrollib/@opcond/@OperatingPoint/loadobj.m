function this = loadobj(this,s) 
% LOADOBJ  
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/04/25 03:19:39 $

% R2007b move opcond.StatePointSimMech to opcond.StatePoint objects
if this.version < 2.0
    states = this.States(:);
    for ct = numel(states):-1:1
        if isa(states(ct),'opcond.StatePointSimMech')
            newstates = handle(NaN(states(ct).Nx,1));
            for ct2 = 1:states(ct).Nx
                newstates(ct2) = opcond.StatePoint;
                newstates(ct2).Block = opcond.computeSimMechBlockName(states(ct),ct2);
                newstates(ct2).StateName = opcond.computeSimMechStateName(states(ct),ct2);
                newstates(ct2).Nx = 1;
                newstates(ct2).x = states(ct).x(ct2);
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
            end
            states = [states(1:ct-1);newstates;states(ct+1:end)];
        end
    end
    this.States = states;
    this.Version = opcond.getVersion;
end