% This function locates clouds in the MPD data

clear all; close all;

%% Pre-code
% define file paths
Path.home = pwd;
Path.data =strcat(pwd,'\MPD_Data_Unfiltered');


% create a directory of the filenames
cd(Path.data)
Directory = dir("*_MPD_unfiltered.mat");
cd(Path.home)

% for loop that runs once per day of local data
for i = 1:length(Directory)
    
    cd(Path.data)
    load(Directory(i).name)
    cd(Path.home)

    %% Find the clouds
    % apply the spatiotemporal variance operator to the backscatter ratio
    [CloudData] = find_variance_5x5(MPDUnfiltered);

    % Use an edge finder to locate cloud edges
    [CloudData] = compute_edge_finder(CloudData,MPDUnfiltered);
    
    % create the cloud mask
    [CloudData] = create_cloud_mask(CloudData,MPDUnfiltered);
    
    % locate the bottom of the clouds
    [CloudData] = find_cloud_bottom(CloudData,MPDUnfiltered);

    % save the range and time from the MPD structure
    CloudData.time = MPDUnfiltered.time;
    CloudData.range = MPDUnfiltered.range;

    %% create plots
    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]);
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('batlow');
    cd(Path.home)
    imagesc(MPDUnfiltered.time,MPDUnfiltered.range,MPDUnfiltered.backscatterRatio); set(gca,'ydir','normal')
    colorbar
    colormap(cmap1)
    clim([0 10])
    hold on
    p(1) = plot(MPDUnfiltered.time,CloudData.cloudBaseHeight,'s', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    xlabel('Time (Local)')
    xlim([0 24])
    ylabel('Range (m)')
    title('Backscatter Ratio')
    legend(p(1),'Cloud Base')
    ylim([0 5000])

    %% save the data
    cd(Path.data)
    filename = strcat([Directory(i).name(1:8),'_Cloud_Data.mat']);
    save(filename, 'CloudData');
    cd(Path.home)
    
    close(figure(1))
    clear MPDUnfiltered cmap1 CloudData p
end