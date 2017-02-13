
        

for(ll=1:5)
    TempLabel = strcat({'LABEL '}, num2str(ll), {': '}, GroupLabels{gg, ll});
    
    %%% change from cell to a char string
    if(~isempty(TempLabel))
                                TempLabel = TempLabel{1};
                            else
                                TempLabel = 'Label';
                            end;
    
    %%% get size of required text box
    t_temp = Screen('TextBounds', WINDOW_INDEX, TempLabel);
    
    LRect = round([Label_xy(gg, ll, 1), Label_xy(gg, ll, 2), Label_xy(gg, ll, 1) + t_temp(3), Label_xy(gg, ll, 2) + BUTT_HEIGHT]);
    TextReverse = 0;
    
    if(MIRROR_VIEW)
        LRect = GetMirrorRect(LRect, WindW); 
        TextReverse = 1;
    end;
        
    
    Screen('FillRect', WINDOW_INDEX, group_colours(gg, :)/3, LRect);

    %Screen('DrawText', WINDOW_INDEX, TempLabel, LRect(1), LRect(2), group_colours(gg, :)+[100 100 100]);
    
    DrawFormattedText(WINDOW_INDEX, TempLabel, LRect(1), LRect(2), [255 255 255], [], TextReverse);
    
end;