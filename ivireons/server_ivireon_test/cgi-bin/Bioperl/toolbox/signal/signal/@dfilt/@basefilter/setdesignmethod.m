function setdesignmethod(this, designmethod)
%SETDESIGNMETHOD   Set the designmethod.

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:07:38 $

if ~ischar(designmethod),
    error(generatemsgid('MustBeAString'),'The design method must be a string.');
end

set(this, 'privdesignmethod', designmethod);

% [EOF]
