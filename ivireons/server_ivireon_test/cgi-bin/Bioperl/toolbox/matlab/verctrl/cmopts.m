function out = cmopts(variableName)
%CMOPTS Version control settings.
%   CMOPTS returns the name of your version control system. To specify the
%   version control system, select Preferences from the File menu.
%
%   OUT=CMOPTS('VARIABLENAME') returns the setting for VARIABLENAME
%   as a string OUT.
%
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CUSTOMVERCTRL, CLEARCASE,
%   PVCS, and RCS.

%   Author(s): Vaithilingam Senthil
%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/02/29 12:46:54 $

[lwarn, lwarnid] = lastwarn;
warnState = warning('off', 'all');
try
  import com.mathworks.services.Prefs;
  prefs = char(Prefs.getStringPref(Prefs.SOURCE_CONTROL_SYSTEM, 'None'));
catch anError
  prefs = 'None';
end
lastwarn(lwarn, lwarnid);
warning(warnState);

if nargin == 0
  out = prefs;
  return;
else
  try
	out = eval(variableName);
  catch
	error('MATLAB:sourceControl:variableNotDefined','''%s'' is not defined.' ,variableName);
  end
end
