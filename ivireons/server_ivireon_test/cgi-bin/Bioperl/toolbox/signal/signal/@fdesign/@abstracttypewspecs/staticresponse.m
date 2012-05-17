function staticresponse(this, hax, magunits)
%STATICRESPONSE   

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:22 $

if nargin < 2, hax      = gca;  end
if nargin < 3, magunits = 'db'; end
if ischar(hax),
    magunits = hax;
    hax      = gca;
end

staticresponse(this.CurrentSpecs, hax, magunits);

% [EOF]
