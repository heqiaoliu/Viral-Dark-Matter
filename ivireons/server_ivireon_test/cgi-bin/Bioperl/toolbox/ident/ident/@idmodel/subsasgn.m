function sys = subsasgn(sys,Struct,rhs)
%   See also SET, SUBSREF.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $  $Date: 2008/10/02 18:48:35 $

if nargin==1,
    return
end
StructL = length(Struct);
% Peel off first layer of subassignment
switch Struct(1).type
    case '.'
        % Assignment of the form sys.fieldname(...)=rhs
        FieldName = Struct(1).subs;
        try
            if StructL==1,
                FieldValue = rhs;
            else
                FieldValue = subsasgn(get(sys,FieldName),Struct(2:end),rhs);
            end
            set(sys,FieldName,FieldValue)
        catch E
            throw(E)
        end
    otherwise
        ctrlMsgUtils.error('Ident:general:unknownSubsasgn',Struct(1).type,upper(class(sys)))
end

