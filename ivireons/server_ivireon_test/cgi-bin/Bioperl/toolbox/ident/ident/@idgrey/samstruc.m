function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.
%

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $ $Date: 2009/03/09 19:13:36 $

errflag = struct('identifier','','message','');
if ~isa(th1,'idgrey') || ~isa(th2,'idgrey')
    errflag.identifier = 'Ident:transformation:mergeModelType';
    errflag.message =...
        'Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX, IDPROC) can  be merged.';
    return
end
if  ~strcmp(th1.MfileName,th2.MfileName)
    errflag.identifier = 'Ident:transformation:idgreyMergeModelFileName';
    errflag.message = 'Only IDGREY models with the same "MfileName" can be merged.';
    return
end
err = 0;
if ~isempty(th1.FileArgument)
    if isempty(th2.FileArgument)
        err = 1;
    else
        try
            if ~isequal(th1.FileArgument,th2.FileArgument)
                err = 1;
            end
        catch
            err = 1;
        end
    end
end
if err
    errflag.identifier = 'Ident:transformation:idgreyMergeModelFileArg';
    errflag.message = 'Only IDGREY models with the same "FileArgument" can be merged.';
end
