function hfi = fi_impl(varargin)
% Embedded MATLAB Library function for fi the fixed-point value constructor.
%
%   All the possible function signatures are:
%
%     fi(data)
%     fi(data, s)
%     fi(data, s, w)
%     fi(data, s, w, f)
%     fi(data, s, w, slope, bias)
%     fi(data, s, w, slopeadjustmentfactor, fixedexponent, bias)
%
%     fi(data, T)
%     fi(data, T, F)
%
%     fi(..., property1, value1, ...)
%     fi(property1, value1, ....)
%

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/fi.m $
% Copyright 2002-2010 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2010/04/05 22:15:09 $
  

eml.extrinsic('eml_fi_constructor_helper');
eml.extrinsic('sprintf'); 

% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

eml_prefer_const(varargin);
      
% Always inline
eml_must_inline;

% If nargin is 0 i.e. no data is provided throw an assertion
eml_assert(nargin > 0,'Not enough input arguments.');

% Check for ambiguous types
if eml_ambiguous_types
    if isnumeric(varargin{1}) || islogical(varargin{1}) 
        hfi = eml_not_const(varargin{1});
    else
        hfi = eml_not_const(0);
    end
    return;
end

% DTO: Get Simulink DTO setting to set fipref accordingly in calls to eml_fi_constructor_helper.
slDTOStr = eml_option('FixptDatatypeOverride');
slDTOAppliesToStr = eml_option('FixptDatatypeOverrideAppliesTo');


% EML default fimath: Get the setting for fimathForFiConstructors
useInputFimathForFiConstructors = eml_const(eml_option('FimathForFiConstructors') == 1);
emlInputFimath = eml_fimath;

eml_assert(~isstruct(varargin{1}),'First input to fi constructor cannot be of type struct.');
maxWL = eml_option('FixedPointWidthLimit');

% Switch on the number of input arguments.
switch nargin
  case 1 % Only data is given or if fi(a_fi)
    hfi = eml_fi_case1(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,varargin{1});

  case 2 % (data,s) or (data,T) or (data,F) or (fi,T) or (fi,F) or (pv pair)
    hfi = eml_fi_case2(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,varargin{1}, varargin{2});

  case 3 % (data/fi,s,w) or (data/fi,T,F) or (data/fi,pv pair)
    hfi = eml_fi_case3(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,varargin{1}, varargin{2}, varargin{3});

  otherwise 
    hfi = fi_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,varargin{:});
end

function hfi = eml_fi_case1(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,v)
    eml_allow_mx_inputs;  
    eml_must_inline;
    eml_prefer_const(maxWL);
    eml_prefer_const(slDTOStr);
    eml_prefer_const(slDTOAppliesToStr);
    eml_prefer_const(useInputFimathForFiConstructors);
    eml_prefer_const(emlInputFimath);
    eml_prefer_const(v);
    eml.extrinsic('eml_fi_constructor_helper');
    
    b = eml_is_const(v);

    if isfi(v) && ~b
        % non-const fi
        [data,datasz]      = local_createConstDataFromInput(v);
        [T,F,ERR,val,fiisautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,datasz,data));
        hfi       = eml_fi_checkforerror(v,T,F,ERR,isfimathlocal);
        return;
    elseif b
        % const fi or non-fi
        [T,F,ERR,val,fiisautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,size(v),v));
        hfi       = eml_fi_checkforerror(val,T,F,ERR,isfimathlocal);
    else
        % non-const non-fi not allowed
        eml_assert(false,'Input v in fi(v) must be a constant or a fi.');
    end

     % Throw a coder warning if the now obsolete "Fimath For Fi Cconstructors" property is set to "Same As MATLAB Factory Default" and the fi is fimathless - i.e.
     % a fimath has not been specified.
    if ~useInputFimathForFiConstructors && ~isfimathlocal
        warnMsg = eml_const(sprintf(['The ''Same as MATLAB factory default'' setting for the ''FIMATH for fi and fimath constructors'' is now obsolete.\n',...
                            'All fi objects constructed in the EML Function block with an unspecified fimath now use the ''Embedded MATLAB Function Block fimath'' as their default fimath.\n',...
                            'If your ''Embedded MATLAB Function Block fimath'' is not the MATLAB factory default fimath, you may see different results when running your model in release R2009b and later.\n',...
                            'For more information on this change, see the <a href="matlab:helpview([docroot ''/toolbox/fixedpoint/fixedpoint.map''], ''cc_eml_block_fimath'')">R2009b Fixed-Point Toolbox Release Notes.</a>\n',...
                            'To turn off this warning, run slupdate on your model.']));
        eml_assert(0,'warning',warnMsg);
    end
    
