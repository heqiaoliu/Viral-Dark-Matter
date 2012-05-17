function hPrm = getparameter(this, varargin)
%GETPARAMETER   Get the parameter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:09:44 $

hPrm = abstract_getparameter(this, varargin{:});
if nargin < 2 || ~strcmpi(varargin{1}, '-all') && ~isempty(hPrm) && nargin == 1, 
    %Only return plottype if it was asked for
    hPrm = find(hPrm, '-not', 'tag', 'montecarlo');
end

% [EOF]
