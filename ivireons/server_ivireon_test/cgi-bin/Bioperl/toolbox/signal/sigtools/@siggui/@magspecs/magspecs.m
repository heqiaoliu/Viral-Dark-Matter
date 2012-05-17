function this = magspecs
%MAGSPECS This is the constructor for the magspecs class.

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2004/04/13 00:24:21 $

% Use built-in constructor
this = siggui.magspecs;

% Create a labelsandvalues object
construct_mf(this, 'Maximum', 5);

% Set the version
set(this, 'version', 1.0);

settag(this)

% [EOF]
