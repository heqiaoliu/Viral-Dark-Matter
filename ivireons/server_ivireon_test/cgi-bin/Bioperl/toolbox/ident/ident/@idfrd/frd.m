function f = frd(ifr)
%FRD  convert model objects to an LTI/FRD object
%   Requires Control System Toolbox
%   SYS = FRD(MF)
%
%   MF is an IDFRD model, obtained for example by SPA, ETFE or IDFRD.
%
%   If MF is an IDMODEL object it is first converted to IDFRD. Then the
%   syntax SYS = FRD(MF,W) allows the frequency vector W also to be
%   defined. If W is omitted a default choice is made. Note that
%   specification of frequency W is not allowed if MF is an IDFRD object.
%
%   SYS is returned as an FRD object.
%
%   Covariance information and spectrum information is not translated.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.9 $  $Date: 2009/10/16 04:55:03 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:frdCstbRequired')
end

nu = size(ifr,'Nu');
if nu == 0
    ctrlMsgUtils.error('Ident:transformation:frdTimeseriesData')
end
uni = ifr.Units;
if lower(uni(1))=='r'
    if ~strcmp(uni,'rad/s')
        ctrlMsgUtils.warning('Ident:transformation:frdUnitsCheck1')
    end
    uni = 'rad/s';
else
    if ~strcmp(uni,'Hz')
        ctrlMsgUtils.warning('Ident:transformation:frdUnitsCheck2')
    end
    uni = 'Hz';
end

notes = ifr.Notes;
if ~ischar(notes) && ~iscellstr(notes)
    ctrlMsgUtils.warning('Ident:transformation:LTINotesFormat')
    notes = {};
end

inpd = ifr.InputDelay;
if any(inpd<0)
    ctrlMsgUtils.warning('Ident:transformation:negativeDelayToLTI')
    inpd = max(0,inpd);
end

f = frd(ifr.ResponseData,ifr.Frequency,ifr.Ts,'InputDelay',inpd,...
    'Units',uni,'InputName',ifr.InputName,'OutputName',ifr.OutputName,...
    'Notes',notes,'Ts',ifr.Ts,'UserData',ifr.UserData,'Name',ifr.Name);
