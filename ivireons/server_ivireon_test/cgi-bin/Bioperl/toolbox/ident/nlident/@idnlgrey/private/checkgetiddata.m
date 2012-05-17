function [errmsg, data, nlsys, warnings, retmat, noisefree] = checkgetiddata(data, nlsys, command)
%CHECKGETIDDATA  Checks that data is consistent with nlsys. PRIVATE
%   FUNCTION.
%
%   [ERRMSG, DATA, NLSYS, WARNINGTXT, RETMAT, NOISEFREE] = ...
%      CHECKGETIDDATA(DATA, NLSYS);
%
%   DATA is the output-input data = [Y U]. Here U is the input data that
%   can be given either as an IDDATA object or as a matrix  U = [U1 U2 ...
%   Um], where the k:th column vector is input Uk.  Similarly, Y is either
%   an IDDATA object or a matrix of outputs (with as many columns as there
%   are outputs). For time-continuous IDNLGREY objects, DATA passed as a
%   matrix will lead to that the data sample interval, Ts, is set to one.
%
%   NLSYS holds the IDNLGREY model against which DATA is checked.
%
%   ERRMSG is a struct specifying the first error encountered during
%   object consistency checking (empty if no errors found).
%
%   WARNINGTXT is a cell array with warning messages and ids obtained through the
%   DATA checking. cell(0,2) is returned in case no warning was found.
%
%   RETMAT is a logical that is true if DATA to return is a N-by-Ny+Nu
%   matrix and false if the returned DATA is an IDDATA object.
%
%   NOISEFREE is a logical that should only be an output in case the caller
%   is sim. If a noise free simulation is requested it will be true and
%   otherwise fals.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $ $Date: 2009/12/07 20:42:42 $
%   Written by Peter Lindskog.

% Check that the function is called with 2 or 3 input arguments.
nin = nargin;
error(nargchk(2, 3, nin, 'struct'));
ispredict = (nargout < 6);

% Initialize errmsg, InterSample, warnings, retmat, InterSample, and
% noisefree.
errmsg = struct([]);
warnings = cell(0,2);
retmat = false;
noisefree = true;

% Get size info from nlsys.
nu = size(nlsys, 'nu');
ny = size(nlsys, 'ny');

% Check data.
Ts = pvget(nlsys, 'Ts');
if isa(data, 'iddata')
    % Handle the IDDATA case.
    % Check that the domain of the data object is time.
    if ~strcmpi(pvget(data, 'Domain'), 'time')
        ID = 'Ident:idnlmodel:timeDomainDataRequired';
        msg = ctrlMsgUtils.message(ID,['idnlgrey/' command]);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    
    % Check size of data.
    [n, nyd, nud, ne] = size(data);
    if (n == 0)
        ID = 'Ident:idnlmodel:nonEmptyDataRequired';
        msg = ctrlMsgUtils.message(ID,command);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    elseif ispredict
        % Called from predict or pem.
        if (nu ~= nud) || (ny ~= nyd)
            ID = 'Ident:general:modelDataDimMismatch';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    else
        % Called from sim.
        if (nu ~= nud)
            % Simulation with noise.
            if (nud ~= nu+ny)
                ID = 'Ident:analysis:simDataModelDimMismatch';
                msg = ctrlMsgUtils.message(ID,nu,nu+ny);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            noisefree = false;
        end
    end
    
    % Check that sampling is equal.
    Tsdata = pvget(data, 'Ts');
    if isempty(Tsdata)
        ID = 'Ident:idnlmodel:idnlgreyNonUniformData';
        msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    
    % Check that Ts is the same for all experiments.
    for i = 2:ne
        if (Tsdata{1} ~= Tsdata{i})
            ID = 'Ident:general:idprepNonUniqueDataTs';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    end
    Tsdata = Tsdata{1};
    
    % Check input data.
    if (nu > 0)
        InterSample = pvget(data, 'InterSample');
        % Check that zero or first order hold sampling was used for all experiments.
        if ~all(ismember(lower(InterSample), {'zoh' 'foh'}))
            ID = 'Ident:idnlmodel:idnlgreyDataInterSamp';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % Check that the InputName of DATA and NLSYS are the same.
        datain = pvget(data, 'InputName');
        nlsysin = pvget(nlsys, 'InputName');            
            
        for i = 1:length(nlsysin)
            if (~isempty(datain{i}) && ~isempty(nlsysin{i}))
                if ~strcmpi(datain{i}, nlsysin{i})
                    warningid = 'Ident:general:dataModelUnameMismatch';
                    warningtxt = ctrlMsgUtils.message(warningid);
                    warnings = [warnings; {warningid warningtxt}];
                    break;
                end
            end
        end
    end
    
    % Check output data (when called from predict or pem).
    if ispredict
        % Check that the OutputName of DATA and NLSYS are the same.
        dataout = pvget(data, 'OutputName');
        nlsysout = pvget(nlsys, 'OutputName');
        for i = 1:length(nlsysout)
            if (~isempty(dataout{i}) && ~isempty(nlsysout{i}))
                if ~strcmpi(dataout{i}, nlsysout{i})
                    warningid = 'Ident:general:dataModelYnameMismatch';
                    warningtxt = ctrlMsgUtils.message(warningid);
                    warnings = [warnings; {warningid warningtxt}];
                    break;
                end
            end
        end
    end
    
    % If name of data is empty, then set it to ''.
    if isempty(pvget(data, 'Name'))
        data = pvset(data, 'Name', '');
    end
