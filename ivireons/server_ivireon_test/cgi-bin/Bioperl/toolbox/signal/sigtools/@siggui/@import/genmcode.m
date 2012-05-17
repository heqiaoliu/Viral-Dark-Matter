function b = genmcode(h)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/01/25 22:53:21 $

hcs = find(h, '-class', 'siggui.coeffspecifier');

% Get the constructor from the Filter Structure popup
object = getshortstruct(hcs,'object');

if strcmpi(hcs.SOS, 'on')
    object = [object 'sos'];
end

coeffs = getselectedcoeffs(hcs);

% Loop over the coefficients and convert them to a string of numbers.
isobj = false;
for indx = 1:length(coeffs)
    [coeffs{indx}, msg] = evaluatevars(coeffs{indx});
    if ~isempty(find(findstr(msg, 'is not numeric.'))),
        errStr = '';
    end
    if isa(coeffs{indx}, 'dfilt.basefilter'),
        isobj = true;
    end
    
    if ~isobj
        coeffs{indx} = num2str(coeffs{indx}(:)');
    else
        try
            b = genmcode(coeffs{1});
        catch
            b = '';
        end
        return
    end
end

% Get the labels from the coefficient specifier
labels = getcurrentlabels(hcs);
for indx = 1:length(labels)
    labels{indx}(end) = [];
    sindx = strfind(labels{indx}, ' ');
    labels{indx}(sindx) = '_';
end

for indx = 1:length(coeffs)
    coeffs{indx} = sprintf('[%s]', coeffs{indx});
    
    % Remove all the extra spaces.
    [s, f] = regexp(coeffs{indx}, ' + ');
    idx = [];
    for jndx = 1:length(s)
        idx = [idx s(jndx)+1:f(jndx)];
    end
    
    coeffs{indx}(idx) = [];
    descs{indx} = sprintf('%s coefficient vector', labels{indx});
end

% Format the labels and coeffs.
inputs = sprintf('%s, ', labels{:});
inputs(end-1:end) = [];

b = sigcodegen.mcodebuffer;
b.addcr(b.formatparams(labels, coeffs, descs));
b.cr;
b.addcr('Hd = %s(%s);', object, inputs);

% [EOF]
