function siggen = siggen(h)

% SIGGEN Creates/links a signal designer with an importtable (h)

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.15 $ $Date: 2010/05/10 16:58:54 $

import javax.swing.*;
import javax.swing.border.*
import java.awt.*;
import com.mathworks.mwswing.*;

% build signal designer GUI if empty
if isempty(h.signalgenerator)
    siggen = lsimgui.signalgenerator; 
    siggen.Visible = 'on';
    
    % assign the target table
    siggen.importtable = h;
    
    % assign the target signal designer
    h.signalgenerator = siggen;  
	javaHandles.frame = MJFrame(sprintf('Signal Designer'));
	
	% Build the top panel
	javaHandles.topPanel = JPanel(BorderLayout);
    PNLsig = JPanel;
	LBLtype = JLabel(sprintf('Signal type:'));
	javaHandles.COMBOsignal = JComboBox;
    javaHandles.COMBOsignal.setName('siggen:combo:sigtype');
	javaHandles.COMBOsignal.addItem(sprintf('Sine wave'));
	javaHandles.COMBOsignal.addItem(sprintf('Square wave'));
	javaHandles.COMBOsignal.addItem(sprintf('Step function'));
  	javaHandles.COMBOsignal.addItem(sprintf('White noise'));
	PNLsig.add(LBLtype);
	PNLsig.add(javaHandles.COMBOsignal);
    javaHandles.topPanel.add(PNLsig, BorderLayout.WEST);
	

	% Build center panel
	javaHandles.card = CardLayout;
	javaHandles.centerPanel = JPanel(javaHandles.card);
	javaHandles.centerPanel.setBorder(BorderFactory.createTitledBorder(sprintf('Signal attributes:')));
    
    % Build sine wave panel
	thisPanel = JPanel(BorderLayout);
	PNLsine = JPanel(GridLayout(4,2,5,5));
	LBLname = JLabel(sprintf('Name:'));
	LBLfreq = JLabel(sprintf('Frequency (Hz):'));
	LBLamp = JLabel(sprintf('Amplitude:'));
	LBLduration = MJLabel(sprintf('Duration (secs):'));
	javaHandles.sineTXTname = JTextField('Sine1');
    javaHandles.sineTXTname.setName('siggen:textfield:sinename');
    set(javaHandles.sineTXTname,'Tag','Sine1');
    hc = handle(javaHandles.sineTXTname, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkStr(es,ed,javaHandles.sineTXTname));
    set(hc,'FocusLostCallback',@(es,ed) localChkStr(es,ed,javaHandles.sineTXTname));
	javaHandles.sineTXTfreq = JTextField('0.1');
    javaHandles.sineTXTfreq.setName('siggen:textfield:sinefreq');
    set(javaHandles.sineTXTfreq,'Tag','0.1');
    hc = handle(javaHandles.sineTXTfreq, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.sineTXTfreq));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.sineTXTfreq));
	javaHandles.sineTXTamp = JTextField('1');
    javaHandles.sineTXTamp.setName('siggen:textfield:sineamp');
    set(javaHandles.sineTXTamp,'Tag','1');
    hc = handle(javaHandles.sineTXTamp, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.sineTXTamp));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.sineTXTamp));
	javaHandles.sineTXTduration = JTextField(sprintf('%0.5g',(h.Simsamples-1)*h.Interval));
    javaHandles.sineTXTduration.setName('siggen:textfield:sineduration');
    set(javaHandles.sineTXTduration,'Tag','100');
    hc = handle(javaHandles.sineTXTduration, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.sineTXTduration));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.sineTXTduration));

    PNLsine.add(LBLname);
    PNLsine.add(javaHandles.sineTXTname);
	PNLsine.add(LBLfreq);
    PNLsine.add(javaHandles.sineTXTfreq);
	PNLsine.add(LBLamp);
    PNLsine.add(javaHandles.sineTXTamp);
	PNLsine.add(LBLduration); 
	PNLsine.add(javaHandles.sineTXTduration);
    PNLsineouter = JPanel;
    PNLsineouter.add(PNLsine);
	thisPanel.add(PNLsineouter,BorderLayout.WEST);
	thesePanels(1) = thisPanel;
	
    % Build square wave panel
	thisPanel = JPanel(BorderLayout);
	PNLsquare = JPanel(GridLayout(4,2,5,5));
	LBLname = JLabel(sprintf('Name:'));
	LBLfreq = JLabel(sprintf('Frequency (Hz):'));
	LBLamp = JLabel(sprintf('Amplitude:'));
	LBLduration = JLabel(sprintf('Duration (secs):'));
	javaHandles.squareTXTname = JTextField('Square1');
    javaHandles.squareTXTname.setName('siggen:textfield:squarename');
    set(javaHandles.squareTXTname,'Tag','Square1');
    hc = handle(javaHandles.squareTXTname, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkStr(es,ed,javaHandles.squareTXTname));
    set(hc,'FocusLostCallback',@(es,ed) localChkStr(es,ed,javaHandles.squareTXTname));
	javaHandles.squareTXTfreq = JTextField('0.1');
    javaHandles.squareTXTfreq.setName('siggen:textfield:squarefreq');
    set(javaHandles.squareTXTfreq,'Tag','0.1');
    hc = handle(javaHandles.squareTXTfreq, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.squareTXTfreq));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.squareTXTfreq));
	javaHandles.squareTXTamp = JTextField('1');
    javaHandles.squareTXTamp.setName('siggen:textfield:squareamp');
    set(javaHandles.squareTXTamp,'Tag','1'); 
    hc = handle(javaHandles.squareTXTamp, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.squareTXTamp));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.squareTXTamp));
	javaHandles.squareTXTduration = JTextField(sprintf('%0.5g',(h.Simsamples-1)*h.Interval));
    set(javaHandles.squareTXTduration,'Tag','100'); 
    hc = handle(javaHandles.squareTXTduration, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.squareTXTduration));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.squareTXTduration));
    javaHandles.squareTXTduration.setName('siggen:textfield:squareduration');
    PNLsquare.add(LBLname);
    PNLsquare.add(javaHandles.squareTXTname);
	PNLsquare.add(LBLfreq);
    PNLsquare.add(javaHandles.squareTXTfreq);
	PNLsquare.add(LBLamp);
   	PNLsquare.add(javaHandles.squareTXTamp);
	PNLsquare.add(LBLduration);
	PNLsquare.add(javaHandles.squareTXTduration);   
	thisPanel.add(PNLsquare);
    PNLsquareouter = JPanel;
    PNLsquareouter.add(PNLsquare);
	thisPanel.add(PNLsquareouter,BorderLayout.WEST);
	thesePanels(2) = thisPanel;
	
    % Build step panel
	thisPanel = JPanel(BorderLayout);
	PNLstep = JPanel(GridLayout(5,2,5,5));
	LBLname = JLabel(sprintf('Name:'));
	LBLlvl = JLabel(sprintf('Starting level:'));
	LBLsize = JLabel(sprintf('Step size:'));
	LBLtransition = JLabel(sprintf('Transition time (secs):'));
	LBLduration = JLabel(sprintf('Duration (secs):'));
	javaHandles.stepTXTname = JTextField('Step1');
    javaHandles.stepTXTname.setName('siggen:textfield:stepname');
    set(javaHandles.stepTXTname,'Tag','Step1'); 
    hc = handle(javaHandles.stepTXTname, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkStr(es,ed,javaHandles.stepTXTname));
    set(hc,'FocusLostCallback',@(es,ed) localChkStr(es,ed,javaHandles.stepTXTname));  
	javaHandles.stepTXTlvl = JTextField('0');
    javaHandles.stepTXTlvl.setName('siggen:textfield:steplvl');
    set(javaHandles.stepTXTlvl,'Tag','0');
    hc = handle(javaHandles.stepTXTlvl, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTlvl));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTlvl));
	javaHandles.stepTXTsize = JTextField('1');
    javaHandles.stepTXTsize.setName('siggen:textfield:stepsize');
    set(javaHandles.stepTXTsize,'Tag','1');
    hc = handle(javaHandles.stepTXTsize, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTsize));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTsize));
	javaHandles.stepTXTtransition = JTextField(sprintf('%0.5g',h.Interval));
    javaHandles.stepTXTtransition.setName('siggen:textfield:steptrans');
    set(javaHandles.stepTXTtransition,'Tag','1');
    hc = handle(javaHandles.stepTXTtransition, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTtransition));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTtransition));
	javaHandles.stepTXTduration = JTextField(sprintf('%0.5g',(h.Simsamples-1)*h.Interval));
    javaHandles.stepTXTduration.setName('siggen:textfield:stepduration');
    set(javaHandles.stepTXTduration,'Tag','100');
    hc = handle(javaHandles.stepTXTduration, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTduration));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.stepTXTduration));

    PNLstep.add(LBLname);
   	PNLstep.add(javaHandles.stepTXTname);
	PNLstep.add(LBLlvl);
    PNLstep.add(javaHandles.stepTXTlvl);
	PNLstep.add(LBLsize);
    PNLstep.add(javaHandles.stepTXTsize);
	PNLstep.add(LBLtransition);
    PNLstep.add(javaHandles.stepTXTtransition);
	PNLstep.add(LBLduration);
	PNLstep.add(javaHandles.stepTXTduration);
    thisPanel.add(PNLstep);
	%thisPanel.setBorder( BorderFactory.createTitledBorder('Signal attributes'));
    PNLstepouter = JPanel;
    PNLstepouter.add(PNLstep);
	thisPanel.add(PNLstepouter,BorderLayout.WEST);
	thesePanels(3) = thisPanel;
	
    % Build white noise panel   
	thisPanel = JPanel(BorderLayout);
	PNLnoise = JPanel(GridLayout(5,2,5,5));
	LBLname = JLabel(sprintf('Name:'));
	LBLmean = JLabel(sprintf('Mean:'));
	LBLstd = JLabel(sprintf('Standard deviation:'));
    LBLdist = JLabel(sprintf('Probability density:'));
	LBLduration = JLabel(sprintf('Duration (secs):'));
	javaHandles.noiseTXTname = JTextField('Noise1'); 
    javaHandles.noiseTXTname.setName('siggen:textfield:noisename');
    set(javaHandles.noiseTXTname,'Tag','Noise1');
    hc = handle(javaHandles.noiseTXTname, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkStr(es,ed,javaHandles.noiseTXTname));
    set(hc,'FocusLostCallback',@(es,ed) localChkStr(es,ed,javaHandles.noiseTXTname));
	javaHandles.noiseTXTmean = JTextField('1');
    javaHandles.noiseTXTmean.setName('siggen:textfield:noisemean');
    set(javaHandles.noiseTXTmean,'Tag','1'); 
    hc = handle(javaHandles.noiseTXTmean, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.noiseTXTmean));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.noiseTXTmean));
	javaHandles.noiseTXTstd = JTextField('1');
    javaHandles.noiseTXTstd.setName('siggen:textfield:noisestd');
    set(javaHandles.noiseTXTstd,'Tag','1');     
    hc = handle(javaHandles.noiseTXTstd, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,javaHandles.noiseTXTstd));
    set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,javaHandles.noiseTXTstd));

    
    javaHandles.COMBOdist = JComboBox;
    javaHandles.COMBOdist.addItem(sprintf('Gaussian'));
    javaHandles.COMBOdist.addItem(sprintf('Uniform'));
    javaHandles.COMBOdist.setName('siggen:combo:dist');
	javaHandles.noiseTXTduration = JTextField(sprintf('%0.5g',(h.Simsamples-1)*h.Interval));  
    javaHandles.noiseTXTduration.setName('siggen:textfield:noiseduration');
    PNLnoise.add(LBLname);
    PNLnoise.add(javaHandles.noiseTXTname);
	PNLnoise.add(LBLmean);
    PNLnoise.add(javaHandles.noiseTXTmean);
	PNLnoise.add(LBLstd);
    PNLnoise.add(javaHandles.noiseTXTstd);
	PNLnoise.add(LBLdist);
    PNLnoise.add(javaHandles.COMBOdist);
	PNLnoise.add(LBLduration);
	PNLnoise.add(javaHandles.noiseTXTduration);
	thisPanel.add(PNLnoise);
	%thisPanel.setBorder( BorderFactory.createTitledBorder('Signal attributes'));
    PNLnoiseouter = JPanel;
    PNLnoiseouter.add(PNLnoise);
	thisPanel.add(PNLnoiseouter,BorderLayout.WEST);
	thesePanels(4) = thisPanel;
	javaHandles.centerPanel.add(thesePanels(1),'sine');
	javaHandles.centerPanel.add(thesePanels(2),'square');
	javaHandles.centerPanel.add(thesePanels(3),'step');
	javaHandles.centerPanel.add(thesePanels(4),'noise');
	javaHandles.card.first(javaHandles.centerPanel);

    % callbacks
    siggen.addlisteners(handle.listener(siggen,findprop(siggen,'type'),'PropertyPostSet', {@localPanelVis siggen}));  
     siggen.addlisteners(handle.listener(siggen,findprop(siggen,'visible'),'PropertyPostSet',...
        {@localSigGenVisible siggen}));     
    siggen.addlisteners(handle.listener(h,findprop(h,'visible'),'PropertyPostSet',...
        {@localFrameKill siggen}));         
    hc = handle(javaHandles.COMBOsignal, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localSetType(es,ed,siggen,javaHandles.COMBOsignal));
    
    
    
	
	% Build the button panel	
	PNLbtn = JPanel;
	javaHandles.BTNok = JButton(sprintf('Insert'));
    javaHandles.BTNok.setName('siggen:button:ok');
    hc = handle(javaHandles.BTNok, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localOK(es,ed,siggen));
    
   	javaHandles.BTNcancel = JButton(sprintf('Close'));
    javaHandles.BTNcancel.setName('siggen:button:cancel');
    hc = handle(javaHandles.BTNcancel, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localFrameKill(es,ed,siggen));
    
	javaHandles.BTNhelp = JButton(sprintf('Help'));
    javaHandles.BTNhelp.setName('siggen:button:help');
    hc = handle(javaHandles.BTNhelp, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localHelp(es,ed));
    
    PNLbtn.add(javaHandles.BTNok);
	PNLbtn.add(javaHandles.BTNcancel);
	PNLbtn.add(javaHandles.BTNhelp);
	
	% Build overall panel
	PNLmain = JPanel(BorderLayout(5,5));
	PNLmain.add(javaHandles.topPanel,BorderLayout.NORTH);
	PNLmain.add(javaHandles.centerPanel,BorderLayout.CENTER);
	PNLmain.add(PNLbtn,BorderLayout.SOUTH);
	javaHandles.frame.getContentPane.add(PNLmain);
    javaHandles.frame.setSize(281,314);
	javaHandles.frame.setVisible(0);
    javaHandles.frame.pack;
    
    % set signal designer properties
    siggen.jhandles = javaHandles;
    siggen.panels = thesePanels;
    siggen.type = 'sine';
    
    % set the window close callback
    hc = handle(javaHandles.frame, 'callbackproperties');
    set(hc,'WindowClosingCallback',@(es,ed) localFrameKill(es,ed,siggen));
    
