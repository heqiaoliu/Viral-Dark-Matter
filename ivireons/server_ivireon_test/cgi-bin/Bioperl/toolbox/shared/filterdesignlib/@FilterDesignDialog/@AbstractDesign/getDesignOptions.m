function designOptions = getDesignOptions(this, varargin)
%GETDESIGNOPTIONS   Get the designOptions.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/12/05 02:22:15 $

% If we are passed a structure, use it for the settings, otherwise use the
% object handle.
if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

designOptions = {};

% Get the FDesign based on the source, which is not necessarily the current
% state of the object.
hFDesign = getFDesign(this, source);
if isempty(hFDesign)	
     return;	
end

% Make sure the design method is valid
methodEntries = getValidMethods(this, 'short');
method = getSimpleMethod(this, source);
if ~any(strcmpi(method,methodEntries)),
    return
end

optstruct = designoptions(hFDesign, method);

% Cache the default options 
optDefaults = optstruct;

optstruct = rmfield(optstruct, {'FilterStructure', 'DefaultFilterStructure'});

if isfield(optstruct, 'SOSScaleOpts')
    optstruct = rmfield(optstruct, {'SOSScaleOpts', 'DefaultSOSScaleOpts'});
end
isSOSScale = false;
if isfield(optstruct, 'SOSScaleNorm')
    isSOSScale = true;
    optstruct = rmfield(optstruct, {'SOSScaleNorm', 'DefaultSOSScaleNorm'});
end
isminmaxphase = false;
if isfield(optstruct, 'MinPhase') && isfield(optstruct, 'MaxPhase'),
    isminmaxphase = true;
    optstruct = rmfield(optstruct, {'MinPhase', 'MaxPhase'});
    optstruct = rmfield(optstruct, {'DefaultMinPhase', 'DefaultMaxPhase'});
end

isuniformgrid = false;
if isfield(optstruct, 'UniformGrid')
    isuniformgrid = true;
    optstruct = rmfield(optstruct, {'UniformGrid', 'DefaultUniformGrid'});
end

isdecay = false;
if isfield(optstruct, 'StopbandDecay')
    isdecay = true;
    optstruct = rmfield(optstruct, {'StopbandDecay', 'DefaultStopbandDecay'});
end

fn = fieldnames(optstruct);

% Remove FilterStructure and DefaultFilterStructure from the list.
indx = find(strcmpi(fn, 'FilterStructure'));
fn([indx indx+length(fn)/2]) = [];

designOptions = cell(1, length(fn)+2);

fstruct = source.Structure;

designOptions(1:2) = {'FilterStructure', convertStructure(this, fstruct)};

for indx = 1:length(fn)/2

    designOptions{2*indx+1} = fn{indx};

    if (isstruct(source) && isfield(source,fn{indx}))|| ...
            (isa(source, 'FilterDesignDialog.AbstractDesign')...
            && isprop(source,fn{indx}))
        value = source.(fn{indx});
    else
        % Apply the default values
        % It is necessary when load a model in fdtbx available environment
        % but the model is created in fdtbx unavailable environment
        key = strcat('Default',fn{indx});
        value = optDefaults.(key);
    end

    vvals = optstruct.(fn{indx});
    if ~iscell(vvals) && any(strcmp(vvals, ...
            {'int', 'double', 'posdouble', 'double_vector'}))
        value = evaluatevars(value);
    elseif ~iscellstr(vvals) && any(strcmpi(vvals, {'mxArray', 'MATLAB array'}))

        try

            % If we are given "mxArray" or "MATLAB array" we do not know
            % what to do with the value.  Try to evaluate it.  If it comes
            % out as a number, then assume it is a variable.
            tempvalue = evaluatevars(value);
            if isnumeric(tempvalue)
                value = tempvalue;
            end
        catch ME %#ok<NASGU>
            % If evaluatevars failed, try "evalin" directly
            try
                value = evalin('base', value);
            catch ME %#ok<NASGU>
                % NO OP
            end
        end
    elseif strcmpi(fn{indx}, 'halfbanddesignmethod')
        value = getSimpleMethod(this, struct('DesignMethod', value));
    end

    designOptions{2*indx+2} = value;
end

if isminmaxphase,
    if strcmpi(this.PhaseConstraint,'Minimum'),
        designOptions{2*indx+3} = 'MinPhase';
        designOptions{2*indx+4} = true;
    end
    if strcmpi(this.PhaseConstraint,'Maximum'),
        designOptions{2*indx+3} = 'MaxPhase';
        designOptions{2*indx+4} = true;
    end
end

if isuniformgrid && ...
    (~isfield(optstruct, 'MinOrder') || strcmp(this.MinOrder, 'Any')) && ...
    (~isfield(optstruct, 'StopbandShape') || strcmp(this.StopbandShape, 'Flat')) && ...
    (~isminmaxphase || strcmp(this.PhaseConstraint, 'Linear'))
    designOptions = [designOptions {'UniformGrid', this.UniformGrid}];
end

if isdecay && ~strcmp(this.StopbandShape, 'Flat')
    designOptions = [designOptions {'StopbandDecay', evalin('base', this.StopbandDecay)}];
end

if any(strcmpi(convertStructure(this), ...
        {'df1sos', 'df1tsos', 'df2sos', 'df2tsos'}))
    if isfdtbxdlg(this)
        if strcmpi(this.Scale,'on') && isSOSScale
            designOptions = [designOptions {'SOSScaleNorm', 'Linf'}]; 
        elseif this.Enabled
             designOptions = [designOptions {'SOSScaleNorm', ''}];
        end
    end
end
% [EOF]
