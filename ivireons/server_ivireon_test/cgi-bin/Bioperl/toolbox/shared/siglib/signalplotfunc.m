function varargout = signalplotfunc(action,fname,inputnames,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009 The MathWorks, Inc.

% Default display functions for MATLAB plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        % Either one or more dfilt objects or one or more numerator-denominator
        % pairs.
        case {'fvtoolmag','fvtoolphase','fvtoolmagphase','fvtoolgrpdelay',...
                'fvtoolphdelay','fvtoolimpulse','fvtoolstep','fvtoolpolezero',...
                'fvtoolfiltcoef','fvtoolfiltinfo'} 
            x = inputvals{1};
            if n==1 
                toshow = isa(x,'dfilt.abstractfilter') && ~isa(x,'mfilt.abstractmultirate');
            else
                if rem(n,2)==0 && isnumeric(x) && isvector(x) && ~isscalar(x)
                     toshow = all(cellfun(@(x) isnumeric(x) && isvector(x) && ~isscalar(x),...
                         inputvals));
                else
                     toshow = all(cellfun(@(x) isa(x,'dfilt.abstractfilter') && ...
                         ~isa(x,'mfilt.abstractmultirate'),inputvals));
                end
            end
        % Either a sigwin object or one or more windows vectors specified using winname
        case 'wvtool'
            x = inputvals{1};
            if n==1
                toshow = isa(x,'sigwin.window') || ...
                    (isnumeric(x) && isvector(x) && ~isscalar(x));
            else
                toshow = all(cellfun(@(x) isnumeric(x) && isvector(x) && ~isscalar(x),...
                         inputvals));
            end
        % A numeric vector or matrix. Optionally add either a positive integer 
        % or between 2 and 3 positive scalars.
        case 'strips'
            x = inputvals{1};
            toshow = isnumeric(x) && ~isscalar(x) && ndims(x)==2;
            if toshow && n==2
                n1 = inputvals{2};                
                toshow = isnumeric(n1) && isscalar(n1) && round(n1)==n1;   
            elseif toshow && n==3
                sd = inputvals{2};
                fs = inputvals{3};
                toshow = isnumeric(sd) && isnumeric(fs) && isscalar(sd) && ...
                    isscalar(fs) && sd>0 && fs>0;
                if n==3 && toshow
                    scale = inputvals{4};
                    toshow = isnumeric(scale) && isscalar(scale) && ...
                        scale>0;
                end   
            else
                toshow = false;
            end
        % A pair of numerator-denominator vectors followed by either: i.) a frequency
        % vector with 2 or more entries; or ii.) a real scalar value indicating
        % the number of frequency points.
        case 'freqs'
            if n==3
                num = inputvals{1};
                den = inputvals{2};
                w = inputvals{3};
                toshow = isnumeric(num) && isnumeric(den) && isvector(num) && ...
                    isvector(den) && isnumeric(w) && isvector(w);
            end
        % A pair of numerator-denominator vectors. Optionally add a
        % scalar or vector of integers and a positive scalar.
        case {'impz','stepz','freqz'}
            if n>=2 && n<=4
                num = inputvals{1};
                den = inputvals{2};
                toshow = isnumeric(num) && isnumeric(den) && isvector(num) && ...
                    isvector(den);
                if toshow && n>=3
                    n1 = inputvals{3};
                    toshow = isnumeric(n1) && isvector(n1) && all(n1==round(n1));
                    if toshow && n==4
                        fs = inputvals{4};
                        toshow = isnumeric(fs) && isscalar(fs) && fs>0;
                    end
                end
            end
        % A pair of numerator-denominator vectors. Optionally add a
        % real scalar or vector and a positive scalar.            
        case {'grpdelay','phasedelay','phasez'}
             if n>=2 && n<=4       
                num = inputvals{1};
                den = inputvals{2}; 
                toshow = isnumeric(num) && isnumeric(den) && isvector(num) && ...
                    isvector(den);
                if toshow && n>=3
                    w = inputvals{3};                   
                    toshow = isnumeric(w) && isvector(w);
                    if toshow && n==4
                        fs = inputvals{4};
                        toshow = isnumeric(fs) && isscalar(fs) && fs>0;
                    end
                end
             end
        % A pair of numerator-denominator vectors. Optionally add
        % real scalar or vector.
        case 'zerophase'
             if n>=2 && n<=3       
                num = inputvals{1};
                den = inputvals{2}; 
                toshow = isnumeric(num) && isnumeric(den) && isvector(num) && ...
                    isvector(den);
                if toshow && n>=3 
                    w = inputvals{3};
                    toshow = isnumeric(w) && isvector(w);
                end
             end
        % A pair row vectors or column vectors or a
        % dfilt object
        case 'zplane'
            if n==1
                toshow = isa(inputvals{1},'dfilt.abstractfilter') && ...
                    ~isa(inputvals{1},'mfilt.abstractmultirate');
            elseif n==2
                z = inputvals{1};
                p = inputvals{2};
                toshow = isnumeric(z) && isnumeric(p) && isvector(z) && ...
                    isvector(p) && ((size(z,1)==1 && size(p,1)==1) || ...
                    (size(z,2)==1 && size(p,2)==1));
            end
        % A pair of vectors of the same length. Optionally add a scalar
        % or numeric vector and a positive integer.
        case {'cpsd','mscohere'}
            if n>=2 && n<=3  
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && isnumeric(y) && isvector(x) && ...
                    isvector(y) && ~isscalar(x) && length(x)==length(y);
                if toshow && n>=3
                    window = inputvals{3};
                    toshow = isnumeric(window) && isvector(window);
                    if toshow && n==4
                        nooverlap = inputvals{4};
                        toshow = isnumeric(nooverlap) && isscalar(nooverlap) && ...
                            nooverlap>0 && round(nooverlap)==nooverlap;
                    end
                end
            end
        % A numeric vector with an optional scalar time-bandwidth product
        case 'pmtm'
           if n>=1 && n<=2
              x = inputvals{1};
              toshow = isnumeric(x) && ~isscalar(x) && isvector(x);
              if n==2
                  p = inputvals{2}; 
                  toshow = toshow && isscalar(p) && isnumeric(p) && p>0;
              end
           end
        % A numeric vector with an optional scalar integer order
        % -or-
        % A numeric vector with an optional scalar integer number of
        % sinusoids
        case {'pburg','pcov','peig','pmcov','pmusic','pyulear'}
           if n>=1 && n<=2
              x = inputvals{1};
              toshow = isnumeric(x) && ~isscalar(x) && isvector(x);
              if n==2
                  p = inputvals{2}; 
                  toshow = toshow && isscalar(p) && isnumeric(p) && ...
                      round(p)==p;
              end
           end
        % A single numeric vector
        case {'periodogram_psd','periodogram_msp','pwelch_psd','pwelch_msp'}
           if n==1
               x = inputvals{1};
               toshow = isnumeric(x) && ~isscalar(x) && isvector(x);
           end


        % A numeric vector. Optionally add in order: i.) a numeric vector
        % or integer>1
        % ii.) a positive integer iii.) a numeric vector or integer
        case 'spectrogram'
            if n>=1 && n<=4
                x = inputvals{1};
                toshow = isnumeric(x) && ~isscalar(x) && isvector(x);
                if toshow && n>=2
                    w = inputvals{2};
                    toshow = ((isvector(w) && ~isscalar(w)) || ...
                        (isscalar(w) && round(w)==w && w>1));
                    if toshow && n==4
                        nfft = inputvals{4}; 
                        toshow = isnumeric(nfft) && isscalar(nfft) && nfft>0;
                    end
                end
            end
        % A pair of numeric vectors of the same length. Optionally add in order: i.) a numeric vector
        % or integer>1
        % ii.) 1 or 2 positive integers iii.) a numeric scalar            
        case 'tfestimate' 
            if n>=2 && n<=5
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && ~isscalar(x) && isvector(x) && ...
                    isnumeric(y) && isvector(y) && length(x)==length(y);
                if toshow && n>=3
                    nooverlap = inputvals{3};
                    toshow = isnumeric(nooverlap) && isscalar(nooverlap) && ...
                        round(nooverlap)==nooverlap && nooverlap>0;
                    if toshow && n>=4
                       nfft = inputvals{4};
                       toshow = isnumeric(nfft) && isscalar(nfft) && ...
                           round(nfft)==nfft && nfft>0;  
                       if toshow && n==5
                           fs = inputvals{5};
                           toshow = isnumeric(fs) && isscalar(fs) && ...
                               fs>0;     
                       end
                    end
                end
            end
    end
    varargout{1} = toshow;
