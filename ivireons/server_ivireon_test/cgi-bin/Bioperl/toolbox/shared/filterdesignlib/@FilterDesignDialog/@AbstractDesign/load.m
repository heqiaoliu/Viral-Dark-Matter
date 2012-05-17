function this = load(s)
%LOAD     Static load method.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/03/15 23:30:38 $

this = feval(s.class, 'OperatingMode', s.OperatingMode);

this.VariableName     = s.VariableName;
this.ImpulseResponse  = s.ImpulseResponse;
this.OrderMode        = s.OrderMode;
this.Order            = s.Order;
this.FilterType       = s.FilterType;
this.Factor           = s.Factor;
this.FrequencyUnits   = s.FrequencyUnits;
this.InputSampleRate  = s.InputSampleRate;
this.MagnitudeUnits   = s.MagnitudeUnits;
this.LastAppliedState = s.LastAppliedState;
this.LastAppliedSpecs = s.LastAppliedSpecs;
this.LastAppliedDesignOpts = s.LastAppliedDesignOpts;

this.thisloadobj(s);

% Set the design method last.
this.DesignMethod    = s.DesignMethod;
this.Structure       = s.Structure;
this.Scale           = s.Scale;

if isprop(this, 'UniformGrid') && ~isfield(s.DesignOptionsCache, 'UniformGrid')
    s.DesignOptionsCache.UniformGrid = false;
end

FDTbxRequiredToLoadOptions = loadDesignOptions(this, s);

% Set 'Enabled' true if Filter Design Toolbox is not required
EnableDialogIfPossible(this,FDTbxRequiredToLoadOptions,s);

if supportsSLFixedPoint(this) || ~strcmpi(this.OperatingMode, 'simulink')
    hFixedPoint = s.FixedPoint;
    if ishandle(s)
        hFixedPoint = copy(hFixedPoint);
    end
    this.FixedPoint = hFixedPoint;
end

% -------------------------------------------------------------------------
function FDTbxRequired = loadDesignOptions(this, s)

FDTbxRequired = false;
if any(strcmpi(convertStructure(this), ...
        {'df1sos', 'df1tsos', 'df2sos', 'df2tsos'})) && strcmpi(s.Scale,'on'),
    FDTbxRequired = true;
end

s  = s.DesignOptionsCache;
if isempty(s), return; end
fn = fieldnames(s);
for indx = 1:length(fn)
    
    % If we add design options in later releases, they will not be saved.
    % Check if they exist before trying to set them.
    if isprop(this, fn{indx})
        this.(fn{indx}) = s.(fn{indx});
    else
        this.DesignOptionsCache = s;
        FDTbxRequired = true;
    end
end

% -------------------------------------------------------------------------
function EnableDialogIfPossible(this,FDTbxRequiredToLoadOptions,s)
% Set 'Enabled' true if Filter Design Toolbox is not required

if ~isfdtbxinstalled && this.isResetable && strcmpi(this.OperatingMode,'simulink'),
    % Test specifications
    spec = getSpecification(this);
    specEntries = set(getFDesign(this), 'Specification');
    if ~any(strcmpi(spec,specEntries)),
        FDTbxRequired = true;
    else
        % Test design methods
        methodEntries = getValidMethods(this);
        if ~any(strcmpi(s.DesignMethod,methodEntries)),
            FDTbxRequired = true;
        else
            % Test filter structures
            structureEntries = getValidStructures(this, 'full');
            if ~any(strcmpi(s.Structure,structureEntries)),
                FDTbxRequired = true;
            else
                % Test design options
                FDTbxRequired = FDTbxRequiredToLoadOptions;
            end
        end
    end
    this.Enabled = ~FDTbxRequired;
end


% [EOF]
