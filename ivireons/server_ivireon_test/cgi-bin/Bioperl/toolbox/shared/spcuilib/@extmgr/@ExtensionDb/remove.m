function remove(this, hRegister, varargin)
%REMOVE Remove instance-specific copy from extension list.
%  REMOVE(hExtensionDb,hRegister) removes one child from instance list.
%  No error occurs if instance does not exist.
%
%  REMOVE(hExtensionDb) removes all children from instance list.
%
%     Calls disableExtension() method before disconnecting,
%     which in turns calls an empty disable() overload on Extension
%     extension instance.  Extension developers can overload
%     the disable() for termination actions.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/09/09 21:29:01 $

% The extension might never have been enabled
%
% Upon exit of this function, the instance of hRegister goes
% out of scope and triggers destructor

if nargin<2
    % Remove all instances
    iterator.visitImmediateChildrenBkwd(this, ...
        @(hExtension) local_remove(hExtension, varargin{:}));
else
    % Remove first Extension object with matching Register record
    % (i.e., has matching Type/Name in global Register)
    hExtension = getExtension(this, hRegister);
    if ~isempty(hExtension)
        local_remove(hExtension, varargin{:});
    end
end

% -------------------------------------------------------------------------
function local_remove(hExtension, varargin)

% Remove one extension instance from database
%
% Note there is no need for the ExtensionDb database handle.
% After disabling the child, we just disconnect child and
% the database parent simply loses this instance.
disableExtension(hExtension, varargin{:});
disconnect(hExtension);   % remove child from database
delete(hExtension);

% [EOF]
