function showpzeditcard(Editor)
%SHOWPZEDITCARD  Shows edit selection card for selected pzgroup

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2010/04/30 00:36:58 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;

% Indices
idxC = Editor.idxC;
idxPZ = Editor.idxPZ;
PCard = Editor.Handles.PZTabHandles.PCard;

% Determine which edited selection card panel to display 
if (length(idxPZ) > 1 ) || (isempty(idxPZ))
   % More than 1 row selected or no row selected
   PZType = 'Blank';
else 
   % One row selected
   Group = Editor.CompList(idxC).PZGroup(idxPZ);
   if ~isempty(Group)
       PZType = Group.Type;
       % drawnow is added to solve the racing issue here:
       % when we change a real pole value and click another real pole before
       % hitting enter key, we have to make sure that the value in the previous
       % card is updated before the card is replaced.
       drawnow
       % Update edit fields in card
       Editor.refreshpzeditfields(idxPZ);
       LocalUpdateListeners(Editor, idxPZ, PZType);
   end
end

% Display card
awtinvoke(PCard.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',PCard,java.lang.String(PZType));

% if no rows selected, disable delete pz group menu
awtinvoke(Editor.Handles.PZTabHandles.DeleteMenu,'setEnabled(Z)',~isempty(idxPZ));



%-----------------------Local Functions-----------------------------------%

% ------------------------------------------------------------------------%
% Function: LocalUpdateListeners
% Purpose: Update listeners for PZ edit fields
% Note: two event listeners are added: ActionPerformedCallback and
% FocusLostCallback.  however, when user change the value and click the
% enter key, both events are fired and therefore the callbacks will run
% twice.  This doubles the running time for callbacks, which could be a
% problem for heavy-weighted callbacks.
% ------------------------------------------------------------------------%

function LocalUpdateListeners(Editor, idxPZ, PZType)
PZTabHandles = Editor.Handles.PZTabHandles;

switch PZType
    case 'Real'
        EditR1=PZTabHandles.EditR1;

        % Callbacks for EditR1
        hC = handle(EditR1, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalR1Change Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalR1Change Editor idxPZ})

    case 'Complex'
        % Complex pole/zero
        EditCWn = PZTabHandles.EditCWn;
        EditCZeta = PZTabHandles.EditCZeta;
        EditCR = PZTabHandles.EditCR;
        EditCI = PZTabHandles.EditCI;

        % Callbacks for EditCWn
        hC = handle(EditCWn, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalCWnChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalCWnChange Editor idxPZ})
        % Callbacks for EditZeta
        hC = handle(EditCZeta, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalCZetaChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalCZetaChange Editor idxPZ})
        % Callbacks for EditCR
        hC = handle(EditCR, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalCRCIChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalCRCIChange Editor idxPZ})
        % Callbacks for EditCI
        hC = handle(EditCI, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalCRCIChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalCRCIChange Editor idxPZ})

    case 'LeadLag'
        EditLLZ = PZTabHandles.EditLLZ;
        EditLLP = PZTabHandles.EditLLP;
        EditLLPhase = PZTabHandles.EditLLPhase;
        EditLLFreq = PZTabHandles.EditLLFreq;

        % Callbacks for EditLLZ
        hC = handle(EditLLZ, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalLLZPChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalLLZPChange Editor idxPZ})
        % Callbacks for EditLLP
        hC = handle(EditLLP, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalLLZPChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalLLZPChange Editor idxPZ})
        % Callbacks for EditLLPhase
        hC = handle(EditLLPhase, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalLLPhaseChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalLLPhaseChange Editor idxPZ})
        % Callbacks for EditLLFreq
        hC = handle(EditLLFreq, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalLLFreqChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalLLFreqChange Editor idxPZ})


    case 'Notch'
        % Notch filter.
        EditNWn = PZTabHandles.EditNWn;
        EditNZZeta = PZTabHandles.EditNZZeta;
        EditNPZeta = PZTabHandles.EditNPZeta;
        EditNDepth = PZTabHandles.EditNDepth;
        EditNWidth = PZTabHandles.EditNWidth;


        % Callbacks for EditNWn
        hC = handle(EditNWn, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalNotchWnChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalNotchWnChange Editor idxPZ})
        % Callbacks for EditNZZeta
        hC = handle(EditNZZeta, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalNotchZeta12Change Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalNotchZeta12Change Editor idxPZ})
        % Callbacks for EditNPZeta
        hC = handle(EditNPZeta, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalNotchZeta12Change Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalNotchZeta12Change Editor idxPZ})
        % Callbacks for EditNDepth
        hC = handle(EditNDepth, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalNotchDepthChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalNotchDepthChange Editor idxPZ})
        % Callbacks for EditNWidth
        hC = handle(EditNWidth, 'callbackproperties' );
        set(hC,'ActionPerformedCallback',{@LocalNotchWidthChange Editor idxPZ})
        set(hC,'FocusLostCallback',{@LocalNotchWidthChange Editor idxPZ})
