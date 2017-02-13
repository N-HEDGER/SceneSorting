%%% version of sorting task to run in stereoscope
%%% includes LR switch for mirror
%%% all position calculations are as for non-mirroring.
%%% BUT images are flipped as read in
%%% coordinates of destination rects are flipped at drawing



close all;
clear all;

%%%% definitions
KbName('UnifyKeyNames');
MIRROR_VIEW=0;

SORTING = 1;
SELECTING = 2;
LABELLING = 3;

MIN_GROUPS = 5;
MAX_GROUPS = 10;

CURRENT_TASK=SORTING;

%%%% find subject's name
subject = input('subject name: ', 's');

datafilename=strcat('Data/Sorting_', subject);
datafilenamepic=strcat(datafilename,'.jpg');

log_text=sprintf('Data/%s_log.txt',subject);
log_text_fid=fopen(log_text,'a+');

if(exist(strcat(datafilename, '.mat'), 'file'))
    fprintf('Your datafile already exists\n');
    load(datafilename, 'Start_x', 'Start_y', 'ImOrder', 'Width', 'Height', 'N_GROUPS', 'GroupLabels', 'Label_xy', 'GroupMembers');
    %load(datafilename, 'Start_x', 'Start_y', 'ImOrder', 'Width', 'Height');
    NEW_SUB = 0;
else
    NEW_SUB = 1;
end;

N_IMAGES = 80;
if(NEW_SUB)
    ImOrder = randperm(N_IMAGES);
    %%% group
    N_GROUPS = 0;
    GroupLabels = cell(MAX_GROUPS, 5);
    Label_xy = NaN(MAX_GROUPS, 5, 2);
    GroupMembers = NaN(N_IMAGES, 1);
else
    fprintf('Your data was saved as %s\n', datafilename);
    dummy_check = input('Do you want to continue? (y / n)', 's');
    if(strcmp(dummy_check, 'n'))
        return;
    end;
end;

ScreenInfo = Screen('Resolution', 0);

WindW = min(0.90*ScreenInfo.width, 1800);
WindH = min(ScreenInfo.height, 1440);
StackW = 450;

%%%% open one window %%%
WINDOW_INDEX = Screen('openwindow', 0, [], [0 0 WindW WindH]);
%%% set up buttons
labeltext{1} = 'SORT';
labeltext{2} = 'GROUPS';
labeltext{3} = 'LABEL';

Screen('TextFont',WINDOW_INDEX, 'Courier New');
Screen('TextSize', WINDOW_INDEX, 20);
Screen('TextStyle', WINDOW_INDEX, 1);

textbox = Screen('TextBounds', WINDOW_INDEX, labeltext{2});
BUTT_WIDTH = textbox(3)*1.2;
BUTT_HEIGHT = textbox(4)*1.2;
%%% top left position of buttons
BUTT_POS(1:3, 1) = WindH - BUTT_HEIGHT*1.2;
BUTT_POS(1, 2) = StackW + BUTT_WIDTH*0.2;
BUTT_POS(3, 2) = WindW - BUTT_WIDTH*1.2;
BUTT_POS(2, 2) = (BUTT_POS(1, 2) + BUTT_POS(3, 2))/2;
%%% positions of button labels on window
for(bb=1:3)
    BUTT_RECTS(bb, :) = [BUTT_POS(bb, 2) BUTT_POS(bb, 1) BUTT_POS(bb, 2) + BUTT_WIDTH BUTT_POS(bb, 1) + BUTT_HEIGHT];
    t_temp = Screen('TextBounds', WINDOW_INDEX, labeltext{bb});
    text_rect(bb, :)= CenterRect(t_temp, BUTT_RECTS(bb, :));
end;

if(NEW_SUB==0)
    if(Width~=WindW || Height ~=WindH)
        Start_x = Start_x*(WindW/Width);
        Start_y = Start_y*(WindH/Height);
    end;
end;
Width = WindW;
Height = WindH;

DARK_GREY = [100 100 100];
LIGHT_GREY = [200 200 200];

Screen('FillRect', WINDOW_INDEX, DARK_GREY);
if(MIRROR_VIEW)
    Screen('FillRect', WINDOW_INDEX, LIGHT_GREY, [0 0 WindW-StackW WindH]);
else
    Screen('FillRect', WINDOW_INDEX, LIGHT_GREY, [StackW 0 WindW WindH]);
end;

%%% turn images into off-screen textures?
%%% open a few images
for(im=1:N_IMAGES)
    FileNameIn = strcat('ImagesToClassify/Scene', num2str(im), 'left5.tif');
    ImArray(im, :, :, 1:3) = imresize(imread(FileNameIn), 0.35);
    texIndex(im)=Screen('MakeTexture', WINDOW_INDEX, squeeze(ImArray(im, :, :, :)));
