function undo(t)
%UNDO  Undoes transaction.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:17 $

% Undo transaction
t.Transaction.undo;

% Evaluate refresh function
for ct=1:length(t.RootObjects)
    try
        LocalRefresh(t.RootObjects(ct));
    end
end


%---------------------------------------------

function LocalRefresh(Root)
% REVISIT: this is a workaround 

switch Root.classhandle.package.Name
case 'sisodata'
    %Force clear of all parameter specs, need to get round g162245
    sisodata.ut_ResetPSpecs(Root);
     
    % Broadcast LoopDataChanged event (triggers global update)
    Root.dataevent('all');
case 'plotconstr'
    if ishandle(Root)
        update(Root);
    end
end
