function [errmsg, outOrder] = checkgetOrder(inOrder, curOrder)
%CHECKGETORDER  Checks that the Order information is valid. PRIVATE
%   FUNCTION.
%
%   [ERRMSG, OUTORDER] = CHECKGETORDER(INORDER, CURORDER);
%
%   INORDER is either a vector with 3 entries ([ny nu nx]) or
%   a structure with fields ny, nu and nx.
%
%   CURORDER is a structure with fields ny, nu and nx, representing the
%   current order information. It is used to check that ny and nu are not
%   changed after that an IDNLGREY object is created.
%
%   ERRMSG is either '' or a non-empty string specifying the first error
%   encountered during Order checking.
%
%   OUTORDER is the parsed and checked Order, returned as a structure.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2008/12/04 22:34:53 $
%   Written by Peter Lindskog.

% Check that the function is called with 1 or 2 arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Initialize outOrder and errmsg.
errmsg = struct([]);

outOrder = struct('ny', 1, 'nu', 0', 'nx', 0);

% Check inOrder.
if isstruct(inOrder)
    % Copy fields from inOrder to OutOrder.
    if (isfield(inOrder, 'ny') && isfield(inOrder, 'nu') && isfield(inOrder, 'nx'))
        % inOrder must contain the fields ny, nu and nx.
        if isIntScalar(inOrder.ny, 1, Inf, true)
            outOrder.ny = inOrder.ny;
        else
            ID = 'Ident:idnlmodel:idnlgreyPosIntVal';
            msg = ctrlMsgUtils.message(ID,'ORDER.ny');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        if isIntScalar(inOrder.nu, 0, Inf, true)
            outOrder.nu = inOrder.nu;
        else
            ID = 'Ident:idnlmodel:idnlgreyNonNegIntVal';
            msg = ctrlMsgUtils.message(ID,'ORDER.nu');
            errmsg = struct('identifier',ID,'message',msg);
        end
        if isIntScalar(inOrder.nx, 0, Inf, true)
            outOrder.nx = inOrder.nx;
        else
            ID = 'Ident:idnlmodel:idnlgreyNonNegIntVal';
            msg = ctrlMsgUtils.message(ID,'ORDER.nx');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    else
        ID = 'Ident:idnlmodel:idnlgreyOrder1';
        msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
    end
elseif isnumeric(inOrder)
    if isempty(inOrder) || (ndims(inOrder) ~= 2) || ~any(size(inOrder) == [1 1]) || (length(inOrder) ~= 3)
        ID = 'Ident:idnlmodel:idnlgreyOrder1';
        msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
        return;
    elseif ~isIntScalar(inOrder(1), 1, Inf, true)
        ID = 'Ident:idnlmodel:idnlgreyPosIntVal';
        msg = ctrlMsgUtils.message(ID,'ORDER(1)');
        errmsg = struct('identifier',ID,'message',msg);
        return;
    elseif ~isIntScalar(inOrder(2), 0, Inf, true)
        ID = 'Ident:idnlmodel:idnlgreyNonNegIntVal';
        msg = ctrlMsgUtils.message(ID,'ORDER(2)');
        errmsg = struct('identifier',ID,'message',msg);
        return;
    elseif ~isIntScalar(inOrder(3), 0, Inf, true)
        ID = 'Ident:idnlmodel:idnlgreyNonNegIntVal';
        msg = ctrlMsgUtils.message(ID,'ORDER(3)');
        errmsg = struct('identifier',ID,'message',msg);
        return;
    end
    outOrder.ny = inOrder(1);
    outOrder.nu = inOrder(2);
    outOrder.nx = inOrder(3);
else
    ID = 'Ident:idnlmodel:idnlgreyOrder1';
    msg = ctrlMsgUtils.message(ID);
    errmsg = struct('identifier',ID,'message',msg);
end

% Check that Order is not changed.
if (nin > 1)
    if ~isequal(outOrder, curOrder)
        ID = 'Ident:idnlmodel:idnlgreyOrder2';
        msg = ctrlMsgUtils.message(ID);
        errmsg = struct('identifier',ID,'message',msg);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local function.                                                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isIntScalar(value, low, high, islimited)
% Check that value is an integer in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (isfinite(value) && (rem(value, 1) ~= 0))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end
