function varargout = installDataHandler(this, varargin)
%INSTALLDATAHANDLER Install the data handler.
%   installDataHandler(this) Installs the data handler for the current
%   visual.  Returns true if the handler fails to install.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/03/30 23:59:08 $

if nargin < 2
    hVisual = this.Application.Visual;
    hNewHandler = getDataHandler(this, hVisual);
elseif isa(varargin{1}, 'uiscopes.AbstractVisual')
    hVisual = varargin{1};
    hNewHandler = getDataHandler(this, hVisual);
else
    hNewHandler = varargin{1};
end

%Handle errors
this.ErrorStatus = hNewHandler.ErrorStatus;
this.ErrorMsg    = hNewHandler.ErrorMsg;
if strcmpi(this.errorStatus,'failure')
    success = false;
else
    success = true;
end

if success
    
    this.Data = hNewHandler.Data;
    
    if ~isempty(this.DataHandler)

        % Make sure we delete any old DCS objects.
        delete(this.DataHandler);
    end
    this.DataHandler = hNewHandler;
end

if nargout
    varargout = {success};
end

% [EOF]
