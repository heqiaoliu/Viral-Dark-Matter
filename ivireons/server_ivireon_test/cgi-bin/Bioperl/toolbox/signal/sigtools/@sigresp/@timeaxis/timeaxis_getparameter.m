function hPrm = timeresp_getparameter(hObj, varargin)
%TIMERESP_GETPARAMETER

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:07 $

hPrm = abstract_getparameter(hObj, varargin{:});
if nargin < 2 || ~strcmpi(varargin{1}, '-all') && ~isempty(hPrm) && nargin == 1, 
    %Only return plottype if it was asked for
    hPrm = find(hPrm, '-not', 'tag', 'plottype');
end

% [EOF]