end

%---------------------------Callback Functions-----------------------------

% ------------------------------------------------------------------------%
% Function: LocalR1Change
% Purpose:  Change in Real Type pzgroup
% ------------------------------------------------------------------------%
function LocalR1Change(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Location] = LocalCheckChange(jsrc,event);
if validstrchange
    % Update PZGroup with new value
    Group = Editor.CompList(idxC).PZGroup(idxPZ);
    if isempty(Group.Pole)
        PZType = 'Zero';
    else
        PZType = 'Pole';
    end
    
    EventMgr = Editor.Parent.EventManager;
    T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit %s',PZType),...
        'OperationStore','on','InverseOperationStore','on');
    
    Group.(PZType) = Location;
    
    EventMgr.record(T);
    % Notify status and history listeners
    Status = sprintf('Edited %s.', PZType);
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);

    % export the data
    Editor.exportdata;
end

% ------------------------------------------------------------------------%
% Function: LocalCWnChange
% Purpose:  Change in Wn of Complex Type pzgroup
% ------------------------------------------------------------------------%
function LocalCWnChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Wn] = LocalCheckChange(jsrc,event);
if validstrchange
    if  Wn > 0
        Ts = Editor.CompList(idxC).Ts;
        EditCZeta = Editor.Handles.PZTabHandles.EditCZeta;
        Zeta = str2double(char(EditCZeta.getText));
        Wn = unitconv(Wn, Editor.FrequencyUnits, 'rad/sec');

        [Location] = LocalEvalComplex(Zeta, Wn, Ts);

        Group = Editor.CompList(idxC).PZGroup(idxPZ);
        if isempty(Group.Pole)
            PZType = 'Zero';
        else
            PZType = 'Pole';
        end
        
        EventMgr = Editor.Parent.EventManager;
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Complex %s',PZType),...
            'OperationStore','on','InverseOperationStore','on');

        Group.(PZType) = Location;

        EventMgr.record(T);
        % Notify status and history listeners
        Status = sprintf('Edited complex %s.', PZType);
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);

        % export the data
        Editor.exportdata;
    else
        OldText = get(jsrc,'UserData');
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(OldText));
        awtinvoke(jsrc,'setCaretPosition(I)',length(OldText));
    end
end

