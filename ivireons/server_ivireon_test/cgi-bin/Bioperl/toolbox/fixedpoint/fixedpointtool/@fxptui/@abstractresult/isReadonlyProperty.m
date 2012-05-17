function disabled = isReadonlyProperty(h, propName)
%ISREADONLYPROPERTY returns true if for uneditable list view properties

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/02/20 01:10:14 $

disabled = true;
if(h.hasproposedfl && (strcmpi('ProposedFL',propName) || strcmpi('ProposedDT',propName) ||strcmpi('Accept',propName)))
  disabled = false;
end

% [EOF]