else
    siggen = h.signalgenerator;
end % end signalgenerator GUI build

%-------------------- Local Functions ---------------------------

function localPanelVis(eventSrc, eventData, siggen)

% set the appropriate panel visible depending on the siggen type
awtinvoke(siggen.jhandles.card,'show(Ljava.awt.Container;Ljava.lang.String;)',siggen.jhandles.centerPanel,siggen.type);

names = {'sine','square','step','noise'};
durationhandles = {siggen.jhandles.sineTXTduration,siggen.jhandles.squareTXTduration,...
        siggen.jhandles.stepTXTduration,siggen.jhandles.noiseTXTduration};
thisdurationhandle = durationhandles{find(strcmp(siggen.type,names))};
% R.C. changed to make sure the duration text box match the current end
% time (previously number of samples)
%thisdurationhandle.setText(sprintf('%d',siggen.importtable.simsamples));
thisdurationhandle.setText(sprintf('%0.5g',(siggen.importtable.Simsamples-1)*siggen.importtable.Interval));

function localSetType(eventSrc, eventData, siggen, thisCombo)

% assign the siggen type based on the combo setting
names = {'sine','square','step','noise'};
siggen.type = names{double(thisCombo.getSelectedIndex)+1};

function localFrameKill(eventSrc, evetData, siggen)

