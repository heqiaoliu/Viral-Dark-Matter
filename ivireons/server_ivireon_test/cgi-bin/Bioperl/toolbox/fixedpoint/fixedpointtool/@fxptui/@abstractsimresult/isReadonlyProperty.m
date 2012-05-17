function disabled = isReadonlyProperty(h, propName)
%ISREADONLYPROPERTY returns true if for uneditable list view properties

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/08/08 12:52:46 $

disabled = true;
if(strcmp('LogSignal', propName) && h.isinnextrun)
  disabled = false;
  return;
end
if((strcmp('ProposedFL',propName) || strcmp('ProposedDT',propName) ||  strcmp('Accept',propName)) && h.hasproposedfl)
  disabled = false;
end

% [EOF]
