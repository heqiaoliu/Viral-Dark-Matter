function val = pSetClusterOsType(obj, val) %#ok<INUSL>
; %#ok Undocumented

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/11/09 19:51:03 $

% All variants of PBS only support homogenous environments. Note that we
% don't attempt to change the parallel wrapper script here since the cluster
% os type cannot be changed after object creation

if ispc
    allowedVal = 'pc';
else
    allowedVal = 'unix';
end

if ~strcmpi( val, allowedVal )
    error( 'distcomp:pbsscheduler:homogenousCluster', ...
           'PBS schedulers may only be used with homogenous clusters' );
end
