function h = magspecsul
%MAGSPECSUL Construct a MAGSPECSUL object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:28:01 $

h = siggui.magspecsul;
settag(h);

% Create the first labelsandvalues
hu = siggui.labelsandvalues;
settag(hu, 'Upper');

% Create the second labelsandvalues
hl = siggui.labelsandvalues;
settag(hl, 'Lower');

addcomponent(h, [hu hl]);

% [EOF]