% ------------------------------------------------------------------------%
% Function: LocalCZetaChange
% Purpose:  Change in Zeta of Complex Type pzgroup
% ------------------------------------------------------------------------%
function LocalCZetaChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Zeta] = LocalCheckChange(jsrc,event);
if validstrchange
    if abs(Zeta) > 1
        Zeta = sign(Zeta);
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(sprintf(Editor.PrecisionFormat, Zeta)));
        awtinvoke(jsrc,'setCaretPosition(I)',length(Zeta));
    end
    
    Ts = Editor.CompList(idxC).Ts;
    EditCWn = Editor.Handles.PZTabHandles.EditCWn;
    Wn = unitconv(str2double(char(EditCWn.getText)), Editor.FrequencyUnits, 'rad/sec');
        
    [Location] = LocalEvalComplex(Zeta, Wn, Ts);
    
    Group = Editor.CompList(idxC).PZGroup(idxPZ);
    if isempty(Group.Pole)
        PZType = 'Zero';
    else
        PZType = 'Pole';
    end

    EventMgr = Editor.Parent.EventManager;
    T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Complex %s',PZType),...
        'OperationStore','on','InverseOperationStore','on');

    Group.(PZType) = Location;

    EventMgr.record(T);
    % Notify status and history listeners
    Status = sprintf('Edited complex %s.', PZType);
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);

    
    % export the data
    Editor.exportdata;
end

% ------------------------------------------------------------------------%
% Function: LocalCRCIChange
% Purpose:  Change in real or imag of Complex Type pzgroup
% ------------------------------------------------------------------------%
function LocalCRCIChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, junk] = LocalCheckChange(jsrc,event);
if validstrchange
    EditCR = Editor.Handles.PZTabHandles.EditCR;
    EditCI = Editor.Handles.PZTabHandles.EditCI;

    RealPart = str2double(char(EditCR.getText));
    ImagPart = str2double(char(EditCI.getText));
    Location = [RealPart + i * ImagPart; RealPart - i * ImagPart];
    
    Group = Editor.CompList(idxC).PZGroup(idxPZ);
    if isempty(Group.Pole)
        PZType = 'Zero';
    else
        PZType = 'Pole';
    end

    EventMgr = Editor.Parent.EventManager;
    T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Complex %s',PZType),...
        'OperationStore','on','InverseOperationStore','on');

    Group.(PZType) = Location;

    EventMgr.record(T);
    % Notify status and history listeners
    Status = sprintf('Edited complex %s.', PZType);
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
    % export the data
    Editor.exportdata;
end

% ------------------------------------------------------------------------%
% Function: LocalLLZPChange
% Purpose:  Change in real or imag of LeadLag Type pzgroup
% ------------------------------------------------------------------------%
function LocalLLZPChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

Ts = Editor.CompList(idxC).Ts;
% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, junk] = LocalCheckChange(jsrc,event);
if validstrchange    
    ZeroLoc = str2double(char(Editor.Handles.PZTabHandles.EditLLZ.getText));
    PoleLoc = str2double(char(Editor.Handles.PZTabHandles.EditLLP.getText));
    
    % Continuous condition that pole and zero are stable minimum phase
    Condition1 = (Ts == 0)  && (ZeroLoc <= 0 ) && (PoleLoc <= 0);
    % Discrete condition that pole and zero are stable minimum phase
    Condition2 = (Ts ~= 0) && (abs(ZeroLoc) <= 1)  && (abs(PoleLoc) <= 1);
    
    if Condition1 || Condition2
        if ZeroLoc > PoleLoc
            PZType = 'Lead';
        else
            PZType = 'Lag';
        end
            
        
        EventMgr = Editor.Parent.EventManager;
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit %s',PZType),...
            'OperationStore','on','InverseOperationStore','on');
        
        Group = Editor.CompList(idxC).PZGroup(idxPZ);
        Group.Zero = ZeroLoc;
        Group.Pole = PoleLoc;
        
        EventMgr.record(T);
        % Notify status and history listeners
        Status = sprintf('Edited %s',PZType);
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);
        
        % export the data
        Editor.exportdata;
    else
        OldText = get(jsrc,'UserData');
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(OldText));
        awtinvoke(jsrc,'setCaretPosition(I)',length(OldText));
    end
end

