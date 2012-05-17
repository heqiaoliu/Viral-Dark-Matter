function hBuffer = getMCodeBuffer(this)
%GETMCODEBUFFER Get the mCodeBuffer.
%   OUT = GETMCODEBUFFER(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/04/11 20:36:36 $

laState = get(this, 'LastAppliedState');
spec    = getSpecification(this, laState);

% Get the MCode variables from the subclass.
mCodeInfo = getMCodeInfo(this);

variables = mCodeInfo.Variables;
values    = mCodeInfo.Values;

if isfield(mCodeInfo, 'Descriptions')
    descriptions = mCodeInfo.Descriptions;
else
    descriptions = repmat({''}, size(variables));
end

if isfield(mCodeInfo, 'Inputs')
    inputs = mCodeInfo.Inputs;
else
    % Handle variables concatenated horizontally or vertically. 
    [nr, ~] = size(variables);
    if nr>1,
        inputs = [{sprintf('''%s''', spec)}; variables];
    else
        inputs = [{sprintf('''%s''', spec)}, variables];
    end
end

if ~strcmpi(laState.FrequencyUnits, 'normalized (0 to 1)')
    variables{end+1}    = 'Fs';
    values{end+1}       = num2str(convertfrequnits(laState.InputSampleRate, ...
        laState.FrequencyUnits, 'hz'));
    descriptions{end+1} = '';
    inputs{end+1}       = 'Fs';
end

hBuffer = sigcodegen.mcodebuffer;

% Format the parameters
hBuffer.addcr(hBuffer.formatparams(variables, values, descriptions));
hBuffer.cr;

hfdesign = getFDesign(this);

% Add the constructor.
if strcmpi(laState.FilterType, 'single-rate')
    hBuffer.add('h = %s(', class(hfdesign));
else
    
    specs = getSpecs(this, laState);
    
    hBuffer.add('h = fdesign.');
    
    if strcmpi(laState.FilterType, 'sample-rate converter')
        hBuffer.add('rsrc(%d, %d', specs.Factor, specs.SecondFactor);
    else
        hBuffer.add('%s(%d', lower(laState.FilterType), specs.Factor);
    end
    
    hBuffer.add(', ''%s'', ', get(hfdesign, 'Response'));
end

% If we are not using dB units pass the units to the constructor.
if ~strcmpi(laState.MagnitudeUnits, 'db')
    inputs{end+1} = sprintf('''%s''', laState.MagnitudeUnits);
end

% Add all of the post specification input arguments.
hBuffer.add('%s', inputs{1});
for indx = 2:length(inputs)
    hBuffer.add(', %s', inputs{indx});
end

hBuffer.addcr(');');

% Add the design method.
hBuffer.cr;

laDOpts = getDesignOptions(this, get(this, 'LastAppliedState'));

methodName = getSimpleMethod(this, laState);

hBuffer.add('Hd = design(h, ''%s''', methodName);

set(hfdesign, 'Specification', spec);
defaultDOpts = designopts(hfdesign, methodName);
for indx = 1:2:length(laDOpts)
    
    % If the last applied design option is the default, do not bother
    % adding it to the input list of DESIGN.
    if isequal(defaultDOpts.(laDOpts{indx}), laDOpts{indx+1})
        continue;
    end
    hBuffer.addcr(', ...');
    if isnumeric(laDOpts{indx+1})
        if length(laDOpts{indx+1})==1
            laDOpts{indx+1} = num2str(laDOpts{indx+1});
        else
            laDOpts{indx+1} = mat2str(laDOpts{indx+1});
        end
    elseif islogical(laDOpts{indx+1})
        if laDOpts{indx+1}
            laDOpts{indx+1} = 'true';
        else
            laDOpts{indx+1} = 'false';
        end
    else
        if ischar(laDOpts{indx+1})
            laDOpts{indx+1} = ['''' laDOpts{indx+1} ''''];
            if ~strcmpi(laDOpts{indx}, 'sosscalenorm')
                laDOpts{indx+1} = lower(laDOpts{indx+1});
            end
        else
            % Add code to support cell arrays made of a string or function
            % handle and a number (e.g. FIR window design with a Chebyshev
            % window)
            if iscell(laDOpts{indx+1})
                temp = laDOpts{indx+1};
                aux = '{';
                for i=1:length(temp),
                    if isnumeric(temp{i}),
                        temp{i} = num2str(temp{i});
                    elseif ischar(temp{i}),
                        temp{i} = ['''' temp{i} ''''];
                    elseif strcmpi(class(temp{i}),'function_handle')
                         temp{i} = ['@' char(temp{i})];
                    end
                    aux = [aux temp{i} ','];
                end
                laDOpts{indx+1} = [aux(1:end-1) '}']; % Remove last coma
            end
        end
    end
    hBuffer.add('    ''%s'', %s', laDOpts{indx}, laDOpts{indx+1});
end
hBuffer.add(');');

if ~isempty(this.FixedPoint)
    hBuffer.cr;
    hBuffer.cr;
    hBuffer.add(getMCodeBuffer(this.FixedPoint, this.LastAppliedFilter));
end

% [EOF]
