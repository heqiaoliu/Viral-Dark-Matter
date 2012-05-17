function msg = pmessage(this, msg)
%PMESSAGE: error message for setting Parameters structure
%This file generates the common error message for errors encountered 
%when setting Parameters.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:24:48 $

% Author(s): Qinghua Zhang

lastmsg = sprintf('Type "idprops %s" for a description of parameters of %s object.', ...
    class(this), upper(class(this)));

instruction = ['To change the dimensions of the fields of the "Parameters" property in a consistent way or to fill up its default empty fields, do the following:\n',...
    ' (1) Extract the current value of "Parameters" property\n',...
    ' (2) Modify the fields of the extracted structure\n',...
    ' (3) Set the modified structure as the value of the "Parameters" property.'];
msg.message = sprintf('%s\n\n%s %s',msg.message,instruction,lastmsg);