% ------------------------------------------------------------------------%
% Function: LocalLLPhaseChange
% Purpose:  Change in phase of LeadLag Type pzgroup
% ------------------------------------------------------------------------%
function LocalLLPhaseChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Phasemdeg] = LocalCheckChange(jsrc,event);
if validstrchange
    Phasemrad = Phasemdeg*pi/180;
    maxphasevalue = asin(1-eps); % max phasevalue phasemdeg < 90 for computation
    if (abs(Phasemrad) > maxphasevalue)
        Phasemrad = sign(Phasemrad)*maxphasevalue;
    end
    
    Ts = Editor.CompList(idxC).Ts;
    Wm = str2double(char(Editor.Handles.PZTabHandles.EditLLFreq.getText));
    % make sure Wm is in rad/sec
    Wm = unitconv(Wm, Editor.FrequencyUnits, 'rad/sec');
       
    [ZeroLoc, PoleLoc] = LocalEvalLeadLag(Phasemrad, Wm, Ts);
    
    if ZeroLoc > PoleLoc
        PZType = 'Lead';
    else
        PZType = 'Lag';
    end
      
    EventMgr = Editor.Parent.EventManager;
    T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit %s',PZType),...
        'OperationStore','on','InverseOperationStore','on');

    Group = Editor.CompList(idxC).PZGroup(idxPZ);
    Group.Zero = ZeroLoc;
    Group.Pole = PoleLoc;

    EventMgr.record(T);
    % Notify status and history listeners
    Status = sprintf('Edited %s',PZType);
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
    % export the data
    Editor.exportdata;
end

% ------------------------------------------------------------------------%
% Function: LocalLLFreqChange
% Purpose:  Change in Frequency location of max phase for a 
%           LeadLag Type pzgroup
% ------------------------------------------------------------------------%
function LocalLLFreqChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Wm]= LocalCheckChange(jsrc,event);
if validstrchange
    if Wm >= 0
        Ts = Editor.CompList(idxC).Ts;
        Phasemrad = str2double(char(Editor.Handles.PZTabHandles.EditLLPhase.getText))*pi/180;
        Wm = unitconv(Wm, Editor.FrequencyUnits, 'rad/sec');

        [ZeroLoc, PoleLoc] = LocalEvalLeadLag(Phasemrad, Wm, Ts);

        if ZeroLoc > PoleLoc
            PZType = 'Lead';
        else
            PZType = 'Lag';
        end
        
        EventMgr = Editor.Parent.EventManager;
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit %s',PZType),...
            'OperationStore','on','InverseOperationStore','on');

        Group = Editor.CompList(idxC).PZGroup(idxPZ);
        Group.Zero = ZeroLoc;
        Group.Pole = PoleLoc;
        EventMgr.record(T);
        % Notify status and history listeners
        Status = sprintf('Edited %s',PZType);
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);
        
        % export the data
        Editor.exportdata;
    else
        OldText = get(jsrc,'UserData');
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(OldText));
        awtinvoke(jsrc,'setCaretPosition(I)',length(OldText));
    end
end

% ------------------------------------------------------------------------%
% Function: LocalNotchWnChange
% Purpose:  Change in freq of Notch Type pzgroup
% ------------------------------------------------------------------------%
function LocalNotchWnChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Wn] = LocalCheckChange(jsrc, event);
if validstrchange
    if Wn >= 10*eps/log(10) % sets a valid range for numerical solution
        Ts = Editor.CompList(idxC).Ts;
        EditNZZeta = Editor.Handles.PZTabHandles.EditNZZeta;
        EditNPZeta = Editor.Handles.PZTabHandles.EditNPZeta;
        Wn = unitconv(Wn, Editor.FrequencyUnits, 'rad/sec');
        ZZeta = str2double(char(EditNZZeta.getText));
        PZeta = str2double(char(EditNPZeta.getText));
               
        [ZeroLoc, PoleLoc] = LocalEvalNotch1(Wn, ZZeta, PZeta, Ts);

        EventMgr = Editor.Parent.EventManager;
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Notch'),...
            'OperationStore','on','InverseOperationStore','on');
        
        Group = Editor.CompList(idxC).PZGroup(idxPZ);
        Group.Zero = ZeroLoc;
        Group.Pole = PoleLoc;
        
        EventMgr.record(T);
        % Notify status and history listeners
        Status = sprintf('Edited Notch');
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);

        % export the data
        Editor.exportdata;
    else
        OldText = get(jsrc,'UserData');
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(OldText));
        awtinvoke(jsrc,'setCaretPosition(I)',length(OldText));
    end