end;

ImW = size(ImArray, 3);
ImH = size(ImArray, 2);

%N_STACKS = floor(WindH/ImH);
N_STACKS = 5;
PerStack = ceil(N_IMAGES/N_STACKS);
StackH = WindH/N_STACKS;

Stacky = StackH*(0:N_STACKS-1) + 1;
x_incr = (StackW - ImW)/PerStack;
y_incr = (StackH - ImH - 20)/PerStack;


Screen('Preference', 'SkipSyncTests', 1);


[~, order_to_draw] = sort(ImOrder, 2, 'descend');
for(ii=1:N_IMAGES)
    im = order_to_draw(ii);
    
    if(NEW_SUB)
        
        if(mod(ii, PerStack)==1)
            %%% new stack %%%
            Start_x(im) = 1;
            Start_y(im) = Stacky(floor(ii/PerStack)+1);
        else
            Start_x(im) = round(Start_x(order_to_draw(ii-1)) + x_incr);
            Start_y(im) = round(Start_y(order_to_draw(ii-1)) + y_incr);
        end;
    end;
end;

notdoneyet = 0;
start_time = GetSecs;

PRESSED = 1;
RELEASED = 0;
LEFT_BUTTON = RELEASED;

LAST_SELECTED = NaN;
SELECTED = NaN;



current_time=GetSecs;
log_txt=sprintf('Experimental loop begin at %f',current_time);
fprintf(log_text_fid,'%s\n',log_txt);
log_txt=sprintf('Experimental loop begin at %s',num2str(clock));
fprintf(log_text_fid,'%s\n',log_txt);
formatSpecQuit=('Subject quitted at: %s');


