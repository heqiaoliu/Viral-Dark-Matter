function deal2props(inputArgs,theObject,propertyList)
%DEAL2PROPS Deal input arguments to named object properties.
%   DEAL2PROPS({I1,I2,..., H, {'P1','P2',...}) copies
%   input arguments I1, I2, ..., to properties P1, P2, ..., of
%   object H.  The number of inputs and property names does not have to
%   match.  In particular, the number of properties can be greater than the
%   number of inputs, and extra properties are left unmodified.
%
%   Typical usage is for the method or constructor to use varargin in its
%   signature, and pass that as a cell-array directly to DEAL2PROPS, as
%   follows:
%      function myMethod(hObj,varargin)
%      deal2props(varargin,hObj,{'p1','p2','p3'});
%
%   In this example, myMethod may be called with just two input
%   arguments, in which case property 'p3' is left unmodified.
%   DEAL2PROPS is useful when creating object constructors as well.  In the
%   following example, a constructor for a class named 'myClass' is shown,
%   where the input arguments to the constructor are assigned to
%   properties p1, p2, and p3, if the corresponding input is provided.
%   If only one input argument is passed, only property p1 is updated.
%
%      function h = className(varargin)
%      h = package.className;
%      deal2props(varargin,h,{'p1','p2','p3'});

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/02/02 13:13:06 $

% Copy only defined input args to output properties
N=min(numel(propertyList),numel(inputArgs));
for i=1:N
    set(theObject,propertyList{i},inputArgs{i});
end

% [EOF]
