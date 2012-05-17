function str = coeffviewstr(this, varargin)
%COEFFVIEWSTR   

%   Author(s): J. Schickler
%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/03/31 17:11:32 $

pnum = get(this, 'privNum');
pden = get(this, 'privDen');
sv   = get(this, 'ScaleValues');

str  = '';

sep = '--------------------------';

for indx = 1:nsections(this)
    [num_str, den_str, sv_str] = dispstr(this.filterquantizer, ...
        pnum(indx, :).', pden(indx, :).', sv(indx), varargin{:});
    
    % Add each section.
    str = strvcat(str, ...
        sep, ...
        sprintf('Section #%d', indx), ...
        sep, ...
        'Numerator:', ...
        num_str, ...
        'Denominator:', ...
        den_str, ...
        'Gain:', ...
        sv_str);
end

% Add the output gain.
[num_str, den_str, sv_str] = dispstr(this.filterquantizer, 1, 1, sv(end), varargin{:});
str = strvcat(str, sep, 'Output Gain:', sv_str);

% [EOF]
