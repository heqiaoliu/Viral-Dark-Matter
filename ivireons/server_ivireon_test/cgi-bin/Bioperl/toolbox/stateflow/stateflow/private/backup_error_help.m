function backup_error_help
%CYCLE_ERROR_HELP
%   Opens up Stateflow model sf_backup_undesirable.mdl
%   which illustrates a couple of commonly found
%   cycle(loop) flow-graph constructs which are 
%   not allowed by Stateflow 3.0 and shows how to
%   fix them.

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/10/08 18:22:24 $
modelName = 'sf_backup_undesirable';
open_system(modelName);
