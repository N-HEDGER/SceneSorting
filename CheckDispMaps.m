%%%% work through all stereo images in Complete SYNS dataset %%%
%%% show final disparity map
%%% show final pair of aligned images
%%%% ?? do i need to show final matches - to check if max disparity is
%%%% represented?

%%% need to be connected to filestore of SYNS
%%% smb://ewgraf.files.soton.ac.uk/EWGraf/

%close all;
clear all;

NVIEWS=18;

%%%% find all outdoor scenes

IndoorPath1 = '/Volumes/EWGraf/NaturalScenes_Hampshire_clean/indoors/lidar_spheron_stereo/';
OutdoorPath1 = '/Volumes/EWGraf/NaturalScenes_Hampshire_clean/outdoors/lidar_spheron_stereo/';
Path2 = []; % do be filled per scene
Path3 = 'StereoTIF/';


for(INOUT= 2:2) % indoor scenes then outdoor %
    %%%% couldn't find good matches for scene 9, view 15. skipped to scene
    %%%% 10
    
    switch INOUT
        case 1, Path1 = IndoorPath1; nScenes = 12;
        case 2, Path1 = OutdoorPath1; nScenes = 80;
    end;
    SceneList = dir(Path1);
    
    
    %for(scene_num=1:nScenes)
    for(scene_num=3)
        %%% find the correct directory %%%
        nn=0;
        match_search=1;
        while(match_search)
            nn= nn+1;
            %SceneList(nn).name
            match = strncmp(SceneList(nn).name, strcat(num2str(scene_num), '_'), 2); % matching either 2 digits or digit plus _
            if(match==1)
                MainDir = strcat(Path1, SceneList(nn).name, '/', Path3);
                match_search = 0;
            end;
        end;
        
        %for(vv=1:NVIEWS)
        for(vv=6:8)
            
            %fprintf('processing view %d, in dir %s\n', vv, SceneList(nn).name);
            
            %%% figure out what final files (right image and depth map) should be called
            % RightName = strcat(MainDir, 'right_aligned/Im', num2str(vv), '.tif');
            DispMapName = strcat(MainDir, 'disps/DMap', num2str(vv), '.mat');
            
            %%% lower resolution images as stimuli in stereoscope
            StimLName = strcat(MainDir, 'stim/ImL', num2str(vv), '.tif');
            StimRName = strcat(MainDir, 'stim/ImR', num2str(vv), '.tif');

            
            
            if(exist(DispMapName))
                load(DispMapName);
                
                ImL = imresize(imread(StimLName), 0.35);
                ImR = imresize(imread(StimRName), 0.35);
                
                %%% find parts of image with sensible matches
                index_bad1 = find(dMap<-20);
                dMap(index_bad1) = NaN;
                index_bad2 = find(dMap==321);
                dMap(index_bad2) = NaN;
                
                index_good = find(dMap>=-20);

                Dmin = prctile(dMap(index_good), 1);
                Dmax = prctile(dMap(index_good), 99);
                
                dMap2 = imresize(dMap, 0.2);
                
                fprintf('Disparity for scene %d, view %d, min: %f\t, max: %f\n', scene_num, vv, Dmin, Dmax);
                
                figure('Name', strcat('Scene', num2str(scene_num), 'View', num2str(vv)));
                nWide = 3;
                nTall = 2;
                
                subplot(nTall, nWide, 1)
                imshowpair(ImL, ImR);
                
                Lower = prctile(dMap, 1, 1);
                Lower2 = prctile(dMap, 5, 1);
                Lower3 = prctile(dMap, 10, 1);
                Upper = prctile(dMap, 99, 1);
                Upper2 = prctile(dMap, 97, 1);
                Upper3 = prctile(dMap, 92, 1);
                
                %%%% try doing 'min smoothing' to get rid of noise %%%
                for(ii=1:length(Upper))
                    switch ii
                        case 1, UpperMin(ii) = min(Upper(1:3)); UpperMin2(ii) = min(Upper2(1:3));
                        case length(Upper), UpperMin(ii)=min(Upper((end-2):end)); UpperMin2(ii)=min(Upper2((end-2):end));
                        otherwise
                            UpperMin(ii) = min(Upper((ii-1):(ii+1))); UpperMin2(ii) = min(Upper2((ii-1):(ii+1)));
                    end;
                end;
                            
                
                
                
                subplot(nTall, nWide, 2)
                hold on;
                %plot(Lower);
                plot(Lower2);
                plot(Lower3);
                %plot(UpperMin);
                plot(UpperMin2);
                plot(Upper3);
                %plot(UpperMin, 'k');
                

                %figure('Name', strcat('DMapScene', num2str(scene_num), 'View', num2str(vv)));
                subplot(nTall, nWide, 3)
                imshow(dMap2, [Dmin Dmax]);
                colormap jet
                colorbar
                hold on;
                subplot(nTall, nWide, 4)
                imshow(ImL);
                subplot(nTall, nWide, 5)
                hist(dMap(:), 200);
                subplot(nTall, nWide, 6)
                imshow(dMap2, [prctile(dMap(:), 5) prctile(dMap(:), 97.5)]);
                colormap jet
                colorbar
                hold on;              
            else
                fprintf('No disparity map for scene %d, view %d\n', scene_num, vv);
                
            end;
            
        end;
    end;
end;
