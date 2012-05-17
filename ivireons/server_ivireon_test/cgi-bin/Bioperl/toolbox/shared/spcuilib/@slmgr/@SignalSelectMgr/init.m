function init(this, varargin)
%INIT     Initialize the objects signals.
%   INIT(THIS, SIG1, SIG2, etc.) Initialize the objects contained signals.
%   This will remove any existing signals from the DB.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:21 $

signals = get(this, 'Signals');
for indx = 1:length(signals)
    removeSignal(this, signals(indx));
end

addSignal(this, varargin{:});

% [EOF]
