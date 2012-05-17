function addListeners(this)

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2010/04/11 20:29:58 $

sisodb = this.SISODB;

this.Listeners = handle.listener(sisodb.LoopData,'ConfigChanged',...
    {@LocalUpdateConfigDisplay this});


function LocalUpdateConfigDisplay(es,ed,this)
% Update current architecture panel

import com.mathworks.mwswing.*;
import javax.swing.*;
import java.awt.*;

Config = this.SISODB.LoopData.getconfig;

if ~isequal(Config,0)
    ArchitectureIcon = ImageIcon(sisogui.getIconPath(this.SISODB.LoopData.getconfig));
    awtinvoke(this.Handles.CurrentArchitectureDescription,'setIcon',ArchitectureIcon);
end

% Update Sample Time Conversion Button
% If model is FRD disable it.
if isa(this.SISODB.LoopData.Plant.getP,'ltipack.frddata')
    setEnabled(this.Handles.C2DButton,false);
else
    setEnabled(this.Handles.C2DButton,true);
end

if this.SISODB.LoopData.Plant.isUncertain
    setEnabled(this.Handles.UncertaintyButton,true);
else
    setEnabled(this.Handles.UncertaintyButton,false);
end