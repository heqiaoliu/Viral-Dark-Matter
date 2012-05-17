function flag = isDataTypeConversion(this)
% Check if the block type is data type conversion.  
% Note that
%   cast
%   caststage
%   convert
%   convertio
% are all data type conversion blocks.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:30:37 $

if (strcmpi(this.blocktype,'convert') || strcmpi(this.blocktype,'convertio') ...
        || strcmpi(this.blocktype,'cast') || strcmpi(this.blocktype,'caststage'))
    flag = true;
else
    flag = false;
end
            