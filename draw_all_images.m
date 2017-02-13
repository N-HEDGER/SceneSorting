[~, order_to_draw] = sort(ImOrder, 2, 'descend');


    TexRects = [Start_x', Start_y', Start_x' + ImW, Start_y' + ImH];
    
    
    if(MIRROR_VIEW)
        TexRects = GetMirrorRect(TexRects, WindW);
    end;

for(im=1:N_IMAGES)
    CurIm = order_to_draw(im);   
    Screen('DrawTexture', WINDOW_INDEX, texIndex(CurIm), [], TexRects(CurIm, :));
end;