end

% ------------------------------------------------------------------------%
% Function: LocalNotchZeta12Change
% Purpose:  Change in freq of Notch Type pzgroup
% ------------------------------------------------------------------------%
function LocalNotchZeta12Change(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC; 

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Zeta] = LocalCheckChange(jsrc,event);
if validstrchange
    if Zeta > 1
        src.setText(sprintf(Editor.PrecisionFormat, 1));
    else
        if Zeta < 0
            jsrc.setText(sprintf(Editor.PrecisionFormat, 0));
        end
    end

    EditNZZeta = Editor.Handles.PZTabHandles.EditNZZeta;
    EditNPZeta = Editor.Handles.PZTabHandles.EditNPZeta;
    ZZeta = str2double(char(EditNZZeta.getText));
    PZeta = str2double(char(EditNPZeta.getText));

    if PZeta > ZZeta

        Ts = Editor.CompList(idxC).Ts;
        EditNWn = Editor.Handles.PZTabHandles.EditNWn;
        Wn = str2double(char(EditNWn.getText));
        Wn = unitconv(Wn, Editor.FrequencyUnits, 'rad/sec');

        [ZeroLoc, PoleLoc] = LocalEvalNotch1(Wn, ZZeta, PZeta, Ts);
        
        EventMgr = Editor.Parent.EventManager;
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Notch'),...
            'OperationStore','on','InverseOperationStore','on');
        
        
        Group = Editor.CompList(idxC).PZGroup(idxPZ);
        Group.Zero = ZeroLoc;
        Group.Pole = PoleLoc;
        
        
        EventMgr.record(T);
        % Notify status and history listeners
        Status = sprintf('Edited Notch');
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);

        % export the data
        Editor.exportdata;
    else
        OldText = get(jsrc,'UserData');
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(OldText));
        awtinvoke(jsrc,'setCaretPosition(I)',length(OldText));
    end


end

% ------------------------------------------------------------------------%
% Function: LocalNotchDepthChange
% Purpose:  Change in depth of Notch Type pzgroup
% ------------------------------------------------------------------------%
function LocalNotchDepthChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC;

% get source java handle from event data
jsrc = event.getSource;
% Error handling
DepthText = char(jsrc.getText);
DepthTextOld = get(jsrc, 'UserData');
isfocusevent = isa(event, 'java.awt.event.FocusEvent');
if ~(strcmp(DepthText, DepthTextOld) && isfocusevent)
    try
        DepthLog = eval(DepthText);
        if  isreal(DepthLog) && (DepthLog <= 0) 
            Depth = 10^(DepthLog/20);
            
            Ts = Editor.CompList(idxC).Ts;
            EditNWidth = Editor.Handles.PZTabHandles.EditNWidth;
            EditNWn = Editor.Handles.PZTabHandles.EditNWn;
            Width = str2double(char(EditNWidth.getText));
            Wn = str2double(char(EditNWn.getText));
            Wn = unitconv(Wn, Editor.FrequencyUnits, 'rad/sec');

            [ZeroLoc, PoleLoc] = LocalEvalNotch2(Depth, Width, Wn, Ts);
            
            EventMgr = Editor.Parent.EventManager;
            T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Notch'),...
                'OperationStore','on','InverseOperationStore','on');
            
            Group = Editor.CompList(idxC).PZGroup(idxPZ);
            Group.Zero = ZeroLoc;
            Group.Pole = PoleLoc;
            
            EventMgr.record(T);
            % Notify status and history listeners
            Status = sprintf('Edited Notch');
            EventMgr.newstatus(Status);
            EventMgr.recordtxt('history',Status);

            
            % export the data
            Editor.exportdata;

        else
            awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(DepthTextOld));
            awtinvoke(jsrc,'setCaretPosition(I)',length(DepthTextOld));
        end
    catch
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(DepthTextOld));
        awtinvoke(jsrc,'setCaretPosition(I)',length(DepthTextOld));
    end