elseif strcmp(action,'defaultdisplay')
    dispStr = '';
    switch lower(fname)
        case 'fvtoolmag'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''magnitude'');figure(gcf)'];
        case 'fvtoolphase' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''phase'');figure(gcf)']; 
        case 'fvtoolmagphase'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''freq'');figure(gcf)'];   
        case 'fvtoolgrpdelay'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''grpdelay'');figure(gcf)'];
        case 'fvtoolphdelay'
             inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''phasedelay'');figure(gcf)'];           
        case 'fvtoolimpulse'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''impulse'');figure(gcf)']; 
        case 'fvtoolstep'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''step'');figure(gcf)'];
        case 'fvtoolpolezero'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''polezero'');figure(gcf)'];
        case 'fvtoolfiltcoef'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''coefficients'');figure(gcf)'];
        case 'fvtoolfiltinfo'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''info'');figure(gcf)'];
        case 'wvtool'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['wvtool(' inputNameArray{1:end-1} ');'];
        case {'burg','cov','mcov','mtm','yulear'}
            if length(inputnames)==1
               dispStr = sprintf('psd(spectrum.%s,%s);;figure(gcf)',fname,inputnames{1});
            elseif length(inputnames)==2
               dispStr = sprintf('psd(spectrum.%s(%s),%s,);;figure(gcf)',fname,inputnames{1},...
                   inputnames{2});
            end 
        case 'periodogram_psd'    
            if length(inputnames)==1
               dispStr = sprintf('psd(spectrum.periodogram,%s);;figure(gcf)',inputnames{1});
            end  
        case 'periodogram_msp'    
            if length(inputnames)==1
               dispStr = sprintf('msspectrum(spectrum.periodogram,%s);figure(gcf)',inputnames{1});
            end
        case 'peig'    
            if length(inputnames)==1
               dispStr = sprintf('pseudospectrum(spectrum.eigenvector,%s);figure(gcf)',inputnames{1});
            elseif length(inputnames)==2
               dispStr = sprintf('pseudospectrum(spectrum.eigenvector(%s),%s,);figure(gcf)',inputnames{1},...
                   inputnames{2});
            end
        case 'pmusic'    
            if length(inputnames)==1
               dispStr = sprintf('pseudospectrum(spectrum.music,%s);figure(gcf);',inputnames{1});
            elseif length(inputnames)==2
               dispStr = sprintf('pseudospectrum(spectrum.music(%s),%s,);figure(gcf)',inputnames{1},...
                   inputnames{2});
            end
        case 'pwelch_psd'    
            if length(inputnames)==1
               dispStr = sprintf('psd(spectrum.welch,%s);figure(gcf)',inputnames{1});
            end  
        case 'pwelch_msp'    
            if length(inputnames)==1
               dispStr = sprintf('msspectrum(spectrum.welch,%s);figure(gcf)',inputnames{1});
            end
    end
    varargout{1} = dispStr;   
