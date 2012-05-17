function [errmsg, FileName] = checkgetFileName(FileName, Order, ParValue, FileArgument)
%CHECKGETFILENAME  Checks that FileName is a callable MATLAB, p- or MEX-file or
%   a proper function handle. PRIVATE FUNCTION.
%
%   [ERRMSG, FILENAME] = CHECKGETFILENAME(FILENAME, ORDER, PARVALUE, ...
%                                         FILEARGUMENT);
%
%   FILENAME is a string specifying a callable MATLAB, p- or MEX-file) or a
%   function handle.
%
%   ORDER is a structure with fields nx, nu, ny.
%
%   PARVALUE is a cell array of parameter values.
%
%   FILEARGUMENT is a cell array containing optional inputs to FILENAME. If
%   FILEARGUMENT = {}, then FILENAME will not be called with a last
%   FILEARGUMENT.
%
%   ERRMSG is a struct specifying the first error encountered during
%   FileName checking (empty if no errors found).

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $ $Date: 2010/03/22 03:49:07 $
%   Written by Peter Lindskog.

% Check that the function is called with 4 input arguments.
nin = nargin;
error(nargchk(4, 4, nin, 'struct'));

% Check FileName.
if isempty(FileName)
    FileName = '';
else
    if isa(FileName, 'function_handle')
        % FileName is a function handle.
        modfunc = FileName;
        FileName = func2str(modfunc);
    else
        % FileName must be a callable MATLAB, p- or MEX-file. Check that.
        ID = 'Ident:idnlmodel:idnlgreyFileName';
        msg0 = ctrlMsgUtils.message(ID);
        if ~ischar(FileName) || (ndims(FileName) ~= 2) || ~isvarname(FileName)
            errmsg = struct('identifier',ID,'message',msg0);
            return;
        end
        FileName = FileName(:)';
        
        % Check that FileName is a callable MATLAB, p- or MEX-function.
        if ~any(exist(FileName, 'file') == [2 3 6])
            errmsg = struct('identifier',ID,'message',msg0);
            return;
        end
        
        % Try to convert FileName to a function handle.
        try
            modfunc = str2func(FileName);
        catch E
            ID = 'Ident:idnlmodel:str2FuncFailure';
            msg = ctrlMsgUtils.message(ID,FileName, E.message);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    end
    
    % Check that modfunc can be called as intended.
    was = warning('off'); [lw,lwid] = lastwarn;
    try
        [x, y] = feval(modfunc, 0, ones(Order.nx, 1), ones(1, Order.nu),...
            ParValue{:}, FileArgument);
        warning(was), lastwarn(lw,lwid)
    catch E
        warning(was), lastwarn(lw,lwid)
        if isa(FileName, 'function_handle')
            FileName = ['@' func2str(FileName)];
        end
        ID = 'Ident:idnlmodel:ODEFunEvalFailure';
        msg = ctrlMsgUtils.message(ID,FileName, E.message);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    
    % Check that x is a non-empty numeric scalar or vector of appropriate
    % size.
    if ~isnumeric(x) || (ndims(x) ~= 2) || (~any(size(x) == [1 1]) && ~isempty(x))
        ID = 'Ident:idnlmodel:ODEFunFirstOutputType';
        msg = ctrlMsgUtils.message(ID,FileName);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    elseif (length(x) ~= Order.nx)
        ID = 'Ident:idnlmodel:ODEFunFirstOutputSize';
        msg = ctrlMsgUtils.message(ID,FileName,Order.nx);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    
    % Check that y is a non-empty numeric scalar or vector of appropriate
    % size.
    if ~isnumeric(y) || (ndims(y) ~= 2) || ~any(size(y) == [1 1])
        ID = 'Ident:idnlmodel:ODEFunSecondOutputType';
        msg = ctrlMsgUtils.message(ID,FileName);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    elseif (length(y) ~= Order.ny)
        ID = 'Ident:idnlmodel:ODEFunSecondOutputSize';
        msg = ctrlMsgUtils.message(ID,FileName,Order.ny);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
end

% Everything went fine. Return empty struct
errmsg = struct([]);
