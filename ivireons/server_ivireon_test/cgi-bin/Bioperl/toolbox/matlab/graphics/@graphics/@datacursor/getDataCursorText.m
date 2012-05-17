function [str] = getDataCursorText(hThis,hgObject,hDataCursorInfo,hDatatipEvent,varargin)

% This should be a static function, therefore, ignore "hThis"

% Copyright 2002-2006 The MathWorks, Inc.


str = [];
ERRMSG = {xlate('Error in custom'),xlate('datatip string function')};
        
if nargin>4
  hDatatip = varargin{1};
else
  hDatatip = [];
end

% invoke UpdateFcn defined through behavior object 
if ~isempty(get(hDataCursorInfo,'UpdateFcnCache'))
    try
       str = hgfeval(get(hDataCursorInfo,'UpdateFcnCache'),...
                hDatatip,hDatatipEvent);
    catch
        str = ERRMSG;
    end
% else invoke class method
elseif get(hDataCursorInfo,'TargetHasGetDatatipTextMethod')
    try
       str = getDatatipText(hgObject,hDatatipEvent);
    catch
       str = ERRMSG; 
    end
    
% else do default
else
   [str] = hThis.default_getDatatipText(hgObject,hDatatipEvent);
end


