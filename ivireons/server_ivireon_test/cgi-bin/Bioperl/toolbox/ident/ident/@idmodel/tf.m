function model = tf(IdMod,noi)
%TF  Transformation to TF object of Control System Toolbox.
%
%   SYS = TF(MODEL)
%
%   MODEL is any IDMODEL object (IDPOLY, IDSS, IDARX, IDPROC or IDGREY)
%   SYS is a transfer function represented by TF object of Control System
%   Toolbox.
%
%   The noise source-inputs (e) in MODEL will be labeled as an
%   InputGroup 'Noise', while the measured inputs are grouped as
%   'Measured'. The noise channels are first normalized so that
%   the noise inputs in SYS correspond to uncorrelated sources
%   with unit variances.
%
%   SYS = TF(MODEL('measured')) or SYS = TF(MODEL,'measured') ignores the
%   noise inputs.  'm' may be used as short for 'measured'.
%
%   SYS = TF(MODEL('Noise')) gives a system of the transfer functions
%   from the noise sources (normalized as described above) to the outputs.
%
%   See also TF, IDMODEL/TFDATA, IDMODEL/ZPK, IDMODEL/SS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.11.2.11 $  $Date: 2009/10/16 04:55:28 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','tf')
end

if nargin>1
    if strncmpi(noi,{'measured'},length(noi))
        IdMod = IdMod('m');
    else
        ctrlMsgUtils.error('Ident:transformation:Idmodel2LTISecondArg','TF')
    end
end

was = ctrlMsgUtils.SuspendWarnings;

IdMod = pvset(IdMod,'Utility',[]);%%% To avoid unnecessary calculations
[ny,nu] = size(IdMod);
if nu>0
    [num,den] = tfdata(IdMod);
    ynam = IdMod.OutputName;
else
    num = {}; den = {};
    ynam = cell(0,1);
end

unam = IdMod.InputName;
inpd = IdMod.InputDelay;
lam = pvget(IdMod,'NoiseVariance');
if  norm(lam) >0
    noim = noisecnv(IdMod('n'),'n');
    [num1,den1] = tfdata(noim);
    num = [num,num1]; den =[den,den1];
    unam = [unam;noim.InputName];
    ynam = IdMod.OutputName;
    inpd = [inpd;zeros(size(noim,'nu'),1)];%
end

model = tf(num,den,'Ts',IdMod.Ts);
delete(was)

if norm(lam)>0
    if nu>0
        if isstruct(get(model,'InputGroup'))
            inpg.Measured = 1:nu;
            inpg.Noise = nu+1:nu+ny;
            set(model,'InputGroup',inpg);
        else
            set(model,'InputGroup',{1:nu,'Measured';nu+1:nu+ny,'Noise'})
        end
    else
        if isstruct(get(model,'InputGroup'))
            inpg.Noise = 1:ny;
            set(model,'InputGroup',inpg);
        else
            set(model,'InputGroup',{1:ny,'Noise'});
        end
    end
end
%inpd = IdMod.InputDelay;
if any(inpd<0)
    ctrlMsgUtils.warning('Ident:transformation:negativeDelayToLTI')
    inpd = max(0,inpd);
    % todo: Absorb negative delays as extra zeros in case of TF/ZPK
end

notes = IdMod.Notes;
if ~ischar(notes) && ~iscellstr(notes)
    ctrlMsgUtils.warning('Ident:transformation:LTINotesFormat')
    notes = {};
end

set(model,'InputName',unam,'OutputName',ynam,...
    'InputDelay',inpd, 'Name',IdMod.Name,'Notes',notes,'UserData',IdMod.UserData)
