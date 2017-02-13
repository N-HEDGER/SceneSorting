

for(bb=1:3)
    But_col(bb, :) = [100 0 0];
    switch CURRENT_TASK
        case SORTING, But_col(1, :) = [50 255 50];
        case SELECTING, But_col(2, :) = [50 255 50];
        case LABELLING, But_col(3, :) = [50 255 50];
    end;
    
    
    B_Rect = BUTT_RECTS(bb, :);
    T_Rect = text_rect(bb, :);
    TextReverse = 0;
    
    if(MIRROR_VIEW)
        B_Rect = GetMirrorRect(B_Rect, WindW);
        T_Rect = GetMirrorRect(T_Rect, WindW);
        TextReverse = 1;
    end;
    
    Screen('FillRect', WINDOW_INDEX, But_col(bb, :), B_Rect);
    
   % Screen('DrawText', WINDOW_INDEX, labeltext{bb}, T_Rect(1), T_Rect(2), [255 255 255], [], [], TextReverse);
    DrawFormattedText(WINDOW_INDEX, labeltext{bb}, T_Rect(1), T_Rect(2), [255 255 255], [], TextReverse);
    
end;