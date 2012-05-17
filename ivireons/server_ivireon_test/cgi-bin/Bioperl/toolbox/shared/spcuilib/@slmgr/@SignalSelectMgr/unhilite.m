function unhilite(this)
%UNHILITE Unhilite the selected signals.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:28 $

signals = get(this, 'Signals');

if ~isempty(signals)
    unhilite(signals);
end

% [EOF]
