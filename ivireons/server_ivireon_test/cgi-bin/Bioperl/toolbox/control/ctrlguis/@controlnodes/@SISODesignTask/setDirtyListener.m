function setDirtyListener(this)
% Used to set the project dirty after data is changed

%   Copyright 2004-2008 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2008/06/13 15:13:58 $

L = [handle.listener(this.sisodb.LoopData,'LoopDataChanged',{@localDataChanged this}); ...
    handle.listener(this,this.findprop('Dirty'),'PropertyPostSet',{@localDirtyChanged this})];
this.DirtyListener = L;

end

function localDataChanged(es,ed,this)
% set project dirty and turn off listener
    this.setDirty(true);
    this.DirtyListener(1).Enabled = 'off';
end

function localDirtyChanged(es,ed,this)
if ~this.Dirty
    % Project no longer dirty. Turn listener back on
    this.DirtyListener(1).Enabled = 'on';
end
    
end