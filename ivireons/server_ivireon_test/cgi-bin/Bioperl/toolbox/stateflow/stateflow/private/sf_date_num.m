function dateNum = sf_date_num(dateStr)
% DATENUMVAL = SF_DATE_NUM(DATESTR)
% wrapper around datenum

% Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.6.2.3 $  $Date: 2008/12/01 08:07:08 $

% Must get rid of this function once G56149 is fixed.
% Calls datenum in a try catch and if there is an error
% (i.e, on international UNIX machines) reverts to
% returning 0.0
%

persistent sDateNumError

if(isequal(sDateNumError,1))
   dateNum = 0.0;
else
   try
      dateNum = datenum(dateStr);
   catch ME
      dateNum = 0.0;
      sDateNumError = 1;
   end
end
