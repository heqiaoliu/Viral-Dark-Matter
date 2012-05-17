function varargout = subsref(t,s)
%SUBSREF Subscripted reference for a paretotails object.
%   B = SUBSREF(T,S) is called for the syntax T(X) when T is a
%   paretotails object.  S is a structure array with the fields:
%       type -- string containing '()', '{}', or '.' specifying the
%               subscript type.
%       subs -- Cell array or string containing the actual subscripts.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:56 $

if isequal(s(1).type, '.') && numel(s)<=2 && ...
        ismember(s(1).subs,{'lowerparams' 'upperparams'}) && ...
        (isscalar(s) || isequal(s(2).type,'()'))
    % This is a call to a method of this subclass
    if isscalar(s)
        args = {};
    else
        args = s(2).subs;
    end
    switch(s(1).subs)
      case 'lowerparams'
        [varargout{1:nargout}] = lowerparams(t,args{:});
      case 'upperparams'
        [varargout{1:nargout}] = upperparams(t,args{:});
    end
    return
end

% Otherwise delegate to superior class
[varargout{1:nargout}] = subsref@piecewisedistribution(t,s);
