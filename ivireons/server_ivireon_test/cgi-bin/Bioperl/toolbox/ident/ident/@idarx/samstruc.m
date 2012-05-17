function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.
%

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $ $Date: 2008/05/19 23:02:14 $

errflag = struct('identifier','','message','');
if ~isa(th1,'idarx') || ~isa(th2,'idarx')
    errflag.identifier = 'Ident:transformation:mergeModelType';
    errflag.message =...
        'Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX, IDPROC) can  be merged.';
    return
end
if ~(all(all(th1.na==th2.na)') && all(all(th1.nb==th2.nb)') && all(all(th1.nk==th2.nk)'))
    errflag.identifier = 'Ident:transformation:mergeModelOrder';
    errflag.message = 'Only models of the same orders can be merged.';
end