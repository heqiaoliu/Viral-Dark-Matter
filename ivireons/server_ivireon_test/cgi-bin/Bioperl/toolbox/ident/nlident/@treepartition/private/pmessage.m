function msg = pmessage(this, msg)
%PMESSAGE: error message for setting Parameters structure
%This file generates the common error message for errors encountered 
%when setting Parameters.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/10/16 04:57:09 $

% Author(s): Qinghua Zhang

lastmsg = sprintf('Type "idprops %s" for a description of parameters of %s object.', ...
    class(this), upper(class(this)));

instruction = ['To change the dimensions of the fields of the "Parameters" property in a consistent way or to fill up its default empty fields, do the following:\n',...
    ' (1) Extract the current value of "Parameters" property as a new MATLAB variable\n',...
    ' (2) Modify the fields of the extracted structure such that they are dimensionally consistent\n',...
    ' (3) Set the modified structure as the value of the "Parameters" property.'];
msg.message = sprintf('%s\n\n%s\n%s',msg.message,instruction,lastmsg);