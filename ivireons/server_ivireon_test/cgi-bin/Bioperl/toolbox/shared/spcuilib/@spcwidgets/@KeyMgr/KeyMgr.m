function hKeyMgr = KeyMgr(varargin)
%KeyMgr Constructor for spcwidgets.KeyMgr
%   KeyMgr creates a key manager object that manages key presses in an
%   HG Figure window, and supplies an optional key help dialog.  Any key
%   presses in the figure will be serviced by functions specified by
%   child KeyGroup objects.
%
%   KeyMgr(TITLE,FIG) constructs a KeyHandler with title TITLE and
%   associates object with a figure with handle FIG.  The title is used
%   for the help dialog title bar.  If omitted, TITLE is set to
%   'Keyboard Command Help' and FIG is set to the current figure.
%
%   KeyMgr(TITLE), KeyMgr(FIG), and KeyMgr are supported.
%
%   Note that the Help button in the dialog is mapped to the 'doc'
%   command, with additional arguments specified via the HelpArgs
%   property.  These should be set by the client as appropriate.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/08/14 04:06:44 $

hKeyMgr = spcwidgets.KeyMgr;
defaultTitle = 'Keyboard Command Help';
if nargin==2
    theTitle = varargin{1};
    theFigure = varargin{2};
elseif nargin==1
    if ischar(varargin{1})
        theTitle = varargin{1};
        theFigure = gcf;
    else
        theTitle = defaultTitle;
        theFigure = varargin{1};
    end
elseif nargin==0
    theTitle = defaultTitle;
    theFigure = gcf;
else
    error(generatemsgid('InvalidArgs'),...
            'Too many input arguments.');
end

% Copy required arguments
hKeyMgr.Parent = theFigure;

% Initialize DialogBase properties
% to be a managed dialog
%
% Arg 2 is an application handle:
%   handle -> Managed (Multi-instance dialog)
%   empty  -> Unmanaged (Non-multi-instance dialog)
%
hKeyMgr.init(theTitle, theFigure);

% Install listener for closing dialog when object goes out of scope

% If the object goes away, close the dialog
hKeyMgr.Listeners = handle.listener(hKeyMgr, ...
    'ObjectBeingDestroyed', @(h1,e1)close(hKeyMgr));

% If Enable is changed, update the dialog (only if it's already open)
hKeyMgr.Listeners(2) = handle.listener(hKeyMgr, ...
    hKeyMgr.findprop('Enabled'), ...
    'PropertyPostSet', @(h1,ev)show(hKeyMgr,false));

% If the figure goes away, close the dialog
addlistener(hKeyMgr.Parent, 'ObjectBeingDestroyed', @(h1,e1)close(hKeyMgr));

% [EOF]