siggen.Visible = 'off';

function localOK(eventSrc, eventDat,h)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

% callback for the OK button
inputtable = h.importtable;
selectedInputs = double(inputtable.STable.getSelectedRows)+1;

% R.C.: input data are sampled at 0:interval:duration (in secs) times
% and sqrt(eps(inputtable.Interval)) is added to make sure length is right
if length(selectedInputs)>0
    switch h.type
    case 'sine'
        durationStr = char(h.jhandles.sineTXTduration.getText);
        duration = str2double(durationStr);
		freqStr = char(h.jhandles.sineTXTfreq.getText);
        freq = str2double(freqStr);
		ampStr = char(h.jhandles.sineTXTamp.getText);
        amp = str2double(ampStr);
        % screen out bad amp and freqs
        if ~isfinite(freq) || ~isfinite(amp) || ~isfinite(duration) || freq<=0 || amp < 0 || duration <=inputtable.Interval
            errordlg(sprintf('Invalid entry'),'Linear Simulation Tool', 'modal')
            return
        end
        copiedData.construction = sprintf('Sine wave: amplitude: %s, frequency: %0.3gHz,\nbased on a sample interval of %0.3g secs', ...
            ampStr, freq, inputtable.Interval);         
		%copiedData.data = (sin(2*pi*(0:(duration-1))*freq*inputtable.Interval)*amp)';
        copiedData.data = (sin(2*pi*freq*(0:inputtable.Interval:duration+sqrt(eps(inputtable.Interval))))*amp)';
        copiedData.subsource = char(h.jhandles.sineTXTname.getText);  
    case 'square'
        durationStr = char(h.jhandles.squareTXTduration.getText);
        duration = str2double(durationStr);
		freqStr = char(h.jhandles.squareTXTfreq.getText);
        freq = str2double(freqStr);
		ampStr = char(h.jhandles.squareTXTamp.getText);
        amp = str2double(ampStr);
        % screen out bad amp and freqs
        if ~isfinite(freq) || ~isfinite(amp) || ~isfinite(duration) || freq<=0 || amp < 0 || duration <= inputtable.Interval
            errordlg(sprintf('Invalid entry'),'Linear Simulation Tool', 'modal')
            return
        end
        copiedData.construction = sprintf('Square wave: amplitude: %s, frequency: %0.3gHz,\nbased on a sample interval of %0.3g secs',...
              ampStr, freq, inputtable.Interval);
