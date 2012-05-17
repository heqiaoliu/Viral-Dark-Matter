function openBlkView(hBlk)
%

% Author(s): A. Stothert 14-Oct-2009
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:26 $

% OPENBLKVIEW static method to open view for a check block

%What class block are we dealing with. Need this to determine
%static methods to call
cls = hBlk.DialogControllerArgs;

%Get the underlying core block. The core block is used as a hook to
%store block visualization objects
hCoreBlk = feval(strcat(cls,'.getCoreBlock'),hBlk);

%Create/get data object to link block to visualization
VisData = getappdata(hCoreBlk,'BlockVisualizationData');
if isempty(VisData)
   VisData = checkpack.checkblkviews.CheckBlockScopeVisData;
   setappdata(hCoreBlk,'BlockVisualizationData',VisData)
end

%Create/get visualization object for the block
blkVis = getappdata(hCoreBlk,'BlockVisualization');
if isempty(blkVis) || ~ishandle(blkVis)
   dlgPos = localGetDlgPos(cls,hBlk.ViewDlgPos);
   blkVis = feval(strcat(cls,'.createBlockScope'),hBlk.MaskType,dlgPos,{VisData, hBlk});
   setappdata(hCoreBlk,'BlockVisualization',blkVis)
end
%Make sure requirements are shown correctly, this also means committing
%any unapplied changes
dlgs = hBlk.getDialogSource.getOpenDialogs;
if ~isempty(dlgs)
   if dlgs{1}.hasUnappliedChanges
      dlgs{1}.apply
   end
end
show(blkVis);
end

function dlgPos = localGetDlgPos(cls,dlgPos)
%Helper function to find initial dialog position and size

defaultPos = feval(strcat(cls,'.getDefaultPos'));
try
   dlgPos = str2num(dlgPos); %#ok<ST2NM>
catch %#ok<CTCH>
   %Default size
   dlgPos = defaultPos;
end

%Protect against bad figure positions
monPos = get(0,'MonitorPositions');
xMin = min(monPos(:,1));
[xMax,imax] = max(monPos(:,1));
xMax = xMax + monPos(imax,3);
yMin = min(monPos(:,2));
[yMax,imax] = max(monPos(:,2));
yMax = yMax + monPos(imax,4);
if isempty(dlgPos) || numel(dlgPos) ~= 4 || any(~isfinite(dlgPos)) || ~isreal(dlgPos) || ...
      dlgPos(1) < xMin || dlgPos(1)> xMax || ...
      dlgPos(2) < yMin || dlgPos(2) > yMax || ...
      dlgPos(3) <=0 || dlgPos(4) <= 0
   %Reset position
   dlgPos = defaultPos;
end
end
