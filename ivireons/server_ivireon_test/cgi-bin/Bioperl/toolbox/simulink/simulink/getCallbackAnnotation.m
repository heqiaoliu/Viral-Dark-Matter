function ca = getCallbackAnnotation()
% GETCALLBACKANNOTATION
%
%   If an annotation's callback is executing, that annotation is returned.
%   Otherwise, nothing is returned.

% Copyright 2005 The MathWorks, Inc.
  
  ca = callback_annotation;
  