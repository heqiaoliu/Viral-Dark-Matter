function Out = set(sys,varargin)
%SET  Set properties of IDMODEL models.
%
%   SET(SYS,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the IDMODEL model SYS to the value VALUE.  An equivalent syntax
%   is
%       SYS.PropertyName = VALUE .
%
%   SET(SYS,'Property1',Value1,'Property2',Value2,...) sets multiple
%   IDMODEL property values with a single statement.
%
%   SET(SYS,'Property') displays legitimate values for the specified
%   property of SYS.
%
%   SET(SYS) displays all properties of SYS and their admissible
%   values.  Type HELP IDPROPS for more details on IDMODEL properties.
%
%   Note: Resetting the sampling time does not alter the model data.
%         Use C2D or D2D for conversions between the continuous and
%         discrete domains.
%
%   See also GET, IDHELP, IDPROPS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.10 $  $Date: 2009/12/22 18:53:47 $

ni = nargin;
no = nargout;

if ~isa(sys,'idmodel'),
    % Call built-in SET. Handles calls like set(gcf,'user',ss)
    builtin('set',sys,varargin{:});
    return
elseif no && ni>2
    ctrlMsgUtils.error('Ident:general:setOutputArg','idmodel/set','idmodel/set')
end

% Get public properties and their assignable values
[AllProps,AsgnValues] = pnames(sys);

% Handle read-only cases
if ni==1
    % SET(SYS) or S = SET(SYS)
    if no
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        cell2struct(AsgnValues,AllProps,1)
        fprintf('Type "idprops", or "idprops %s", for more details.\n',class(sys))
    end
    
elseif ni==2
    % SET(SYS,'Property') or STR = SET(SYS,'Property')
    % Return admissible property value(s)
    [~,PropAlg,Typealg] = iddef('algorithm');
    AllProps = [AllProps; PropAlg'];
    AsgnValues = [AsgnValues; Typealg'];
    try
        [~,imatch] = pnmatchd(varargin{1},AllProps,7);
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
        ctrlMsgUtils.error('Ident:general:setFirstInput','idmodel/set')
    elseif rem(ni-1,2)~=0
        ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs',...
            upper(class(sys)),'idmodel/set')
    end
    
    % Match specified property names against list of public properties and
    % set property values at object level
    % RE: a) Include all properties to appropriately detect multiple matches
    
    [~,PropAlg] = iddef('algorithm');
    AllProps = [AllProps; PropAlg'];
    try
        for i=1:2:ni-1
            varargin{i} = pnmatchd(varargin{i},AllProps,7);
            if isa(varargin{i+1},'idmodel') && strcmp(varargin{i},'Focus')
                % This is to avoid that the set-command is redirected to the
                % wrong pvset in case a 'Focus' is to be set
                [a,b,c,d] = ssdata(varargin{i+1});
                varargin{i+1} = {a,b,c,d,pvget(varargin{i+1},'Ts')};
            end
            
            if isa(sys,'idpoly') && size(sys,2)>1 && any(strcmpi(varargin{i},{'b','f'}))
                Fmt = pvget(sys,'BFFormat');
                try
                    Val = varargin{i+1};
                    if (isa(Val,'double') && Fmt==0) || (iscell(Val) && Fmt~=0)
                        fmtstr = 'double';
                        if Fmt==0
                            fmtstr = 'cell';
                        end
                        ctrlMsgUtils.warning('Ident:idmodel:IdpolyBFFormatMismatch',...
                            upper(varargin{i}),class(Val),fmtstr)
                        qw = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:IdpolyBFFormatMismatch'); %#ok<NASGU>
                    end
                end
            end
            
        end
        sys = pvset(sys,varargin{:});
    catch E
        throw(E)
    end
    
    % Assign sys in caller's workspace
    assignin('caller',sysname,sys)
end

