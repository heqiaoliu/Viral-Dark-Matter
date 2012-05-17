
%   Copyright 2007-2010 The MathWorks, Inc.
   
% ===================== rtw default target info ======================
function [rtwDefaultTargetInfo mode] = getrtwDefaultTargetInfo
% MAT-files are generated from matlabroot/rtw/internal/tfl/
rtwDefaultTfls = load('rtw_default_targetInfo_tfl.mat');
rtwDefaultHWs = load('rtw_default_targetInfo_hw.mat');

% MATLAB Host target HW info needs to be determined at run time.
mlHostHw = RTW.HWDeviceRegistry;
mlHostHw.Vendor = 'Generic';
mlHostHw.Type = 'MATLAB Host Computer';
mlHostHw.Alias = {'MATLAB Host'};
mlHostHw.Platform = {'Target'};

if exist('rtwhostwordlengths', 'file') == 2 ||  ...
        exist('rtwhostwordlengths', 'file') == 6
    wl = rtwhostwordlengths;
    mlHostHw.BitPerChar = wl.CharNumBits;
    mlHostHw.BitPerShort = wl.ShortNumBits;
    mlHostHw.BitPerInt = wl.IntNumBits;
    mlHostHw.BitPerLong = wl.LongNumBits;
    mlHostHw.BitPerFloat = wl.FloatNumBits;
    mlHostHw.BitPerDouble = wl.DoubleNumBits;
    mlHostHw.BitPerPointer = wl.PointerNumBits;
    mlHostHw.WordSize = wl.WordSize;
    mlHostHw.setVisible({'WordSize'});
else
    mlHostHw.BitPerChar = 8;
    mlHostHw.BitPerShort = 16;
    mlHostHw.BitPerInt = 32;
    mlHostHw.BitPerLong = 32;
    mlHostHw.BitPerFloat = 32;
    mlHostHw.BitPerDouble = 64;    
    mlHostHw.BitPerPointer = 32;    
    mlHostHw.WordSize = 32;
    mlHostHw.setInvisible({'BitPerChar', 'BitPerShort', 'BitPerInt',...
                           'BitPerLong','BitPerFloat','BitPerDouble',...
                           'BitPerPointer', 'WordSize'});
end

if exist('rtw_host_implementation_props', 'file') == 2 || ...
        exist('rtw_host_implementation_props', 'file') == 6
    imp = rtw_host_implementation_props;
    mlHostHw.Endianess = imp.Endianess;
    mlHostHw.setVisible({'Endianess'});
    if imp.ShiftRightIntArith
        mlHostHw.ShiftRightIntArith = true;
    else
        mlHostHw.ShiftRightIntArith = false;
    end
    mlHostHw.IntDivRoundTo = imp.IntDivRoundTo;
    mlHostHw.setEnabled({'IntDivRoundTo'});
    mlHostHw.LargestAtomicInteger = 'Char';
    mlHostHw.setEnabled({'LargestAtomicInteger'});
    mlHostHw.LargestAtomicFloat = 'None';
    mlHostHw.setEnabled({'LargestAtomicFloat'});

else
    mlHostHw.Endianess = 'Unspecified';
    mlHostHw.ShiftRightIntArith = true;
    mlHostHw.IntDivRoundTo = 'Undefined';
    mlHostHw.setInvisible({'Endianess','ShiftRightIntArith'});
    mlHostHw.setEnabled({'IntDivRoundTo'});
    mlHostHw.LargestAtomicInteger = 'Char';
    mlHostHw.setEnabled({'LargestAtomicInteger'});
    mlHostHw.LargestAtomicFloat = 'None';
    mlHostHw.setEnabled({'LargestAtomicFloat'});
end

% return targetInfo objects in an array
rtwDefaultTargetInfo = [rtwDefaultTfls.thisTfl rtwDefaultHWs.thisHW mlHostHw];
mode = 'nocheck';
