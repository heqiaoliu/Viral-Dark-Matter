function this = Config(theType,theName,theEnable,hPropertyDb)
%Config Create extension configuration object.
%  Config(TYPE,NAME,ENABLE,PROPS) creates a configuration object
%  with TYPE and NAME as specified, enabled as specified
%  by logical flag ENABLE, and with extension property database PROPS.
%  PROPS is recorded as a reference.
%
%  Config(TYPE,NAME,ENABLE) does not add any properties to the
%  configuration.
%
%  Config(TYPE,NAME,PROPS) adds properties PROPS and assumes ENABLE is
%  false.
%
%  Config(TYPE,NAME) assumes ENABLE=false and adds no properties.
%
% If no PROPS database is specified, an empty PropertyDb child is created
% and added, so that this child object will always exist.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/09/09 21:28:55 $

this = extmgr.Config;

if nargin > 0
    this.Type=theType;
    if nargin > 1
        this.Name=theName;
        if nargin > 2
            if isa(theEnable,'extmgr.PropertyDb')
                this.PropertyDb = theEnable; % theEnable is really hPropertyDb
                if nargin>3
                    % Force a "too many input arguments" error.
                    error(nargchk(1,1,2,'struct'));
                end
            else
                this.Enable = theEnable;
                if nargin>3
                    this.PropertyDb = hPropertyDb;
                end
            end
        end
    end
end

% Make sure an PropertyDb is always in .PropertyDb,
% even if we must make an empty one
if isempty(this.PropertyDb)
    this.PropertyDb = extmgr.PropertyDb;
end

% [EOF]
