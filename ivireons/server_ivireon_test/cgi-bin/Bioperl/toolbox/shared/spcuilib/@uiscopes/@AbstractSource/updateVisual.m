function updateVisual(this)
%UPDATEVISUAL Update the visual with the source's new data
% 
%   UPDATEVISUAL(this)

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:44:14 $

if ~isempty(this.Application.Visual) && this.IsSourceValid
    update(this.Application.Visual);
    postUpdate(this.Application.Visual);
end

% [EOF]
