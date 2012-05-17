function design(this)
%DESIGN Design the filter specified.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.5 $  $Date: 2007/12/14 15:18:16 $

hDM = get(this, 'CurrentDesignMethod');
if isempty(hDM),
    buildcurrent(this);
    hDM = get(this, 'CurrentDesignMethod');
end

set(this, 'isDesigned', 1);

sendstatus(this, 'Designing Filter ... ');

try
    
    % Send the active components to the design method
    syncGUIvals(hDM, get(this, 'ActiveComponents'));
    
    % Design the filter
    data.filter = designwfs(hDM);
    data.mcode   = genmcode(hDM);
catch ME
    set(this, 'isDesigned', 0);
    throwAsCaller(ME);
end

% Send the FilterDesigned Event
send(this, 'FilterDesigned', ...
    sigdatatypes.sigeventdata(this, 'FilterDesigned', data));

sendstatus(this, 'Designing Filter ... Done');

% [EOF]
