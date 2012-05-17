function installSourceName(this, fullName)
%INSTALLSOURCENAME update data source name for display

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:46:43 $

this.Name      = no_cr(fullName);
this.NameShort = no_cr(get_param(fullName, 'Name'));

% --------------------------------------------------------
function y = no_cr(y)

y(y==sprintf('\n')) = ' ';

% [EOF]
