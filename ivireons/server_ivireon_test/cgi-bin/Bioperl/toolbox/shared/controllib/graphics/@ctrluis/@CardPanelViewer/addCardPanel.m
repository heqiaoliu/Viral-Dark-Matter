function addCardPanel(this,Panel,varargin)
% addCardPanel Adds Panel to list for cardpanelviewer
% 
% addCardPanel(this,Panel)   adds cardpanel to the end
% addCardPanel(this,Panel,idx)

%   Author(s): Craig Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:14 $

if isequal(nargin,1)
    Panel = uipanel('parent',this.MainPanel);
end

set(Panel,'units','normalized','position',this.CardPosition, ...
    'visible', 'off', 'parent',this.MainPanel,this.CardPanelBorderProperties{:});

if nargin < 3 || (varargin{1} > length(this.CardPanels))
    this.CardPanels = [this.CardPanels; Panel];
else
    idx = varargin{1};
    this.CardPanels = [this.CardPanels(1,1:idx-1);Panel;this.CardPanels(1,idx:end)];
end
