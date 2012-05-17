function addfilter(this, varargin)
%ADDFILTER Add a filter to FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.5 $  $Date: 2007/12/14 15:21:28 $

error(nargchk(2,inf,nargin,'struct'));

filters = findfilters(this, varargin{:});

if isempty(filters(1).Fs),
    maxfs = max(get(this, 'Fs'));
    if isnan(maxfs)
        maxfs = 1;
    end
    for indx = 1:length(filters)
        set(filters(indx), 'Fs', maxfs);
    end
end

hFVT = getcomponent(this, 'fvtool');

hFVT.addfilter(filters);

% [EOF]