while(GetSecs - start_time<60*10)  % max time sorting
    
    %%% check for key presses
    
    [~, ~, keyCode] = KbCheck;
    
    if keyCode(KbName('ESCAPE')) % escape
        imageArray = Screen('GetImage', WINDOW_INDEX);
        imwrite (imageArray,datafilenamepic);
        log_txt=sprintf(formatSpecQuit,num2str(clock));
        fprintf(log_text_fid,'%s\n',log_txt);
        Screen('CloseAll');
        return;
    end;
    
    %%% get position of mouse
    [Mx,My,buttons] = GetMouse;
    
    %%% check if a button is being pressed
    Button_OverLap = Mx>BUTT_RECTS(:, 1) & Mx<BUTT_RECTS(:, 3) & My>BUTT_RECTS(:, 2) & My<BUTT_RECTS(:, 4);
    ButtOverLap = find(Button_OverLap);
    if(~isempty(ButtOverLap))
        if(buttons(1) && LEFT_BUTTON == RELEASED)
            % left button has been newly pressed %
            LEFT_BUTTON = PRESSED;
            switch(ButtOverLap)
                case 1, CURRENT_TASK=SORTING;
                case 2, CURRENT_TASK=SELECTING;
                case 3, CURRENT_TASK=LABELLING;
            end;
            
        else
            LEFT_BUTTON = RELEASED;
        end;
    end;
    
    if(CURRENT_TASK==SORTING)
        
        %%% see if left button is pressed
        if(buttons(1))
            %%%% is this 'newly' pressed?
            if(LEFT_BUTTON == RELEASED)
                LEFT_BUTTON = PRESSED;
                %%% see if newly pressed over an image
                OverLap = Mx>Start_x & Mx<Start_x + ImW & My>Start_y & My<Start_y + ImH;
                ImOverLap = find(OverLap);
                if(~isempty(ImOverLap))
                    %%% key newly pressed, and over an image
                    %%% check which image is foremost of overlapping ims %%%
                    SELECTED = find(ImOrder==(min(ImOrder(ImOverLap))));
                    %fprintf('image selected: %d\n', SELECTED);
                    
                    %%% position of mouse at 'lift off'
                    [MxLift,MyLift] = GetMouse;
                    %%% position of selected image at 'lift off'
                    ImLift_x = Start_x(SELECTED);
                    ImLift_y = Start_y(SELECTED);
                    
                    %%% move this image to the front of the stack and update order
                    SelPos = ImOrder(SELECTED);
                    %%% find images that were in front of this image
                    InFront = find(ImOrder<SelPos);
                    ImOrder(InFront) = ImOrder(InFront) + 1;
                    ImOrder(SELECTED)=1;
                end;
                draw_all_images;
            else
                %%% left button is being held down
                %%% check if big / stereo view is being done
                if(buttons(2))
                    % when right button is added to left, do big / stereo view
                    % which could take a bit longer
                    FileNameBig = strcat('ImagesToClassify/Scene', num2str(SELECTED), 'left5.tif');
                    if(MIRROR_VIEW)
                        BigIm = fliplr(imresize(imread(FileNameBig), 1));                      
                    else
                         BigIm = imresize(imread(FileNameBig), 1);
                    end;
                    
                    [BigH, BigW, ~] = size(BigIm);
                    BigTexIndex=Screen('MakeTexture', WINDOW_INDEX, BigIm);
                    Big_x = (WindW - BigW)/2;
                    Big_y = (WindH - BigH)/2;
                    % put texture into image
                    Screen('DrawTexture', WINDOW_INDEX, BigTexIndex, [], [Big_x, Big_y, Big_x + BigW, Big_y + BigH]);
                    
                else
                    %%% current image was already selected - update positions
                    %%% how much has mouse moved since selection
                    
                    if(isnan(SELECTED))
                        %%% do nothing
                    else
                        
                        xShift = Mx - MxLift;
                        yShift = My - MyLift;
                        
                        Start_x(SELECTED) = ImLift_x + xShift;
                        Start_y(SELECTED) = ImLift_y + yShift;
                        
                    end;
                    draw_all_images;
                end;
            end;
        else
            if(LEFT_BUTTON==PRESSED)
                %%%% save what subject has done so far %%%
                %save(datafilename, 'Start_x', 'Start_y', 'ImOrder', 'Width', 'Height');
                if(exist('GroupLabels','var'))
                    save(datafilename, 'Start_x', 'Start_y', 'ImOrder', 'Width', 'Height', 'N_GROUPS', 'GroupLabels', 'Label_xy', 'GroupMembers');
                else
                    save(datafilename, 'Start_x', 'Start_y', 'ImOrder', 'Width', 'Height');
                end;
            end;
            LEFT_BUTTON = RELEASED;
            SELECTED = NaN;
            LAST_SELECTED = NaN;
            if(buttons(2))
                %%% only button 2 pressed
                %%% flip order of images
                ImOrder = N_IMAGES-ImOrder+1;
                WaitSecs(0.2);
                draw_all_images;
            else
                %%%% neither button being pressed
                
                draw_all_images;
                
            end;
        end;
        
    elseif(CURRENT_TASK==SELECTING)
        find_groups;
        
    elseif(CURRENT_TASK==LABELLING)
        
        % images get drawn in find groups
        find_groups;
        if(N_GROUPS<MIN_GROUPS || N_GROUPS>MAX_GROUPS)
            %%% somehow show the error %%%
            Screen('Flip', WINDOW_INDEX);
            WaitSecs(0.3);
            CURRENT_TASK = SORTING;
        else
            
            for(gg=1:N_GROUPS)
                %%% find position of group %%%
                Label_xy(gg, 1, 1) = mean(Start_x(GroupMembers==gg));
                Label_xy(gg, 1, 2) = mean(Start_y(GroupMembers==gg));
                
                for(ll=2:5)
                    Label_xy(gg, ll, 1) = Label_xy(gg, ll-1, 1);
                    Label_xy(gg, ll, 2) = Label_xy(gg, ll-1, 2) + BUTT_HEIGHT;
                    
                end;
                
                draw_labels;
            end;
            
            %%% check if left mouse button is freshly clicked
            %%% if so, check for overlap with label positions
            %%%% if overlap exists, echo text from keyboard into
            
            if(buttons(1))
                %%%% is this 'newly' pressed?
                if(LEFT_BUTTON == RELEASED)
                    LEFT_BUTTON = PRESSED;
                    
                    %%% see if newly pressed over an image
                    x_vals = reshape(Label_xy(:, :, 1), 50, 1);
                    y_vals = reshape(Label_xy(:, :, 2), 50, 1);
                    
                    OverLap = Mx>x_vals & Mx<x_vals + BUTT_HEIGHT*4 & My>y_vals & My<y_vals + BUTT_HEIGHT;
                    LabelOverLap = find(OverLap);
                    if(~isempty(LabelOverLap))
                        %%% key newly pressed, and over a label - find which
                        [GroupL, LabelN] = ind2sub([10 5], LabelOverLap(1));
                        %%% get correct colour of group
                        GETTING_LABEL = 1;
                        TempLabel = strcat({'Label '}, num2str(LabelN), {': '}, GroupLabels{GroupL, LabelN});
                        TempLabel = TempLabel{1};
                        t_temp = Screen('TextBounds', WINDOW_INDEX, TempLabel);
                        LRect = round([Label_xy(GroupL, LabelN, 1), Label_xy(GroupL, LabelN, 2), Label_xy(GroupL, LabelN, 1) + t_temp(3), Label_xy(GroupL, LabelN, 2) + BUTT_HEIGHT]);
                        TextReverse = 0;
                        
                        if(MIRROR_VIEW)
                            LRect = GetMirrorRect(LRect, WindW);
                            TextReverse = 1;
                        end;
                        
                        Screen('FillRect', WINDOW_INDEX, group_colours(GroupL, :)/2, LRect);
                        DrawFormattedText(WINDOW_INDEX, TempLabel, LRect(1), LRect(2), [10 255 10], [], TextReverse);
                        Screen('Flip', WINDOW_INDEX);
                        while(GETTING_LABEL)
                            [secs, keyCode, deltaSecs] = KbStrokeWait([], GetSecs+5);
                            if(sum(keyCode)==0)
                                % no key pressed within time limit
                                GETTING_LABEL=0;
                            else
                                %%% see what was pressed
                               % if(sum([keyCode(KbName('return')) keyCode(KbName('enter'))])>0)
                               if(sum([keyCode(KbName('return'))])>0)
                                    GETTING_LABEL=0;
                                elseif(keyCode(KbName('DELETE')))
                                    TempLabel = GroupLabels{GroupL, LabelN};
                                    if(~isempty(TempLabel))
                                        GroupLabels{GroupL, LabelN} = TempLabel(1:end-1);
                                    end;
                                elseif(keyCode(KbName('SPACE')))
                                    TempLabel = GroupLabels{GroupL, LabelN};
                                    if(~isempty(TempLabel))
                                        GroupLabels{GroupL, LabelN} = strcat(TempLabel, {' '});
                                    end;
                                else
                                    GroupLabels{GroupL, LabelN} = strcat(GroupLabels{GroupL, LabelN}, KbName(keyCode));
                                end;
                            end;
                            TempLabel = strcat({'Label '}, num2str(LabelN), {': '}, GroupLabels{GroupL, LabelN});
                            if(~isempty(TempLabel))
                                TempLabel = TempLabel{1};
                            else
                                TempLabel = 'Label';
                            end;
                            t_temp = Screen('TextBounds', WINDOW_INDEX, TempLabel);
                            LRect = round([Label_xy(GroupL, LabelN, 1), Label_xy(GroupL, LabelN, 2), Label_xy(GroupL, LabelN, 1) + t_temp(3), Label_xy(GroupL, LabelN, 2) + BUTT_HEIGHT]);
                            TextReverse = 0;
                            
                            if(MIRROR_VIEW)
                                LRect = GetMirrorRect(LRect, WindW);
                                TextReverse = 1;
                            end;
                            
                            Screen('FillRect', WINDOW_INDEX, group_colours(GroupL, :)/3, LRect);
                            DrawFormattedText(WINDOW_INDEX, TempLabel, LRect(1), LRect(2), [255 255 255], [], TextReverse);
                            Screen('Flip', WINDOW_INDEX);
                        end;
                        
                        %GroupLabels{GroupL, LabelN} = GetEchoString(WINDOW_INDEX, strcat('LABEL ', num2str(LabelN)), Label_xy(GroupL, LabelN, 1), Label_xy(GroupL, LabelN, 2), [100 255 100]);
                        %GroupLabels{GroupL, LabelN} = GetEchoString(WINDOW_INDEX, strcat('LABEL ', num2str(LabelN)), Label_xy(GroupL, LabelN, 1), Label_xy(GroupL, LabelN, 2), [100 255 100]);
                    end;
                    save(datafilename, 'Start_x', 'Start_y', 'ImOrder', 'Width', 'Height', 'N_GROUPS', 'GroupLabels', 'Label_xy', 'GroupMembers');
                end;
            else
                LEFT_BUTTON = RELEASED;
            end;
        end;
    end;
    
    draw_buttons;
    
    %%% show cursor position
    if(MIRROR_VIEW)
        Mx_draw = WindW - Mx + 1;
        My_draw = My;
        Screen('DrawDots', WINDOW_INDEX, [Mx_draw, My_draw], 10, [255 255 255]);
        HideCursor;
    end;
    
    Screen('Flip', WINDOW_INDEX);
    ShowCursor;
    if(MIRROR_VIEW)
        Screen('FillRect', WINDOW_INDEX, LIGHT_GREY, [0 0 WindW-StackW WindH]);
    else
        Screen('FillRect', WINDOW_INDEX, LIGHT_GREY, [StackW 0 WindW WindH]);
    end;
end;



Screen('Closeall')