% 		copiedData.data = (((((0:(duration-1))*freq*inputtable.Interval- ...
%             floor((0:(duration-1))*freq*inputtable.Interval))<=0.5)*2-1)*amp)';
        copiedData.data = (localSquareGenerator(2*pi*freq*(0:inputtable.Interval:duration+sqrt(eps(inputtable.Interval))))*amp)';
        copiedData.subsource = char(h.jhandles.squareTXTname.getText);  
    case 'step'
        durationStr = char(h.jhandles.stepTXTduration.getText);
        duration = str2double(durationStr);
		startLvlStr = char(h.jhandles.stepTXTlvl.getText);
        startLvl = str2double(startLvlStr);
		ampStr = char(h.jhandles.stepTXTsize.getText);
        amp = str2double(ampStr);
        transitionStr = char(h.jhandles.stepTXTtransition.getText);
        transitionValue = str2double(transitionStr);
        % screen out bad amp or trans
        if ~isfinite(amp) || ~isfinite(transitionValue) || ~isfinite(duration) || ~isfinite(startLvl) ...
                || amp<0 || transitionValue<0 || duration <= transitionValue
              errordlg(sprintf('Invalid entry'),'Linear Simulation Tool', 'modal')
            return
        end  
        copiedData.construction = sprintf('Step: size: %s, initial value: %s, transition time: %s secs,\nbased on a sample interval of %0.3g secs',...
             ampStr, startLvlStr, transitionStr, inputtable.Interval);           
