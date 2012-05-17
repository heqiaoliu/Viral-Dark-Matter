function this = Explorer(varargin)
%EXPLORER Construct an EXPLORER object

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:16 $

% Should we make this object singleton since it is a viewer on the
% singleton object represented by extmgr.RegisterLib.

this = extmgr.Explorer;

set(this, 'CurrentNode', 'Library');

% Make sure that each of the specified registration files is updated.
for indx = 1:length(varargin)
    hLib = extmgr.RegisterLib;
    hLib.getRegisterDb(varargin{indx});
end

% [EOF]
