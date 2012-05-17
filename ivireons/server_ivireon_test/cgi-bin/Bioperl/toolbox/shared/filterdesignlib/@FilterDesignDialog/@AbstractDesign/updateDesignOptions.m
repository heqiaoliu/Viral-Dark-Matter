function updateDesignOptions(this)
%UPDATEDESIGNOPTIONS   Update the design options.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/10/16 06:38:22 $

hd = getFDesign(this, this);

if isempty(hd), return; end

% Make sure the design method is valid
methodEntries = getValidMethods(this, 'short');
method = getSimpleMethod(this);
if ~any(strcmpi(method,methodEntries)),
    return
end

dopts = designoptions(hd, method);

if isfield(dopts, 'MinPhase') && isfield(dopts, 'MaxPhase'),
    dopts = rmfield(dopts, {'MinPhase', 'MaxPhase'});
    dopts = rmfield(dopts, {'DefaultMinPhase', 'DefaultMaxPhase'});
    N = length(fieldnames(dopts));
    dopts.PhaseConstraint = {'Linear','Minimum','Maximum'};
    dopts = orderfields(dopts,[1 N+1 2:N]);
    dopts.DefaultPhaseConstraint = 'Linear';
    dopts = orderfields(dopts,[1:N/2+2 N+2 N/2+3:N+1]);
end

fn = fieldnames(dopts);
for indx = 1:length(fn)/2
    
    if ~any(strcmpi(fn{indx}, ...
            {'FilterStructure', 'SOSScaleNorm', 'SOSScaleOpts'}))

        % If there is no property on the dialog for the design option, add
        % a new dynamic property for it.
        p = findprop(this, fn{indx});

        % If we already have the property, there is no need to do anything.
        if isempty(p)
            if strcmpi(dopts.(fn{indx}), 'bool')
                dtype = 'bool';
            else
                dtype = 'string';
            end

            % Add the new property.
            p = schema.prop(this, sprintf('Default%s', fn{indx}), dtype);
            set(p, 'Visible', 'Off');
            p = schema.prop(this, fn{indx}, dtype);
        end

        % Get the default value in the correct format.
        if iscell(dopts.(fn{indx}))
            if strcmpi(fn{indx}, 'halfbanddesignmethod')
                set(p, 'SetFunction', @set_halfbanddesignmethod);
                dv = 'Equiripple';
            else
                set(p, 'SetFunction', {@set_enum, dopts.(fn{indx})});
                dv = sentencecase(dopts.(sprintf('Default%s', fn{indx})));
            end
        elseif strcmpi(dopts.(fn{indx}), 'bool')
            dv = dopts.(sprintf('Default%s', fn{indx}));
        else
            dv = dopts.(sprintf('Default%s', fn{indx}));
            if ischar(dv)
                dv = ['''' dv ''''];
            else
                dv = mat2str(dv);
            end
        end

        if isequal(this.(sprintf('Default%s', fn{indx})), this.(fn{indx}))
            % Set the default value in the new property.
            set(this, fn{indx}, dv);
            set(this, sprintf('Default%s', fn{indx}), dv);
        end
    end
end


% -------------------------------------------------------------------------
function e = set_halfbanddesignmethod(~, e)

switch lower(e)
    case 'equiripple'
        e = 'Equiripple';
    case 'kaiserwin'
        e = 'Kaiser window';
    case 'butterworth'
        e = 'Butterworth';
    case 'ellip'
        e = 'Elliptic';
    case 'iirlinphase'
        e = 'IIR quasi-linear phase';
    otherwise
        if ~any(strcmpi(e, {'Equiripple', 'Kaiser window', 'Butterworth', ...
                'Elliptic', 'IIR quasi-linear phase'}))
            error(generatemsgid('InvalidEnum'),'Invalid HalfbandDesignMethod');
        end
end


% -------------------------------------------------------------------------
function e = set_enum(~, e, opts)

if ~any(strcmpi(e, opts))
    error(generatemsgid('InvalidEnum'), 'Invalid Option');
end

% -------------------------------------------------------------------------
function str = sentencecase(str)

str = [upper(str(1)) lower(str(2:end))];

% [EOF]
