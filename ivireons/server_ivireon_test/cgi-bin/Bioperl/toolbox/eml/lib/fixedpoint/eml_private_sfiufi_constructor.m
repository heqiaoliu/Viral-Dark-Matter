function hfi = eml_private_sfiufi_constructor(issigned,varargin)
% EML_PRIVATE_SFIUFI_CONSTRUCTOR
%#eml

%   Copyright 2008-2010 The MathWorks, Inc.

% Always inline
eml_must_inline;
eml_assert(nargin>1,'Not enough input arguments.');

eml.extrinsic('eml_sfiufi_constructor_helper');
eml.extrinsic('strcmpi');

eml_prefer_const(varargin);

% Check for ambiguous types
if eml_ambiguous_types
    if isnumeric(varargin{1}) || islogical(varargin{1}) 
        hfi = eml_not_const(varargin{1});
    else
        hfi = eml_not_const(0);
    end
    return;
end

% Will the input fimath (EML block's fimath) be use always by sfi & ufi? Or should it obey the drop donw in the Ports & Data Manager
% useInputFimathForThisConstructor = true; % Always use input fimath
useInputFimathForThisConstructor = eml_const(eml_option('FimathForFiConstructors') == 1); % Obey the Ports & Data Manager drop down

emlInputFimath = eml_fimath;

maxWL = eml_option('FixedPointWidthLimit');
% DTO: Get Simulink DTO setting to set fipref accordingly in calls to eml_fi_constructor_helper.
slDTOStr = eml_option('FixptDatatypeOverride');
slDTOAppliesToStr = eml_option('FixptDatatypeOverrideAppliesTo');
lVar = length(varargin);

for idx = 1:lVar
    if ~isnumeric(varargin{idx})
        eml_assert(0,'Input must be numeric.');
    end
end

% Fimath is not local in the ufi & sfi case 
isfimathlocal = false;

switch lVar
  case 1 % sfi()val) or sfi(a_fi)
    if isfi(varargin{1}) && ~eml_is_const(varargin{1})
        % non-const fi
        Tin = numerictype(varargin{1});
        data = 0;
        if eml_const(strcmpi(Tin.Scaling,'SlopeBias'))
            [T,F,ERR] = eml_const(eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForThisConstructor,emlInputFimath,issigned,data,Tin.WordLength,Tin.Slope,Tin.Bias));
        else
            [T,F,ERR] = eml_const(eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForThisConstructor,emlInputFimath,issigned,data,Tin.WordLength,Tin.FractionLength));
        end
        hfi = eml_fi_checkforerror(varargin{1},T,F,ERR,isfimathlocal);
    elseif eml_is_const(varargin{1});
        [T,F,ERR] = eml_const(eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForThisConstructor,emlInputFimath,issigned,varargin{1}));
        hfi = eml_fi_checkforerror(varargin{1},T,F,ERR,isfimathlocal);
    else
        eml_assert(eml_is_const(varargin{1}),'Input v in sfi(v) or ufi(v) must be a constant or a fi.');
    end
  otherwise
      if eml_is_const(varargin{1})
          eml_fi_checkforconst(varargin{2:end});
          [T,F,ERR,val] = eml_const(eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForThisConstructor,emlInputFimath,issigned,varargin{:}));
          hfi = eml_fi_checkforerror(val,T,F,ERR,isfimathlocal);
      else % ~eml_is_const(varargin{1})
          eml_assert(isnumeric(varargin{1}),...
                     'Input var1 in fi(var1,...) must be numeric or a constant.');
          eml_fi_checkforconst(varargin{2:end});
          % Check to see if var2-varN give a numerictype
          % Create some temp data
          if eml_is_const(size(varargin{1}))
              data = zeros(size(varargin{1}));%local_createConstDataFromInput(varargin{1});
          else
              data = 0;
          end
          [T,F,ERR,val,isautoscaled] = eml_const(eml_sfiufi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForThisConstructor,emlInputFimath,issigned,data,varargin{2:end}));
          hfi = eml_fi_checkforntype(varargin{1},T,F,ERR,isautoscaled,isfimathlocal);
      end
end

%------------------------------------------------------------------------------------------------
function data = local_createConstDataFromInput(varin) %#ok unused
% Create const data from variin (a variable input).
% If varin is a fi return a fi of value 0 with the same type a& fimath
% Other wise just return 0.

if isfi(varin)
    data = eml_cast(0,numerictype(varin),fimath(varin));
else
    data = 0;
end

%--------------------------------------------------------------------------------------------
