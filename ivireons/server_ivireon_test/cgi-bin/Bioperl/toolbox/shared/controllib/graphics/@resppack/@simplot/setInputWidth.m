function setInputWidth(this,Nu)
%SETINPUTWIDTH  Specifies number of input channels for SIMPLOT.

%  Author(s): P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:54 $

% RE: Only used for LSIM-type plots (multi-output response data)
if prod(this.AxesGrid.Size(2))>1
    ctrlMsgUtils.error('Controllib:plots:simplot1')
end
Ny = this.AxesGrid.Size(1);
if strcmp(this.InputStyle,'paired')
   if Nu~=Ny
       ctrlMsgUtils.error('Controllib:plots:simplot4')
   end
   Nnew = 1;
else
   Nnew = Nu;
end

% Adjust channel names
rInput = this.Input;
Nch = length(rInput.ChannelName);
rInput.ChannelName = [rInput.ChannelName(1:min(Nu,Nch)) ; repmat({''},Nu-Nch,1)];

% Adjust length of Data/View vectors
Nold = length(rInput.Data);
if Nold>Nnew
   % Delete extra data/view pairs
   rInput.Data = rInput.Data(1:Nnew);
   deleteview(rInput.View(Nnew+1:Nold))
   rInput.View = rInput.View(1:Nnew);
elseif Nold<Nnew
   % Add missing data/view pairs
   Axes = getaxes(this);
   [Data, View] = createinputview(this, Nnew-Nold);
   for ct=1:Nnew-Nold
      initialize(View(ct),Axes)
   end
   rInput.Data = [rInput.Data ; Data];
   rInput.View = [rInput.View ; View];
   % Update style
   applystyle(rInput)
   % Install tips
   addtip(rInput)
end
