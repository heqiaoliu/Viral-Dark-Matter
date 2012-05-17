function y = isenum(A)
% EML.ISENUM returns if A is an enumeration object.
%
% Example:
%   MyEnum.m:
%   classdef(Enumeration) MyEnum < int32
%        enumeration
%            MyEnum.MYCONSTANT(100)
%            MyEnum.MYCONSTANT2(200)
%        end
%   end
%
%   foo.m:
%   function y = foo(x)
%     if (eml.isenum(x))
%         y = 'Is an enumeration object';
%     else
%         y = 'is NOT an enumeration object';
%     end
%
%
%   y = foo(MyEnum.CONSTANT(100))
%
%   y =
%      'is an enumeration object'
%
%   y = foo(10)
%
%   y =
%      'is NOT an enumeration object'
%
%   Copyright 2008-2010 The MathWorks, Inc.

f = metaclass(A);
y = f.Enumeration; % Not documented
