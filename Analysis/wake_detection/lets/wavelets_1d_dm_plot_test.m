function [ filt_proj1d_dc_cwt ] = wavelets_1d_dm_plot_test( root,root_data_out,root_out,spec,aux_path,aux_path_out,filename,lenght_factor,resol_factor,pivot,rot_angle,lim1d,lim_cwt,cutoff,info)
    
%(example) [ scale proj1d_dc_cwt ] = wavelets_1d_dm_plot_test('/home/asus/Dropbox/extras/storage/guillimin/test/','/home/asus/Dropbox/extras/storage/guillimin/test/','/home/asus/Dropbox/extras/storage/guillimin/test/','64Mpc_96c_48p_zi63_nowakes','/','','0.000xv0.dat',1,1,[0,0,0],[0,0],'minmax','minmax',0.8,[0]);
%(example) wavelets_1d_dm_plot_test('/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/','64Mpc_1024c_512p_zi63_wakeGmu1t10m7zi31m','/sample0001/','','15.000xv0.dat',2,2,[0,0,0],[0,0],'minmax','minmax',0.8,[0]);
%(example) wavelets_1d_dm_plot_test('/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/','64Mpc_1024c_512p_zi63_nowakem','/sample0001/','','15.000xv0.dat',2,2,[0,0,0],[0,0],'minmax','minmax',0.4,[0,2,3]);

%plan:
%info=0 -> plots the histogram as well
%info=1 -> just the box display and colourbars separeted,
%info=2 -> just the box, title and colorbar



cd('../../preprocessing');

[ nodes_list redshift_list ] = preprocessing_many_nodes(root,spec,aux_path );

[ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in header i_node j_node k_node number_node_dim ] = preprocessing_nodes_all_but_phasespace( root,spec,aux_path,filename);

cd('../../parameters')

[ vSgammaS displacement vel_pert] = wake( Gmu,z);

cd('../Analysis/wake_detection/lets');

mkdir(root_out);
mkdir(root_out,strcat(spec,aux_path));
mkdir(strcat(root_out,spec,aux_path),strcat('plot/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/'));
path_out=strcat(root_out,spec,aux_path,'plot/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj//');


path_data=strcat(strcat(root_data_out,spec,aux_path),'data/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/dm/wavelet/dc/');

%plot the wavelet levels

wavelets_1d_dm_data_out( root,root_data_out,spec,aux_path,aux_path_out,filename,lenght_factor,resol_factor,pivot,rot_angle,cutoff);
proj1d_dc_cwt=dlmread(char(strcat(path_data,'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_data.txt')));
scale=dlmread(char(strcat(path_data,'scale/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_scale.txt')));

gcc_to_mpc=size_box/nc;
pvz=pivot(3)*gcc_to_mpc;



fig=figure('Visible', 'off');
set(gcf, 'Position', [0 0 800 600]);
ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
hp = pcolor(ax2, -size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(proj1d_dc_cwt)); hp.EdgeColor = 'none';
if (~ischar(lim_cwt))
    caxis(lim_cwt);
end
colorbar;

