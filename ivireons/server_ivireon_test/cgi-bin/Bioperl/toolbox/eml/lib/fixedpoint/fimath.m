function hf = fimath(varargin)
% Embedded MATLAB Library function for fimath the embedded.fimath constructor.
%
%   All the possible function signatures are:
%
%       F = fimath
%       F = fimath(property1, value1, ...)
%       F = fimath(A) will return the fimath of A if A is a fi. 
%

% $INCLUDE(DOC) toolbox/eml/fixedpoint/fimath.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.15 $  $Date: 2009/12/28 04:10:45 $

% FIMATH  Object which encapsulates fixed-point math information.
%     Syntax:

eml.extrinsic('eml_fimath_constructor_helper');
eml.extrinsic('sprintf');

eml_transient;
eml_prefer_const(varargin);

% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

% EML default fimath
useInputFimathForFimathConstructors = eml_const(eml_option('FimathForFiConstructors') == 1);
if ~useInputFimathForFimathConstructors && nargin == 0
   warnMsg = eml_const(sprintf(['The ''Same as MATLAB factory default'' setting for the ''FIMATH for fi and fimath constructors'' is now obsolete.\n',...
                       'All fimath objects constructed in the EML Function block with unspecified fimath properties now inherit their properties from the ''Embedded MATLAB Function Block fimath''.\n',...
                       'If your ''Embedded MATLAB Function Block fimath'' is not the MATLAB factory default fimath, you may see different results when running your model in release R2009b and later.\n',...
                       'For more information on this change, see the <a href="matlab:helpview([docroot ''/toolbox/fixedpoint/fixedpoint.map''], ''cc_eml_block_fimath'')">R2009b Fixed-Point Toolbox Release Notes.</a>\n',...
                       'To turn off this warning, run slupdate on your model.']));
   eml_assert(0,'warning',warnMsg);
end
emlInputFimath = eml_fimath;

switch nargin
  case 0
    [hf,err] = eml_const(eml_fimath_constructor_helper(useInputFimathForFimathConstructors, emlInputFimath));
    if ~isempty(err)
        eml_assert(0,err);
    end
    
  case 1 % fimath(afi) is taken care of by the @fi/fimath lib function
  
    % IF types are ambiguous return a 0
    if eml_ambiguous_types
      hf = 0;
      return;
    end

    if isfimath(varargin{1})
        hf = varargin{1};
    else
        hf = 0;
        eml_assert(0,'Index exceeds matrix dimensions.');
    end 
    
  otherwise    
    [hf,err] =  eml_const(eml_fimath_constructor_helper(useInputFimathForFimathConstructors,...
                                                      emlInputFimath,...
                                                      varargin{:}));
    if ~isempty(err)
        eml_assert(0,err);
    end
end
%-------------------------------------------------------------------------------
