function pil_demo_create_helper_model(target_block, save_model, alg_blocks)
% PIL_DEMO_CREATE_HELPER_MODEL - Perform SIL / PIL block post-processing.
%
% This function performs the following actions:
%
% 1: Adds convenience blocks (one for each element of "alg_blocks") for 
%    running "target_block_verify" to the model containing "target_block"
% 2: saves the system containing the "target_block" as "save_model". 
%
% pil_demo_create_helper_model(target_block, save_model, alg_blocks)
%
% target_block - SIL / PIL block to process.
%
% save_model - name of the model to save the system containing the target_block as. 
%
% alg_blocks - cell array of algorithm blocks for "target_block_verify"
%

% Copyright 2006 The MathWorks, Inc.

error(nargchk(3, 3, nargin, 'struct'));

target_block_model = get_param(target_block, 'Parent');
target_block_name = get_param(target_block, 'Name');
% load required libraries
load_system('pil_demo_lib');
% process each alg block
width = 400;
height = 100;
x = 15;
y = 110;
verticalGap = 10;
for i=1:length(alg_blocks)
    alg_block = alg_blocks{i};
    % add the "verify" block in a reasonable position
    y = y + ((height + verticalGap) * (i-1));
    %
    block = add_block('pil_demo_lib/Verification Example', ...
                      [target_block_model '/verify_' num2str(i)], ...
                      'Position', ...
                      [x y x+width y+height]);
    % configure the "verify" block
    set_param(block, 'simulationBlock', alg_block);
    set_param(block, 'targetBlock', [save_model '/' target_block_name]);
end
origLocation = get_param(target_block_model, 'Location');
origX = origLocation(1);
origY = origLocation(2);
origWidth = origLocation(3) - origX;
set_param(target_block_model, 'Location', ...
          [origX, origY, origX + origWidth, origY + y + height + 30]);

% save to the "save_model"
close_system(save_model, 0);
save_system(target_block_model, save_model);
disp('###');
hlink = targets_hyperlink_manager('new', 'Example Verification Process', ...
                                  save_model);
disp(['### Use the ' hlink ' block(s) to verify the target block for this demo.']); 
disp('###');
                          
