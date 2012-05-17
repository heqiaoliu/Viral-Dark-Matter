function pcgd_blinkBlock(modNum,isTest,blockPath)
    % This function simply blinks the block todraw attention to the block
    % 0.) get the base data

%   Copyright 2007 The MathWorks, Inc.

    [pcgDemoData] = RTWDemos.pcgd_startEmbeddedCoderOverview;
    
    % Insure the model is open;
    [pcgDemoData] = RTWDemos.pcgd_modelIsOpen(pcgDemoData,1,1);
    % get the path to the block
    for inx = 1 : length(blockPath) % note blockPath could be multiple blocks
        if (isTest)
            fullPath{inx} = [pcgDemoData.Harness{1},'/',blockPath{inx}];
            so            = get_param(pcgDemoData.Harness{1},'Object');
        else
            fullPath{inx} = [pcgDemoData.Models{modNum},'/',blockPath{inx}];
            so            = get_param(pcgDemoData.Models{modNum},'Object');
        end
    end
    
    % Make sure the model is visable on the screen
    so.view;
   
   % start the block flashing
   %
    for inx = 1 : 4
        for jnx = 1 : length(blockPath)
            if (inx == 1) || (inx == 3)
                set_param(fullPath{jnx},'backgroundColor','magenta',...
                                        'foregroundColor','green');
            else
                set_param(fullPath{jnx},'backgroundColor','white',...
                                        'foregroundColor','black');
            end       
        end
        pause(.25)
    end
    
end