end

% ------------------------------------------------------------------------%
% Function: LocalNotchWidthChange
% Purpose:  Change in width of Notch Type pzgroup
% ------------------------------------------------------------------------%
function LocalNotchWidthChange(hsrc, event, Editor, idxPZ)
idxC = Editor.idxC; 

% get source java handle from event data
jsrc = event.getSource;
% Error handling
[validstrchange, Width] = LocalCheckChange(jsrc,event);
if validstrchange
    if (Width > 0) || isnan(Width)

        Ts = Editor.CompList(idxC).Ts;
        EditNDepth = Editor.Handles.PZTabHandles.EditNDepth;
        EditNWn = Editor.Handles.PZTabHandles.EditNWn;
        DepthLog = str2double(char(EditNDepth.getText));
        Depth = 10^(DepthLog/20);
        Wn = str2double(char(EditNWn.getText));
        Wn = unitconv(Wn, Editor.FrequencyUnits, 'rad/sec');

        [ZeroLoc, PoleLoc] = LocalEvalNotch2(Depth, Width, Wn, Ts);

        EventMgr = Editor.Parent.EventManager;
        T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Edit Notch'),...
            'OperationStore','on','InverseOperationStore','on');
        
        Group = Editor.CompList(idxC).PZGroup(idxPZ);
        Group.Zero = ZeroLoc;
        Group.Pole = PoleLoc;
        
        EventMgr.record(T);
        % Notify status and history listeners
        Status = sprintf('Edited Notch');
        EventMgr.newstatus(Status);
        EventMgr.recordtxt('history',Status);
        % export the data
        Editor.exportdata;

    else
        OldText = get(jsrc,'UserData');
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(OldText));
        awtinvoke(jsrc,'setCaretPosition(I)',length(OldText));
    end
end

% ------------------------------------------------------------------------%
% Function: LocalEvalComplex
% Purpose:  Calculates the real and imag part of a Complex Type pzgroup
%           from damping ratio and natural frequency
% ------------------------------------------------------------------------%
function [Location] = LocalEvalComplex(Zeta, Wn, Ts)

Loc = -Zeta*Wn + Wn*sqrt(Zeta^2-1);
Location = [Loc; conj(Loc)];

if Ts ~= 0
    Location = exp(Location*Ts);
end


% ------------------------------------------------------------------------%
% Function: LocalEvalLeadLag
% Purpose:  Calculate zero and pole of Lead Lag Type pzgroup
% ------------------------------------------------------------------------%
function [ZeroLoc, PoleLoc] = LocalEvalLeadLag(Phasem, Wm, Ts)

maxphasevalue = asin(1-eps); % Range imposed on valid phase inputs Phasem < pi/4
if (abs(Phasem) > maxphasevalue)
    ZeroLoc = NaN;
    PoleLoc = NaN;
else
    % Zero = alpha * Pole
    alpha = (1-sin(Phasem))/(1+sin(Phasem));

    ZeroLoc = -Wm*sqrt(alpha);
    PoleLoc = ZeroLoc/alpha;

    if (Ts ~= 0)
        ZeroLoc = exp(ZeroLoc*Ts);
        PoleLoc = exp(PoleLoc*Ts);
    end
end




% ------------------------------------------------------------------------%
% Function: LocalEvalNotch1
% Purpose:  Calculate pole/zero for change inn freq, zeta1 or zeta2 of 
%           Notch Type pzgroup
% ------------------------------------------------------------------------%
function [ZeroLocation, PoleLocation] = LocalEvalNotch1(Wn, ZetaZ, ZetaP, Ts)

