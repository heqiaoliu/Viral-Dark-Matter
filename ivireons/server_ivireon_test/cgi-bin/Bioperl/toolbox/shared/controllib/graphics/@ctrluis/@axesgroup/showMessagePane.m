function showMessagePane(this,Flag,Component)
% showMessagePane  Shows message pane

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:42 $

if isempty(this.MessagePane)
    this.MessagePane = ctrluis.PopupPanel(ancestor(this.Parent,'Figure'));
    L = handle.listener(this,this.findprop('Visible'),'PropertyPostSet',{@localVisChange this});
    this.MessagePane.addListeners(L);
end

if Flag
    this.MessagePane.setPanel(Component)
    this.messagepanepos;
    this.MessagePane.setVisible(true)
    this.MessagePane.showPanel;
else
    this.MessagePane.setVisible(false);
end
end

function localVisChange(es,ed,this)
    if strcmpi(this.Visible,'off')
        this.showMessagePane(false)
    end
end