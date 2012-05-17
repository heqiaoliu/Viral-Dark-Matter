function [Value,errflag] = datachk(Value,str)
%DATACHK  Auxiliary function to @IDDATA/SET
%   Checks if Value contains a matrix of numeric data.
%   Makes it into a cell if it isn't

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2009/03/23 16:37:35 $

errflag = struct([]);
str2 = sprintf('The value of the "%s" property must be a double matrix or a cell array of such matrices.',str);
if ~iscell(Value),
    Value  = {Value};
end
message = '';
[nr1,nc1] = size(Value{1});
[l1,l2] = size(Value);
if l1>l2
    Value=Value.';
end
if min(l1,l2)>1
    identifier = 'Ident:iddata:datachk1';
    message = ['If ',str,' is a cell array, it must be of dimension 1 by Ne'];
else
    for kk=1:length(Value)
        if ~isa(Value{kk},'double') || ndims(Value{kk})>2
            identifier = 'Ident:iddata:datachk2';
            message = str2;
        end
        [nr,nc] = size(Value{kk});
        if nc~=0 && nc~=nc1 && (strcmp(str,'OutputData') || strcmp(str,'InputData'))
            identifier = 'Ident:iddata:datachk3';
            message = ['For multiple experiments, each cell in ',str,' must have the same number of columns'];
        end
        if nr<nc && nr~=0
            if strcmp(str,'OutputData')
                ctrlMsgUtils.warning('Ident:iddata:MoreOutputsThanSamples');
            elseif strcmp(str,'InputData')
                ctrlMsgUtils.warning('Ident:iddata:MoreInputsThanSamples');
            end
        end
    end
end
if ~isempty(message)
    errflag = struct('message',message,'identifier',identifier);
end
