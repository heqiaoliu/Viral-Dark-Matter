function configBlk(hBlk)

% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:29 $

% CONFIGBLK static method to configure the library block contents
%

try
   %If the block dialog is open and has unapplied changes do not reinitialize
   %the block
   openDlgs = hBlk.getDialogSource.getOpenDialogs;
   if ~isempty(openDlgs) && openDlgs{1}.hasUnappliedChanges
      return
   end
   
   %Call parent class config methods
   iconStr1 = checkpack.absCheckDlg.configBlk(hBlk);
   iconStr2 = slctrlblkdlgs.absCheckFrequencyDlg.configBlk(hBlk);
   iconStr  = sprintf('%s%s',iconStr1,iconStr2);
   
   %Set block
   iconBasic = fullfile(matlabroot,'toolbox','slcontrol','slctrlutil', ...
      'resources','CheckPZMapIcon');
   %Note, add image first as need to layer other detail over the image
   strImg = sprintf('image(imread(''%s.bmp'',''bmp''),''center'');\n',iconBasic);
   iconStr = sprintf('%s%s',strImg,iconStr);
   if ~isequal(hBlk.MaskDisplay,iconStr)
      hBlk.MaskDisplay = iconStr;
   end
catch E
   fprintf('***** slctrlblkdlgs.configBlk: %s\n',E.message)
end
end