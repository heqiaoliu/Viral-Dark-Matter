function h = uibutton(varargin)
%UIBUTTON Constructor for a uibutton object.
%    UIBUTTON(NAME,PLACE,FCN) specifies button name NAME, placement PLACE,
%    and function-handle FCN which is responsible for constructing an
%    HG button.
%
%    One argument, hParent, is automatically passed to the function
%    FCN, so the function can instantiate a button widget parented
%    to the appropriate toolbar.  FCN may be an anonymous function.
%    A typical example of FCN is
%           @myButtonFcn
%
%    if just the default argument is needed, or
%           @(hParent)myButton1Fcn(hParent)
%           @(hParent)myButton2Fcn(hParent,userArgs)
%
%    if additional arguments, or removal of default arguments, is desired.
%    The function must return a handle; and example follows:
%
%         function y = myButton1Fcn(hParent)
%         y = uipushtool(hParent, ...
%             'cdata', openTheFileIcon, ...
%             'tooltip','Open a file...', ...
%             'click', @openTheFileAction);
%
%    UIBUTTON(NAME,PLACE), UIBUTTON(NAME,FCN), and UIBUTTON(NAME)
%    assume default values for PLACE (which defaults to 0) and FCN
%    which defaults to an empty function.  Note that FCN must be
%    filled in prior to rendering the button using the render()
%    method.
%
%   % Example:
%
%     hBut1 = uimgr.uibutton('But1');
%
%     % where the argument is the name to use for the new UIMgr node

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/07/06 20:47:13 $

% Allow subclass to invoke this directly
if (nargin>0) && isscalar(varargin{1})
    h = varargin{1};
    varargin(1) = [];
else
    h = uimgr.uibutton;
end

% State property name for (toggle) buttons
h.StateName = 'State';

% Fill in all other prop/value pairs
h.uiitem(varargin{:});

% [EOF]
