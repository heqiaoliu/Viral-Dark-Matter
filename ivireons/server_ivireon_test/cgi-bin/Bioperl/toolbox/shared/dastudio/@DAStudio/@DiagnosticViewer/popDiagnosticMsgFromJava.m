function popDiagnosticMsgFromJava(h,msg)
%  POPDIAGNOSTICMSGFROMJAVA
%  This pops the matching diagnostic message from the
%  java window
%  Copyright 1990-2005 The MathWorks, Inc.
  
%  $Revision: 1.1.6.1 $ 

msg = h.convertNagToUDDObject(msg);
msg = convertMsgToStruct(msg);

for i = length(h.messages):-1:1
    if isequal(msg,convertMsgToStruct(h.messages(i)))
        % pop this message

        h.messages(i) = [];

        if (h.javaAllocated == 1)
            win = h.jDiagnosticViewerWindow;
            
            if isempty(h.messages)
                win.removeAllMsgs;
            else
                win.addDiagnosticMsgs;
            end
        end  

        return;
    end
end

function msg = convertMsgToStruct(msg)
    msg = struct(msg);
    msg.Contents = struct(msg.Contents);
