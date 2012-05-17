function h = hsvplot(varargin)
%HSVPLOT  Constructor for @hsvplot class.
%
%  H = HSVPLOT(AX) creates an @hsvplot object in the area occupied by the 
%  axes with handle AX.
%
%  H = HSVPLOT uses GCA as default axes.
%
%  H = HSVPLOT('Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:02 $

% Create class instance
h = resppack.hsvplot;

% Initialize Options
h.Options = struct(...
   'AbsTol',0,...
   'RelTol',1e-8,...
   'Offset',1e-8);


% Parse input list
if nargin>0 && ishghandle(varargin{1},'axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = [1 1];

% Check for hold mode
[junk,HeldRespFlag] = check_hold(h, ax, gridsize);
if HeldRespFlag
    ctrlMsgUtils.error('Controllib:plots:hsvplot1')
end

% Generic property init
init_prop(h, ax, gridsize);
%
% User-specified initial values (before listeners are installed...)
h.set(varargin{:});

% Initialize the handle graphics objects used in @hsvplot class.
h.initialize(ax, gridsize);
