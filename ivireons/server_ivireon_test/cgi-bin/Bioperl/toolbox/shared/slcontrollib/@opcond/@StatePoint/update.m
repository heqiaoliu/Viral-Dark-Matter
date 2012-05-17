function update(this,new_states,all_states)
%

% UPDATE  Update the state point data if needed.
%

% Author(s): John W. Glass 10-Dec-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:28:38 $

% Update the state data given a vector of state structures
for ct = 1:length(this)
    if isempty(new_states)
        struct_element = [];
    else
        struct_element = opcond.findStateStructElement(this(ct),new_states);
    end
    if ~isempty(struct_element)
        %% Get the number of this
        Nx = struct_element.dimensions;
        %% Create the index vector for the this
        ind = (1:Nx)';

        %% Update the states if the number of this has changed
        if (isempty(this(ct).Nx)) || (Nx ~= this(ct).Nx)
            state = this(ct);
            %% Set the properties
            state.Nx = Nx;
            x = struct_element.values(ind);
            state.x  = x(:);
            this(ct) = state;
        end
        %% Update the sample time
        if ~isequal(this(ct).Ts,struct_element.sampleTime);
            %% Do not throw an error since we can always update this
            %% information.
            this(ct).Ts = struct_element.sampleTime;
            this(ct).SampleType = struct_element.label;
        end
        %% Update the inReferencedModel flag
        if ~isequal(this(ct).inReferencedModel,struct_element.inReferencedModel);
            this(ct).inReferencedModel = struct_element.inReferencedModel;
        end
    elseif isempty(this(ct).Ts)
        % Backwards compatibility for releases that did not have this field
        struct_element = opcond.findStateStructElement(this(ct),all_states);
        this(ct).Ts = struct_element.sampleTime;
        this(ct).SampleType = struct_element.label;
    end
end
