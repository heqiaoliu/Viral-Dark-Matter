function [filters, hasfs] = findfilters(this, varargin)
%FINDFILTERS   Find the filters in the input.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/07/27 20:32:24 $

Fs = [];
for indx = 1:length(varargin)
    if ischar(varargin{indx}) && strcmpi(varargin{indx}, 'fs'),
        Fs = varargin{indx+1};
        varargin(indx:end) = [];
        break;
    end
end

if ispref('SignalProcessingToolbox', 'DefaultFs'),
    defaultFs = getpref('SignalProcessingToolbox', 'DefaultFs');
else
    defaultFs = 1;
end

hfvt = getcomponent(this, 'fvtool');

[filters, index] = hfvt.findfilters(varargin{:});
for indx = index.object
    
    % Copy the filter, but make sure we keep the mask info.
    mi = [];
    if isprop(filters(indx).Filter, 'MaskInfo')
        mi = get(filters(indx).Filter, 'MaskInfo');
    end
    filters(indx).Filter = copy(filters(indx).Filter);
    if ~isempty(mi)
        schema.prop(filters(indx).Filter, 'MaskInfo', 'mxArray');
        set(filters(indx).Filter, 'MaskInfo', mi);
    end
end

% Set the filter's Sampling Frequency to [] and we will fix it later
% depending on the inputs.
set(filters(setdiff(1:length(filters), index.objectwfs)), 'Fs', []);

if isempty(Fs)

    % When we don't have any filters we won't have an old Fs.  The default
    % is 1, so we use that instead.
    if isempty(this.filters) || isempty(this.Filters{1})
        oldfs = defaultFs;
    else
        oldfs = get(this, 'Fs');
    end
    
    maxindx = min(length(filters), length(oldfs));

    for indx = 1:maxindx

        % If the old Fs is not a nan and the current filter doesn't already have
        % an Fs we want to use the old Fs.
        if ~isnan(oldfs(indx)) && isempty(get(filters(indx),'Fs'))
            set(filters(indx), 'Fs', oldfs(indx));
        end
    end
    mfs = max(oldfs);
    if isnan(mfs)
        mfs = defaultFs;
    end
    for indx = maxindx+1:length(filters)
        if isempty(get(filters(indx), 'Fs'))
            set(filters(indx), 'Fs', mfs);
        end
    end

else
    if length(Fs) == 1
        set(filters, 'Fs', Fs);
    else
        if length(filters) ~= length(Fs)
            error(generatemsgid('lengthMismatch'), ...
                'Sampling Frequency must be a scalar or a vector of the same length as the number of filters in FVTool.');
        end
        for indx = 1:length(Fs)
            set(filters(indx), 'Fs', Fs(indx));
        end
    end
end

hasfs = false;
empty = [];
for indx = 1:length(filters)
    hspecs = privgetfdesign(filters(indx).Filter);
    if ~isempty(hspecs) && ~hspecs.NormalizedFrequency
        set(filters(indx), 'Fs', hspecs.Fs);
        hasfs = true;
    elseif filters(indx).Fs ~= defaultFs
        hasfs = true;
    else
        empty = [empty indx];
    end
end

if ~isempty(empty)
    hasfs = false;
    set(filters, 'Fs', defaultFs);
end

% [EOF]
