function moveDataCursor(hThis,hgObject,hDataCursor,dir)

% Copyright 2002-2008 The MathWorks, Inc.

% This should be a static function, therefore, ignore "hThis"

str = [];

% Check for a behavior object:
hB = hggetbehavior(hgObject,'datacursor','-peek');
if ~isempty(hB) && ~isempty(hB.MoveDataCursorFcn)
    hgfeval(hB.MoveDataCursorFcn,hDataCursor,dir);

% invoke class method
elseif ismethod(hgObject,'moveDataCursor')
   moveDataCursor(hgObject,hDataCursor,dir);
  
% else do default
else
   hThis.default_moveDataCursor(hgObject,hDataCursor,dir);
end


