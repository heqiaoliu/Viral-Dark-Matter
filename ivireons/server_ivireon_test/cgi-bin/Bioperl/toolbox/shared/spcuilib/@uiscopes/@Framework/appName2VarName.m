function varName = appName2VarName(this)
%APPNAME2VARNAME Convert the application name to a valid variable name.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:34:54 $

varName = genvarname(this.getAppName(true));

% [EOF]
