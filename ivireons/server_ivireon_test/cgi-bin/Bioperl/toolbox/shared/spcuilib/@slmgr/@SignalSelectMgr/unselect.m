function unselect(this, varargin)
%UNSELECT Unselect the specified lines.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:29 $

signals = get(this, 'Signals');

if ~isempty(signals)
    unselect(signals, varargin{:});
end

% [EOF]
