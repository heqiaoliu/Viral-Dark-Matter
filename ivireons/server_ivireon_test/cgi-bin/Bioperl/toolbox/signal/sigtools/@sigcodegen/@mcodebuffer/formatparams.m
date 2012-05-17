function str = formatparams(this, params, values, descs)
%FORMATPARAMS Formats parameters
%   H.FORMATPARAMS(PARAMS, VALUES, DESCS) format the cells of strings PARAMS,
%   VALUES, and DESCS so that "PARAMS{:} = VALUES{:};  % DESCS{:}" and the
%   '=' and '%' line up.  The cell arrays must all be of the same length,
%   but DESCS can have empty entries in it.  In this case a local map will
%   be used which will determine the description from the parameter name.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/11/19 21:46:10 $

lv = length(values);

if nargin < 4,
    descs = cell(size(params));
end

if lv ~= length(params) | lv ~= length(descs)
    error(generatemsgid('lengthMismatch'), ...
        'Parameters, values and descriptions must be the same length.');
end

% Look for empty descriptions and fill them in from the map
for indx = 1:length(descs),
    if isempty(descs{indx}),
        descs{indx} = lclmap(params{indx});
    end
end

for indx = 1:lv
    values{indx} = [values{indx} ';'];
end

tempstr = [strvcat(params) repmat(' = ', lv, 1) strvcat(values)];

% If any of the strings is already over 50 characters we need to move that
% line to the bottom of the list and make its comment on the above line.
if size(tempstr, 2) > 50,
    
    % Break out the strings and deblank them so we can see which is over 50
    % characters
    ondx = []; % overflow index
    for indx = 1:size(tempstr, 1),
        cellstr{indx} = deblank(tempstr(indx, :));
        if length(cellstr{indx}) > 50,
            ondx = [ondx, indx];
        end
    end
    
    % Divide the over and under strings and their descriptions
    overstrs   = cellstr(ondx);
    overdescs  = descs(ondx);
    understrs  = cellstr;
    underdescs = descs;
    understrs(ondx)  = [];
    underdescs(ondx) = [];
    
    % All of the under strings can just be combined with their descriptions
    tempstr = [strvcat(understrs) repmat('  % ', length(understrs), 1) strvcat(underdescs)];
    
    % The over strings have their descriptions on the line above the
    % variable declaration.
    for indx = 1:length(overstrs),
        overstrs{indx} = sprintf('\n%% %s\n%s', overdescs{indx}, ...
            this.format(overstrs{indx}, '=', 2));
    end
    
    tempstr = strvcat(tempstr, overstrs{:});
    
else
    tempstr = [tempstr repmat('  % ', lv, 1) strvcat(descs)];
end

str = '';
for indx = 1:size(tempstr,1)
    str = sprintf('%s\n%s', str, deblank(tempstr(indx,:)));
end
str(1) = [];

% -------------------------------------------------------------------------
function desc = lclmap(param)
%Map the known parameter names to their descriptions.

indx = regexp(param, '\d');

indx = max(indx);

% Only handles a single number.
if isempty(indx) || indx ~= length(param),
    pre = '';
else
    switch str2num(param(indx))
        case 1
            pre = 'First ';
        case 2
            pre = 'Second ';
        case 3
            pre = 'Third ';
        case 4
            pre = 'Fourth ';
    end
end

param(indx) = [];
if length(param) > 5,
    switch param(end)
        case 'L'
            pre = sprintf('%sLower ', pre);
            param(end) = [];
        case 'U'
            pre = sprintf('%sUpper ', pre);
            param(end) = [];
    end
end

switch lower(param)
    case 'n'
        desc = 'Order';
    case 'nb'
        desc = 'Numerator Order';
    case 'na'
        desc = 'Denominator Order';
    case 'apass'
        desc = 'Passband Ripple (dB)';
    case 'dpass'
        desc = 'Passband Ripple';
    case 'astop'
        desc = 'Stopband Attenuation (dB)';
    case 'dstop'
        desc = 'Stopband Attenuation';
    case 'fpass'
        desc = 'Passband Frequency';
    case 'fstop'
        desc = 'Stopband Frequency';
    case 'fc'
        desc = 'Cutoff Frequency';
    case 'f6db'
        desc = '6-dB Frequency';
    case 'fs'
        desc = 'Sampling Frequency';
    case 'fo'
        desc = 'Original Frequency';
    case 'ft'
        desc = 'Target Frequency';
    case 'wpass'
        desc = 'Passband Weight';
    case 'wstop'
        desc = 'Stopband Weight';
    case 'f'
        desc = 'Frequency Vector';
    case 'a'
        desc = 'Amplitude Vector';
    case 'w'
        desc = 'Weight Vector';
    case 'r'
        desc = 'Ripple Vector';
    case 'e'
        desc = 'Frequency Edges';
    case 'g'
        desc = 'Group Delay Vector';
    case 'dens'
        desc = 'Density Factor';
    case 'in'
        desc = 'Initial Numerator';
    case 'id'
        desc = 'Initial Denominator';
    case 'l'
        desc = 'Band';
    case 'tw'
        desc = 'Transition Width';
    case 'bw'
        desc = 'Bandwidth';
    case 'q'
        desc = 'Q-factor';
    case 'match'
        desc = 'Band to match exactly';
    otherwise
        desc = '';
end

desc = sprintf('%s%s', pre, desc);

if isempty(desc)
    desc = ' ';
end

% [EOF]