ZeroLoc = -ZetaZ*Wn + Wn*sqrt(ZetaZ^2-1);
PoleLoc = -ZetaP*Wn + Wn*sqrt(ZetaP^2-1);

ZeroLocation = [ZeroLoc; conj(ZeroLoc)];
PoleLocation = [PoleLoc; conj(PoleLoc)];

if (Ts ~= 0)
    ZeroLocation = exp(ZeroLocation*Ts);
    PoleLocation = exp(PoleLocation*Ts);
end




% ------------------------------------------------------------------------%
% Function: LocalEvalNotch2
% Purpose:  Calculate pole/zero for change in depth or width of 
%           Notch Type pzgroup
% ------------------------------------------------------------------------%
function [ZeroLocation, PoleLocation] = LocalEvalNotch2(Depth, Width, Wn, Ts)

% Calculate maxwidth
maxwidth = maxnotchwidth(Depth);

if (Width > maxwidth) || (Depth == 1) || (Width == 0) || isnan(Width)
    ZPole = 1; % equivalent to set width = maxwidth
else
    y = 10^Width;
    alpha = Depth^0.25;
    Beta2 = (y-1)^2/4/y; 
    ZPole = sqrt(Beta2*(1-alpha)*(1+alpha)/((alpha-Depth)*(alpha+Depth)));
end

ZZero = ZPole * Depth;

ZeroLoc = -ZZero*Wn + Wn*sqrt(ZZero^2-1);
PoleLoc = -ZPole*Wn + Wn*sqrt(ZPole^2-1);

ZeroLocation = [ZeroLoc; conj(ZeroLoc)];
PoleLocation = [PoleLoc; conj(PoleLoc)];

if (Ts ~= 0)
    ZeroLocation = exp(ZeroLocation*Ts);
    PoleLocation = exp(PoleLocation*Ts);
end


% ------------------------------------------------------------------------%
% Function: maxnotchwidth
% Purpose:  Calculates max notch width given a depth for max width zeta2=1
% ------------------------------------------------------------------------%
function maxwidth = maxnotchwidth(depth)
%      s^2 + (2*Zeta1^2)*s + wn^2
% G(s)--------------
%      s^2 + (2*Zeta2^2)*s + wn^2
%
% Depth = Zeta1/Zeta2

p=.25; % percent depth for width calculation
if depth == 1
    maxwidth = NaN; % depth = 1 -> pole/zero cancellation
else
    alpha = depth^p;
    Betad = sqrt((alpha^2-depth^2)/(1-alpha^2));
    maxwidth = log10(1 + 2*Betad^2 + 2*Betad*sqrt(1+Betad^2));
end


% ------------------------------------------------------------------------%
% Function: LocalCheckChange
% Purpose:  Check Change in Edit field
% ------------------------------------------------------------------------%
function  [validstrchange, thisValue] = LocalCheckChange(jsrc, event)
% Error handling
thisText = char(jsrc.getText);
thisTextOld = get(jsrc, 'UserData');
isfocusevent = isa(event, 'java.awt.event.FocusEvent');

validstrchange = false;
thisValue = NaN;

% If focus lost and string has not changed do not update field.
% This is done so that the precision of the value in the model 
% is not changed from truncated string representation for lost 
% focus event
if ~(strcmp(thisText, thisTextOld) && isfocusevent)
    try
        thisValue = eval(thisText);
        validstrchange = true;
        if ~(isreal(thisValue) && isfinite(thisValue))
            validstrchange = false;
            awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(thisTextOld));
            awtinvoke(jsrc,'setCaretPosition(I)',length(thisTextOld));
        end
    catch
        validstrchange = false;
        awtinvoke(jsrc,'setText(Ljava/lang/String;)',java.lang.String(thisTextOld));
        awtinvoke(jsrc,'setCaretPosition(I)',length(thisTextOld));
    end
end