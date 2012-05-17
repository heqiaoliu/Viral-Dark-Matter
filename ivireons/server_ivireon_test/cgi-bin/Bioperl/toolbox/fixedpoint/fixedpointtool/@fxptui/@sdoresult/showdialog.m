function showdialog(h)
% Show the parameter dialog of the signal object
%
%   Author(s) : V.Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/11/13 17:57:31 $

daobj = h.daobject;
if ~isempty(daobj)
    DAStudio.Dialog(daobj,h.Path,'DLG_STANDALONE');
else
    return;
end
