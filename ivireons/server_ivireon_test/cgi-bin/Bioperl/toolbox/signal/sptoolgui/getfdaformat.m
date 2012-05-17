function FDAstate = getfdaformat(filtSPT)
%   GETFDAFORMAT   

%   Author(s): J. Sun
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:29:32 $

% If session has already been converted, use FDASpecs field if not translate
if isfield(filtSPT,'FDAspecs') && ~isempty(filtSPT.FDAspecs)
%    make sure not to do the job again if already exist.
    FDAstate = filtSPT.FDAspecs;
else
%     do the translation    
    FDAstate.Components = cell(1,3);
    FDAstate.Components{1}.Tag = 'siggui.filterorder';
    switch filtSPT.specs.currentModule
        case 'fdremez'
            FDAstate.DesignMethod = 'filtdes.remez';
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdremez.order);                       
                
            FDAstate.Components{1}.isMinOrd = 1;
            if(isequal(filtSPT.specs.fdremez.setOrderFlag, 0))                
                FDAstate.Components{1}.mode = 'minimum';
            else
                FDAstate.Components{1}.mode = 'specify';
            end
           if isequal(filtSPT.specs.fdremez.m(:), [1 1 0 0]')
%                     lowpass
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';  
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';
                FDAstate.Components{2}.freqUnits = 'Hz';
                FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
               
                % Set lowpass Fpass
                FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdremez.f(2)*(filtSPT.Fs/2));
                % Set lowpass Fstop
                FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdremez.f(3)*(filtSPT.Fs/2));
                
                if(~isequal(filtSPT.specs.fdremez.setOrderFlag, 0))
%                     'specify' mode                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpweight';
%                     FDAstate.Components{3}.Version = 1;
                    FDAstate.Components{3}.Wpass = num2str(filtSPT.specs.fdremez.wt(1));
                    FDAstate.Components{3}.Wstop = num2str(filtSPT.specs.fdremez.wt(2));
                else
%                     'minimum' mode
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmag';
                    FDAstate.Components{3}.IRType = 'FIR';
                    FDAstate.Components{3}.magUnits = 'dB';
%                     FDAstate.Components{3}.Version = 1;

                    % Set lowpass Apass
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdremez.Rp);
                    % Set lowpass Astop
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdremez.Rs);
                end
           elseif isequal(filtSPT.specs.fdremez.m(:), [0 0 1 1]')
%                     highpass
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';                                                

                FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';
                FDAstate.Components{2}.freqUnits = 'Hz';
                FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);                               
                FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdremez.f(3)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdremez.f(2)*(filtSPT.Fs/2));                              
                
                if(~isequal(filtSPT.specs.fdremez.setOrderFlag, 0))
%                     'specify' mode                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpweight';
%                     FDAstate.Components{3}.Version = 1;
                    FDAstate.Components{3}.Wpass = num2str(filtSPT.specs.fdremez.wt(1));
                    FDAstate.Components{3}.Wstop = num2str(filtSPT.specs.fdremez.wt(2));
                else
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmag';
                    FDAstate.Components{3}.IRType = 'FIR';
                    FDAstate.Components{3}.magUnits = 'dB';
%                     FDAstate.Components{3}.Version = 1;
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdremez.Rp);
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdremez.Rs);  
                end
           elseif isequal(filtSPT.specs.fdremez.m(:), [0 0 1 1 0 0]')
%                     bandpass
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';                                                
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                FDAstate.Components{2}.freqUnits = 'Hz';
                FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);                
                FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdremez.f(2)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdremez.f(3)*(filtSPT.Fs/2));                
                FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdremez.f(4)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdremez.f(5)*(filtSPT.Fs/2));                                                                   
                
                if(~isequal(filtSPT.specs.fdremez.setOrderFlag, 0))                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpweight';
