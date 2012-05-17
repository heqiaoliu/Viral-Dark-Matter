function f = frd(ifr,w)
%FRD  convert model objects to an LTI/FRD object
%   Requires Control System Toolbox
%   SYS = FRD(MF)
%
%   MF is an IDFRD model, obtained for example by SPA, ETFE or IDFRD.
%   
%   If MF is an IDMODEL object it is first converted to IDFRD. Then the
%   syntax  
%   SYS = FRD(MF,W)
%   allows the frequency vector W also to be defined. If W is omitted a
%   default choice is made.
%
%   SYS is returned as an FRD object.
%
%   Covariance information and spectrum information are not translated.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2009/10/16 04:55:09 $

if ~iscstbinstalled
   ctrlMsgUtils.error('Ident:transformation:frdCstbRequired')
end
nu = size(ifr,'Nu');
if nu == 0
   ctrlMsgUtils.error('Ident:transformation:frdTimeSeries')
end
if nargin > 1
   ifr = idfrd(ifr('m'),w);
else
   ifr = idfrd(ifr('m'));
end
f = frd(ifr);
  
