function add(this, varargin)
%ADD Add extension type to type database.
%  ADD(hRegisterDb,T1,T2,...) adds RegisterType objects T1, T2, ...,
%  to extension database with handle hRegisterDb.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:47 $

if nargin < 2
    return;
end

if ~isa(varargin{1}, getChildClass(this))
    varargin = {feval(getChildClass(this), varargin{:})};
end

% One or more RegisterType objects passed
for i=1:numel(varargin)
    hRegisterType = varargin{i};
    if ~isa(hRegisterType, getChildClass(this))
        error(generatemsgid('InvalidChild'), 'Extension type must be an RegisterType object');
    end
    
    % See if type is already present in database
    % If so, remove these
    if ~isempty(findType(this, hRegisterType.Type))
        remove(this, 'Type', hRegisterType.Type);
    end
    
    % Connect property to object
    %  newType is "down" from h,
    %  but h must appear first in the connect method,
    %  so we write:
    connect(hRegisterType,this,'up');
end

% [EOF]