%                     FDAstate.Components{3}.Version = 1;
    %                 jsun - are the weights right???
                    FDAstate.Components{3}.Wstop1 = num2str(filtSPT.specs.fdremez.wt(1));
                    FDAstate.Components{3}.Wpass = num2str(filtSPT.specs.fdremez.wt(2));
                    FDAstate.Components{3}.Wstop2 = num2str(filtSPT.specs.fdremez.wt(3));
                else
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmag';
                    FDAstate.Components{3}.IRType = 'FIR';
                    FDAstate.Components{3}.magUnits = 'dB';
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdremez.Rp);
                    % Set Astop1 and Astop2 - right???
                    FDAstate.Components{3}.Astop1 = num2str(filtSPT.specs.fdremez.Rs);
                    FDAstate.Components{3}.Astop2 = num2str(filtSPT.specs.fdremez.Rs);  
                end
           elseif isequal(filtSPT.specs.fdremez.m(:), [1 1 0 0 1 1]') 
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                FDAstate.Components{2}.freqUnits = 'Hz';
                FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                                
                FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdremez.f(2)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdremez.f(3)*(filtSPT.Fs/2));                
                FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdremez.f(4)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdremez.f(5)*(filtSPT.Fs/2));                                                   
                
                if(~isequal(filtSPT.specs.fdremez.setOrderFlag, 0))
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsweight';
    %                 jsun - are the weights right???
                    FDAstate.Components{3}.Wpass1 = num2str(filtSPT.specs.fdremez.wt(1));
                    FDAstate.Components{3}.Wstop = num2str(filtSPT.specs.fdremez.wt(2));
                    FDAstate.Components{3}.Wpass2 = num2str(filtSPT.specs.fdremez.wt(3));
                else
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmag';
                    FDAstate.Components{3}.IRType = 'FIR';
                    FDAstate.Components{3}.magUnits = 'dB';
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdremez.Rs);
                    % Set Astop1 and Astop2 - right???
                    FDAstate.Components{3}.Apass1 = num2str(filtSPT.specs.fdremez.Rp);
                    FDAstate.Components{3}.Apass2 = num2str(filtSPT.specs.fdremez.Rp);   
                end
           end                                                              
        case 'fdfirls'
            FDAstate.DesignMethod = 'filtdes.firls';
            FDAstate.Components{1}.isMinOrd = 0;     %least square FIR only support this
            FDAstate.Components{1}.mode = 'specify'; %least square FIR only support this
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdfirls.order);
            
            FDAstate.Components{2}.freqUnits = 'Hz';
            FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                                    
            if isequal(filtSPT.specs.fdfirls.m(:), [1 1 0 0]') 
%                 lowpass filter
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';                                                
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';                
                FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdfirls.f(2)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdfirls.f(3)*(filtSPT.Fs/2));
                      
                FDAstate.Components{3}.Wpass = num2str(filtSPT.specs.fdfirls.Rp);
                FDAstate.Components{3}.Wstop = num2str(filtSPT.specs.fdfirls.Rs);
                FDAstate.Components{3}.Tag = 'fdadesignpanel.lpweight';
                %              remove the unused cell emements
%                 FDAstate.Components(4) = [];

            elseif isequal(filtSPT.specs.fdfirls.m(:), [0 0 1 1]') 
%                 highpass filter
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';  
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';                
                FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdfirls.f(3)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdfirls.f(2)*(filtSPT.Fs/2));
                      
                FDAstate.Components{3}.Tag = 'fdadesignpanel.hpweight';
                FDAstate.Components{3}.Wpass = num2str(filtSPT.specs.fdfirls.Rp);
                FDAstate.Components{3}.Wstop = num2str(filtSPT.specs.fdfirls.Rs);                
            elseif isequal(filtSPT.specs.fdfirls.m(:), [0 0 1 1 0 0]') 
%                 bandpass filter
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';  
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                
                FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdfirls.f(2)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdfirls.f(3)*(filtSPT.Fs/2));                
                FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdfirls.f(4)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdfirls.f(5)*(filtSPT.Fs/2));
              
                FDAstate.Components{3}.Tag = 'fdadesignpanel.bpweight';
%                 FDAstate.Components{3}.Version = 1;
%                 jsun - are the weights right???
                FDAstate.Components{3}.Wstop1 = num2str(filtSPT.specs.fdfirls.wt(1));
                FDAstate.Components{3}.Wpass = num2str(filtSPT.specs.fdfirls.wt(2));
                FDAstate.Components{3}.Wstop2 = num2str(filtSPT.specs.fdfirls.wt(3));
            elseif isequal(filtSPT.specs.fdfirls.m(:), [1 1 0 0 1 1]') 
%                 bandstop filter
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                
                FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                
                FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdfirls.f(2)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdfirls.f(3)*(filtSPT.Fs/2));                
                FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdfirls.f(4)*(filtSPT.Fs/2));
                FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdfirls.f(5)*(filtSPT.Fs/2));
               
                FDAstate.Components{3}.Tag = 'fdadesignpanel.bsweight';
                FDAstate.Components{3}.Wpass1 = num2str(filtSPT.specs.fdfirls.wt(1));
                FDAstate.Components{3}.Wstop = num2str(filtSPT.specs.fdfirls.wt(2));
                FDAstate.Components{3}.Wpass2 = num2str(filtSPT.specs.fdfirls.wt(3));
            end   
        case 'fdkaiser'
            FDAstate.DesignMethod = 'filtdes.fir1';
