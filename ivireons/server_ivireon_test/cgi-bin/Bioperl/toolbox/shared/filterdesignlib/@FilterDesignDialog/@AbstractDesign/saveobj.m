function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:17 $

s.class = this.class;

s.OperatingMode    = this.OperatingMode;
s.VariableName     = this.VariableName;
s.ImpulseResponse  = this.ImpulseResponse;
s.OrderMode        = this.OrderMode;
s.Order            = this.Order;
s.FilterType       = this.FilterType;
s.Factor           = this.Factor;
s.FrequencyUnits   = this.FrequencyUnits;
s.InputSampleRate  = this.InputSampleRate;
s.MagnitudeUnits   = this.MagnitudeUnits;
s.LastAppliedState = this.LastAppliedState;
s.LastAppliedSpecs = this.LastAppliedSpecs;
s.LastAppliedDesignOpts = this.LastAppliedDesignOpts;

s = thissaveobj(this, s);

% Set the design method last.
s.DesignMethod    = this.DesignMethod;
s.Structure       = this.Structure;
s.Scale           = this.Scale;

s.DesignOptionsCache = saveDesignOptions(this);

s.FixedPoint = this.FixedPoint;

% -------------------------------------------------------------------------
function s = saveDesignOptions(this)

hfd = get(this, 'FDesign');

% Make sure the design method is valid
methodEntries = getValidMethods(this, 'short');
method = getSimpleMethod(this);
if any(strcmpi(method,methodEntries)),
    optstruct = designoptions(hfd, method);
    if isfield(optstruct, 'MinPhase') && isfield(optstruct, 'MaxPhase'),
        optstruct = rmfield(optstruct, {'MinPhase', 'MaxPhase'});
        optstruct = rmfield(optstruct, {'DefaultMinPhase', 'DefaultMaxPhase'});
        N = length(fieldnames(optstruct));
        optstruct.PhaseConstraint = {'Linear','Minimum','Maximum'};
        optstruct = orderfields(optstruct,[1 N+1 2:N]);
        optstruct.DefaultPhaseConstraint = 'Linear';
        optstruct = orderfields(optstruct,[1:N/2+2 N+2 N/2+3:N+1]);
    end
    fn = fieldnames(optstruct);
    
    % Remove the 'Default's.
    fn = fn(1:length(fn)/2);
    
    s = [];
    % go through fn one-by-one to avoid messing up the order of design options
    for indx = 1:length(fn)
        % Remove the settings that are captured elsewhere.
        if ~isempty(setdiff(fn{indx}, {'FilterStructure', 'SOSScaleNorm', 'SOSScaleOpts'}))
            s.(fn{indx}) = this.(fn{indx});
        end
    end
else
    s = this.DesignOptionsCache;
end

% [EOF]
