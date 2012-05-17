function SyncSimulinkIO(this,flag)
%%Syncs the IOs of the Simulink model.

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/03/13 17:39:40 $

%% Get the user defined IO Condition state
newios = getlinio(this.Model);

%% Determine if there are any loop openings in the IOs
indopenloop = find(strcmp(get(newios,{'OpenLoop'}),'on'));
if any(indopenloop)
    set(newios(indopenloop),'OpenLoop','off');
    str = ['Please select only input and/or output signals for closed-loop signals.',...
           'Open-loop points will not be used.'];
    errordlg(xlate(str),...
              xlate('Simulink Control Design'),'modal');
    setlinio(this.Model,newios);return
end

%% Get the state from the GUI
oldios = this.IOData;

%% Get the block names for comparison
oldblocknames = get(oldios,{'Block'});
newblocknames = get(newios,{'Block'});

%% Find the intersection
[commonblocks,ia,ib] = intersect(oldblocknames,newblocknames);

%% Create indices to work with
indold = 1:length(oldios);
indnew = 1:length(newios);

%% Remove the intersecting IOs from the indices
indnew(ib) = [];

%% Find the old IO points that are not active and are not in the current
%% Simulink diagram
indold(ia) = [];
%% Old ios that are not in the new IOs list
nonoldios = oldios(indold);
%% Create empty non-active IO list
nonactive = [];
%% Loop over nonoldios to find non-active ones
for ct = 1:length(nonoldios)
    if strcmp(nonoldios(ct).Active,'off')
        nonactive = [nonactive;nonoldios(ct)];
    end
end

%% Create the new IO list
this.IOData = [newios(sort(ib));nonactive;newios(indnew)];