function hfi = eml_fi_case2(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,p1,p2)
    eml_allow_mx_inputs;  
    eml_prefer_const(maxWL);
    eml_prefer_const(slDTOStr);
    eml_prefer_const(slDTOAppliesToStr);
    eml_prefer_const(useInputFimathForFiConstructors);
    eml_prefer_const(emlInputFimath);

    eml_must_inline;
    eml_prefer_const(p1, p2);
    eml.extrinsic('eml_fi_constructor_helper');

    if eml_is_const(p1)
        eml_assert(eml_is_const(p2),'Input var2 in fi(var1,var2) must be a constant.');
        [T,F,ERR,val,fiisautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,size(p1),p1,p2));
        hfi = eml_fi_checkforerror(val,T,F,ERR,isfimathlocal);
    else % ~eml_is_const(p1)
        eml_assert(isnumeric(p1),'Input var1 in fi(var1,var2) must be numeric or a constant.');
        eml_assert(eml_is_const(p2),'Input var2 in fi(var1,var2) must be a constant.');
        eml_assert(isnumerictype(p2) || isfimath(p2),...
                   'Input var2 in fi(var1,var2) must be a numerictype or a fimath if var1 is not a constant.');
        if isnumerictype(p2) && eml_const(p2.isscalingunspecified)
            eml_assert(0,'Input var2 in fi(var1,var2) cannot be a numerictype of unspecified scaling if var1 is not a constant.');
        end
        [data,datasz] = local_createConstDataFromInput(p1);
        
        [T1,F1,ERR,val,fiisautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,datasz,data,p2));
        hfi = eml_fi_checkforerror(p1,T1,F1,ERR,isfimathlocal);
    end
    
    % Throw a coder warning if the now obsolete "Fimath For Fi Cconstructors" property is set to "Same As MATLAB Factory Default" and the fi is fimathless - i.e.
    % a fimath has not been specified.
    if ~useInputFimathForFiConstructors && ~isfimathlocal
        warnMsg = eml_const(sprintf(['The ''Same as MATLAB factory default'' setting for the ''FIMATH for fi and fimath constructors'' is now obsolete.\n',...
                            'All fi objects constructed in the EML Function block with an unspecified fimath now use the ''Embedded MATLAB Function Block fimath'' as their default fimath.\n',...
                            'If your ''Embedded MATLAB Function Block fimath'' is not the MATLAB factory default fimath, you may see different results when running your model in release R2009b and later.\n',...
                            'For more information on this change, see the <a href="matlab:helpview([docroot ''/toolbox/fixedpoint/fixedpoint.map''], ''cc_eml_block_fimath'')">R2009b Fixed-Point Toolbox Release Notes.</a>\n',...
                            'To turn off this warning, run slupdate on your model.']));
        eml_assert(0,'warning',warnMsg);
    end

function hfi = eml_fi_case3(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath, p1, p2, p3)
    eml_allow_mx_inputs;  
    eml_must_inline;
    eml_prefer_const(maxWL);
    eml_prefer_const(slDTOStr);
    eml_prefer_const(slDTOAppliesToStr);
    eml_prefer_const(useInputFimathForFiConstructors);
    eml_prefer_const(emlInputFimath);

    eml_prefer_const(p1, p2, p3);
    eml.extrinsic('eml_fi_constructor_helper');

    if ~eml_is_const(p1)
        eml_assert(isnumeric(p1),'Input var1 in fi(var1,...,var3) must be numeric or a constant.');
        if isnumerictype(p2) && eml_const(p2.isscalingunspecified)
            eml_assert(0,'Input var2 in fi(var1,var2,var3) cannot be a numerictype of unspecified scaling if var1 is not a constant.');
        end
    end
    hfi = fi_helper(maxWL,slDTOStr, slDTOAppliesToStr,useInputFimathForFiConstructors, emlInputFimath, p1, p2, p3);


%------------------------------------------------------------------------------------------------
function [data,datasz] = local_createConstDataFromInput(varin)
% Create const data from variin (a variable input).
% If varin is a fi return a fi of value 0 with the same type a& fimath
% Other wise just return 0.

if isfi(varin)
    data = eml_fimathislocal(eml_cast(0,numerictype(varin),fimath(varin)),eml_fimathislocal(varin));
else
    data = 0;
end

