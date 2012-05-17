function abstract_setGUI(this, Hd)
%ABSTRACT_SETGUI   Setup the GUI based on a DFILT and FDESIGN

%   Author(s): J. Schickler
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2010/05/20 03:03:09 $

hfdesign = getfdesign(Hd);
hfmethod = getfmethod(Hd);

spec = get(hfdesign, 'Specification');

% Ask the design object if it is FIR or IIR.  Set this first incase the
% constraints are impulse response limited.
if isfir(hfmethod)
    set(this, 'ImpulseResponse', 'FIR');
else
    set(this, 'ImpulseResponse', 'IIR');
end

% If we find 'N' in the specification string we are in specify order mode.
if strncmp(spec, 'Nb,', 3)
    Nb = get(hfdesign, 'NumOrder');
    Na = get(hfdesign, 'DenOrder');
    if isprop(this, 'DenominatorOrder') && isprop(this, 'SpecifyDenominator')
        set(this, 'SpecifyDenominator', true, ...
            'OrderMode', 'specify', ...
            'Order', num2str(Nb), ...
            'DenominatorOrder', num2str(Na));
    elseif Nb == Na
        set(this, 'OrderMode', 'specify', ...
            'Order', num2str(Nb));
    else
        error('filterdesign:filterbuilder:CannotImport', ...
            'Cannot import designs if the numerator and denominator orders do not match.');
    end
    
elseif strncmp(spec, 'N,', 2) || isequal(spec, 'N')
    set(this, 'OrderMode', 'specify', ...
        'Order', num2str(hfdesign.FilterOrder));
else
    set(this, 'OrderMode', 'minimum');
end

if isa(hfdesign, 'fdesign.decimator')
    set(this, ...
        'FilterType', 'decimator', ...
        'Factor',     num2str(hfdesign.DecimationFactor));
elseif isa(hfdesign, 'fdesign.interpolator')
    set(this, ...
        'FilterType', 'interpolator', ...
        'Factor',     num2str(hfdesign.InterpolationFactor));
elseif isa(hfdesign, 'fdesign.rsrc')
    set(this, ...
        'FilterType',   'sample-rate converter', ...
        'Factor',       num2str(hfdesign.InterpolationFactor), ...
        'SecondFactor', num2str(hfdesign.DecimationFactor));
    
end

if hfdesign.NormalizedFrequency
    set(this, 'FrequencyUnits', 'normalized');
else
    %     [fs,e,units] = engunits(hfdesign.Fs); %#ok
    %     set(this, 'FrequencyUnits', [units 'Hz'], 'InputSampleRate', num2str(fs));
    fs = hfdesign.Fs;
    set(this, 'FrequencyUnits', 'Hz', 'InputSampleRate', num2str(fs));
end

% Set up the algorithm based on hfmethod
set(this, 'DesignMethod', matchCase(get(hfmethod, 'DesignAlgorithm'), ...
    getValidMethods(this)));

updateDesignOptions(this);

dopts = designopts(hfdesign, this.getSimpleMethod);

if isfield(dopts, 'MinPhase') && isfield(dopts, 'MaxPhase'),
    if hfmethod.MinPhase,
        this.PhaseConstraint = 'Minimum';
    elseif hfmethod.MaxPhase,
        this.PhaseConstraint = 'Maximum';
    else
        this.PhaseConstraint = 'Linear';
    end
    dopts = rmfield(dopts, {'MinPhase', 'MaxPhase'});
end

% Set the structure, because this can be manipulated from that stored in
% the FMETHOD (multirates and CONVERT) we need to get this from the filter
% and not the FMETHOD directly.
if strcmpi(hfmethod.DesignAlgorithm, 'multistage equiripple') || ...
   any(strcmpi(hfmethod.FilterStructure, {'cascadeallpass','cascadewdfallpass'})),
    cls = hfmethod.FilterStructure;
else
    cls = getClassName(Hd);
end
structure = convertStructure(this, cls);
set(this, 'Structure', structure);

% Set the other properties
fn = setdiff(fieldnames(dopts), ...
    {'FilterStructure', 'DesignAlgorithm', 'SOSScaleNorm', 'SOSScaleOpts', 'Window'});
for indx = 1:length(fn)
    value = hfmethod.(fn{indx});
    if isnumeric(value) && ~islogical(value)
        value = num2str(value);
        if isempty(value)
            value = '[]';
        end
    elseif isa(value, 'function_handle')
        value = func2str(value);
    elseif iscell(value)
        
        if isa(value{1}, 'function_handle')
            value{1} = func2str(value{1});
        end
        
        if length(value) > 1
            if isnumeric(value{2})
                value{2} = mat2str(value{2});
            end
            
            value = sprintf('{''%s'', %s}', value{:});
        else
            value = sprintf('{''%s''}', value{1});
        end
    elseif ischar(value)
        value(1) = upper(value(1));
    end
    set(this, fn{indx}, value);
end

% Special case window.
if isfield(dopts, 'Window')
    value = hfmethod.Window;
    if ischar(value)
        value = mat2str(value);
    elseif iscell(value)
        if ischar(value{1})
            fcn = sprintf('{%s', mat2str(value{1}));
        else
            fcn = sprintf('{%s', lclFuncToStr(value{1}));
        end
        for indx = 2:length(value)
            fcn = sprintf('%s, %s', fcn, mat2str(value{indx}));
        end
        fcn = sprintf('%s}', fcn);
        value = fcn;
    elseif isempty(value)
        value = '';
    else
        % Must be a function handle
        value = lclFuncToStr(value);
    end
    set(this, 'Window', value);
end

if isfield(dopts, 'SOSScaleNorm') && isempty(hfmethod.SOSScaleNorm)
    set(this, 'Scale', 'off');
end

if isfield(dopts, 'SOSScaleOpts') && isempty(hfmethod.SOSScaleOpts)
    set(this, 'Scale', 'off');
end

% Update the fixed point panel.
if ~isempty(this.FixedPoint)
    updateSettings(this.FixedPoint, Hd);
end

set(this, 'LastAppliedFilter', Hd);

% -------------------------------------------------------------------------
function str = lclFuncToStr(fcn)

info = functions(fcn);
if strcmp(info.type, 'anonymous')
    % no need to add the @ for anonymous functions
    str = sprintf('%s', func2str(fcn));
else
    str = sprintf('@%s', func2str(fcn));
end

% -------------------------------------------------------------------------
function str = matchCase(str, allStrs)

idx = find(strcmpi(str, allStrs));
if isempty(idx)
    str = allStrs{1};
else
    str = allStrs{idx};
end

% -------------------------------------------------------------------------
function cls = getClassName(Hd)

cls = get(classhandle(Hd), 'Name');

switch cls
    case {'cascade', 'parallel'}
        for indx = 1:nstages(Hd)
            cls = getClassName(Hd.Stage(indx));
            if ~isempty(cls)
                return;
            end
        end
        
    case 'scalar'
        cls = '';
end

% [EOF]
