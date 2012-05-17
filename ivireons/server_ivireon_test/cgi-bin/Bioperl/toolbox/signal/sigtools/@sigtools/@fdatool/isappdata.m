function boolflag = isappdata(hFDA,fieldname)
%ISAPPDATA  True if application-defined data exists.
%   ISAPPDATA(hFDA, FIELDNAME) Returns true if FIELDNAME exists as
%   an application-defined field associated with hFDA.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:21:14 $

error(nargchk(2,2,nargin,'struct'));

data = get(hFDA,'ApplicationData');

boolflag = isfield(data,fieldname);

