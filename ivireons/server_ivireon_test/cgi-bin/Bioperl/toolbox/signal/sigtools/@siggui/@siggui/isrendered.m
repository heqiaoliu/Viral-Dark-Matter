function boolflag = isrendered(h)
%ISRENDERED Returns true if the render method has been called

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:31:53 $

boolflag = ~isempty(findprop(h,'RenderedPropHandles'));

% [EOF]