% 		copiedData.data = (ones(1,duration)*startLvl+ [zeros(1,transitionValue) ...
%                 ones(1,duration-transitionValue)]*amp)';
 		copiedData.data = (~((0:inputtable.Interval:duration+sqrt(eps(inputtable.Interval)))<transitionValue)*amp+startLvl)';
        copiedData.subsource = char(h.jhandles.stepTXTname.getText); 
    case 'noise'
        durationStr = char(h.jhandles.noiseTXTduration.getText);
        duration = str2double(durationStr);
		meanLvlStr = char(h.jhandles.noiseTXTmean.getText);
        meanLvl = str2double(meanLvlStr);
		stdLvlStr = char(h.jhandles.noiseTXTstd.getText);
        stdLvl = str2double(stdLvlStr);
        probdist = char(h.jhandles.COMBOdist.getSelectedItem);
        if ~isfinite(duration) || ~isfinite(meanLvl) || ~isfinite(stdLvl) ...
                || duration <= inputtable.Interval || stdLvl<0
            errordlg(sprintf('Invalid entry'),'Linear Simulation Tool','modal')
            return
        end
        copiedData.construction = sprintf('Noise: mean: %s, standard deviation: %s, prob density: %s',...
            meanLvlStr, stdLvlStr, probdist);