elseif isnumeric(data)
    % Handle the matrix case. Start checking the type of DATA.
    if (ndims(data) ~= 2) || isempty(data) || ~isreal(data) || ~all(all(isfinite(data)))
        ID = 'Ident:idnlmodel:idnlgreyDoubleData';
        msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    
    % Check dimensions of DATA.
    if ispredict
        % Called from predict or pem.
        if (size(data, 2) ~= nu+ny)
            ID = 'Ident:general:modelDataDimMismatch';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    else
        % Called from sim.
        if (size(data, 2) ~= nu)
            % Simulation with noise.
            if (size(data, 2) ~= nu+ny)
                ID = 'Ident:analysis:simDataModelDimMismatch';
                msg = ctrlMsgUtils.message(ID,nu,nu+ny);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
            noisefree = false;
        end
    end
    
    % Create iddata object.
    if (Ts > 0)
        if ispredict
            % Called from predict or pem.
            data = iddata(data(:, 1:ny), data(:, ny+1:end), Ts, 'Name', '');
        else
            % Called from predict or sim.
            data = iddata([], data, Ts, 'Name', '');
        end
        Tsdata = pvget(nlsys, 'Ts');
    else
        if ispredict
            % Called from predict or pem.
            data = iddata(data(:, 1:ny), data(:, ny+1:end), 1, 'Name', '');
        else
            % Called from predict or sim.
            data = iddata([], data, 1, 'Name', '');
        end
        Tsdata = 1;
        warningid = 'Ident:general:doubleDataTs';
        warningtxt = ctrlMsgUtils.message(warningid);
        warnings = [warnings; {warningid warningtxt}];
    end
    
    % Assign values to InputName of data.
    try
        set(data, 'InputName', pvget(nlsys, 'InputName'));
    catch
    end
    
    % Assign values to InputName of data.
    try
        set(data, 'OutputName', pvget(nlsys, 'OutputName'));
    catch
    end
    retmat = true;
else
    ID = 'Ident:general:invalidData';
    msg = ctrlMsgUtils.message(ID);
    errmsg = struct('identifier',ID,'message',msg);
    return;
end

% If Ts and Tsdata disagree (discrete system) change Ts of NLSYS to that of DATA.
if (Ts > 0)
    if (Ts ~= Tsdata)
        warningid = 'Ident:general:dataModelTsMismatch';
        warningtxt = ctrlMsgUtils.message(warningid,...
            sprintf('%g',Ts),sprintf('%g',Tsdata));
        warnings = [warnings; {warningid warningtxt}];
        nlsys = pvset(nlsys, 'Ts', Tsdata);
    end
end
