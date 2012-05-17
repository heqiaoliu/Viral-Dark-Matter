function h = uistatus(varargin)
%UISTATUS Constructor for uistatus object. 
%    UISTATUS(NAME,PLACE,FCN) specifies status option name NAME, placement
%    PLACE, and function-handle FCN which is responsible for constructing
%    an HG status option.
%
%    One argument, hParent, is automatically passed to the function
%    FCN, so the function can instantiate a  widget parented to the
%    appropriate statusbar.  FCN may be an anonymous function.
%    A typical example of FCN is
%           @myStatusFcn
%
%    if just the default argument is needed, or
%
%           @(hParent)myStatus1Fcn(hParent)
%           @(hParent)myStatus2Fcn(hParent,userArgs)
%
%    if additional arguments, or removal of default arguments, is desired.
%    The function must return a handle; and example follows.
%
%         function y = myStatusFcn(hParent)
%         y = uistatus(hParent, ...
%             'state','CAP',...
%             'width', 40, ...
%             'text',state);
%
%    UISTATUS(NAME,PLACE), UISTATUS(NAME,FCN), and UISTATUS(NAME)
%    assume default values for PLACE (which defaults to 0) and FCN
%    which defaults to an empty function.  Note that FCN must be
%    filled in prior to rendering the status region using the render()
%    method.
%
%       % Example:
%
%       ho2 = uimgr.uistatus('Rate', @status_opt_rate);
%
%       % where the first argument is the name to use for the new UIMgr node,
%       % and the second argument is the function to call upon rendering

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/06 20:47:21 $

% Allow subclass to invoke this directly
h = uimgr.uistatus;

% Save/restore displayed text, in case it changed, for option regions
h.StateName = 'text';

% Fill in all other prop/value pairs
h.uiitem(varargin{:});

% [EOF]
