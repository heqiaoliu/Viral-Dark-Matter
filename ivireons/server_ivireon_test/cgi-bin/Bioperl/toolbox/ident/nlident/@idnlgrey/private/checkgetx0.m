function [errmsg, x0init] = checkgetx0(InitialStates, x0, ned, calltype)
%CHECKGETX0  Checks that X0INIT passed to predict or sim is valid. PRIVATE
%   FUNCTION.
%
%   [ERRMSG, X0INIT] = CHECKGETX0(INITIALSTATES, X0, NED, CALLTYPE);
%
%   ININITIALSTATES is a NX-by-1 structure array with fields
%      Name   : name of the state (a string).
%      Unit   : unit of the state (a string).
%      Value  : value of the states (a finite real 1-by-Ne vector, where
%               Ne is the number of experiments).
%      Minimum: minimum values of the states (a real 1-by-Ne vector or a
%               real scalar, in which case all initial states have the
%               same minimum value).
%      Maximum: maximum values of the states (a real 1-by-Ne vector or a
%               real scalar, in which case all initial states have the
%               same maximum value).
%      Fixed  : a boolean 1-by-Ne vector, or a scalar boolean (applicable
%               for all states) specifying whether the initial state is
%               fixed or not.
%   INITIALSTATES should be NLSYS.INITIALSTATES.
%
%   X0 specifies the initial state strategy to use. In the predict case it
%   can be 'zero', 'fixed', 'estimate', 'model', a real Nx-by-1/Nx-by-Ne
%   vector/matrix, a Nx-by-1 cell array with 1-by-Ne real vectors, or an
%   Nx-by-a structure array of InitialStates. All choices but 'estimate'
%   are allowed in the sim case.
%
%   NED specifies the number of experiments of the DATA object used for the
%   prediction/simulation.
%
%   CALLTYPE should be a character specifying the caller:
%      'f': called from fixedstates.
%      'p': called from predict.
%      's': called from sim.
%
%   ERRMSG is either '' or a non-empty string specifying the first error
%   encountered during InitialStates checking.
%
%   X0INIT is the parsed and checked initial state, returned as a NX-by-1
%   structure array.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $ $Date: 2008/12/04 22:34:57 $
%   Written by Peter Lindskog.

% Check that the function is called with 4 arguments.
nin = nargin;
error(nargchk(4, 4, nin, 'struct'));

% Initialize errmsg and x0.
errmsg = '';
x0init = InitialStates;

% Get num, number of experiment stored in NLSYS.
if isempty(x0init)
    return;
else
    nem = length(x0init(1).Value);
end

% Check and get x0init.
fixall = false;
freeall = false;
if islogical(calltype)
    if (calltype)
        % Called from predict in R2007b or earlier. Input argument then
        % called ispredict.
        calltype = 'p';
    else
        % Called from sim in R2007b or earlier. Input argument then
        % called ispredict.
        calltype = 's';
        fixall = true;
    end
else
    calltype = lower(calltype(1));
    if (calltype(1) == 's')
        fixall = true;
    end
end

switch calltype
    case 'f'
        command = 'findstates';
    case 'p'
        command = 'predict';
    case 's'
        command = 'sim';
end

if ischar(x0)
    % x0 is a string.
    if (calltype == 'f')
        % The findstates case.
        choices = {'zero' 'estimate' 'model'};
    elseif (calltype == 'p')
        % The predict case.
        choices = {'zero' 'fixed' 'estimate' 'model'};
    else
        % The sim case.
        choices = {'zero' 'fixed' 'model'};
    end
    
    % Check x0init.
    choice = strmatch(lower(x0), choices);
    if (isempty(x0) || isempty(choice))
        ID = 'Ident:analysis:X0val';
        msg = ctrlMsgUtils.message(ID,command,['idnlgrey/',command]);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    else
        switch choices{choice}
            case 'zero'
                [x0init.Value] = deal(zeros(1, nem));
                for i = 1:length(x0init)
                    % Check that inInitialStates(i).Minimum <= 0.
                    if any(x0init(i).Minimum > 0)
                        ID = 'Ident:analysis:idnlgreyX0val2';
                        msg = ctrlMsgUtils.message(ID,i);
                        errmsg = struct('identifier',ID,'message',msg);
                        return;
                    end
                    % Check that inInitialStates(i).Maximum >= 0.
                    if any(x0init(i).Maximum < 0)
                        ID = 'Ident:analysis:idnlgreyX0val3';
                        msg = ctrlMsgUtils.message(ID,i);
                        errmsg = struct('identifier',ID,'message',msg);
                        
                        return;
                    end
                end
                if (calltype == 'f')
                    % The findstates case.
                    freeall = true;
                else
                    % The other cases.
                    fixall = true;
                end
            case 'fixed'
                fixall = true;
            case 'estimate'
                [x0init.Fixed] = deal(false(1, nem));
        end
    end
else
    % x0 may be a vector/matrix, a cell array of 1-by-Ne matrices or an
    % Nx-by-1 structure array of InitialStates.
    if isnumeric(x0)
        nx = size(x0, 1);
    else
        nx = length(x0);
    end
    if (nx ~= length(x0init))
        ID = 'Ident:analysis:X0valSize';
        msg = ctrlMsgUtils.message(ID,nx,length(x0init));
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    [errmsg, x0init] = checkgetInitialStates(x0, nx, true);
    if ~isempty(errmsg)
        return;
    end
    
    % Copy Name and Unit information from InitialStates to x0init.
    [x0init.Name] = deal(InitialStates.Name);
    [x0init.Unit] = deal(InitialStates.Name);
    
    if ((calltype == 'f') && isnumeric(x0))
        % The findstates case.
        freeall = true;
    end
end

% Fix or free states.
if (fixall)
    for i = 1:length(x0init)
        x0init(i).Fixed = true(size(x0init(i).Fixed));
    end
elseif (freeall)
    for i = 1:length(x0init)
        x0init(i).Fixed = false(size(x0init(i).Fixed));
    end
end

% Check consistency between nem & ned (i.e., the number of experiments
% specified by x0 and the number of experiments specified by data).
nem = length(x0init(1).Value);
if (nem == 1)
    if (ned > 1)
        % Extend x0init to the number of states specified by ned.
        for i = 1:length(x0init)
            x0init(i).Value = repmat(x0init(i).Value, 1 , ned);
            x0init(i).Minimum = repmat(x0init(i).Minimum, 1 , ned);
            x0init(i).Maximum = repmat(x0init(i).Maximum, 1 , ned);
            x0init(i).Fixed = repmat(x0init(i).Fixed, 1 , ned);
        end
    end
elseif (nem ~= ned)
    for i = 1:length(x0init)
        % Check Value, Minimum, Maximum and Fixed.
        if (   (length(unique(x0init(i).Value)) == 1)   ...
                && (length(unique(x0init(i).Minimum)) == 1) ...
                && (length(unique(x0init(i).Maximum)) == 1) ...
                && (length(unique(x0init(i).Fixed)) == 1))
            x0init(i).Value = repmat(x0init(i).Value(1), 1 , ned);
            x0init(i).Minimum = repmat(x0init(i).Minimum(1), 1 , ned);
            x0init(i).Maximum = repmat(x0init(i).Maximum(1), 1 , ned);
            x0init(i).Fixed = repmat(x0init(i).Fixed(1), 1 , ned);
        else
            ID = 'Ident:analysis:X0NumExpMismatch';
            msg = ctrlMsgUtils.message(ID,nem,ned);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    end
end
