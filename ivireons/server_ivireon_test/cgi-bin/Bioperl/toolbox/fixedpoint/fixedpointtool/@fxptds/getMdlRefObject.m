function blkobj = getMdlRefObject(data)
%GETMDLREFOBJECT Get the mdlref block object for which a signal is logged.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/20 07:53:50 $

mdlref = get_param(data.ModelReference, 'Object');
load_system(mdlref.ModelName);
refpth = data.Signal.BlockPath;
blkpth = strrep(refpth, data.ModelReference, mdlref.ModelName);
blkobj = get_param(blkpth, 'Object');

% [EOF]
