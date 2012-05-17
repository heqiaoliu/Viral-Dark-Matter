function varargout = commonplotfunc(action,fname,inputnames,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009 The MathWorks, Inc.

% Default display functions for shared toolbox plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        case 'bolling' % Numeric vector or matrix and optional grouping variable
            if n==2
                asset = inputvals{1};
                samples = inputvals{2};
                toshow = isnumeric(asset) && isvector(asset) && all(asset>0) && ...
                    isscalar(samples) && samples>0 && round(samples)==samples;
            elseif n==3
                asset = inputvals{1};
                samples = inputvals{2};
                alpha = inputvals{3};
                toshow = isnumeric(asset) && isvector(asset) && all(asset>0) && ...
                    isscalar(samples) && samples>0 && round(samples)==samples && ...
                    isscalar(alpha) && alpha>0;
            elseif n==4
                asset = inputvals{1};
                samples = inputvals{2};
                alpha = inputvals{3};
                width = inputvals{4};
                toshow = isnumeric(asset) && isvector(asset) && all(asset>0) && ...
                    isscalar(samples) && samples>0 && round(samples)==samples && ...
                    isscalar(alpha) && alpha>0 && isscalar(width) && width>0;
            end
        case 'highlow'
            if n==3
                high = inputvals{1};
                low = inputvals{2};
                close = inputvals{3};
                toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && ...
                    isvector(high) && size(high,2)==1 && isequal(size(high),size(low)) && ...
                    isequal(size(high),size(close));
            elseif n==4
                high = inputvals{1};
                low = inputvals{2};
                close = inputvals{3};
                open = inputvals{4};
                toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && isnumeric(open) && ...
                    isvector(high) && size(high,2)==1 && isequal(size(high),size(low)) && ...
                    isequal(size(high),size(close)) && isequal(size(high),size(open));
            elseif n==5
                high = inputvals{1};
                low = inputvals{2};
                close = inputvals{3};
                open = inputvals{4};
                color = inputvals{5};
                toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && isnumeric(open) && ...
                    isvector(high) && size(high,2)==1 && isequal(size(high),size(low)) && ...
                    isequal(size(high),size(close)) && isequal(size(high),size(open)) && ischar(color);
            end
        case 'candle'
            if n==4
                high = inputvals{1};
                low = inputvals{2};
                close = inputvals{3};
                open = inputvals{4};
                toshow = isnumeric(high) && isnumeric(low) && isnumeric(close) && isnumeric(open) && ...
                    isvector(high) && isvector(low) && isvector(close) && ...
                    isvector(open) && length(high)==length(low) && length(high)==length(close) && ...
                    length(high)==length(open);
            end
        case 'kagi'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,2)==2 && ...
                    size(x,1)>1 && all(x(:,2)>=0);
            end
        case 'renko'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,2)==2 && ...
                    size(x,1)>1 && all(x(:,2)>=0);
            elseif n==2
                x = inputvals{1};
                threshhold = inputvals{2};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,2)==2 && ...
                    size(x,1)>1 && all(x(:,2)>=0) && isscalar(threshhold) && ...
                    threshhold>=0;
            end
        case 'movavg'
            if n==3
                asset = inputvals{1};
                lead = inputvals{2};
                lag = inputvals{3};
                toshow = isnumeric(asset) && isvector(asset) && all(asset(:)>=0) && ...
                    isscalar(lead) && isscalar(lag) && lead<=lag && round(lead)==lead && ...
                    round(lag)==lag;
            elseif n==4
                asset = inputvals{1};
                lead = inputvals{2};
                lag = inputvals{3};
                alpha = inputvals{4};
                toshow = isnumeric(asset) && isvector(asset) && all(asset(:)>=0) && ...
                    isscalar(lead) && isscalar(lag) && lead<=lag && round(lead)==lead && ...
                    round(lag)==lag && isscalar(alpha) && alpha>=0;
            end
        case 'priceandvol'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)==6 && ...
                    all(x(:)>=0);
            end
        case 'pointfig'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && isvector(x) && ~isscalar(x) && all(x(:)>=0);
            end
        case 'volarea'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)==3 && ...
                    all(x(:)>=0);
            end
        case {'sfitsurface','sfitpredfunc','sfitpredobs','sfitcontour'}
            if n==1 
                toshow = isa(inputvals{1},'sfit');
            elseif n==3
                xy = inputvals{2};
                z = inputvals{3};
                toshow = isa(inputvals{1},'sfit') && isfloat(xy) && ndims(xy)==2 &&...
                    size(xy,2)==2 &&  isfloat(z) && isvector(z) && ...
                    size(z,2)==1 && length(z)==size(xy,1);
            end  
        case {'sfitresiduals'}
            if n==3
                xy = inputvals{2};
                z = inputvals{3};
                toshow = isa(inputvals{1},'sfit') && isfloat(xy) && ndims(xy)==2 &&...
                    size(xy,2)==2 &&  isfloat(z) && isvector(z) && ...
                    size(z,2)==1 && length(z)==size(xy,1);
            end 
        case {'cfitfit','cfitpredfunc','cfitpredobs','cfitderiv1','cfitderiv2','cfitintegral'}
            if n==1 
                toshow = isa(inputvals{1},'cfit');
            elseif n==3 || n==4
                xdata = inputvals{2};
                ydata = inputvals{3};
                toshow = isa(inputvals{1},'cfit') && isfloat(xdata) && isvector(xdata) && ...
                    isfloat(ydata) && isvector(ydata) && ...
                    length(xdata) == length(ydata);
            end
            if n==4 && toshow
                if isscalar(inputvals{4})
                    level = inputvals{4};
                    toshow = level>=0 && level<=1;
                else
                    outliers = inputvals{4};
                    toshow =  islogical(outliers) && isvector(outliers) && ...
                        length(outliers) == length(ydata);
                end
            end
        case {'cfitresduals','cfitstrersiduals'}
            if n==3 || n==4
                xdata = inputvals{2};
                ydata = inputvals{3};
                toshow = isa(inputvals{1},'cfit') && isfloat(xdata) && isvector(xdata) && ...
                    isfloat(ydata) && isvector(ydata) && ...
                    length(xdata) == length(ydata);
            end
            if n==4 && toshow
                if isscalar(inputvals{4})
                    level = inputvals{4};
                    toshow = level>=0 && level<=1;
                else
                    outliers = inputvals{4};
                    toshow =  islogical(outliers) && isvector(outliers) && ...
                        length(outliers) == length(ydata);
                end
            end
        case 'cftool'
            if n==2 || n==3 
                x = inputvals{1};
                y = inputvals{2};
                toshow = isfloat(x) && isvector(x) && ...
                    isfloat(y) && isvector(y) && ...
                    length(x) == length(y);
                if n==3
                    w = inputvals{3};
                    toshow = toshow && isvector(w) && isfloat(w) && length(x) == length(w);
                end
            end  
         case 'sftool'
            if n==3 || n==4 
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                toshow = isfloat(x) && isvector(x) && ...
                    isfloat(y) && isvector(y) && ...
                    isfloat(z) && isvector(z) && ...
                    length(x) == length(y) && ...
                    length(x) == length(z);
                if n==4
                    w = inputvals{4};
                    toshow = toshow && isvector(w) && isfloat(w) && length(x) == length(w);
                end
            end  
    end
    varargout{1} = toshow;
