function cmd = buildImportCommand(this, bImport)
%BUILIMPORTCOMMAND Create the command that will be used to import the data.
%   This function should be overridden to be useful.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: This indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/19 02:55:39 $

    cmd = '';
    set(this.filetree, 'matlabCmd', cmd);

end
