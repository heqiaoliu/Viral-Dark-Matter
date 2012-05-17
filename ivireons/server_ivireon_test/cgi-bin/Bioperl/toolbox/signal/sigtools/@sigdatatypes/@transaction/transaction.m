function h = transaction(hObj, varargin)
%TRANSACTION Set up a transaction that listens to a single object

%   Author(s): D. Foti & J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2008/12/04 23:24:35 $

error(nargchk(1,inf,nargin,'struct'));

h = sigdatatypes.transaction(hObj);

% close the transaction so it is no longer in the tree of current transactions.
h.commit;

allProps = hObj.classhandle.properties;

for i = 1:length(varargin)
    allProps = find(allProps, '-not', 'Name', varargin{i});
end

allProps = find(allProps, 'AccessFlags.PublicSet', 'on');

% Set up the pre and post set listener to capture the transaction
plistener = handle.listener(hObj, allProps, ...
    'PropertyPreSet', @captureSetOp);

set(plistener, 'CallbackTarget', h);

set(h, 'PropertyListeners', plistener);
set(h, 'Object', hObj);

% ---------------------------------------------------------------
function captureSetOp(hT, hEvent)
% Capture the set operation through a transaction

hT.Property{end+1} = hEvent.Source.Name;
hT.OldValue{end+1} = get(hT.Object, hT.Property{end});
hT.NewValue{end+1} = hEvent.NewValue;

% [EOF]
