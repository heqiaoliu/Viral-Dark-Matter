function errflag = samstruc(m1,m2)
%SAMSTRUC Checks if two IDPROC models have the same structure

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:03:25 $

errflag = struct('identifier','','message','');
if ~isa(m1,'idproc') || ~isa(m2,'idproc')
    errflag.identifier = 'Ident:transformation:mergeModelType';
    errflag.message = 'Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX, IDPROC) can  be merged.';
    return
end
typ1 = pvget(m1,'Type');
typ2 = pvget(m2,'Type');
if length(typ1)~=length(typ2)
    errflag.identifier = 'Ident:transformation:mergeModelDim';
    errflag.message = 'The models must have the same number of inputs and outputs';
else
    for k= 1:length(typ1)
        if ~strcmp(typ1{k},typ2{k})
            errflag.identifier = 'Ident:transformation:idprocMergeModelOrder';
            errflag.message = 'The IDPROC models must be of the same Type';
            return
        end
    end
end
