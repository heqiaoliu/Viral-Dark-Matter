function ht = numerictype(varargin)
% Embedded MATLAB Library function for numerictype the embedded.numerictype constructor.
%
%   All the possible function signatures are:
%
%       T = numerictype
%       T = numerictype(s)
%       T = numerictype(s, w)
%       T = numerictype(s, w, f)
%       T = numerictype(s, w, slope, bias)
%       T = numerictype(s, w, slopeadjustmentfactor, fixedexponent, bias)
%       T = numerictype(property1, value1, ...)
%       T = numerictype(T1, property1, value1, ...)
%       T = numerictype(A) will return the numerictype of A if A is a fi.
%

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/numerictype.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2009/12/28 04:10:46 $

eml.extrinsic('eml_numerictype_constructor_helper');
eml.extrinsic('num2str');
eml_transient;
eml_prefer_const(varargin);

nvar = nargin;

maxWL = eml_option('FixedPointWidthLimit');

switch nvar
 case 0
  [ht,err] = eml_const(eml_numerictype_constructor_helper(maxWL));
  if ~isempty(err)
    eml_assert(0,err);
  end
 
 % If input is a SL signal, 3 rounds on inference happens. The first round is for
 % size and the type is assumed to be double even if the signal is fixed-point
 % (unless specified in the model explorer). The code needs to compensate for this.
 case 1 % numerictype(s) or numerictype(fi)
   if eml_ambiguous_types
       [ht,err] = eml_const(eml_numerictype_constructor_helper(maxWL));
       if ~isempty(err)
           eml_assert(0,err);
       end  
   elseif isfi(varargin{1}) % If isfi(varargin{1}) return its numerictype
       ht = eml_typeof(varargin{1});
   else % if ~isfi(varargin{1}) and varargin{1} is a const
       eml_assert(eml_is_const(varargin{1}),'In numerictype(s) s must be a scalar constant or a fi.');
       [ht,err] = eml_const(eml_numerictype_constructor_helper(maxWL,varargin{1}));
       if ~isempty(err)
           eml_assert(0,err);
       end
   end
   
  otherwise % numerictype(s,w) or numerictype('property',value, ...)
    for i = 1:length(varargin)
        eml_assert(eml_is_const(varargin{i}), ['All inputs to this function must be constant. Input #', eml_const(num2str(i)), ' is not a constant.']);
    end;
    [ht,err] = eml_const(eml_numerictype_constructor_helper(maxWL,varargin{:}));
    if ~isempty(err)
        eml_assert(0,err);
    end   
end


