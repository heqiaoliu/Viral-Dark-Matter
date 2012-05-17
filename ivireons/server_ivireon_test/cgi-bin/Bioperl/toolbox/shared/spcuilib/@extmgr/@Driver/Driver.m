function this = Driver(varargin)
%DRIVER  Construct an extmgr.Driver object for extension configuration system.
%   DRIVER(hAPP, REGNAME, CFGFILE) Construct an extmgr.Driver object.
%   DRIVER(..., hLOG)
%
%   Inputs:
%
%   hLOG    - Handle to a uiservices.MessageLog object.
%   hAPP    - Handle to the application object.
%   REGNAME - Registration name, e.g. 'scopext.m'
%   CFGFILE - Saved configuration file.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:26 $

this = extmgr.Driver;
if nargin > 0
    if isa(varargin{end}, 'uiservices.MessageLog')
        this.MessageLog = varargin{end};
        varargin(end) = [];
    end
    if ~isempty(varargin)
        
        % If we are passed the application and reg file, we can initialize
        % the whoel object.
        this.init(varargin{:});
    end
end

% Add a destructor to the driver to delete the objects that it connects
% (owns) to itself.  The ExtensionDb and the ConfigDb.
spcuddutils.addDestructor(this);

% [EOF]
