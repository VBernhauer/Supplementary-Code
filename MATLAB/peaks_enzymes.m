function [] = peaks_enzymes()

    %%% command:
    %%% peaks_enzymes()  
   
    clc;
    close all
    set(0,'DefaultFigureVisible','on');
        
    metadata = load('datamat.mat');
    
    pars = readtable('maxLikValues.txt');
    pars = pars.Var2(2:end);
    
    Dose = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50];
    
    tmax = metadata.tmax_h;    

    timeXaxis = {[0,24,48,72,120,168,240];...
                 [];
                 [0,24,48,72,120,168,240];...
                 [0,24,48,72,120,168,240];...
                 [0,24,48,72,120,168,240];...
                 [0,24,48,72,120,168,240]};
    YLims = {[-0.1 1.1];...
             [];...
             [0.4 7.6];...
             [0.4 7.6];...
             [0.4 7.6];...
             [0.4 7.6]};    
    YTick = {0:0.2:1;...
             [];...
             1:2:7;...
             1:2:7;...
             1:2:7;...
             1:2:7};    
    YTickLabel = {{'0','0.2','0.4','0.6','0.8','1.0'};...
                  {};...
                  {'1.0','3.0','5.0','7.0'};...
                  {'1.0','3.0','5.0','7.0'};...
                  {'1.0','3.0','5.0','7.0'};...
                  {'1.0','3.0','5.0','7.0'}};
    %%% y-axis labels %%%
    ylabels = {' activation';...
               '';...
               ' mRNA expression';...
               ' mRNA expression';...
               ' mRNA expression';...
               ' mRNA expression'};
    Text  = {'PXR';...   
             '';...
             'CYP3A4';...
             'CYP2C9';...
             'CYP2B6';...
             'MDR1'};
    
     yaxislabels = ["";...
                    "";
                    "";...
                    "";...
                    "";...
                    ""];
                   
    
    %%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    colors = jet(length(Dose));
    for ii = 1:length(Dose)
        Legend{ii} = strcat(num2str(Dose(ii)),' \muM');
    end
    ftsize = 14;
    ftsizesm = 12;
    ftsizelt = 10;
    figlabs = {'(a)','','(b)','(c)','(d)','(e)'};
    tiledplot = tiledlayout(3,2,'TileSpacing','Compact');
    set(gcf, 'Position',  [300, 100, 700, 800]);
    mm = 0;
    nn = 0;
    for aa = 1:6
        mm = mm+1;
        ax(mm) = nexttile(mm);
        if mm == 2
            set(ax(mm),'Visible','off');
        else
            nn = nn + 1;
            set(ax(mm),...
                'box','on',...
                'XLim',[-0.05*max(timeXaxis{mm}) 1.05*max(timeXaxis{mm})],...
                'XTick',timeXaxis{mm},...
                'XTickLabel',timeXaxis{mm},...
                'XTickLabelRotation',45,...
                'YLim',YLims{mm},...
                'YTick',YTick{mm},...
                'FontSize',ftsizesm);
            set(gca,'TickLength',[0.025, 0.01])
            ylabel(textwrap(yaxislabels(mm),35),'FontSize',ftsizesm);      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            hold on;
            for i = 1:length(Dose)
                output = peak(pars,Dose(i));
                disp(['Var: ', Text{mm}, ' Dose: ', num2str(Dose(i)), ' Time: ', num2str(output(nn,1)), ' Peak: ', num2str(output(nn,2))]);
                plot(ax(mm),output(nn,1),output(nn,2),...
                    'Marker','o',...
                    'MarkerSize',5,...
                    'MarkerFaceColor',colors(i,:),...
                    'MarkerEdgeColor',colors(i,:),...
                    'Color',colors(i,:),...
                    'LineStyle','none')
                hold on;
                title(strcat('\rm',Text{mm},ylabels{mm}),'FontSize',12);
                text(0.9,0.9,figlabs{mm},...
                    'Units','Normalized',...
                    'HorizontalAlignment','center',...
                    'FontSize',10,...
                    'FontWeight','bold');    
                hold on;
            end
        end
    end
%     leg = legend(ax(5),Legend{:,:},'Position',[0.8 0.1 0.075 0.4],'FontSize',10,'Orientation','Vertical');
    leg = legend(ax(1),Legend{:,:},'FontSize',ftsizelt,'Orientation','Vertical');
    rect = [0.62, 0.7, .25, .27];
    set(leg, 'Position', rect)
    title(leg,'RIF concentration, $L_\mathrm{pxr}$','Interpreter','latex','FontSize',ftsizesm)
%     leg.Layout.Tile = 'North';
    xlabel(tiledplot,'Time (hours)','FontSize',ftsize);    
    tiledplot.TileSpacing = 'compact';
    tiledplot.Padding = 'compact';

    %%% save figure %%%
    if ~exist('./figures', 'dir')
        mkdir('./figures')
    end
    savefig(strcat('figures/peaks_enzymes.fig'));
    exportgraphics(gcf,'figures/peaks_enzymes.png');
    % exportgraphics(gcf,'../../LaTeX/figures/peaks_enzymes.eps','ContentType','vector');


    %%% helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%% output of the model %%%
    function [output] = peak(pars,Dose) 
        solution = ode23s(@ode,[0 tmax],...
                               [0 1 1 1 1],...
                               [],...
                               pars,...
                               Dose);
        output = [];
        for kk = 1:5
            time = solution.x';
            sol  = solution.y';
            [solpeak,id] = max(sol(:,kk));
            output = [output; [time(id), solpeak]];
        end
    end

    %%% ODE system %%%
    function [dxdt] = ode(t,x,pars,Xint)        
        dxdt = zeros(5,1);

        dxdt(1) = pars(1)*(1-x(1))*Xint*exp(-pars(2)*t) - pars(3)*x(1);     % activated PXR
        dxdt(2) = pars(4)*x(1) + pars(5)*(1-x(2));                          % CYP3A4
        dxdt(3) = pars(6)*x(1) + pars(7)*(1-x(3));                          % CYP2C9
        dxdt(4) = pars(8)*x(1) + pars(9)*(1-x(4));                          % CYP2B6
        dxdt(5) = pars(10)*x(1) + pars(11)*(1-x(5));                        % MDR1
    end

end