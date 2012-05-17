function op = setxu(this,x,varargin)
%

%SETXU Set states and inputs in operating points.
%
%   OP_NEW=SETXU(OP_POINT,X,U) sets the states and inputs in the operating 
%   point, OP_POINT, with the values in X and U. A new operating point 
%   containing these values, OP_NEW, is returned. The variable X can be a 
%   vector or a structure with the same format as those returned from a 
%   Simulink simulation. The variable U can be a vector. Both X and U can 
%   be extracted from another operating point object with the getxu function.
% 
%   See also GETXU, OPERPOINT.

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/06/13 15:28:30 $

% Create a copy of the object being passed into the method
op = copy(this);

% Extract the states from the operating condition object
if isa(x,'struct')
    %% RE: Check for a valid Simulink structure.
    states = this.States;
    %% Get the state names to match up with in the struct
    statenames = get(states,'Block');
    %% Loop over each element in the structure
    xsignals = x.signals;  
    for ct = 1:length(xsignals)
        ind = find(strcmp(xsignals(ct).blockName,statenames));
        if isempty(ind)
            ctrlMsgUtils.warning('SLControllib:opcond:InvalidSimulinkState',xsignals(ct).blockName);
        else
            for ct2 = 1:length(ind)
                if strcmp(states(ind(ct2)).SampleType,xsignals(ct).label) && ...
                        isequal(states(ind(ct2)).Ts,xsignals(ct).sampleTime) && ...
                        strcmp(states(ind(ct2)).StateName,xsignals(ct).stateName)
                    states(ind(ct2)).x = xsignals(ct).values(:);
                    continue
                end
            end
        end
    end
    op.States = states;
else
    %% Get the states of the system
    [sizes, x0, x_str] = feval(this.Model,[],[],[],'sizes');
    states = op.States;
    
    %% Check for a unique state object.  If there is not one there is not a
    %% way to map the state vector to the structure element.
    if numel(unique(get(this.States,'Block'))) < numel(this.States)
        ctrlMsgUtils.error('SLControllib:opcond:StateVectorNotSupported','"setxu(OP_POINT,X,U)"',this.Model);
    end
    
    for ct = 1:length(this.States)
        %% Find the state indices
        ind = find(strcmp(x_str,states(ct).Block));
        state = states(ct);
        %% Set the properties
        state.Nx = length(ind);
        state.x  = x(ind);
        states(ct) = state;
    end
    op.States = states;
end

if nargin == 3
    u = varargin{1};
    %% Extract the input levels
    offset = 0;
    inputs = op.Inputs;
    for ct = 1:length(this.Inputs)
        input = inputs(ct);
        input.u = u(offset+1:offset+this.Inputs(ct).PortWidth);
        inputs(ct) = input;
        offset = offset + this.Inputs(ct).PortWidth;
    end
    op.Inputs = inputs;
end
