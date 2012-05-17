function [minval,indx] = min(x0,y0,dim)
% Embedded MATLAB Library fixed-point function for min.
%
% Limitations:
% 1) Does not support complex.

%   Copyright 2004-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.10 $  $Date: 2009/10/24 19:03:30 $

eml_allow_mx_inputs;    

eml_assert(nargin > 0,'error','Not enough input arguments.');
eml_assert(isreal(x0),'Complex inputs to MIN are not supported.');
if (nargin == 2)
    eml_assert(isreal(y0),'Complex inputs to MIN are not supported.');
end

% Check for ambiguous types and return with the correct size output
if eml_ambiguous_types
    if nargin == 1 
        if nargout == 1 
            eml_min_or_max('min',double(x0)); 
        else 
            [~,indx] = eml_min_or_max('min',double(x0)); 
        end 
    elseif nargin == 2 
        if nargout == 1 
            eml_min_or_max('min',double(x0),double(y0)); 
        else 
            [~,indx] = eml_min_or_max('min',double(x0),double(y0)); 
        end 
    else 
        if nargout == 1 
            eml_min_or_max('min',double(x0),double(y0),double(dim)); 
        else 
            [~,indx] = eml_min_or_max('min',double(x0),double(y0),double(dim)); 
        end 
    end 
    return 

end

if nargin==1
    % minval     = min(x)
    % [minval,indx] = min(x)
    
    if isfixed(x0)
        % Fixed FI
        x = x0;
        if nargout <= 1
            minval = eml_min_or_max('min',x);
        else
            [minval,indx] = eml_min_or_max('min',x);
        end
    elseif isfloat(x0)
        % True Double or True Single FI
        dType  = eml_fi_getDType(x0);
        x      = eml_cast(x0,dType);
        T      = eml_typeof(x0);
        F      = eml_fimath(x0);
        if nargout <= 1
            minval = eml_cast(eml_min_or_max('min',x),T,F);
        else
            [minvalTemp,indx] = eml_min_or_max('min',x);
            minval            = eml_fimathislocal(eml_cast(minvalTemp,T,F),false);
        end
    else
        % FI datatype not supported
        eml_fi_assert_dataTypeNotSupported('MIN','fixed-point,double, or single');
    end
        
    
elseif nargin==2
    % minval = min(x,y)

    if ( (isfi(x0) && isfixed(x0)) || ...
         (isfi(y0) && isfixed(y0)) )
        % Fixed FI

        if ~isfi(y0) % fi , non-fi
            tx = eml_typeof(x0);
            % Cast y0 to x0's type
            f = eml_fimath(x0);
            x = x0; y = eml_fimathislocal(eml_cast(y0,tx,f),eml_fimathislocal(x0));
        elseif ~isfi(x0) % non-fi , fi
            ty = eml_typeof(y0);
            % Cast x0 to y0's type
            f = eml_fimath(y0);
            y = y0; x = eml_fimathislocal(eml_cast(x0,ty,f),eml_fimathislocal(y0));
        else % fi , fi
             % Obtain the eml_typeofs of x & y
            tx = eml_typeof(x0); ty = eml_typeof(y0);
            % Get the fimaths
            fx = eml_fimath(x0); 
            fy = eml_fimath(y0); 
            % Check for numerictypes and fimaths to be equal.
            eml_assert(eml_const(isequal(tx,ty)),'NUMERICTYPE of both operands must be equal.');
            eml_assert(eml_const(isequal(fx,fy)),'FIMATH of both operands must be equal');
            x = x0; y = y0;
        end
        
        if nargout <= 1
            minval = eml_min_or_max('min',x,y);
        else
            % This will produce an assertion for nargout>1
            [minval,indx] = eml_min_or_max('min',x,y);
        end
        
    elseif ( isfi(x0) && isfloat(x0) ) || ...
            ( isfi(y0) && isfloat(y0) )
        % True Double or True Single FI
        
        if ~isfi(x0) % non-fi , fi
            dType = eml_fi_getDType(y0);
            T     = eml_typeof(y0);
            F     = eml_fimath(y0);
        else % fi , non-fi or fi , fi
            dType = eml_fi_getDType(x0);
            T     = eml_typeof(x0);
            F     = eml_fimath(x0);
        end
        x = eml_cast(x0,dType);
        y = eml_cast(y0,dType);

        if nargout <= 1
            minval = eml_fimathislocal(eml_cast(eml_min_or_max('min',x,y),T,F),false);
        else
            % This will produce an assertion for nargout>1
            [minvalTemp,indx] = eml_min_or_max('min',x,y);
            minval            = eml_fimathislocal(eml_cast(minvalTemp,T,F),false);
        end

    else
        % FI datatype not supported
        eml_fi_assert_dataTypeNotSupported('MIN','fixed-point,double, or single');
    end
    
elseif nargin==3
    % [minval,indx] = min(A,[],DIM)

    if isfixed(x0)
        % Fixed FI
        if nargout <= 1
            minval = eml_min_or_max('min',x0,y0,double(dim));
        else
            [minval,indx] = eml_min_or_max('min',x0,y0,double(dim));
        end
    elseif isfloat(x0)
        % True Double or True Single FI
        dType  = eml_fi_getDType(x0);
        x      = eml_cast(x0,dType);
        T      = eml_typeof(x0);
        F      = eml_fimath(x0);

        if nargout <= 1
            minval = eml_cast(eml_min_or_max('min',x,y0,double(dim)),T,F);
        else
            [minvalTemp,indx] = eml_min_or_max('min',x,y0,double(dim));
            minval            = eml_cast(minvalTemp,T,F);
        end
    else
        % FI datatype not supported
        eml_fi_assert_dataTypeNotSupported('MIN','fixed-point,double, or single');
    end
    
end

%---------------------------------------------------------------------------------------------------
