
function str = tostring(this)
%TOSTRING

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/11/13 05:03:50 $

[s fn] = getdesignoptstostring(this);

nfields = length(fn);
value   = cell(1,nfields);
for nc = 1:length(fn),
    val = s.(fn{nc});
    if iscell(val),
        str = ['{',tostr(val{1})];
        for k = 2:length(val),
            str = [str,[', ',tostr(val{k})]]; %#ok<*AGROW>
        end
        str = [str,'}'];
        value{nc} = str;
    elseif isscalar(val) && ishandle(val) && ~isnumeric(val)
        childfn = fieldnames(val);
        tempfn  = cell(size(childfn));
        tempval = cell(size(childfn));
        nfields = nfields + length(childfn) - 1;
        for jndx = 1:length(childfn)
            name = designoptstostringnames(childfn{jndx});
            tempfn{jndx}  = sprintf('%s', name);
            tempval{jndx} = tostr(val.(childfn{jndx}));
        end
        fn{nc}    = strvcat(tempfn); %#ok<*VCAT>
        value{nc} = strvcat(tempval);
    else
        value{nc} = tostr(val);
        fn{nc} = designoptstostringnames(fn{nc});
    end    
end
if ~isempty(fn),
    str = [strvcat(fn) repmat(' : ', nfields, 1) strvcat(value)];
else
    str = '';
end

%--------------------------------------------------------------------------
function str = tostr(val)
if isnumeric(val) && ~isempty(val),
    str = num2str(val);
elseif islogical(val) && val,
    str = 'true';
elseif islogical(val),
    str = 'false';
elseif isempty(val),
    str = ' ';
elseif isa(val,'function_handle'),
    str = ['@',func2str(val)];
else
    if strcmp(val,'Not used')
        val = lower(val);
    end
    str = val;
end
%--------------------------------------------------------------------------
function nameOut = designoptstostringnames(nameIn)
switch nameIn
    case 'MatchExactly'
        nameOut = 'Match Exactly';
    case 'SOSScaleNorm'
        nameOut = 'Scale Norm';
    case 'sosReorder'
        nameOut = 'Reorder Rule';
    case 'MaxNumerator'
        nameOut = 'Maximum Numerator Value';
    case 'NumeratorConstraint'
        nameOut = 'Numerator Constraint';
    case 'OverflowMode'
        nameOut = 'Overflow Mode';
    case 'ScaleValueConstraint'
        nameOut = 'Scale Value Constraint';
    case 'MaxScaleValue'
        nameOut = 'Maximum Scale Value';
    case 'DensityFactor'
        nameOut = 'Density Factor';
    case 'MaxPhase'
        nameOut = 'Maximum Phase';
    case 'MinOrder'
        nameOut = 'Minimum Order';
    case 'MinPhase'
        nameOut = 'Minimum Phase';
    case 'StopbandDecay'
        nameOut = 'Stopband Decay';
    case 'StopbandShape'
        nameOut = 'Stopband Shape';
    case 'UniformGrid'
        nameOut = 'Uniform Grid';
    otherwise
        nameOut = nameIn;
end
    

% [EOF]

