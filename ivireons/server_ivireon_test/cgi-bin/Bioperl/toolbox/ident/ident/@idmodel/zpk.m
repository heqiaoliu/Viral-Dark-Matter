function model = zpk(IdMod,noi)
%ZPK  Transformation to ZPK object of Control System Toolbox.
%
%   SYS = ZPK(MODEL)
%
%   MODEL is any IDMODEL object (IDPOLY, IDSS, IDARX, IDPROC or IDGREY)
%   SYS is a zero-pole-gain model represented by ZPK object of Control
%   System Toolbox.
%
%   The noise source-inputs (e) in MODEL will be labeled as an
%   InputGroup 'Noise', while the measured inputs are grouped as
%   'Measured'. The noise channels are first normalized so that
%   the noise inputs in SYS correspond to uncorrelated sources
%   with unit variances.
%
%   SYS = ZPK(MODEL('measured')) or SYS = ZPK(MODEL,'measured') ignores the
%   noise inputs. 'm' may be used as short for 'measured'.
%
%   SYS = ZPK(MODEL('Noise')) gives a system of the transfer functions
%   from the noise sources (normalized as described above) to the outputs.
%
%   See also IDMODEL/ZPKDATA, IDMODEL/SS, IDMODEL/TF, LTI/ZPK.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.12.2.11 $  $Date: 2009/10/16 04:55:30 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','zpk')
end

if nargin>1
    if strncmpi(noi,{'measured'},length(noi))
        IdMod = IdMod('m');
    else
        ctrlMsgUtils.error('Ident:transformation:Idmodel2LTISecondArg','ZPK')
    end
end

was = ctrlMsgUtils.SuspendWarnings;

IdMod = pvset(IdMod,'Utility',[]);%%% To avoid unnecessary calculations
[ny,nu] = size(IdMod);
if nu>0
    [z,p,k] = zpkdata(IdMod);
    yna = IdMod.OutputName;
else
    z = {}; 
    p = {}; 
    k = [];
    yna = cell(0,1);
end

unam = IdMod.InputName;
inpd = IdMod.InputDelay;
lam = pvget(IdMod,'NoiseVariance');
if  norm(lam) >0
    noim = noisecnv(IdMod('n'),'n');
    [z1,p1,k1] = zpkdata(noim);
    z = [z,z1]; p =[p,p1]; k =[k,k1];

    unam = [unam;noim.InputName];
    yna = IdMod.OutputName;
    inpd = [inpd;zeros(size(noim,'nu'),1)];%
end

model = zpk(z,p,k,'Ts',IdMod.Ts);
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
end

notes = IdMod.Notes;
if ~ischar(notes) && ~iscellstr(notes)
    ctrlMsgUtils.warning('Ident:transformation:LTINotesFormat')
    notes = {};
end

set(model,'InputName',unam,'OutputName',yna,...
    'InputDelay',inpd, 'Name',IdMod.Name,'Notes',notes,'UserData',IdMod.UserData)
