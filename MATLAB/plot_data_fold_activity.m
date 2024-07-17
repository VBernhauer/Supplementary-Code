function [] = plot_data_fold_activity()

    %%% command:
    %%% plot_data_fold_activity()
   
    clc;
    close all;
    clear all;
    set(0,'DefaultFigureVisible','on');
        
    % load data and parameters
    metadata = load('datamat_activity.mat');
    
    %%% CYPs %%%
    data = metadata.dataMetabFold;
    time = metadata.time_act;
    timeXaxis = [0,24,48,72,120];
    YLims = {[0.5 5.5];... 
             [];...
             [];...
             [0.5 5.5];...
             [0.5 5.5];...
             [0.5 30.5]};    
    YTick = {1:1:5;...  
             [];...
             [];...
             1:1:5;... 
             1:1:5;...
             5:5:25};    
    YTickLabel = {{'1.0','2.0','3.0','4.0','5.0'};...  
                  {};...
                  {};...
                  {'1.0','2.0','3.0','4.0','5.0'};...
                  {'1.0','2.0','3.0','4.0','5.0'};...
                  {'5.0','10.0','15.0','20.0','25.0'}};
    %%% y-axis labels %%%
    yaxislabels = {'Fold activity';...
                   '';...
                   '';...
                   'Fold activity';...
                   'Fold activity';...
                   'pmol per well'};
    Text  = {'1-OH-midazolam, single substrate';...
             '';...
             '';...
             '1-OH-midazolam, substrate mixture';...
             '4-OH-diclofenac, substrate mixture';...
             '1-OH-bupropion, substrate mixture'};
    
    if ~exist('./figures', 'dir')
        mkdir('./figures')
    end

    %%%% Each donor in different color %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    facecol_sin = {'red','blue','green'};
    names_sin = {'Donor 1','Donor 2','Donor 3'};
    markers_sin = {'o','diamond','square'};
    
    facecol_mix = {'red','green'};
    names_mix = {'Donor 1','Donor 3'};
    markers_mix = {'o','square'};
    
    figlabs = {'(a)','','','(b)','(c)','(d)'};
    markersize = 50;
    markerfa = {0.5,0.5,0.5};
    mcolors = [0 0 0];
    
    pos = {[55,4.8,0];...
           [];...
           [];...
           [55,4.8,0];...
           [55,4.8,0];...
           [55,26.25,0]};
    
    figure(1);
    clc;
    tiledplot = tiledlayout(2,3);
    set(gcf, 'Position',  [500, 100, 1200, 600]);
    clc;
    mm = 0;
    for aa = 1:6
        mm = mm+1;
        ax(mm) = nexttile(mm);
        if ismember(mm,[2,3])
            set(ax(mm),'Visible','off');
        else
            set(ax(mm),...
                'box','on',...
                'XLim',[-0.05*max(timeXaxis) 1.05*max(timeXaxis)],...
                'XTick',timeXaxis,...
                'XTickLabel',timeXaxis,...
                'XTickLabelRotation',45,...
                'YLim',YLims{mm},...
                'YTick',YTick{mm},...
                'YTickLabel',YTickLabel{mm},...
                'FontSize',10);
            set(gca,'TickLength',[0.025, 0.01])
%             ylabel(yaxislabels{mm},'FontSize',10);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            hold on;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if mm == 1
                for kk = 1:size(data{mm},1)
                    scatter(time,data{mm}(kk,:),markersize,... 
                        'Marker',markers_sin{kk}, ...
                        'MarkerEdgeColor',mcolors,...
                        'MarkerFaceColor',facecol_sin{kk},...
                        'MarkerFaceAlpha',markerfa{kk});
                end
                hold on;
            elseif ismember(mm,[4,5,6])
                for kk = 1:size(data{mm-2},1)
                    scatter(time,data{mm-2}(kk,:),markersize,... 
                        'Marker',markers_mix{kk}, ...
                        'MarkerEdgeColor',mcolors,...
                        'MarkerFaceColor',facecol_mix{kk},...
                        'MarkerFaceAlpha',markerfa{kk});
                end
                hold on;
            end
            title(strcat('\rm',Text{mm}),'FontSize',10,'Position',pos{mm});
            text(0.1,0.9,figlabs{mm},...
                    'Units','Normalized',...
                    'HorizontalAlignment','center',...
                    'FontSize',10,...
                    'FontWeight','bold'); 
        end
    end
    
    leg = legend(ax(1),names_sin,'Location','NorthOutside','FontSize',10,'Orientation','Horizontal');
    leg.Layout.Tile = 'North';
    xlabel(tiledplot,'Time post rifampicin pre-treatment (hours)','FontSize',14);
    ylabel(tiledplot,'Fold activity to corresponding control','FontSize',14);
    tiledplot.TileSpacing = 'compact';
    tiledplot.Padding = 'compact';

    savefig(strcat('figures/data_activity.fig'));
    exportgraphics(gcf,'figures/data_activity.png');
%     exportgraphics(gcf,'figures/data_activity.pdf','ContentType','vector');
%     exportgraphics(gcf,'../LaTeX/figures/data_activity.eps','ContentType','vector');
            
end