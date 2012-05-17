function update(states,new_states,all_states)
%

% UPDATE Update the state specification
%

% Author(s): John W. Glass 10-Dec-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:58:25 $

% Update the state data
for ct = 1:length(states)
    if isempty(new_states)
        struct_element = [];
    else
        struct_element = opcond.findStateStructElement(states(ct),new_states);
    end
    if ~isempty(struct_element)
        % Get the number of states
        Nx = struct_element.dimensions;
        % Create the index vector for the states
        ind = (1:Nx)';

        % Update the states if the number of states has changed
        if (isempty(states(ct).Nx)) || (Nx ~= states(ct).Nx)
            % Set the properties
            state = states(ct);
            state.Nx        = Nx;
            x = struct_element.values(ind);
            state.x         = x(:);
            if ((length(state.Min) ~= state.Nx) || (length(state.Max) ~= state.Nx))
                state.Min       = -inf*ones(size(ind));
                state.Max       =  inf*ones(size(ind));
            end
            state.SteadyState = true(size(ind));
            state.Known     = false(size(ind));
            states(ct) = state;
        end
        %% Update the sample time
        if ~isequal(states(ct).Ts,struct_element.sampleTime);
            %% Do not throw an error since we can always update this
            %% information.
            states(ct).Ts = struct_element.sampleTime;
            states(ct).SampleType = struct_element.label;
        end
        %% Update the inReferencedModel flag
        if ~isequal(states(ct).inReferencedModel,struct_element.inReferencedModel);
            states(ct).inReferencedModel = struct_element.inReferencedModel;
        end
    elseif isempty(states(ct).Ts)
        % Backwards compatibility for releases that did not have this field
        struct_element = opcond.findStateStructElement(states(ct),all_states);
        states(ct).Ts = struct_element.sampleTime;
        states(ct).SampleType = struct_element.label;
    end
end