hold on;
set(gca,'YScale','log');
xlabel(ax2,'$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20); ylabel(ax2,'Scale parameter (Mpc)', 'interpreter', 'latex', 'fontsize', 20);
title(strcat({'Continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
descr = {strcat('z = ',num2str(z));
    strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
    strcat('lenghtFactor = ',num2str(lenght_factor));
    strcat('resolFactor = ',num2str(resol_factor));
    strcat('$(\theta,\phi)$ = (',num2str(rot_angle(1)),',',num2str(rot_angle(2)),')' );
    strcat('box displ wrt centre  = ');
    strcat('(',num2str(pivot(1)),',',num2str(pivot(2)),',',num2str(pivot(3)),')',' (cell unit)');
    strcat('boxSize/dim = ',num2str(size_box/lenght_factor),'\ Mpc'); 
    strcat('cell/dim = ',num2str(np/lenght_factor));
    strcat('sliceSize = ',num2str(size_box/(np/(resol_factor))),'\ Mpc');
    strcat('expectedWakeThick = ');
    strcat( num2str(displacement),'\ Mpc');
    strcat('wakeThickResol = ');
    strcat( num2str(displacement/(size_box/(np))));
    strcat('wavelet basis = Morse')};
%axes(ax1); % sets ax1 to current axes
%fig.CurrentAxes = ax1;
ax1 = axes('Position',[0 0 1 1],'Visible','off');
txt=text(0.82,0.5,descr);
set(txt,'Parent',ax1,'interpreter', 'latex');

if (~ischar(lim_cwt))
    if (~ischar(lim1d))
        mkdir(path_out,strcat(num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
        saveas(fig,strcat(path_out,num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    else
        mkdir(path_out,strcat('minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
        saveas(fig,strcat(path_out,'minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    end
else
    if (~ischar(lim1d))
        mkdir(path_out,strcat(num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/'));
        saveas(fig,strcat(path_out,num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    else
        mkdir(path_out,strcat('minmax/wavelet/','abs/minmax/'));
        saveas(fig,strcat(path_out,'minmax/wavelet/','abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    end
end


hold off;

%plot the filtered 1d propjection

proj1d_dc_icwt=dlmread(char(strcat(path_data,strcat('filter_1dproj_',num2str(cutoff),'MpcCut/'),'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_filter_data.txt')));

fig=figure('Visible', 'off');
set(gcf, 'Position', [0 0 800 400]);
ax2 = axes('Position',[0.2 0.2 0.6 0.6]);

hold on;

gcc_to_mpc=size_box/nc;
pvy=pivot(2)*gcc_to_mpc;
pvz=pivot(3)*gcc_to_mpc;

cell_bins1d_z=[(size_box/2)-(size_box/(2*lenght_factor))+pvz:size_box/(np*resol_factor):(size_box/2)+(size_box/(2*lenght_factor))+pvz];
cell_bins1d_z(end)=[];

xlim ([-inf inf]);

if (~ischar(lim1d))
    plot(ax2,cell_bins1d_z,proj1d_dc_icwt,'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
    ylim(lim1d);
   % xlim([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy]);

else 
    plot(ax2,cell_bins1d_z,proj1d_dc_icwt,'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
    %xlim([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy]);

end

xlabel(ax2,'$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20);
ylabel(ax2,'Density contrast', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);

title(ax2,{strcat('Density contrast of the'),'filtered 1dprojection'},'interpreter', 'latex', 'fontsize', 20);
descr = {strcat('z = ',num2str(z));
    strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
    strcat('lenghtFactor = ',num2str(lenght_factor));
    strcat('resolFactor = ',num2str(resol_factor));
    strcat('$(\theta,\phi)$ = (',num2str(rot_angle(1)),',',num2str(rot_angle(2)),')' );
    strcat('box displ wrt centre  = ');
    strcat('(',num2str(pivot(1)),',',num2str(pivot(2)),',',num2str(pivot(3)),')',' (cell unit)');
    strcat('boxSize/dim = ',num2str(size_box/lenght_factor),'\ Mpc'); 
    strcat('cell/dim = ',num2str(np/lenght_factor));
    strcat('sliceSize = ',num2str(size_box/(np/(resol_factor))),'\ Mpc');
    strcat('expectedWakeThick = ');
    strcat( num2str(displacement),'\ Mpc');
    strcat('wakeThickResol = ');
    strcat( num2str(displacement/(size_box/(np))));
    strcat('expecPartic/slice = ');
    strcat(num2str(((np/lenght_factor)^2)/resol_factor));
    strcat('peak =',num2str(max(proj1d_dc_icwt)));
    strcat('$\sigma$ = ',num2str(std(proj1d_dc_icwt)));
    strcat('$peak/ \sigma$ = ',num2str(max(proj1d_dc_icwt)/std(proj1d_dc_icwt)));
    strcat('wavelet basis = Morse');
    strcat('cutoff = ',num2str(cutoff),'Mpc')};
%axes(ax1); % sets ax1 to current axes
%fig.CurrentAxes = ax1;
ax1 = axes('Position',[0 0 1 1],'Visible','off');
txt=text(0.82,0.5,descr);
set(txt,'Parent',ax1,'interpreter', 'latex');
hold off;

if (~ischar(lim1d))
    mkdir(path_out,strcat(num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/'));
    saveas(fig,strcat(path_out,num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
else
    mkdir(path_out,strcat('minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/'));
    saveas(fig,strcat(path_out,'minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
end

%plot the filtered wavelet coeficients

filt_proj1d_dc_cwt=dlmread(char(strcat(path_data,strcat('filtered_cwt_',num2str(cutoff),'MpcCut/'),'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_filter_data.txt')));

gcc_to_mpc=size_box/nc;
pvz=pivot(3)*gcc_to_mpc;




if ismember(0,info)
    
    
    fig0=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
    
    if (~ischar(lim1d))
    his=histogram( ax2,abs(filt_proj1d_dc_cwt),'BinLimits',lim1d );
    else
    his=histogram( ax2,abs(filt_proj1d_dc_cwt));        
    end
    
    
%     hp = pcolor( ax2,-size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(filt_proj1d_dc_cwt)); hp.EdgeColor = 'none';
%     if (~ischar(lim_cwt))
%         caxis(lim_cwt);
%     end
%     colorbar;
    
    
    hold on;
    
%     set(gca,'YScale','log');
%     xlabel(ax2,'$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Histogram of filtered continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('lenghtFactor = ',num2str(lenght_factor));
        strcat('resolFactor = ',num2str(resol_factor));
        strcat('$(\theta,\phi)$ = (',num2str(rot_angle(1)),',',num2str(rot_angle(2)),')' );
        strcat('box displ wrt centre  = ');
        strcat('(',num2str(pivot(1)),',',num2str(pivot(2)),',',num2str(pivot(3)),')',' (cell unit)');
        strcat('boxSize/dim = ',num2str(size_box/lenght_factor),'\ Mpc');
        strcat('cell/dim = ',num2str(np/lenght_factor));
        strcat('sliceSize = ',num2str(size_box/(np/(resol_factor))),'\ Mpc');
        strcat('expectedWakeThick = ');
        strcat( num2str(displacement),'\ Mpc');
        strcat('wakeThickResol = ');
        strcat( num2str(displacement/(size_box/(np))));
        strcat('wavelet basis = Morse');
        strcat('cutoff = ',num2str(cutoff),'Mpc');
        strcat('$\sigma$ = ',num2str(std(abs(filt_proj1d_dc_cwt(:)))));
        strcat('skewness = ',num2str(skewness(abs(filt_proj1d_dc_cwt(:)))));
        strcat('kurtosis = ',num2str(kurtosis(abs(filt_proj1d_dc_cwt(:)))));
        strcat('num of bins = ',num2str(his.NumBins))};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    
    % if ismember(0,info)
    %     if (~ischar(lim))
    %  0       mkdir(path_out,strcat('dm_0/',num2str(lim(1)),'_',num2str(lim(2)),'lim','/'));
    %         saveas(fig0,strcat(path_out,'dm_0/',num2str(lim(1)),'_',num2str(lim(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_hist_z',num2str(z),'_plot.png'));
    %     else
    %         mkdir(path_out,strcat('dm_0/','minmax/'));
    %         saveas(fig0,strcat(path_out,'dm_0/','minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_hist_z',num2str(z),'_plot.png'));
    %     end
    %
    % end
        hold off;

end




if ismember(-1,info)
    
    peak2d=max(abs(filt_proj1d_dc_cwt(:)));
    [row_peak2d,col_peak2d] = find(abs(filt_proj1d_dc_cwt)==peak2d);
    
    row_peak2d_p= scale(row_peak2d) ;
    col_peak2d_p= -size_box/(2*lenght_factor)+size_box/(2)+pvz+(size_box/lenght_factor)*(col_peak2d/(np*resol_factor/lenght_factor));
    
    figm1=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
    

    
    hp = pcolor( ax2,-size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(filt_proj1d_dc_cwt)); hp.EdgeColor = 'none';
    if (~ischar(lim_cwt))
        caxis(lim_cwt);
    end
    colorbar;
    
%     if ismember(3,info)
%        
%         scatter(ax2,col_peak2d_p,row_peak2d_p);
%         
%     end
    
    hold on;
    set(gca,'YScale','log');
    xlabel(ax2,'$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Filtered continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('lenghtFactor = ',num2str(lenght_factor));
        strcat('resolFactor = ',num2str(resol_factor));
        strcat('$(\theta,\phi)$ = (',num2str(rot_angle(1)),',',num2str(rot_angle(2)),')' );
        strcat('box displ wrt centre  = ');
        strcat('(',num2str(pivot(1)),',',num2str(pivot(2)),',',num2str(pivot(3)),')',' (cell unit)');
        strcat('boxSize/dim = ',num2str(size_box/lenght_factor),'\ Mpc');
        strcat('cell/dim = ',num2str(np/lenght_factor));
        strcat('sliceSize = ',num2str(size_box/(np/(resol_factor))),'\ Mpc');
        strcat('expectedWakeThick = ');
        strcat( num2str(displacement),'\ Mpc');
        strcat('wakeThickResol = ');
        strcat( num2str(displacement/(size_box/(np))));
        strcat('wavelet basis = Morse');
        strcat('cutoff = ',num2str(cutoff),'Mpc');
        strcat('peak = ',num2str(peak2d));
        strcat('$\sigma$ = ',num2str(std(abs(filt_proj1d_dc_cwt(:)))));
        strcat('$peak/ \sigma$ = ',num2str(peak2d/std(abs(filt_proj1d_dc_cwt(:)))));
        strcat('peak location = ');
        strcat('(',num2str(col_peak2d_p),',',num2str(row_peak2d_p),')')};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    
    % if ismember(0,info)
    %     if (~ischar(lim))
    %  0       mkdir(path_out,strcat('dm_0/',num2str(lim(1)),'_',num2str(lim(2)),'lim','/'));
    %         saveas(fig0,strcat(path_out,'dm_0/',num2str(lim(1)),'_',num2str(lim(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_hist_z',num2str(z),'_plot.png'));
    %     else
    %         mkdir(path_out,strcat('dm_0/','minmax/'));
    %         saveas(fig0,strcat(path_out,'dm_0/','minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_hist_z',num2str(z),'_plot.png'));
    %     end
    %
    % end
    hold off;
end



if ismember(2,info)
    
    peak2d=max(abs(filt_proj1d_dc_cwt(:)));
    [row_peak2d,col_peak2d] = find(abs(filt_proj1d_dc_cwt)==peak2d);
    
    row_peak2d_p= scale(row_peak2d) ;
    col_peak2d_p= -size_box/(2*lenght_factor)+size_box/(2)+pvz+(size_box/lenght_factor)*(col_peak2d/(np*resol_factor/lenght_factor));
    
    fig2=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
    

    
    hp = pcolor( ax2,-size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(filt_proj1d_dc_cwt)); hp.EdgeColor = 'none';
    if (~ischar(lim_cwt))
        caxis(lim_cwt);
    end
    colorbar;
    
%     if ismember(3,info)
%        
%         scatter(ax2,col_peak2d_p,row_peak2d_p);
%         
%     end
    
    hold on;
    set(gca,'YScale','log');
    xlabel(ax2,'$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Filtered continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('lenghtFactor = ',num2str(lenght_factor));
        strcat('resolFactor = ',num2str(resol_factor));
        strcat('$(\theta,\phi)$ = (',num2str(rot_angle(1)),',',num2str(rot_angle(2)),')' );
        strcat('box displ wrt centre  = ');
        strcat('(',num2str(pivot(1)),',',num2str(pivot(2)),',',num2str(pivot(3)),')',' (cell unit)');
        strcat('boxSize/dim = ',num2str(size_box/lenght_factor),'\ Mpc');
        strcat('cell/dim = ',num2str(np/lenght_factor));
        strcat('sliceSize = ',num2str(size_box/(np/(resol_factor))),'\ Mpc');
        strcat('expectedWakeThick = ');
        strcat( num2str(displacement),'\ Mpc');
        strcat('wakeThickResol = ');
        strcat( num2str(displacement/(size_box/(np))));
        strcat('wavelet basis = Morse');
        strcat('cutoff = ',num2str(cutoff),'Mpc');
        strcat('peak = ',num2str(peak2d));
        strcat('$\sigma$ = ',num2str(std(abs(filt_proj1d_dc_cwt(:)))));
        strcat('$peak/ \sigma$ = ',num2str(peak2d/std(abs(filt_proj1d_dc_cwt(:)))));
        strcat('peak location = ');
        strcat('(',num2str(col_peak2d_p),',',num2str(row_peak2d_p),')')};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    
    % if ismember(0,info)
    %     if (~ischar(lim))
    %  0       mkdir(path_out,strcat('dm_0/',num2str(lim(1)),'_',num2str(lim(2)),'lim','/'));
    %         saveas(fig0,strcat(path_out,'dm_0/',num2str(lim(1)),'_',num2str(lim(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_hist_z',num2str(z),'_plot.png'));
    %     else
    %         mkdir(path_out,strcat('dm_0/','minmax/'));
    %         saveas(fig0,strcat(path_out,'dm_0/','minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_hist_z',num2str(z),'_plot.png'));
    %     end
    %
    % end
    hold off;
end



if ismember(0,info)
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(path_out,strcat('dm_0/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig0,strcat(path_out,num2str('dm_0/dc/',lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_info_z',num2str(z),'_plot.png'));
        else
            mkdir(path_out,strcat('dm_0/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig0,strcat(path_out,'dm_0/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_info_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(path_out,strcat(num2str('dm_0/dc/',lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig0,strcat(path_out,num2str('dm_0/dc/',lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_info_z',num2str(z),'_plot.png'));
        else
            mkdir(path_out,strcat('dm_0/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig0,strcat(path_out,'dm_0/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_info_z',num2str(z),'_plot.png'));
        end
    end
    
end

if ismember(-1,info)
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(path_out,strcat('dm_m1/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(figm1,strcat(path_out,'dm_m1/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(path_out,strcat('dm_m1/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(figm1,strcat(path_out,'dm_m1/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(path_out,strcat('dm_m1/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(figm1,strcat(path_out,'dm_m1/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(path_out,strcat('dm_m1/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(figm1,strcat(path_out,'dm_m1/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    end
    
end

if ismember(2,info)
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(path_out,strcat('dm_2/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig2,strcat(path_out,'dm_2/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(path_out,strcat('dm_2/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig2,strcat(path_out,'dm_2/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(path_out,strcat('dm_2/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig2,strcat(path_out,'dm_2/dc/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(path_out,strcat('dm_2/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig2,strcat(path_out,'dm_2/dc/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    end
    
end








%p = parpool(num_cores);
%tic;

% 
% path_analysis_out=strcat(root,spec,aux_path,'Analysis/stat/box_statistics/');
% 
% cd('../../preprocessing');
% 
% [ nodes_list redshift_list ] = preprocessing_many_nodes(root,spec,aux_path );
% 
% path_in=strcat(root,spec,aux_path);
% filename = dir(strcat(path_in,char(redshift_list(1)),'xv',char(nodes_list(1)),'.dat'));
% filename=filename.name;
% 
% [ size_box nc zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos ] = preprocessing_nodes( root,spec,aux_path,filename,1.0);
% 
% 
% %for k = 3:-1:1
% %for k = 1  :   length(sorted_files_list)
% for rds = 1 : length(redshift_list)
%     
%     bins=[-nc/2:2:nc/2];
%     bins(end)=[];
%     count_sum=zeros(1,numel(bins));
%     
%     for node = 1 : length(nodes_list)
%         
%     
%         path_in=strcat(root,spec,aux_path);
%         file_name = dir(strcat(path_in,char(redshift_list(rds)),'xv',char(nodes_list(node)),'.dat'));
%         file_name=file_name.name;
%         
%         
%         [ size_box nc zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos] = preprocessing_nodes( root,spec,aux_path,file_name,1.0);
%         
%         Pos=transpose(Pos);
%         
%         bins=[-nc/2:2:nc/2];
%         
%         pivot=[0,0,0]; %this is the position od the origin of the rotation point with respect to the center of the box
%         
%         
%         theta=0;
%         phi=0;
%         
%         rx=[];
%         
%         %         rx(1,:)=Pos(1,counter(j)+1:counter(j+1))-(nc/2)-pivot(1);
%         %         rx(2,:)=Pos(2,counter(j)+1:counter(j+1))-(nc/2)-pivot(2);
%         %         rx(3,:)=Pos(3,counter(j)+1:counter(j+1))-(nc/2)-pivot(3);
%         
%         rx(1,:)=Pos(1,:)-(nc/2)-pivot(1);
%         rx(2,:)=Pos(2,:)-(nc/2)-pivot(2);
%         rx(3,:)=Pos(3,:)-(nc/2)-pivot(3);
%         
%         
%         Ry = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
%         Rz = [cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0; 0 0 1];
%         %
%         rx=Rz*rx;
%         rx=Ry*rx;
%         
%         liminf=-(1/2)*nc;
%         limsup= (1/2)*nc;
%         conditionsx=rx(1,:)<=liminf|rx(1,:)>=limsup;
%         conditionsy=rx(2,:)<=liminf|rx(2,:)>=limsup;
%         conditionsz=rx(3,:)<=liminf|rx(3,:)>=limsup;
%         conditions=conditionsx|conditionsy|conditionsz;
%         rx(:,conditions)=[];
%         
%         rx=transpose(rx);
%         
%         %display(rx);
%         
%         if(~isempty(rx))
%             
%             [count edges mid loc] = histcn(rx,1,1,bins);
%             % display(count);
%             % display(length(bins));
%             count=count(1:1,1:1,1:length(bins)-1);
%             %     average=mean2(count);
%             %     count=(count-average)/average;
%             count=squeeze(count);
%             count=squeeze(count);
%             
%             count=transpose(count);
%             
%             % display(count);
%             
%             
%             count_sum=count_sum+count;
%         
%         
%         
%          end
%         
% 
%         end
%                 
%         average=mean(count_sum);
%         count_sum=(count_sum-average)/average;
%     
%      
%     %wavelet analysis
%     
% 
%     %hold on;
%     fig=figure('Visible', 'off');
%     
%     [mcwt,periods] = cwt(count_sum,seconds(2*size_box/nc),'waveletparameters',[3 3.01]);
% %     hp = pcolor( 0:size_box/length(count_sum):size_box-size_box/length(count_sum),seconds(periods),abs(mcwt)); 
% %     hp.EdgeColor = 'none';
% 
% imagesc(0:size_box/length(count_sum):size_box-size_box/length(count_sum),seconds(periods),abs(mcwt));
% colorbar;
% 
% set(gca,'YScale','log');
% xlabel('$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc)', 'interpreter', 'latex', 'fontsize', 20);
% title(strcat('Continuous wavelet transformation (Morse)'),'interpreter', 'latex', 'fontsize', 20);
% mkdir(path_analysis_out,strcat('wavelets/mtwt/'));
% path_file_out=strcat(path_analysis_out,'wavelets/mtwt/','_',num2str(rds),'_mcwt_z',num2str(z),'.png');
% saveas(fig,path_file_out);
% hold off;
% 
% fig=figure('Visible', 'off');
% clims = [0 1];
% imagesc(0:size_box/length(count_sum):size_box-size_box/length(count_sum),seconds(periods),abs(mcwt),clims);
% colorbar;
% set(gca,'YScale','log');
% xlabel('$Z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc)', 'interpreter', 'latex', 'fontsize', 20);
% title(strcat('Continuous wavelet transformation (Morse)'),'interpreter', 'latex', 'fontsize', 20);
% mkdir(path_analysis_out,strcat('wavelets/mtwt_lims/'));
% path_file_out=strcat(path_analysis_out,'wavelets/mtwt_lims/','_',num2str(rds),'_mcwt_lims_z',num2str(z),'.png');
% saveas(fig,path_file_out);
% hold off;
%     
%     
% end
% 
%  cd('../wake_detection/lets');
% 
% %toc;
% 
% %delete(gcp('nocreate'))

end

