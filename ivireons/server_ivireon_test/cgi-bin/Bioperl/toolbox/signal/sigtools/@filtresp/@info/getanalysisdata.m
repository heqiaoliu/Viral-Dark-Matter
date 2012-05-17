function [strs, dummy] = getanalysisdata(this)
%GETANALYSISDATA Returns the strings in the text box.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2007/03/13 19:50:20 $

if isempty(this.Filters)
    strs = {''};
else

    filtobj = get(this.Filters, 'Filter');

    if ~iscell(filtobj), filtobj = {filtobj}; end

    % Get the info from each of the filters.
    strs = cell(size(filtobj));

    for indx = 1:length(filtobj)
        if showpoly(this.FilterUtils) && ispolyphase(filtobj{indx})
            Hd = polyphase(filtobj{indx}, 'objects');
            for jndx = 1:length(Hd)
                strs{indx} = strvcat(strs{indx}, sprintf('Polyphase (%d)', jndx), ...
                    ' ', info(Hd(jndx), 'long'), ' ');
            end
            strs{indx}(end, :) = [];
        else
            strs{indx} = info(filtobj{indx}, 'long');
        end
    end
end

dummy = [];

% [EOF]
