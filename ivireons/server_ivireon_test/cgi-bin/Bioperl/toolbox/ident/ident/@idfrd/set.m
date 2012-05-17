function Out = set(sys,varargin)
%SET  Set properties of IDFRD models.
%
%   SET(SYS,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the IDFRD model SYS to the value VALUE.  An equivalent syntax
%   is
%       SYS.PropertyName = VALUE .
%
%   SET(SYS,'Property1',Value1,'Property2',Value2,...) sets multiple
%   IDFRD property values with a single statement.
%
%   SET(SYS,'Property') displays legitimate values for the specified
%   property of SYS.
%
%   SET(SYS) displays all properties of SYS and their admissible
%   values.  Type IDPROPS IDFRD for more details on IDFRD properties.
%
%   Note: Resetting the sampling time does not alter the model data.
%         Use C2D or D2D for conversions between the continuous and
%         discrete domains.
%
%   See also GET, IDFRD, IDPROPS.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $ $Date: 2008/10/02 18:47:27 $

ni = nargin;
no = nargout;

if ~isa(sys,'idfrd'),
    % Call built-in SET. Handles calls like set(gcf,'user',ss)
    builtin('set',sys,varargin{:});
    return
elseif no && ni>2,
    ctrlMsgUtils.error('Ident:general:setOutputArg','idfrd/set','idfrd/set')
end

% Get public properties and their assignable values
[AllProps,AsgnValues] = pnames(sys);

% Handle read-only cases
if ni==1,
    % SET(SYS) or S = SET(SYS)
    if no
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        %settest(sys)
        %disp(pvformat(AllProps,AsgnValues)) %% LL Couldn't make this work
        cell2struct(AsgnValues,AllProps,1)
        disp(sprintf('Type "idprops", or "idprops %s", for more details.',class(sys)))
    end

elseif ni==2,
    % SET(SYS,'Property') or STR = SET(SYS,'Property')
    % Return admissible property value(s)
    try
        [Property,imatch] = pnmatchd(varargin{1},AllProps,7);
        if no,
            Out = AsgnValues{imatch};
        else
            disp(AsgnValues{imatch})
        end
    catch E
        throw(E)
    end

else
    % SET(SYS,'Prop1',Value1, ...)
    AllProps = pnames(sys);

    sysname = inputname(1);
    if isempty(sysname)
        ctrlMsgUtils.error('Ident:general:setFirstInput','idfrd/set')
    elseif rem(ni-1,2)~=0
        ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs',...
            'IDFRD','idfrd/set')
    end

    % Match specified property names against list of public properties and
    % set property values at object level
    % RE: a) Include all properties to appropriately detect multiple matches
    %     b) Limit comparison to first 6 chars (because of NoiseModel)
    try
        for i=1:2:ni-1
            varargin{i} = pnmatchd(varargin{i},AllProps,7);
        end
        sys = pvset(sys,varargin{:});
    catch E
        throw(E)
    end

    % Assign sys in caller's workspace
    assignin('caller',sysname,sys)

end
