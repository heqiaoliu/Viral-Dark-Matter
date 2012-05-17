function msg = exportheader_construct(hEH, varargin)
%EXPORTHEADER_CONSTRUCT Constructor for exportheader

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2005/12/22 19:04:12 $

[filtobj, msg] = parse_inputs(varargin{:});
if ~isempty(msg), return; end

% Instantiate the components of the exportheader object
addcomponent(hEH, siggui.datatypeselector);
addcomponent(hEH, siggui.varsinheader);

% Install Listeners
install_listeners(hEH)

% Filter is set after the listeners are installed so that the
% filter_listener will fire
hEH.Filter = filtobj;


% -------------------------------------------------
function install_listeners(hEH)

listen = handle.listener(hEH, hEH.findprop('Filter'), ...
    'PropertyPostSet', @filter_listener);

set(listen, 'CallbackTarget', hEH);

set(hEH, 'Listeners', listen);


% -------------------------------------------------
function [filtobj, msg] = parse_inputs(varargin)

msg       = nargchk(1,2,nargin);

if ~isempty(msg), 
    filtobj = [];
    return; 
end

filtobj   = varargin{1};

if ~isa(filtobj, 'dfilt.singleton'),
    msg = 'A filter object must be specified.';
end    

% [EOF]
