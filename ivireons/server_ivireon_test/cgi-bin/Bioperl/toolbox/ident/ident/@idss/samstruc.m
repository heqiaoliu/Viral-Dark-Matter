function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.


%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $ $Date: 2009/03/09 19:13:57 $

errflag = struct('identifier','','message','');
if ~isa(th1,'idss') || ~isa(th2,'idss')
    errflag.identifier = 'Ident:transformation:mergeModelType';
    errflag.message = ...
        'Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX, IDPROC) can  be merged.';
    return
end
arg1 = [th1.As,th1.Bs,th1.Cs',th1.Ks,th1.X0s];
arg2 = [th2.As,th2.Bs,th2.Cs',th2.Ks,th2.X0s];
err=0;
try
    if ~isequalwithequalnans(arg1,arg2) || ~isequalwithequalnans(th1.Ds,th2.Ds)
        err = 1;
    end
    %{
    if ~all(all(isnan(arg1)==isnan(arg2))'),err=1;end
    if ~all(all(arg1(~isnan(arg1))==arg2(~isnan(arg2)))'),err=1;end
    if ~all(all(isnan(th1.Ds)==isnan(th2.Ds))'),err=1;end
    if ~all(all(th1.Ds(~isnan(th1.Ds))==th2.Ds(~isnan(th2.Ds)))'),err=1;end
    %}
catch
    err = 1;
end

if err
    errflag.identifier = 'Ident:transformation:idssMergeModelStruc';
    errflag.message = 'State-space models must have the same underlying structure.';
    return
end
