function setBAFLExtraBits(dlg,val)
% Set Bit Allocation Fraction Length extra bits
% Both the IL/FL joint optimization widget and FL panel invoke this
% callback to set the extra bits via the dialog.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $     $Date: 2010/05/20 02:17:49 $

if nargin<2
    str = get(dlg.hBAFLExtraBits,'string');
    val = sscanf(str,'%f');
elseif ~isequal(val,0) && ishghandle(val) 
    % If the value is 0, ishghandle will return true since it thinks 0 is
    % the root. Check if the handle to the widget is passed in via callback
    % is a valid hghandle only if the value is non-zero.
    str = get(val,'string');
    val = sscanf(str,'%f');
end

if ~(embedded.ntxui.BitAllocationDialog.isInputValueValid(val))
    % Invalid value; replace old value into edit box
    val = dlg.BAFLExtraBits;
    errordlg(DAStudio.message('FixedPoint:fiEmbedded:InvalidExtraFLBits'),...
             'Fraction Length','modal');
end
if(dlg.BAWLMethod == 1) % Auto
    % check if the amount of extra bits requested puts the word length limit
    % beyond 65535.
    [intBits,fracBits,~,~] = getWordSize(dlg.UserData,true);
    % fracBits includes the extra bits, so negate it from the fracBits to
    % get the actual fractional bits.Also account for 1 sign bit
    % irrespective of the signedness of data. One can explicitly change the
    % sign bit to "signed" when data is unsigned.
    maxExtraBits = 65535-intBits-1-(fracBits-dlg.BAFLExtraBits);
    if val > maxExtraBits
        warndlg(DAStudio.message('FixedPoint:fiEmbedded:LargeExtraFLBitLength',...
            val,maxExtraBits,65535),...
            'Fraction Length', 'modal');
        val = maxExtraBits;
    end        
end

dlg.BAFLExtraBits = val; % record value
str = sprintf('%d',dlg.BAFLExtraBits); % replace string (removes spaces, etc)
set(dlg.hBAFLExtraBits,'string',str);
set(dlg.hBAILFLExtraBits,'string',str);