if eml_is_const(size(varin))
    datasz = size(varin);
else
    datasz = [1 1];
end

%--------------------------------------------------------------------------------------------
function [data,T,F] = local_getInfoFromConstInput(inp)
% Return data with right value and cast, and also return numerictype and
% fimath of data

eml_transient;

T = numerictype(inp);
F = fimath(inp);

dType = eml_fi_getDType(inp);
data  = eml_cast(inp,dType);
%--------------------------------------------------------------------------------------------
function [data,datasz,T,F] = local_getInfoFromNonConstInput(inp)
% Return data with right value and cast, and also return numerictype and
% fimath of data

eml_transient;

T = numerictype(inp);
F = fimath(inp);
data  = 0;
if eml_is_const(size(inp))
    datasz = size(inp);
else
    datasz = [1 1];
end

%--------------------------------------------------------------------------------------------
function hfi = fi_helper(maxWL,slDTOStr, slDTOAppliesToStr, useInputFimathForFiConstructors, emlInputFimath, varargin)
    
    eml_prefer_const(maxWL);
    eml_prefer_const(slDTOStr);
    eml_prefer_const(slDTOAppliesToStr);
    eml_prefer_const(useInputFimathForFiConstructors);
    eml_prefer_const(emlInputFimath);

    eml_prefer_const(varargin);

    eml.extrinsic('eml_fi_constructor_helper');
    if eml_is_const(varargin{1})
        if size(varargin,1) > 1
            eml_fi_checkforconst(varargin{2:end});
        end
        if isfi(varargin{1}) && isfloat(varargin{1})
            [data,Tvar1,Fvar1] = local_getInfoFromConstInput(varargin{1});
            [T,F,ERR,val,fiisautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,size(data),data,Tvar1,Fvar1,varargin{2:end}));
        else
            data = varargin{1};
            [T,F,ERR,val,fiisautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,size(data),data,varargin{2:end}));
        end
        hfi = eml_fi_checkforerror(val,T,F,ERR,isfimathlocal);
    else % ~eml_is_const(varargin{1})
        eml_assert(isnumeric(varargin{1}),...
                   'Input var1 in fi(var1,...) must be numeric or a constant.');
        if size(varargin,1) > 1
            eml_fi_checkforconst(varargin{2:end});
        end
        % Check to see if var2-varN give a numerictype
        % Create some temp data
        if isfi(varargin{1}) && isfloat(varargin{1})
            [data,datasz,Tvar1,Fvar1] = local_getInfoFromNonConstInput(varargin{1});
            [T,F,ERR,val,isautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,datasz,data,Tvar1,Fvar1,varargin{2:end}));
        else
            [data,datasz] = local_createConstDataFromInput(varargin{1});
            [T,F,ERR,val,isautoscaled,pvpairsetdata,isfimathlocal] = eml_const(eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,useInputFimathForFiConstructors,emlInputFimath,datasz,data,varargin{2:end}));
        end
        % If the data in the fi was finally set by a PV pair then its basically a const, so create the 
        % fi using val instead of varargin{1}
        if pvpairsetdata
            hfi = eml_fi_checkforntype(val,T,F,ERR,isautoscaled,isfimathlocal);
        else
            hfi = eml_fi_checkforntype(varargin{1},T,F,ERR,isautoscaled,isfimathlocal);
        end
        % Throw a coder warning if the now obsolete "Fimath For Fi Cconstructors" property is set to "Same As MATLAB Factory Default" and the fi is fimathless - i.e.
        % a fimath has not been specified.
        if ~useInputFimathForFiConstructors && ~isfimathlocal
            warnMsg = eml_const(sprintf(['The ''Same as MATLAB factory default'' setting for the ''FIMATH for fi and fimath constructors'' is now obsolete.\n',...
                            'All fi objects constructed in the EML Function block with an unspecified fimath now use the ''Embedded MATLAB Function Block fimath'' as their default fimath.\n',...
                            'If your ''Embedded MATLAB Function Block fimath'' is not the MATLAB factory default fimath, you may see different results when running your model in release R2009b and later.\n',...
                            'For more information on this change, see the <a href="matlab:helpview([docroot ''/toolbox/fixedpoint/fixedpoint.map''], ''cc_eml_block_fimath'')">R2009b Fixed-Point Toolbox Release Notes.</a>\n',...
                            'To turn off this warning, run slupdate on your model.']));
            eml_assert(0,'warning',warnMsg);
        end

    end

%--------------------------------------------------------------------------------------------

