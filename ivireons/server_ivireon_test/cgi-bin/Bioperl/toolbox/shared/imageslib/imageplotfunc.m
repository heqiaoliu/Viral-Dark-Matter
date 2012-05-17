function varargout = imageplotfunc(action,fname,inputnames,inputvals)
% IMAGEPLOTFUNC
%   This is an undocumented function and may be removed in a future release.

% IMAGEPLOTFUNC  Support function for Plot Picker component. The function
% may change in future releases.

% Copyright 2009 The MathWorks, Inc.

% Determine if IPT functions should be enabled
if strcmp(action,'defaultshow')
    
    n = length(inputvals);
    toshow = false;
    
    switch lower(fname)
        
        case {'imshow','imtool'}
            
            if n == 1 || n == 2
                
                I = inputvals{1};
                
                % a filename is a string containing a '.'.  We put this
                % check in first so that we can bail out on non-filename
                % strings before calling EXIST which will hit the file
                % system.
                isfile = ischar(I) && numel(I) > 2 && ...
                    ~isempty(strfind(I(2:end-1),'.')) && ...
                    exist(which(I),'file');
                is2d = ndims(I) == 2;
                is3d = ndims(I) == 3;
                isntVector = min(size(I)) > 1;
                
                % define image types
                isgrayscale = ~isfile && isnumeric(I) && is2d && isntVector;
                isindexed = isgrayscale && isinteger(I);
                istruecolor = ~isfile && isnumeric(I) && is3d && ...
                    isntVector && size(I,3) == 3;
                isbinary = ~isfile && islogical(I) && is2d && isntVector;
                
                toshow = isfile || isgrayscale || isindexed || ...
                    istruecolor || isbinary;
                
                % if 2 variables are selected...
                if toshow && n == 2
                    
                    arg2 = inputvals{2};
                    
                    iscolormap = ndims(arg2) == 2 && size(arg2,2) == 3 && ...
                        all(arg2(:) >= 0 & arg2(:) <= 1);
                    isdisplayrange = isnumeric(arg2) && isvector(arg2) && ...
                        length(arg2) == 2 && arg2(2) > arg2(1);
                    
                    if isindexed && iscolormap
                        % imshow(X,map)
                        toshow = true;
                        
                    elseif isgrayscale && isdisplayrange
                        % imshow(I,[low high])
                        toshow = true;
                        
                    else
                        toshow = false;
                        
                    end
                    
                end
                
            end
    end
    varargout{1} = toshow;
    
    % Determine custom execution text for IPT functions. Default execution text
    % is not generated here.
elseif strcmp(action,'defaultdisplay')
    
    dispStr = '';
    switch lower(fname)
        
        % Suppress the appended figure(gcf) for imtool
        case 'imtool'
            inputNameArray = [inputnames(1:end-1);repmat({','},1,length(inputnames)-1)];
            dispStr = ['imtool(' inputNameArray{:} inputnames{end} ');'];
            
    end
    varargout{1} = dispStr;
    
end

