function s = getSpecifiedSign(this)
%getSpecifiedSign Get Sign property and error if unspecified.

%   getSpecifiedSign(T) gets the Sign property of Simulink.NumericType object
%   T and error if the Sign property is unspecified.
%
%   Examples:
%     T1 = fixdt(true, 16, 15);
%     s1 = getSpecifiedSign(T1)
%     %  returns true.
%
%     T2 = fixdt([], 16, 15);
%     s2 = getSpecifiedSign(T2)
%     %  errors because Sign is unspecified.
%
%   See also FIXDT.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/14 19:57:31 $
    s = this.Signed;
    if isempty(s)
        DAStudio.error('FixedPoint:fiEmbedded:signShouldBeSpecified');
    end
    
        