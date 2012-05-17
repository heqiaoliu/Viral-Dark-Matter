function result_listener = addlistener(varargin)
% This undocumented function may be removed in a future release.

% addlistener creates a listener and returns a reference to it.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:44:29 $

%  handle.listener syntaxes
%  ========================
%  source_handle = handle(source_obj);
%  lh = handle.listener(source_handle,...
%     'ObjectBeingDestroyed',@callback_fcn);
%  lh = handle.listener(source_handle, source_handle.findprop('propname'),...
%     'PropertyPostSet', @callback_fcn);
% G615382: Made changes to this function in order to make it both HG1 and
% HG2 compatible.
if ishandle(varargin{1})
    source_handle = handle(varargin{1});
else
    % for MCOS objects
    source_handle = varargin{1};
end
if nargin == 3
    if feature('hgusingmatlabclasses') %& ishghandle(varargin{1}) % for MCOS objects
        result_listener = event.listener(source_handle, varargin{2:end});
    elseif ishandle(source_handle)
        result_listener = handle.listener(source_handle,varargin{2:end});
    else
        eid = 'Spcuilib:uiservices:InvalidSourceHandle';
        error(eid,'invalid source handle');
    end
elseif nargin == 4
    event_type = varargin{3};
    if ~(strcmpi(event_type,'PreSet') || strcmpi(event_type,'PostSet'))
        eid = 'Spcuilib:addlistener:unknownEventType';
        error(eid,'Unknown event type passed to addlistener');
    end
    property = source_handle(1).findprop(varargin{2});
    if feature('hgusingmatlabclasses')
        % for MCOS objects
        result_listener = event.proplistener(source_handle, property, varargin{3},...
            varargin{4});
    elseif ishandle(source_handle)
        event_type = sprintf('Property%s',event_type);
        result_listener = handle.listener(source_handle,property,...
            event_type,varargin{4});
    else
        % for MCOS objects
        result_listener = event.proplistener(source_handle, property, varargin{3},...
            varargin{4});
    end
else
    eid = 'Spcuilib:addlistener:invalidSyntax';
    error(eid,'Invalid number of arguments passed to addlistener');
end
% iptaddlistener
