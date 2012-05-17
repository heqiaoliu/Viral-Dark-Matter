function addpz(Editor,PZAddType)
% ADDPZ  Adds an additional pz element to the pzeditor

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.7 $  $Date: 2009/11/09 16:22:28 $

% discrete sampling time
Ts = Editor.CompList(Editor.idxC).Ts;

% default element to be added
Pole = [];
Zero = [];
% Initialize the new group
switch PZAddType
    
    case 'RealPole'
        Type = 'Real';
        Pole = -1;
        Action = sprintf('Add Pole');
                
    case 'RealZero'
        Type = 'Real';
        Zero = -1;
        Action = sprintf('Add Zero');
                
    case 'Integrator'
        Type = 'Real';
        Pole = 0;
        Action = sprintf('Add Integrator');
        
    case 'Differentiator'
        Type = 'Real';
        Zero = 0;
        Action = sprintf('Add Differentiator');
        
    case 'Lead'
        Type = 'LeadLag';
        Zero = -1;
        Pole = -10;
        Action = sprintf('Add Lead');
        
    case 'Lag'
        Type = 'LeadLag';
        Zero = -10;
        Pole = -1;
        Action = sprintf('Add Lag');
        
    case 'ComplexPole'
        Type = 'Complex';
        Pole = [-1+1i; -1-1i];
        Action = sprintf('Add Complex Pole');
                
    case 'ComplexZero'
        Type = 'Complex';
        Zero = [-1+1i; -1-1i];
         Action = sprintf('Add Complex Zero');
        
    case 'Notch'
        Type = 'Notch';
        Zero = [-.1+.995i; -.1-.995i];
        Pole = [-1+0i; -1-0i];
        Action = sprintf('Add Notch');
end
        
% If discrete (Ts~=0) convert to discrete values
if Ts
    if ~isempty(Zero)
        Zero = exp(Zero*Ts);
    end
    if ~isempty(Pole)
        Pole = exp(Pole*Ts);
    end
end

% Add the PZGroup to the end of the PZGroup list associated with compensator (idxC)
% successful action on the SISOTOOL side will be recorded
EventMgr = Editor.Parent.EventManager;
T = ctrluis.transaction(Editor.LoopData,'Name',sprintf(Action),...
    'OperationStore','on','InverseOperationStore','on');
try
    % call addPZ to update loopdata
    Editor.CompList(Editor.idxC).addPZ(Type,Zero,Pole);
catch ME
    errstr = ltipack.utStripErrorHeader(ME.message);
    awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
            'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
            slctrlexplorer, errstr, xlate('SISOTOOL Pole/Zero Editor'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
    T.Transaction.commit; % commit transaction before deleting wrapper
    delete(T);
    return
end
% Register transaction
EventMgr.record(T);
% Notify status and history listeners
Status = sprintf('Added Poles/Zeros.');
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);

% broadcast event to all
try
    % broadcasting loopdata change event
    Editor.exportdata;
catch ME
    errstr = ltipack.utStripErrorHeader(ME.message);
    awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
            'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
            slctrlexplorer, errstr, xlate('SISOTOOL Pole/Zero Editor'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
end
