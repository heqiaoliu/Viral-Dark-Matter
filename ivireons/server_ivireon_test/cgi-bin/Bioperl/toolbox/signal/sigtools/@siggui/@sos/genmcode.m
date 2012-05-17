function str = genmcode(hObj)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:53:26 $

% Map proper SOS scaling strings 
filtobj = get(hObj, 'Filter');
values = {sprintf('''%s''', get(hObj, 'Direction'))};

if isa(filtobj, 'dfilt.df2') | isa(filtobj, 'dfilt.df2sos'),
    
    params = {'scale', 'dir'};
    descs  = {'Scaling', 'Direction Flag'};
    
    scale = get(hObj, 'Scale');
    inputs = ', scale';
    switch scale
        case 'L-2',
            values = {'2', values{:}};
        case 'L-infinity',
            values = {'inf', values{:}};
        otherwise
            values = {'0', values{:}};
    end
else
    params = {'dir'};
    descs  = {'Direction Flag'};
    inputs = '';
end

if isa(filtobj, 'dfilt.abstractsos'),
    comments = '% Scale the second-order sections filter.';
else
    comments = '% Convert the filter to second-order sections.';
end

str = { ...
        genmcodeutils('formatparams', params, values, descs), ...
                '', ...
                comments, ...
        sprintf('Hd = sos(Hd, dir%s);', inputs), ...
    };

str = sprintf('%s\n', str{:}); str(end) = [];

% [EOF]
