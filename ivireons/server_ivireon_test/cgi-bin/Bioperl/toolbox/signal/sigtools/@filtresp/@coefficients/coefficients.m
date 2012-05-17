function h = coefficients(varargin)
%COEFFICIENTS Constructor
%   COEFFICIENTS(FILTOBJ) Construct a coeffview object using FILTOBJ

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.6 $  $Date: 2004/12/26 22:18:37 $

h = filtresp.coefficients;

allPrm = h.super_construct(varargin{:});
h.FilterUtils = filtresp.filterutils(varargin{:});
findclass(findpackage('dspopts'), 'sosview'); % g 227896
addprops(h, h.FilterUtils);

set(h, 'Name', 'Filter Coefficients')

opts = {'Decimal', 'Hexadecimal'};
if isfixptinstalled
    opts{end+1} = 'Binary';
end

createparameter(h, allPrm, 'Coefficient Display', 'coefficient', opts);

% [EOF]
