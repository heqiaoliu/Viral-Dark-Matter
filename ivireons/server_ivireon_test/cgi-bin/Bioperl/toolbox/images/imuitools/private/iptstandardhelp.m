function iptstandardhelp(helpmenu)
%iptstandardhelp Add Toolbox, Demos, and About to help menu.
%   iptstandardhelp(HELPMENU) adds Image Processing Toolbox Help,
%   Demos, and About Image Processing Toolbox to HELPMENU, which is a
%   uimenu object.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/05/14 21:58:43 $

mapFileLocation = fullfile(docroot, 'toolbox', 'images', 'images.map');

toolboxItem = uimenu(helpmenu, 'Label', 'Image Processing &Toolbox Help', ...
                     'Callback', ...
                     @(varargin) helpview(mapFileLocation, 'ipt_roadmap_page'));
demosItem = uimenu(helpmenu, 'Label', 'Image Processing Toolbox &Demos', ...
                   'Callback', @(varargin) demo('toolbox','image processing'), ...
                   'Separator', 'on');
aboutItem = uimenu(helpmenu, 'Label', 'About Image Processing Toolbox', ...
                   'Callback', @iptabout, ...
                   'Separator', 'on');
