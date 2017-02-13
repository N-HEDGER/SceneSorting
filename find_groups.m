GroupMembers = NaN(N_IMAGES, 1);

GroupMembers(1) = 1;
CURRENT_GROUP = 1;

while(~isempty(find(isnan(GroupMembers))))
    %%% find images part of current group
    group_index = find(GroupMembers==CURRENT_GROUP);
    new_set = [];
    for(ii=1:length(group_index))
        %%% see if this one is part of current group
        ref_x1 = Start_x(group_index(ii));
        ref_x2 = Start_x(group_index(ii)) + ImW;
        ref_y1 = Start_y(group_index(ii));
        ref_y2 = Start_y(group_index(ii)) + ImH;
        set1 = find(Start_x >= ref_x1 & Start_x <= ref_x2 & Start_y >= ref_y1 & Start_y <= ref_y2);
        set2 = find(Start_x + ImW >= ref_x1 & Start_x + ImW  <= ref_x2 & Start_y >= ref_y1 & Start_y <= ref_y2);
        set3 = find(Start_x  + ImW >= ref_x1 & Start_x + ImW  <= ref_x2 & Start_y + ImH >= ref_y1 & Start_y + ImH <= ref_y2);
        set4 = find(Start_x >= ref_x1 & Start_x <= ref_x2 & Start_y + ImH >= ref_y1 & Start_y + ImH <= ref_y2);
        
        new_set = [new_set set1 set2 set3 set4];
    end;
    
    
    new_members = setdiff(new_set,group_index);
    if(~isempty(new_members))
        GroupMembers(new_members) = CURRENT_GROUP;
    else
        %%% find non-affliated members %%
        unclaimed = find(isnan(GroupMembers));
        if(isempty(unclaimed))
            % do nothing
        else
            CURRENT_GROUP = CURRENT_GROUP+1;
            GroupMembers(unclaimed(1)) = CURRENT_GROUP;
        end;
    end;
    
end;

%%%% check if number of groups has changed %%%
if(exist('N_GROUPS', 'var') && CURRENT_GROUP==N_GROUPS)
    %%% do nothing
else
    N_GROUPS = CURRENT_GROUP;
    if(exist('GroupLabels', 'var')==0)
     GroupLabels = cell(MAX_GROUPS, 5);
     Label_xy = NaN(MAX_GROUPS, 5, 2);
    end;
end;

[~, order_to_draw] = sort(ImOrder, 2, 'descend');

group_colours = [255 0 0; 0 255 0; 0 0 255; 100 0 0; 0 100 0; 0 0 100; 100 100 0; 100 0 100; 0 100 100; 70 70 70; 200 200 200]; 

TexRects = [Start_x', Start_y', Start_x' + ImW, Start_y' + ImH];

if(MIRROR_VIEW)
    TexRects = GetMirrorRect(TexRects, WindW);
end;


for(im=1:N_IMAGES)
    CurIm = order_to_draw(im);
    Screen('DrawTexture', WINDOW_INDEX, texIndex(CurIm), [], TexRects(CurIm, :));
    if(GroupMembers(CurIm)<11)
        Screen('FrameRect', WINDOW_INDEX, group_colours(GroupMembers(CurIm), :), TexRects(CurIm, :), 4);
    else
        Screen('FrameRect', WINDOW_INDEX, [0 0 0], TexRects(CurIm, :), 16);
    end;
end;







