function ssmodel = ss(IdMod,noi)
%SS  Transformation to SS object of Control System Toolbox.
%
%   SYS = SS(MODEL)
%
%   MODEL is any IDMODEL object (IDPOLY, IDSS, IDARX, IDPROC, or IDGREY)
%   SYS is a state-space model represented by SS object of Control
%   System Toolbox.
%
%   The noise source-inputs (e) in MODEL will be labeled as an
%   InputGroup 'Noise', while the measured inputs are grouped as
%   'Measured'. The noise channels are first normalized so that
%   the noise inputs in SYS correspond to uncorrelated sources
%   with unit variances.
%
%   SYS = SS(MODEL('Measured')) or SYS = SS(MODEL,'M')
%   ignores the noise inputs.
%
%   SYS = SS(MODEL('noise')) gives a representation of the noise
%   channels only.
%
%   See also IDSS, IDMODEL/SSDATA, IDMODEL/ZPK, IDMODEL/TF.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.15.2.12 $  $Date: 2009/10/16 04:55:27 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','ss')
end

if nargin>1
    if strncmpi(noi,{'measured'},length(noi))
        IdMod = IdMod('m');
    else
        ctrlMsgUtils.error('Ident:transformation:Idmodel2LTISecondArg','SS')
    end
end

[ny,nu] = size(IdMod);

lam = IdMod.NoiseVariance;
IdMod.CovarianceMatrix = []; % to avoid unnecessary calculations
%if isa(IdMod,'idarx') % To avoid extra states from noise input
IdMod = idss(IdMod);
%end

was = ctrlMsgUtils.SuspendWarnings;
IdMod = pvset(IdMod,'Utility',[]);%%% To avoid unnecessary calculations
IdMod = IdMod(:,'allx9');

[a,b,c,d] = ssdata(IdMod);
ssmodel = ss(a,b,c,d,'Ts',IdMod.Ts);
delete(was)

if norm(lam)>0
    if nu>0
        if isstruct(get(ssmodel,'InputGroup'))
            inpg.Measured = (1:nu);
            inpg.Noise = (nu+1:nu+ny);
            set(ssmodel,'InputGroup',inpg);
        else
            set(ssmodel,'InputGroup',{1:nu,'Measured';nu+1:nu+ny,'Noise'})
        end
    else
        if isstruct(get(ssmodel,'InputGroup'))
            inpg.Noise = 1:ny;
            set(ssmodel,'InputGroup',inpg);
        else
            set(ssmodel,'InputGroup',{1:ny,'Noise'});
        end
    end
end
inpd = IdMod.InputDelay;
if any(inpd<0)
    ctrlMsgUtils.warning('Ident:transformation:negativeDelayToLTI')
    inpd = max(0,inpd);
end

notes = IdMod.Notes;
if ~ischar(notes) && ~iscellstr(notes)
    ctrlMsgUtils.warning('Ident:transformation:LTINotesFormat')
    notes = {};
end

set(ssmodel,'InputName',IdMod.InputName,'OutputName',IdMod.OutputName,...
    'InputDelay',inpd,'Name',IdMod.Name,'Notes',notes,'UserData',IdMod.UserData)

if isa(IdMod,'idss') || isa(IdMod,'idgrey')
    set(ssmodel,'StateName',pvget(IdMod,'StateName'))
end