elseif strcmp(action,'defaultdisplay')
    dispStr = '';
    switch lower(fname)
        case 'sfitsurface'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''style'',''Surface'');figure(gcf)'];
        case 'sfitpredfunc' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''style'',''PredFunc'');figure(gcf)'];
        case 'sfitpredobs'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''style'',''PredObs'');figure(gcf)'];
        case 'sfitresiduals' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''style'',''Residuals'');figure(gcf)'];
        case 'sfitcontour' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''style'',''Contour'');figure(gcf)'];
        case 'cfitfit' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''fit'');figure(gcf)'];
        case 'cfitpredfunc' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''predfunc'');figure(gcf)'];
        case 'cfitpredobs' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''predobs'');figure(gcf)'];
        case 'cfitresiduals' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''residuals'');figure(gcf)'];
        case 'cfitstresiduals' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''stresiduals'');figure(gcf)'];
        case 'cfitderiv1' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''deriv1'');figure(gcf)'];
        case 'cfitderiv2' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''deriv2'');figure(gcf)'];
        case 'cfitintegral' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['plot(' inputNameArray{:} '''integral'');figure(gcf)'];
        case 'cftool' 
            inputNameArray = [inputnames(1:end-1);repmat({','},1,length(inputnames)-1)]; 
            dispStr = ['cftool(' inputNameArray{:} inputnames{end} ');'];
         case 'sftool' 
            inputNameArray = [inputnames(1:end-1);repmat({','},1,length(inputnames)-1)]; 
            dispStr = ['sftool(' inputNameArray{:} inputnames{end} ');'];
    end
    varargout{1} = dispStr;
elseif strcmp(action,'defaultlabel')
    lblStr = '';
    switch lower(fname)
        case 'sfitsurface'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''style'',''Surface'')'];
        case 'sfitpredfunc'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''style'',''PredFunc'')'];
        case 'sfitpredobs'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''style'',''PredObs'')'];
        case 'sfitresiduals'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''style'',''Residuals'')'];
        case 'sfitcontour'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''style'',''Contour'')'];
        case 'cfitfit'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} ',''fit'')'];  
        case 'cfitpredfunc'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''predfunc'')'];
        case 'cfitpredobs'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''predobs'')'];
        case 'cfitresiduals'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''residuals'')'];
        case 'cfitstresiduals'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''stresiduals'')'];
        case 'cfitderiv1'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''deriv1'')'];
        case 'cfitderiv2'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''deriv2'')'];
        case 'cfitintegral'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))];            
            lblStr = ['plot(' inputNameArray{:} '''integral'')'];
    end

    varargout{1} = lblStr;
end