%             FDAstate.Components{1}.Tag = 'siggui.filterorder';
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdkaiser.order);
            FDAstate.Components{1}.isMinOrd = 1;            
            
            FDAstate.Components{2}.freqUnits = 'Hz';
            FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);              
                
            FDAstate.Components{3}.Tag = 'siggui.firwinoptionsframe';                    
            FDAstate.Components{3}.Window = 'Kaiser';
            FDAstate.Components{3}.Parameter = num2str(filtSPT.specs.fdkaiser.Beta);            
            
            if(isequal(filtSPT.specs.fdkaiser.setOrderFlag, 0))
                FDAstate.Components{1}.mode = 'minimum';
                FDAstate.Components{3}.isMinOrder = 1; 
                FDAstate.Components{4}.IRType = 'FIR';
                FDAstate.Components{4}.magUnits = 'dB';               
            else
                FDAstate.Components{1}.mode = 'specify';                                
                FDAstate.Components{3}.isMinOrder = 0;
%                 FDAstate.Components{4}.Tag = 'fdadesignpanel.magfirtxt';
            end
            if isequal(filtSPT.specs.fdkaiser.type, 1)
%                     lowpass
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';                                       
                if(~isequal(filtSPT.specs.fdkaiser.setOrderFlag, 0))
%                     'specify' mode                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqcutoff';
                    FDAstate.Components{2}.Fc = num2str(filtSPT.specs.fdkaiser.Wn*filtSPT.Fs/2);                       
                else
%                     'minimum' mode
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdkaiser.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdkaiser.f(3)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{4}.Tag = 'fdadesignpanel.lpmag';
                    FDAstate.Components{4}.Apass = num2str(filtSPT.specs.fdkaiser.Rp);
                    FDAstate.Components{4}.Astop = num2str(filtSPT.specs.fdkaiser.Rs);
                end
            elseif isequal(filtSPT.specs.fdkaiser.type, 2)
%                     highpass
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';                                                

                if(~isequal(filtSPT.specs.fdkaiser.setOrderFlag, 0))
%                     'specify' mode                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqcutoff';
                    FDAstate.Components{2}.Fc = num2str(filtSPT.specs.fdkaiser.Wn*filtSPT.Fs/2);                     
                else
%                     'minimum' mode
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdkaiser.f(3)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdkaiser.f(2)*(filtSPT.Fs/2));

                    FDAstate.Components{4}.Tag = 'fdadesignpanel.hpmag';
                    FDAstate.Components{4}.Apass = num2str(filtSPT.specs.fdkaiser.Rp);
                    FDAstate.Components{4}.Astop = num2str(filtSPT.specs.fdkaiser.Rs);
                end                                                  
           elseif isequal(filtSPT.specs.fdkaiser.type, 3)
%                     bandpass
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';                                                

                if(~isequal(filtSPT.specs.fdkaiser.setOrderFlag, 0))
%                     'specify' mode                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqcutoff';
                    FDAstate.Components{2}.Fc1 = num2str(filtSPT.specs.fdkaiser.Wn(1)*filtSPT.Fs/2);
                    FDAstate.Components{2}.Fc2 = num2str(filtSPT.specs.fdkaiser.Wn(2)*filtSPT.Fs/2);
                else
%                     'minimum' mode
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdkaiser.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdkaiser.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdkaiser.f(4)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdkaiser.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{4}.Tag = 'fdadesignpanel.bpmag';
                    FDAstate.Components{4}.Apass = num2str(filtSPT.specs.fdkaiser.Rp);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{4}.Astop1 = num2str(filtSPT.specs.fdkaiser.Rs);
                    FDAstate.Components{4}.Astop2 = num2str(filtSPT.specs.fdkaiser.Rs);  
                end                                                                      
           elseif isequal(filtSPT.specs.fdkaiser.type, 4)
