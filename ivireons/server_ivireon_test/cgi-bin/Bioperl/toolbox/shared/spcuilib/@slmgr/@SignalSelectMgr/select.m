function select(this, newState, indx)
%SELECT  Select the specified lines.

%   For multiple signals, an optional 1-based index argument
%   may be used to select a subset of signals to select.
%     SELECT(state,signalIndex)

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 08:12:22 $

if nargin<2, newState='on'; end

signals = get(this, 'Signals');

if ~isempty(signals)

    if nargin > 2
        signals = signals(indx);
    end

    select(signals, newState);
    
    % Reseed the getCurrentSystem function with the new system handle.
    % Selecting the lines does not do this for us.
    slmgr.getCurrentSystem(get(signals(1).Block, 'Parent'));
    
end

% [EOF]
