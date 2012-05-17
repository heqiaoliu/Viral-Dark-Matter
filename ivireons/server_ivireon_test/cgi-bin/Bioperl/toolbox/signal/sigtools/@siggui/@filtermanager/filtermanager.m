function this = filtermanager
%FILTERMANAGER   Construct a FILTERMANAGER object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:10:15 $

this = siggui.filtermanager;

% Create a vector object to store all the filter structures.
this.Data = sigutils.vector;

% [EOF]