elseif strcmp(action,'defaultlabel')   
    lblStr = '';
    switch lower(fname)  
        case {'burg','cov','mcov','mtm','yulear'}
            if length(inputnames)==1
               lblStr = sprintf('psd(spectrum.%s,%s);',fname,inputnames{1});
            elseif length(inputnames)==2
               lblStr = sprintf('psd(spectrum.%s(%s),%s,);',fname,inputnames{1},...
                   inputnames{2});
            end
        case 'peig'
            if length(inputnames)==1
               lblStr = sprintf('pseudospectrum(spectrum.eigenvector,%s);',inputnames{1});
            elseif length(inputnames)==2
               lblStr = sprintf('pseudospectrum(spectrum.eigenvector(%s),%s,);',inputnames{1},...
                   inputnames{2});
            end 
        case 'periodogram_psd'
            if length(inputnames)==1
               lblStr = sprintf('psd(spectrum.periodogram,%s);',inputnames{1});
            end  
        case 'periodogram_msp'
            if length(inputnames)==1
               lblStr = sprintf('msspectrum(spectrum.periodogram,%s);',inputnames{1});
            end 
        case 'pmusic'
            if length(inputnames)==1
               lblStr = sprintf('pseudospectrum(spectrum.music,%s);',inputnames{1});
            elseif length(inputnames)==2
               lblStr = sprintf('pseudospectrum(spectrum.music(%s),%s,);',inputnames{1},...
                   inputnames{2});
            end
        case 'pwelch_psd'
            if length(inputnames)==1
               lblStr = sprintf('psd(spectrum.welch,%s);',inputnames{1});
            end  
        case 'pwelch_msp'
            if length(inputnames)==1
               lblStr = sprintf('msspectrum(spectrum.welch,%s);',inputnames{1});
            end
    end
    varargout{1} = lblStr;
end

