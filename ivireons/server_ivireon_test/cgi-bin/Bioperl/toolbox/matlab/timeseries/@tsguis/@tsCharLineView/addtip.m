function addtip(this,tipfcn,info)
%ADDTIP  Adds a buttondownfcn to each dot in @eventCharView object

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/15 20:57:18 $

%% Make sure plotedit mode is off of the line ButtonDownFcn callback
%% will not work
f = ancestor(this.AxesGrid.Parent,'figure');
plotedit(f,'off');
set(f,'Pointer','arrow'); % Work around g290077


%% Install tips on each line
for ct1 = 1:size(this.Lines,1)
    for ct2 = 1:size(this. Lines,2)
        info.Row = ct1; 
        info.Col = ct2;
        % Store the line so that maketip can identify the event 
        info.Line = this.Lines(ct1,ct2);
        this.installtip(this.Lines(ct1,ct2),tipfcn,info)
        set(this.Lines(ct1,ct2),'Tag','CharPoint')
    end
end
