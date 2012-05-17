function result = subsref(nlsys, Struct)
%SUBSREF  Subscripted reference method for IDNLMODEL objects.
%   The following reference operation can be applied to any IDNLMODEL
%   object MOD:
%      MOD.Fieldname           equivalent to GET(MOD, 'Fieldname')
%
%   This expression can be followed by any valid subscripted reference of
%   the result, as in  MOD.cov(1:3,1:3).
%
%   For more information on IDNLMODEL properties, type IDNLPROPS IDNLMODEL.
%
%   See also IDNLMODEL/SET, IDNLMODEL/GET, IDNLMODEL/SUBSASGN.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.10.7 $ $Date: 2009/03/09 19:15:04 $

% Author(s): Qinghua Zhang

% Check that the function is called with 1 or 2 arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

if (nin == 1)
    result = sys;
    return;
end
StructL = length(Struct);

% Peel off first layer of sub-referencing.
switch Struct(1).type
    case '.' % Currently this is the only supported type.
        % The first sub-reference is of the form sys.fieldname-
        % The output is a piece of one of the system properties.
        try
            if (StructL == 1)
                result = get(nlsys, Struct(1).subs);
            else
                result = subsref(get(nlsys, Struct(1).subs), Struct(2:end));
            end
        catch E
            throw(E)
        end
    case '()'
        if  StructL==1 && iscell(Struct.subs) && length(Struct.subs)==1 && ischar(Struct.subs{1})
            [refstr, msg] = strchoice({'measured','noise'}, Struct.subs{1}, []);
            if ~isempty(msg)
                ctrlMsgUtils.error('Ident:utility:invalidSubsref',upper(class(nlsys)))
            end
            result = submodels(nlsys, refstr);
        else
            ctrlMsgUtils.error('Ident:utility:invalidSubsref',upper(class(nlsys)))
        end
    otherwise
        ctrlMsgUtils.error('Ident:general:unSupportedSubsrefType',Struct(1).type,upper(class(nlsys)))
end

% FILE END