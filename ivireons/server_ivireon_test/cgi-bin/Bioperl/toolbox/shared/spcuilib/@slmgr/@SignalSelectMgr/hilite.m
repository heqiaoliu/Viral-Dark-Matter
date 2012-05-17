function hilite(this, varargin)
%HILITE   Hilite the selected signals and their blocks.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:20 $

signals = get(this, 'Signals');

if ~isempty(signals)
    hilite(signals, varargin{:});
end

% [EOF]
