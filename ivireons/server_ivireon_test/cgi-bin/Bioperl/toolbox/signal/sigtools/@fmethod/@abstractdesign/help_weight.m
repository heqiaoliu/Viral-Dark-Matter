function help_weight(this, varargin)
%HELP_WEIGHT

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:42:25 $

for indx = 1:length(varargin)

    name = varargin{indx};

    if strcmpi(name, 'weights')
        weight_str = getvectorstr;
    else
        weight_str = getnamestr(name);
    end
    
    disp(weight_str);
    disp(' ');
end

% -------------------------------------------------------------------------
function weight_str = getvectorstr

weight_str = sprintf('%s\n%s', ...
    '    HD = DESIGN(..., ''Weights'', WEIGHTS) uses the weights in WEIGHTS to weight', ...
    '    the error of each band in the design.  WEIGHTS is a vector of ones by default.');

% -------------------------------------------------------------------------
function weight_str = getnamestr(name)

num = str2num(name(end));

if isempty(num)
    num = '';
    edge = name(2:end);
else
    if num == 1
        num = '1st ';
    elseif num == 2
        num = '2nd ';
    end
    edge = name(2:end-1);
end

weight_str = sprintf('%s\n%s', ...
    sprintf('    HD = DESIGN(..., ''%s'', %s) weights the %s%sband by %s.', ...
    name, upper(name), num, edge, upper(name)), ...
    sprintf('    %s is 1 by default.', upper(name)));

% [EOF]