%         if strcmpi(probdist,xlate('Gaussian'))
%             copiedData.data = meanLvl+stdLvl*randn(duration,1);
%         else 
%             copiedData.data = meanLvl+stdLvl*(rand(duration,1)-0.5)*sqrt(12);
%         end    
        NumSamples = floor((duration-inputtable.Starttime)/inputtable.Interval+sqrt(eps(inputtable.Interval)))+1;
        if strcmpi(probdist,xlate('Gaussian'))
            copiedData.data = meanLvl+stdLvl*randn(NumSamples,1);
        else 
            copiedData.data = meanLvl+stdLvl*(rand(NumSamples,1)-0.5)*sqrt(12);
        end    
        copiedData.subsource = char(h.jhandles.noiseTXTname.getText);         
    end    
  
    copiedData.source = 'signal designer';
	copiedData.length = length(copiedData.data);
	copiedData.columns = 1;
    copiedData.transposed = false;
	numpastedrows = inputtable.pasteData(copiedData);
    
    % if >= 1 rows were successfully imported then bring the lsim gui into focus
	if numpastedrows > 0
		awtinvoke(h.importtable.guistate.handles.frame,'setVisible(Z)',true);
	end
    
    % fire rowselect event so that signal summary updates
    h.importtable.javasend('userentry','')
end

function s = localSquareGenerator(t, duty)
%copied from SQUARE method of signal processing toolbox

% If no duty specified, make duty cycle 50%.
if nargin < 2
	duty = 50;
end
if any(size(duty)~=1),
	ctrlMsgUtils.error('Controllib:general:UnexpectedError','Duty parameter must be a scalar.')
end
% Compute values of t normalized to (0,2*pi)
tmp = mod(t,2*pi);
% Compute normalized frequency for breaking up the interval (0,2*pi)
w0 = 2*pi*duty/100;
% Assign 1 values to normalized t between (0,w0), 0 elsewhere
nodd = (tmp < w0);
% The actual square wave computation
s = 2*nodd-1;

function localSigGenVisible(eventSrc, eventData, siggen)

if strcmp(siggen.visible,'on')
     awtinvoke(siggen.jhandles.frame,'setVisible(Z)',true);
     localPanelVis([],[], siggen); %refresh displayed panel
     siggen.jhandles.frame.toFront;
else
    awtinvoke(siggen.jhandles.frame,'setVisible(Z)',false);
end


function localChkNum(eventSrc, eventData, textbox)

boxcontents = char(textbox.getText);
try 
    eval([boxcontents ';']);
catch
    errstr = sprintf('%s is an invalid text box entry',boxcontents);
    errordlg(errstr,'Linear Simulation Tool','modal')
    textbox.setText(get(textbox,'Tag'));
end

function localChkStr(eventSrc, eventData, textbox)

if isempty(deblank(char(textbox.getText)))
    errordlg('Names cannot be empty','Linear Simulation Tool','modal')
    textbox.setText(get(textbox,'tag'));
end

function localHelp(eventSrc, eventData)

ctrlguihelp('lsim_designsignal');