%                     bandstop
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                
                if(~isequal(filtSPT.specs.fdkaiser.setOrderFlag, 0))
%                     'specify' mode                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqcutoff';
                    FDAstate.Components{2}.Fc1 = num2str(filtSPT.specs.fdkaiser.Wn(1)*filtSPT.Fs/2);
                    FDAstate.Components{2}.Fc2 = num2str(filtSPT.specs.fdkaiser.Wn(2)*filtSPT.Fs/2);
                else
%                     'minimum' mode
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdkaiser.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdkaiser.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdkaiser.f(4)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdkaiser.f(5)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{4}.Tag = 'fdadesignpanel.bsmag';
                    % Set Apass???
                    FDAstate.Components{4}.Astop = num2str(filtSPT.specs.fdkaiser.Rs);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{4}.Apass1 = num2str(filtSPT.specs.fdkaiser.Rp);
                    FDAstate.Components{4}.Apass2 = num2str(filtSPT.specs.fdkaiser.Rp);  
                end                    
            end         
        case 'fdbutter'
            FDAstate.DesignMethod = 'filtdes.butter';
            FDAstate.Components{1}.Tag = 'siggui.filterorder';            
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdbutter.order);
                        
            FDAstate.Components{2}.freqUnits = 'Hz';
            FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                                           
            FDAstate.Components{1}.isMinOrd = 1;
            if(isequal(filtSPT.specs.fdbutter.setOrderFlag, 0))                
                FDAstate.Components{1}.mode = 'minimum';
%                 FDAstate.Components(4) = [];
            else
                FDAstate.Components{1}.mode = 'specify';                
            end
            if isequal(filtSPT.specs.fdbutter.type, 1)
%                     lowpass
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';     
                                
                if(isequal(filtSPT.specs.fdbutter.setOrderFlag, 0))
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';
                    % Set lowpass Fpass
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdbutter.f(2)*(filtSPT.Fs/2));
                    % Set lowpass Fstop
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdbutter.f(3)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmag';     
                    % Set lowpass Apass
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdbutter.Rp);
                    % Set lowpass Astop
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdbutter.Rs); 
                    FDAstate.Components{3}.IRType = 'IIR';
                    FDAstate.Components{3}.magUnits = 'dB';    
                else
%                     'specify' mode                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqcutoff';                    
                    FDAstate.Components{2}.Fc = num2str(filtSPT.specs.fdbutter.w3db*filtSPT.Fs/2);                    
                    FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                    FDAstate.Components{2}.freqUnits = 'Hz';
%                     FDAstate.Components{2}.Version = 1;
                    FDAstate.Components(3) = [];
                end
            elseif isequal(filtSPT.specs.fdbutter.type, 2)
%                     highpass
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';                                                                                

                if(isequal(filtSPT.specs.fdbutter.setOrderFlag, 0))
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';
                    % Set lowpass Fpass
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdbutter.f(3)*(filtSPT.Fs/2));
                    % Set lowpass Fstop
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdbutter.f(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmag';
                    % Set lowpass Apass
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdbutter.Rp);
                    % Set lowpass Astop
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdbutter.Rs); 
                    FDAstate.Components{3}.IRType = 'IIR';
                    FDAstate.Components{3}.magUnits = 'dB';    
                else
%                     'specify' mode                                         
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqcutoff';                    
                    FDAstate.Components{2}.Fc = num2str(filtSPT.specs.fdbutter.w3db*filtSPT.Fs/2);  
                    FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                    FDAstate.Components{2}.freqUnits = 'Hz';
                    FDAstate.Components(3) = [];
%                     FDAstate.Components{2}.Version = 1;
                end                
           elseif isequal(filtSPT.specs.fdbutter.type, 3)
%                     bandpass
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';                                                                                
                
                if(isequal(filtSPT.specs.fdbutter.setOrderFlag, 0))
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdbutter.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdbutter.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdbutter.f(4)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdbutter.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmag';                
                    % Set Apass???
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdbutter.Rp);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Astop1 = num2str(filtSPT.specs.fdbutter.Rs);
                    FDAstate.Components{3}.Astop2 = num2str(filtSPT.specs.fdbutter.Rs);
                    FDAstate.Components{3}.IRType = 'IIR';
                    FDAstate.Components{3}.magUnits = 'dB';    
                else
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqcutoff';                    
                    FDAstate.Components{2}.Fc1 = num2str(filtSPT.specs.fdbutter.w3db(1)*filtSPT.Fs/2);
                    FDAstate.Components{2}.Fc2 = num2str(filtSPT.specs.fdbutter.w3db(2)*filtSPT.Fs/2);                    
                    FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                    FDAstate.Components{2}.freqUnits = 'Hz';
                    FDAstate.Components(3) = [];
