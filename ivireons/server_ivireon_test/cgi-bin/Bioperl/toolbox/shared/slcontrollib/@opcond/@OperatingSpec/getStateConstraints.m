function NewStates = getStateConstraints(this,NewStates)
% GETSTATECONSTRAINTS  Get the state constraints from a model.
%
 
% Author(s): John W. Glass 12-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:02:00 $

for ct = 1:length(NewStates)
    CurrentState = getBlockPath(slcontrol.Utilities,NewStates(ct).blockName);
    if strcmp(CurrentState,NewStates(ct).blockName)
        if ((strcmp(get_param(NewStates(ct).blockName,'BlockType'),'Integrator') || ...
                strcmp(get_param(NewStates(ct).blockName,'BlockType'),'DiscreteIntegrator')) && ...
                strcmp(get_param(NewStates(ct).blockName,'LimitOutput'),'on'))
            runtimeobject = get_param(NewStates(ct).blockName,'RunTimeObject');
            if strcmp(get_param(NewStates(ct).blockName,'BlockType'),'Integrator')
                minlim = runtimeobject.RuntimePrm(3);
                maxlim = runtimeobject.RuntimePrm(2);
                nstates = runtimeobject.NumContStates;
            else
                minlim = runtimeobject.RuntimePrm(5);
                maxlim = runtimeobject.RuntimePrm(4);
                nstates = numel(runtimeobject.DiscStates.Data);
            end

            %% Expand the state limits if needed
            if numel(minlim.data) == nstates
                NewStates(ct).Min = minlim.data(:);
            else
                NewStates(ct).Min = minlim.data*ones(nstates,1);
            end
            if numel(maxlim.data) == nstates
                NewStates(ct).Max = maxlim.data(:);
            else
                NewStates(ct).Max = maxlim.data*ones(nstates,1);
            end
        else
            NewStates(ct).Min = -inf;
            NewStates(ct).Max = inf;
        end
    else
        NewStates(ct).Min = -inf;
        NewStates(ct).Max = inf;
    end
end