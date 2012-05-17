function display(sys)
%DISPLAY   Pretty-print for PID object.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for PID object.
%
%   See also LTIMODELS.

% Author(s): Rong Chen 10-Nov-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/11 20:29:33 $

Inames = sys.InputName;
Onames = sys.OutputName;
Data = sys.Data_;

% Get system name
SysName = sys.Name_;
if isempty(SysName),
    SysName = inputname(1);
end
if isempty(SysName),
    SysName = 'ans';
end

% Get number of models in array
ArraySizes = size(Data);
nsys = numel(Data);
if nsys>1,
    % Construct sequence of indexing coordinates
    indices = zeros(nsys,length(ArraySizes));
    for k=1:length(ArraySizes),
        range = 1:ArraySizes(k);
        base = repmat(range,[prod(ArraySizes(1:k-1)) 1]);
        indices(:,k) = repmat(base(:),[nsys/numel(base) 1]);
    end
end

if nsys==1
    % Single PID
    displaySummaryLine(Data,Inames,Onames)
    dispsys(Data)
else
    % PID array
    Marker = '=';
    for k=1:nsys,
        coord = sprintf('%d,',indices(k,:));
        Model = sprintf('%s %s(:,:,%s) =',ctrlMsgUtils.message('Control:ltiobject:pidDisplayPrefix'),SysName,coord(1:end-1));
        fprintf('\n%s\n',Model)
        disp(Marker(1,ones(1,length(Model))))
        dispsys(Data(k));
    end
    % Last line
    ArrayDims = sprintf('%dx',ArraySizes);
    if any(ArraySizes==0)
        fprintf('%s\n',ctrlMsgUtils.message('Control:ltiobject:pidDisplayArray1',ArrayDims(1:end-1)));
    else
        if Data(1).Ts==0,
            fprintf('%s\n',ctrlMsgUtils.message('Control:ltiobject:pidDisplayArray2',ArrayDims(1:end-1)));
        else
            fprintf('%s\n',ctrlMsgUtils.message('Control:ltiobject:pidDisplayArray3',ArrayDims(1:end-1)));
        end
    end
end
end

function displaySummaryLine(PID,Inames,Onames)

NoInames = isequal('','',Inames{:});
NoOnames = isequal('','',Onames{:});

if ~NoInames
    if isempty(Inames{1}),
        Inames{1} = '';
    else
        Inames{1} = ['"' Inames{1} '"'];
    end
end

if ~NoOnames
    if isempty(Onames{1}),
        Onames{1} = '';
    else
        Onames{1} = ['"' Onames{1} '"'];
    end
end

if PID.Ts==0
    StrHead = ctrlMsgUtils.message('Control:ltiobject:pidDisplayTime1');
else
    StrHead = ctrlMsgUtils.message('Control:ltiobject:pidDisplayTime2');
end

MsgID = ['Control:ltiobject:pidDisplayType' PID.getType];
StrHead = sprintf('%s %s',StrHead,ctrlMsgUtils.message(MsgID));

if NoInames
    if NoOnames
        String = sprintf('%s:',StrHead);
    else
        String = sprintf('%s:',ctrlMsgUtils.message('Control:ltiobject:pidDisplayIO1',StrHead,Onames{1}));
    end
else
    if NoOnames    
        String = sprintf('%s:',ctrlMsgUtils.message('Control:ltiobject:pidDisplayIO2',StrHead,Inames{1}));
    else
        String = sprintf('%s:',ctrlMsgUtils.message('Control:ltiobject:pidDisplayIO3',StrHead,Inames{1},Onames{1}));
    end
end

disp(String)

end

