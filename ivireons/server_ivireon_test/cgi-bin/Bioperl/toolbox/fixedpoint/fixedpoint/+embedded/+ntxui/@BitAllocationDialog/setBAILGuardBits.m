function setBAILGuardBits(dlg,val)
% Set Bit Allocation Integer Length guard bits
% Both the IL/FL joint optimization widget and IL panel invoke this
% callback to set the guard bits via the dialog.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $     $Date: 2010/05/20 02:17:52 $

if nargin<2
    str = get(dlg.hBAILGuardBits,'string');
    val = sscanf(str,'%f');
elseif ~isequal(val,0) && ishghandle(val) 
    % If the value is 0, ishghandle will return true since it thinks 0 is
    % the root. Check if the handle to the widget passed in to the callback
    % is a valid hghandle only if the value is non-zero.
    str = get(val,'string');
    val = sscanf(str,'%f');
end
if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
    % Invalid value; replace old value into edit box
    val = dlg.BAILGuardBits;
    errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidExtraILBits'),...
             'Integer Length','modal');
end
if(dlg.BAWLMethod == 1) % Auto
    % check if the amount of extra bits requested puts the word length limit
    % beyond 65535.
    [intBits,fracBits,~,~] = getWordSize(dlg.UserData,true);
    % intBits includes the extra bits, so negate it from the intBits to get
    % the actual integer bits. Also account for 1 sign bit irrespective of
    % the signedness of data. One can explicitly change the sign bit to
    % "signed" when data is unsigned.
    maxGuardBits = 65535-(intBits-dlg.BAILGuardBits+1)-fracBits;
    if val > maxGuardBits
        warndlg(DAStudio.message('FixedPoint:fiEmbedded:LargeExtraILBitLength',...
            val,maxGuardBits,65535),...
            'Integer Length', 'modal');
        val = maxGuardBits;
    end        
end
dlg.BAILGuardBits = val; % record value
str = sprintf('%d',dlg.BAILGuardBits); % replace string (removes spaces, etc)
set(dlg.hBAILGuardBits,'string',str);
set(dlg.hBAILFLGuardBits,'string',str);