%                     FDAstate.Components{2}.Version = 1;
                end
           elseif isequal(filtSPT.specs.fdbutter.type, 4)
%                     bandstop
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                                
                if(isequal(filtSPT.specs.fdbutter.setOrderFlag, 0))
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdbutter.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdbutter.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdbutter.f(4)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdbutter.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmag';    
                    % Set Apass???
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdbutter.Rs);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Apass1 = num2str(filtSPT.specs.fdbutter.Rp);
                    FDAstate.Components{3}.Apass2 = num2str(filtSPT.specs.fdbutter.Rp); 
                    FDAstate.Components{3}.IRType = 'IIR';
                    FDAstate.Components{3}.magUnits = 'dB';    
                else
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqcutoff';                    
                    FDAstate.Components{2}.Fc1 = num2str(filtSPT.specs.fdbutter.w3db(1)*filtSPT.Fs/2);
                    FDAstate.Components{2}.Fc2 = num2str(filtSPT.specs.fdbutter.w3db(2)*filtSPT.Fs/2);
                    FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
                    FDAstate.Components{2}.freqUnits = 'Hz';
                    FDAstate.Components(3) = [];
%                     FDAstate.Components{2}.Version = 1;
                end
           end         
        case 'fdcheby1'
            FDAstate.DesignMethod = 'filtdes.cheby1';
            FDAstate.Components{1}.Tag = 'siggui.filterorder';
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdcheby1.order);
            FDAstate.Components{1}.isMinOrd = 1;
            
            FDAstate.Components{2}.freqUnits = 'Hz';
            FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
            
            FDAstate.Components{3}.IRType = 'IIR';
            FDAstate.Components{3}.magUnits = 'dB';
            
            if(isequal(filtSPT.specs.fdcheby1.setOrderFlag, 0))                
                FDAstate.Components{1}.mode = 'minimum';
%                 FDAstate.Components(4) = [];
            else
                FDAstate.Components{1}.mode = 'specify';                   
                FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);                    
                FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby1.Rp);
            end
            if isequal(filtSPT.specs.fdcheby1.type, 1)
%                     lowpass
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';                                                
                
                if ~isequal(filtSPT.specs.fdcheby1.setOrderFlag, 0)
                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpass';
                    FDAstate.Components{2}.Fpass = num2str(filtSPT.specs.fdcheby1.Fpass*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmagpass';     
                else
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdcheby1.f(2)*(filtSPT.Fs/2));                                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdcheby1.f(3)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmag';
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby1.Rp);               
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby1.Rs);
                end
            elseif isequal(filtSPT.specs.fdcheby1.type, 2)
%                     highpass
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';                                                
                  
                if ~isequal(filtSPT.specs.fdcheby1.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpass';
                    FDAstate.Components{2}.Fpass = num2str(filtSPT.specs.fdcheby1.Fpass*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmagpass';                     
                else
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdcheby1.f(3)*(filtSPT.Fs/2));                        

                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdcheby1.f(2)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmag'; 
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby1.Rp);
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby1.Rs);
                end                
           elseif isequal(filtSPT.specs.fdcheby1.type, 3)
