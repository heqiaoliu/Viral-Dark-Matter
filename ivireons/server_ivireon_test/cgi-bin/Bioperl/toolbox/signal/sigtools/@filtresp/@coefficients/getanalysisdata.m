function [strs, dummy] = getanalysisdata(this)
%GETANALYSISDATA Returns the strings in the text box.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2009/07/27 20:32:04 $

if isempty(this.Filters),
    strs = {''};
else

    filtobj = get(this.Filters, 'Filter');
    if ~iscell(filtobj), filtobj = {filtobj}; end
    strs = cell(size(filtobj));

    for indx = 1:length(filtobj)
        fmt = {this.Format};
        if showpoly(this.FilterUtils) && ispolyphase(filtobj{indx})
            Hd = polyphase(filtobj{indx}, 'objects');
            for jndx = 1:length(Hd)
                strs{indx} = strvcat(strs{indx}, ...
                    lclformat(coeffviewstr(Hd(jndx), fmt{:}), ...
                    sprintf('Polyphase (%d)', jndx)), ' ');
            end
            strs{indx}(end, :) = [];
        else
            strs{indx} = coeffviewstr(filtobj{indx}, fmt{:});
            if showref(this.FilterUtils) && isquantized(filtobj{indx}) && ...
                    ~isa(filtobj{indx}, 'mfilt.abstractcic')
                strs{indx} = strvcat(lclformat(strs{indx}, 'Quantized'), ' ', ...
                    lclformat(coeffviewstr(reffilter(filtobj{indx}), fmt{:}), 'Reference'));
            end
        end
    end
end

dummy = [];

% -------------------------------------------------------------------------
function str = lclformat(str, pre)

str = cellstr(str);
for jndx = 1:length(str)
    if ~isempty(strfind(str{jndx}, ':'))
        str{jndx} = sprintf('%s %s', pre, str{jndx});
    end
end
str = strvcat(str{:});

% [EOF]
