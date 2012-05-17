function nlsys = subsasgn(nlsys, Struct, rhs)
%SUBSASGN  Subscripted assignment method for IDNLMODEL objects.
%
%   For more information on IDNLMODEL properties, type IDNLPROPS IDNLMODEL.
%
%   See also IDNLMODEL/SET, IDNLMODEL/GET, IDNLMODEL/SUBSREF.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.6 $ $Date: 2008/10/02 18:54:38 $

% Author(s): Qinghua Zhang

% Check that the function is called with three arguments.
nin = nargin;
error(nargchk(1, 3, nin, 'struct'));
if (nin == 1)
    return;
end

% Peel off the first layer of subsassignment.
StructL = length(Struct);
switch Struct(1).type
    case '.'
        % Assignment of the form sys.fieldname(...) = rhs.
        FieldName = Struct(1).subs;
        try
            if (StructL == 1)
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(nlsys, FieldName), Struct(2:end), rhs);
            end
        catch E
            throw(E)
        end
        set(nlsys, FieldName, FieldValue);
    otherwise
        ctrlMsgUtils.error('Ident:general:unknownSubsasgn',Struct(1).type,upper(class(nlsys)))
end

% FILE END