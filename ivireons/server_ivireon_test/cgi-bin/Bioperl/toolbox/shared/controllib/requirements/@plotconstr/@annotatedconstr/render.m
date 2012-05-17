function render(Constr, varargin)
%RENDER   Sets the text and location of the annotation type constraint

%   Author(s): A. Stothert
%   Revised: 
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:16 $

% Get axes info
hGroup  = Constr.Elements;
HostAx  = handle(hGroup.Parent);
HostFig = HostAx.Parent;

if ~Constr.Activated
   % Initialize when constraint is not activated yet (preset for Activated=1)
   % Construct the constraint text
   hText = text(...
      'parent',double(hGroup),...
      'Tag','ConstraintText',...
      'HelpTopicKey', Constr.HelpData.CSHTopic,...
      'ButtonDownFcn', Constr.ButtonDownFcn,...
      'UIContextMenu', Constr.addmenu(HostFig),...
      'XlimInclude','off',...
      'YlimInclude','off');
end

%Set Text to display and position
hChildren = hGroup.Children;
Tags = get(hChildren,'Tag');
idx = strcmp(Tags,'ConstraintText');

%Set text
dispText = Constr.describe('detail');
set(hChildren(idx), ...
   'String',sprintf('%s ',dispText));

%Set position
AxLim = [HostAx.Xlim, HostAx.Ylim];
set(hChildren(idx),...
   'BackgroundColor', Constr.PatchColor, ...
   'HorizontalAlignment','right', ...
   'Margin', 0.1, ...
   'Position', [AxLim(2), 0.5*AxLim(3)+0.5*AxLim(4), Constr.Zlevel]);