%                     bandpass
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';                                                
                          
                if ~isequal(filtSPT.specs.fdcheby1.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpass';
                    FDAstate.Components{2}.Fpass1 = num2str(filtSPT.specs.fdcheby1.Fpass(1)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdcheby1.Fpass(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmagpass';                      
                else
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdcheby1.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdcheby1.f(4)*(filtSPT.Fs/2));

                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdcheby1.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdcheby1.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmag';  
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby1.Rp);
                    FDAstate.Components{3}.Astop1 = num2str(filtSPT.specs.fdcheby1.Rs);
                    FDAstate.Components{3}.Astop2 = num2str(filtSPT.specs.fdcheby1.Rs);     
                end
           elseif isequal(filtSPT.specs.fdcheby1.type, 4)
%                     bandstop
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                                               
                if ~isequal(filtSPT.specs.fdcheby1.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpass';
                    FDAstate.Components{2}.Fpass1 = num2str(filtSPT.specs.fdcheby1.Fpass(1)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdcheby1.Fpass(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmagpass'; 
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby1.Rp);
                else
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdcheby1.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdcheby1.f(5)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdcheby1.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdcheby1.f(4)*(filtSPT.Fs/2));                    

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmag';      
                    % Set Apass???
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby1.Rs);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Apass1 = num2str(filtSPT.specs.fdcheby1.Rp);
                    FDAstate.Components{3}.Apass2 = num2str(filtSPT.specs.fdcheby1.Rp); 
                end
           end 
        case 'fdcheby2'
            FDAstate.DesignMethod = 'filtdes.cheby2';
            FDAstate.Components{1}.Tag = 'siggui.filterorder';
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdcheby2.order);
            FDAstate.Components{1}.isMinOrd = 1;
                        
            FDAstate.Components{2}.freqUnits = 'Hz';
            FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
            
            FDAstate.Components{3}.IRType = 'IIR';
            FDAstate.Components{3}.magUnits = 'dB';
                        
            if(isequal(filtSPT.specs.fdcheby2.setOrderFlag, 0))                
                FDAstate.Components{1}.mode = 'minimum';
            else
                FDAstate.Components{1}.mode = 'specify';                                   
                FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby2.Rs);
            end
            if isequal(filtSPT.specs.fdcheby2.type, 1)
%                     lowpass
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';                                                
                
                if ~isequal(filtSPT.specs.fdcheby2.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqstop';
                    FDAstate.Components{2}.Fstop = num2str(filtSPT.specs.fdcheby2.Fstop*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmagstop'; 
                else                    
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdcheby2.f(2)*(filtSPT.Fs/2));                                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdcheby2.f(3)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmag';
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby2.Rp);               
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby2.Rs);
                end
            elseif isequal(filtSPT.specs.fdcheby2.type, 2)
%                     highpass
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';                                                
                  
                if ~isequal(filtSPT.specs.fdcheby2.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqstop';
                    FDAstate.Components{2}.Fstop = num2str(filtSPT.specs.fdcheby2.Fstop*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmagstop';  
                else
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdcheby2.f(3)*(filtSPT.Fs/2));                        
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdcheby2.f(2)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby2.Rp);
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby2.Rs);
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmag';    
                end                
           elseif isequal(filtSPT.specs.fdcheby2.type, 3)
%                     bandpass
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';                                                
                               
                if ~isequal(filtSPT.specs.fdcheby2.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqstop';
                    FDAstate.Components{2}.Fstop1 = num2str(filtSPT.specs.fdcheby2.Fstop(1)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdcheby2.Fstop(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmagstop';  
                else
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdcheby2.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdcheby2.f(4)*(filtSPT.Fs/2));

                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdcheby2.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdcheby2.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmag';  
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdcheby2.Rp);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Astop1 = num2str(filtSPT.specs.fdcheby2.Rs);
                    FDAstate.Components{3}.Astop2 = num2str(filtSPT.specs.fdcheby2.Rs); 
                end
           elseif isequal(filtSPT.specs.fdcheby2.type, 4)
%                     bandstop
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                                              
                if ~isequal(filtSPT.specs.fdcheby2.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqstop';
                    FDAstate.Components{2}.Fstop1 = num2str(filtSPT.specs.fdcheby2.Fstop(1)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdcheby2.Fstop(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmagstop'; 
                else
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdcheby2.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdcheby2.f(5)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdcheby2.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdcheby2.f(4)*(filtSPT.Fs/2));                    

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmag';      
                    % Set Apass???
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdcheby2.Rs);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Apass1 = num2str(filtSPT.specs.fdcheby2.Rp);
                    FDAstate.Components{3}.Apass2 = num2str(filtSPT.specs.fdcheby2.Rp);  
                end
           end 
        case 'fdellip'
            FDAstate.DesignMethod = 'filtdes.ellip';
            FDAstate.Components{1}.Tag = 'siggui.filterorder';
            FDAstate.Components{1}.order = num2str(filtSPT.specs.fdellip.order);
                        
            FDAstate.Components{2}.freqUnits = 'Hz';
            FDAstate.Components{2}.Fs = num2str(filtSPT.Fs);
            
            FDAstate.Components{3}.IRType = 'IIR';
            FDAstate.Components{3}.magUnits = 'dB';
            
            FDAstate.Components{1}.isMinOrd = 1;
            if(isequal(filtSPT.specs.fdellip.setOrderFlag, 0))                
                FDAstate.Components{1}.mode = 'minimum';
            else
                FDAstate.Components{1}.mode = 'specify';   
                
                FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdellip.Rs);
                FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdellip.Rp);
            end
            if isequal(filtSPT.specs.fdellip.type, 1)
