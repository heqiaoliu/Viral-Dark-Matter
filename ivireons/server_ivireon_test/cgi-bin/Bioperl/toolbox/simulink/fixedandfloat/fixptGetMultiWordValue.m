function retVal = fixptGetMultiWordValue( mwHex, bitsOfLong )
%fixptGetMultiWordValue
%
%  Convert the multiword string, e.g. { { 0UL, 0x2UL } } to decimal
%  string 36893488147419103232 (i.e, 2*2^bitsOfLong+0).

%   Copyright 2008 The MathWorks, Inc.


if nargin < 2
    DAStudio.error('Shared:numericType:inputArgMustBeTwo');
else
    if (~isa(mwHex, 'char')) 
        DAStudio.error('Shared:numericType:firstArgIsNotString');
    end
    if(rem(bitsOfLong, 4.0) ~= 0.0 )
        DAStudio.error('Shared:numericType:secondArgHasIllegalValue');        
    end

    [eValue, extra] = regexp(mwHex, '{ { ([^}]+) } }', 'match', 'split'); %#ok
    
    retVal = mwHex;    
    
    for i = 1:length(eValue)
        vStr = regexp(eValue{i}, '[?0x]\w*UL', 'match');

        if (isempty(vStr))
            DAStudio.error('Shared:numericType:illegalMultiWordFormat');
        end

        if (length(vStr) * bitsOfLong > 128)
            DAStudio.error('Shared:numericType:overMaximumBits');
        end
        
        eVal = fixpt_convertMW2DecStr(eValue{i},double(bitsOfLong));
        retVal = regexprep(retVal, '{ { ([^}]+) } }', eVal, 1);
    end 
 end 