%                     lowpass
                FDAstate.ResponseType = 'lp';
                FDAstate.SubType = 'lp';                                                
                
                if ~isequal(filtSPT.specs.fdellip.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpass';
                    FDAstate.Components{2}.Fpass = num2str(filtSPT.specs.fdellip.Fpass*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmag';                                   
                else
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdellip.f(2)*(filtSPT.Fs/2));                                    
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.lpfreqpassstop';
                     FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdellip.f(3)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.lpmag';
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdellip.Rp);               
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdellip.Rs);
                end
            elseif isequal(filtSPT.specs.fdellip.type, 2)
%                     highpass
                FDAstate.ResponseType = 'hp';
                FDAstate.SubType = 'hp';                                                
                
                if ~isequal(filtSPT.specs.fdellip.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpass';
                    FDAstate.Components{2}.Fpass = num2str(filtSPT.specs.fdellip.Fpass*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmag'; %jsun - this is strange compared with others
                else
                    FDAstate.Components{2}.Fpass  = num2str(filtSPT.specs.fdellip.f(3)*(filtSPT.Fs/2));                        
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.hpfreqpassstop';
                    FDAstate.Components{2}.Fstop  = num2str(filtSPT.specs.fdellip.f(2)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdellip.Rp);
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdellip.Rs);
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.hpmag';      
                end                
           elseif isequal(filtSPT.specs.fdellip.type, 3)
%                     bandpass
                FDAstate.ResponseType = 'bp';
                FDAstate.SubType = 'bp';                                                
                                              
                if ~isequal(filtSPT.specs.fdellip.setOrderFlag, 0)
%                     'specify' mode
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpass';
                    FDAstate.Components{2}.Fpass1 = num2str(filtSPT.specs.fdellip.Fpass(1)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdellip.Fpass(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmagpassstop';   
                else
%                     'minimum' mode
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdellip.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdellip.f(4)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bpfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdellip.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdellip.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bpmag';  
                    FDAstate.Components{3}.Apass = num2str(filtSPT.specs.fdellip.Rp);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Astop1 = num2str(filtSPT.specs.fdellip.Rs);
                    FDAstate.Components{3}.Astop2 = num2str(filtSPT.specs.fdellip.Rs);  
                end
           elseif isequal(filtSPT.specs.fdellip.type, 4)
%                     bandstop
                FDAstate.ResponseType = 'bs';
                FDAstate.SubType = 'bs';  
                             
                if ~isequal(filtSPT.specs.fdellip.setOrderFlag, 0)
                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpass';
                    FDAstate.Components{2}.Fpass1 = num2str(filtSPT.specs.fdellip.Fpass(1)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdellip.Fpass(2)*(filtSPT.Fs/2));
                    
                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmagpassstop'; 
                else
                    FDAstate.Components{2}.Fpass1  = num2str(filtSPT.specs.fdellip.f(2)*(filtSPT.Fs/2));
                    FDAstate.Components{2}.Fpass2 = num2str(filtSPT.specs.fdellip.f(5)*(filtSPT.Fs/2));

                    FDAstate.Components{2}.Tag = 'fdadesignpanel.bsfreqpassstop';
                    FDAstate.Components{2}.Fstop1  = num2str(filtSPT.specs.fdellip.f(3)*(filtSPT.Fs/2));                
                    FDAstate.Components{2}.Fstop2 = num2str(filtSPT.specs.fdellip.f(4)*(filtSPT.Fs/2));                    

                    FDAstate.Components{3}.Tag = 'fdadesignpanel.bsmag';      
                    % Set Apass???
                    FDAstate.Components{3}.Astop = num2str(filtSPT.specs.fdellip.Rs);
                    % Set Astop1 and Astop2???
                    FDAstate.Components{3}.Apass1 = num2str(filtSPT.specs.fdellip.Rp);
                    FDAstate.Components{3}.Apass2 = num2str(filtSPT.specs.fdellip.Rp);   
                end
           end 
        otherwise
            FDAstate.Components = [];
    end
end
