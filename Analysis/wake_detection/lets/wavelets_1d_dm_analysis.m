function [  ] = wavelets_1d_dm_analysis( root,root_data_out,root_plot_out,root_snan_out,spec,aux_path,aux_path_data_out,aux_path_plot_out,aux_path_snan_out,filename,lenght_factor,resol_factor,pivot,rot_angle,lim1d,lim_cwt,cutoff,data_stream,info,analysis)
    
% reads (and/or generate) data of the filtered 1d projections aconding to the input specifications and plot the result



%(example) wavelets_1d_dm_analysis('/home/asus/Dropbox/extras/storage/graham/small_res/','/home/asus/Dropbox/extras/storage/graham/small_res/data/','/home/asus/Dropbox/extras/storage/graham/small_res/plot/','/home/asus/Dropbox/extras/storage/graham/small_res/snan/','64Mpc_96c_48p_zi255_nowakem','/sample1001/','','','','0.000xv0.dat',1,1,[0,0,0],[0,0],'minmax','minmax',10,[1,3],[0,2,3],1);
%(example) wavelets_1d_dm_analysis('/home/asus/Dropbox/extras/storage/guillimin/','/home/asus/Dropbox/extras/storage/guillimin/data/','/home/asus/Dropbox/extras/storage/guillimin/plot/','/home/asus/Dropbox/extras/storage/guillimin/snan/','64Mpc_1024c_512p_zi63_wakeGmu1t10m7zi31m','/sample0001/','','','','15.000xv0.dat',1,1,[0,0,0],[0,0],'minmax','minmax',0.8,[1,3],[0,2,3],1);

% NBody output should be stored as root+spec+aux_path (root directory, specification in the form size_numberofcellsperdimension_number_particlesperdimension_initialredshift_wakespecification&multiplicity, aux_path is the sample number )

% plot will be stored in  root_plot_out+spec+aux_path+aux_path_plot_out

% if specified, data will be stored in  root_data_out+spec+aux_path+aux_path_data_out

% if specified, signal to noise analysis will be stored in  root_snan_out+spec+aux_path+aux_path_snan_out

% filename is the output file from the nbody simulation

% lenght_factor = the analysis cube will have a lateral size given by the
% lateral size of the simulation cube divided by this number

% resol_factor= the bin will hte the particle bin size divided by this
%number

% pivot = a 3d array containing the translation wrt to the center of the
% cube (in grid cell units)

%rot_angle = 2d aray containing the theta and phy spherical angles pointing
%to the direction where the new z axis will be rotated

%cutoff is the lenght scale wich the fluctuations will be removed if above
%that. In Mpc.

%lim1d= limits on the y axis of the plot, in array format. If set to 'minmax'
%will display between the min and max values

%lim_cwt= limits the display of the absolute values of the cont wave transf. If set to 'minmax'
%will display between the min and max values

% data_stream=[1,2,3]
% if data_stream = 0, no data output generated and readed, the data is
% passed directily to this program
% if data_stream = 1, reads data binaries 
% if data_stream = 2, reads data text 
% if data_stream = 3, generates the data output in binary or text if 1 or 2 options are given, respectively


% info=[0,1,2,3]
% if info=0, histogram of each plot is generated
% if info=2, complete plots are generated
% if info=3 complete plots plus info are generated

% analysis=1 -> create a textfile with signal to noise data (peak, std, peak/std)

% test

% test=[1];
% low_cutoff_index=1;
% high_cuttof_index10;

cd('../../preprocessing');

[~,redshift_list,~,size_box,nc,np,zi,~,~,Gmu,ziw] = preprocessing_info(root,spec,aux_path );

[  ~,~,~,~,z ] = preprocessing_filename_info( root,spec,aux_path,filename);

cd('../../parameters')

[ vSgammaS displacement vel_pert] = wake( Gmu,z);

cd('../Analysis/wake_detection/lets');

mkdir(root_plot_out);
mkdir(root_plot_out,strcat(spec,aux_path));
mkdir(strcat(root_plot_out,spec,aux_path),strcat('plot/',aux_path_plot_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/'));
tot_path_out=strcat(root_plot_out,spec,aux_path,'plot/',aux_path_plot_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/');



%plot the wavelet levels


if ismember(0,data_stream)    
   [proj1d_dc_cwt,periods,proj1d_dc_icwt,filt_proj1d_dc_cwt] = wavelets_1d_dm_data_out( root,root_data_out,spec,aux_path,aux_path_data_out,filename,lenght_factor,resol_factor,pivot,rot_angle,cutoff,0);
    scale=seconds(periods);
else    
    path_data=strcat(strcat(root_data_out,spec,aux_path),'data/',aux_path_data_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/dm/wavelet/dc/');
    if ismember(2,data_stream)
        if ismember(3,data_stream)
            wavelets_1d_dm_data_out( root,root_data_out,spec,aux_path,aux_path_data_out,filename,lenght_factor,resol_factor,pivot,rot_angle,cutoff,2);
        end
        proj1d_dc_cwt=dlmread(char(strcat(path_data,'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_data.txt')));    
        scale=dlmread(char(strcat(path_data,'scale/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_scale.txt')));
    end
    if ismember(1,data_stream)
        if ismember(3,data_stream)
            wavelets_1d_dm_data_out( root,root_data_out,spec,aux_path,aux_path_data_out,filename,lenght_factor,resol_factor,pivot,rot_angle,cutoff,1);
        end
        fileID2 = fopen(strcat(path_data,'scale/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_scale.bin'));
        scale=fread(fileID2,'float32','l');
        fclose(fileID2);
        fileID1 = fopen(strcat(path_data,'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_data.bin'));
        proj1d_dc_cwt=fread(fileID1,[length(scale),Inf],'float32','l');
        fclose(fileID1);
    end
end


gcc_to_mpc=size_box/nc;
pvz=pivot(3)*gcc_to_mpc;

if ismember(0,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
    if (~ischar(lim_cwt))
    his=histogram( ax2,proj1d_dc_cwt,'BinLimits',lim_cwt );
    else
    his=histogram( ax2,proj1d_dc_cwt);        
    end
    
    hold on;
    set(gca,'YScale','log');
    xlabel(ax2,'abs(cwt)', 'interpreter', 'latex', 'fontsize', 20); ylabel(ax2,'frequency', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Histogram of the continuous wavelet transformation ','of the density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('z of wake insertion = ',num2str(ziw));
        strcat('z of simulation init = ',num2str(zi));
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
        strcat('$\sigma$ = ',num2str(std(proj1d_dc_cwt(:))));
        strcat('skewness = ',num2str(skewness(proj1d_dc_cwt(:))));
        strcat('kurtosis = ',num2str(kurtosis(proj1d_dc_cwt(:))));
        strcat('num of bins = ',num2str(his.NumBins))};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    hold off;
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_hist_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_0/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_0/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_hist_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_hist_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_0/','minmax/wavelet/','abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_0/','minmax/wavelet/','abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_hist_z',num2str(z),'_plot.png'));
        end
    end
end

if ismember(1,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
%         axes('Position',[0 0 1 1],'Visible','off');
    hp = pcolor( -size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(proj1d_dc_cwt)); hp.EdgeColor = 'none';
        hold on;
    set(gca,'YScale','log');
     xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
%     title(strcat({'Continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
%  set(gca,'xtick',[]);
%     set(gca,'ytick',[]);    
hold off; 
    if (~ischar(lim_cwt))
        fig_cb1=figure('Visible', 'off');
        caxis([lim_cwt(1) lim_cwt(2)]);
        colorbar;
        axis off
        left=800; bottom=100 ; width=60 ; height=600;
        pos=[left bottom width height];
        set(fig_cb1,'OuterPosition',pos);
        
        fig_cb2=figure('Visible', 'off');
        caxis([lim_cwt(1) lim_cwt(2)]);
        colorbar('location','Southoutside');
        axis off
        left=800; bottom=110 ; width=600 ; height=130;
        pos=[left bottom width height];
        set(fig_cb2,'OuterPosition',pos);
    else
        fig_cb1=figure('Visible', 'off');
        caxis([min(min(proj1d_dc_cwt)) max(max(proj1d_dc_cwt))]);
        colorbar;
        axis off
        left=800; bottom=100 ; width=60 ; height=600;
        pos=[left bottom width height];
        set(fig_cb1,'OuterPosition',pos);
        
        fig_cb2=figure('Visible', 'off');
        caxis([min(min(proj1d_dc_cwt)) max(max(proj1d_dc_cwt))]);
        colorbar('location','Southoutside');
        axis off
        left=800; bottom=110 ; width=600 ; height=130;
        pos=[left bottom width height];
        set(fig_cb2,'OuterPosition',pos);
        
    end
    
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_','colormap_h.png'));
        else
            mkdir(tot_path_out,strcat('dm_1/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_1/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_','colormap_h.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/','_','colormap_h.png'));
        else
            mkdir(tot_path_out,strcat('dm_1/','minmax/wavelet/','abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_1/','minmax/wavelet/','abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/','minmax/wavelet/','abs/minmax/','_','colormap_h.png'));
        end
    end
end

if ismember(2,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    hp = pcolor( -size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(proj1d_dc_cwt)); hp.EdgeColor = 'none';
    if (~ischar(lim_cwt))
        caxis(lim_cwt);
    end
    colorbar;
    
    hold on;
    set(gca,'YScale','log');
    xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    hold off;
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_2/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_2/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_2/','minmax/wavelet/','abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_2/','minmax/wavelet/','abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        end
    end
end


if ismember(3,info)
    
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
    xlabel(ax2,'$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20); ylabel(ax2,'Scale parameter (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('z of wake insertion = ',num2str(ziw));
        strcat('z of simulation init = ',num2str(zi));
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
    hold off;
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_3/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_3/','minmax/wavelet/','abs/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_3/','minmax/wavelet/','abs/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_3/','minmax/wavelet/','abs/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
        end
    end
end



%plot the filtered 1d propjection


if ~ismember(0,data_stream)        
    if ismember(2,data_stream)
        proj1d_dc_icwt=dlmread(char(strcat(path_data,strcat('filter_1dproj_',num2str(cutoff),'MpcCut/'),'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_filter_data.txt')));    
    end
    if ismember(1,data_stream)
        fileID1 = fopen(strcat(path_data,strcat('filter_1dproj_',num2str(cutoff),'MpcCut/'),'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_filter_data.bin'));
        proj1d_dc_icwt=fread(fileID1,'float32','l');
        fclose(fileID1);
    end
end

if ismember(0,info)    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 450]);
    ax2 = axes('Position',[0.15 0.2 0.6 0.6]);
    
    hold on;
    
    gcc_to_mpc=size_box/nc;
    pvy=pivot(2)*gcc_to_mpc;
    pvz=pivot(3)*gcc_to_mpc;
    
    cell_bins1d_z=[(size_box/2)-(size_box/(2*lenght_factor))+pvz:size_box/(np*resol_factor):(size_box/2)+(size_box/(2*lenght_factor))+pvz];
    cell_bins1d_z(end)=[];
    
    xlim ([-inf inf]);

    if (~ischar(lim1d))
    his=histogram( ax2,proj1d_dc_icwt,'BinLimits',lim1d );
    else
    his=histogram( ax2,proj1d_dc_icwt);        
    end
    
    xlabel(ax2,'Density contrast', 'interpreter', 'latex', 'fontsize', 20);
    ylabel(ax2,'frequency', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    
    title(ax2,{strcat('Density contrast of the'),'filtered 1dprojection'},'interpreter', 'latex', 'fontsize', 20);
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('z of wake insertion = ',num2str(ziw));
        strcat('z of simulation init = ',num2str(zi));
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
         strcat('skewness = ',num2str(skewness(proj1d_dc_icwt(:))));
        strcat('kurtosis = ',num2str(kurtosis(proj1d_dc_icwt(:))));
        strcat('num of bins = ',num2str(his.NumBins));
        strcat('wavelet basis = Morse');
        strcat('cutoff = ',num2str(cutoff),'Mpc')};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    hold off;
    
    if (~ischar(lim1d))
        mkdir(tot_path_out,strcat('dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_hist_z',num2str(z),'_plot.png'));
    else
        mkdir(tot_path_out,strcat('dm_0/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_0/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_hist_z',num2str(z),'_plot.png'));
    end
end


if ismember(1,info)    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 600 400]);
    
    hold on;
    
    gcc_to_mpc=size_box/nc;
    pvy=pivot(2)*gcc_to_mpc;
    pvz=pivot(3)*gcc_to_mpc;
    
    cell_bins1d_z=[(size_box/2)-(size_box/(2*lenght_factor))+pvz:size_box/(np*resol_factor):(size_box/2)+(size_box/(2*lenght_factor))+pvz];
    cell_bins1d_z(end)=[];
    
    xlim ([-inf inf]);
    
    if (~ischar(lim1d))
        plot(cell_bins1d_z,proj1d_dc_icwt,'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
        ylim(lim1d);
        % xlim([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy]);
        
    else
        plot(cell_bins1d_z,proj1d_dc_icwt,'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
        %xlim([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy]);
        
    end
    
    xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Density contrast', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
%     title({strcat('Density contrast of the'),'filtered 1dprojection'},'interpreter', 'latex', 'fontsize', 20);

    
    
    hold off;
    
    if (~ischar(lim1d))
        mkdir(tot_path_out,strcat('dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    else
        mkdir(tot_path_out,strcat('dm_1/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_1/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    end
end


if ismember(2,info)    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 600 400]);
    
    hold on;
    
    gcc_to_mpc=size_box/nc;
    pvy=pivot(2)*gcc_to_mpc;
    pvz=pivot(3)*gcc_to_mpc;
    
    cell_bins1d_z=[(size_box/2)-(size_box/(2*lenght_factor))+pvz:size_box/(np*resol_factor):(size_box/2)+(size_box/(2*lenght_factor))+pvz];
    cell_bins1d_z(end)=[];
    
    xlim ([-inf inf]);
    
    if (~ischar(lim1d))
        plot(cell_bins1d_z,proj1d_dc_icwt,'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
        ylim(lim1d);
        % xlim([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy]);
        
    else
        plot(cell_bins1d_z,proj1d_dc_icwt,'DisplayName',strcat('z = ',num2str(z)),'LineWidth',2);
        %xlim([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy]);
        
    end
    
    xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Density contrast', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    title({strcat('Density contrast of the'),'filtered 1dprojection'},'interpreter', 'latex', 'fontsize', 20);

    
    
    hold off;
    
    if (~ischar(lim1d))
        mkdir(tot_path_out,strcat('dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    else
        mkdir(tot_path_out,strcat('dm_2/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_2/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    end
end

if ismember(3,info)    
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
    
    xlabel(ax2,'$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20);
    ylabel(ax2,'Density contrast', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    
    title(ax2,{strcat('Density contrast of the'),'filtered 1dprojection'},'interpreter', 'latex', 'fontsize', 20);
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('z of wake insertion = ',num2str(ziw));
        strcat('z of simulation init = ',num2str(zi));
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
        mkdir(tot_path_out,strcat('dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    else
        mkdir(tot_path_out,strcat('dm_3/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/'));
        saveas(fig,strcat(tot_path_out,'dm_3/','minmax/wavelet/','filter_1dproj_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_mcwt_z_z',num2str(z),'_plot.png'));
    end
end


%plot the filtered wavelet coeficients

if ~ismember(0,data_stream)        
    if ismember(2,data_stream)
        filt_proj1d_dc_cwt=dlmread(char(strcat(path_data,strcat('filtered_cwt_',num2str(cutoff),'MpcCut/'),'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_filter_data.txt')));    
    end
    if ismember(1,data_stream)
        fileID1 = fopen(strcat(path_data,strcat('filtered_cwt_',num2str(cutoff),'MpcCut/'),'_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_z',num2str(z),'_wavelet_filter_data.bin'));
        filt_proj1d_dc_cwt=fread(fileID1,[length(scale),Inf],'float32','l');
        fclose(fileID1);
    end
end


gcc_to_mpc=size_box/nc;
pvz=pivot(3)*gcc_to_mpc;

if ismember(0,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
    if (~ischar(lim_cwt))
    his=histogram( ax2,proj1d_dc_cwt,'BinLimits',lim_cwt );
    else
    his=histogram( ax2,proj1d_dc_cwt);        
    end
    
    
    hold on;
    set(gca,'YScale','log');
    xlabel(ax2,'abs(cwt)', 'interpreter', 'latex', 'fontsize', 20); ylabel('frequency', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'Histogram of the filtered continuous wavelet transformation ','of the density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('z of wake insertion = ',num2str(ziw));
        strcat('z of simulation init = ',num2str(zi));
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
        strcat('cutoff = ',num2str(cutoff),'Mpc')};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    hold off;
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_hist_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_0/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_0/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_hist_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_0/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_hist_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_0/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_0/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_hist_z',num2str(z),'_plot.png'));
        end
    end    
end

if ismember(1,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    hp = pcolor( -size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(filt_proj1d_dc_cwt)); hp.EdgeColor = 'none';
    
        hold on;
    set(gca,'YScale','log');
    xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
%     title(strcat({'filtered continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    hold off;
    
    if (~ischar(lim_cwt))
        fig_cb1=figure('Visible', 'off');
        caxis([lim_cwt(1) lim_cwt(2)]);
        colorbar;
        axis off
        left=800; bottom=100 ; width=60 ; height=600;
        pos=[left bottom width height];
        set(fig_cb1,'OuterPosition',pos);
        
        fig_cb2=figure('Visible', 'off');
        caxis([lim_cwt(1) lim_cwt(2)]);
        colorbar('location','Southoutside');
        axis off
        left=800; bottom=110 ; width=600 ; height=130;
        pos=[left bottom width height];
        set(fig_cb2,'OuterPosition',pos);
    else
        fig_cb1=figure('Visible', 'off');
        caxis([min(min(proj1d_dc_cwt)) max(max(proj1d_dc_cwt))]);
        colorbar;
        axis off
        left=800; bottom=100 ; width=60 ; height=600;
        pos=[left bottom width height];
        set(fig_cb1,'OuterPosition',pos);
        
        fig_cb2=figure('Visible', 'off');
        caxis([min(min(proj1d_dc_cwt)) max(max(proj1d_dc_cwt))]);
        colorbar('location','Southoutside');
        axis off
        left=800; bottom=110 ; width=600 ; height=130;
        pos=[left bottom width height];
        set(fig_cb2,'OuterPosition',pos);
        
    end      
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_','colormap_h.png'));
        else
            mkdir(tot_path_out,strcat('dm_1/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_1/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_','colormap_h.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_','colormap_h.png'));
        else
            mkdir(tot_path_out,strcat('dm_1/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_1/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
            saveas(fig_cb2,strcat(tot_path_out,'dm_1/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_','colormap_h.png'));
        end
    end    
end

if ismember(2,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    hp = pcolor( -size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(filt_proj1d_dc_cwt)); hp.EdgeColor = 'none';
    if (~ischar(lim_cwt))
        caxis(lim_cwt);
    end
    colorbar;
       
    hold on;
    set(gca,'YScale','log');
    xlabel('$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'filtered continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    hold off;
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_2/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_2/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_2/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_2/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_2/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    end    
end

if ismember(3,info)
    
    fig=figure('Visible', 'off');
    set(gcf, 'Position', [0 0 800 600]);
    ax2 = axes('Position',[0.15 0.15 0.65 0.65]);
    hp = pcolor( ax2,-size_box/(2*lenght_factor) +size_box/(2)+pvz:size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))):size_box/(2*lenght_factor) +size_box/(2)+pvz-size_box/(lenght_factor*length(proj1d_dc_cwt(1,:))),scale,abs(filt_proj1d_dc_cwt)); hp.EdgeColor = 'none';
    if (~ischar(lim_cwt))
        caxis(lim_cwt);
    end
    colorbar;
    
    
    hold on;
    set(gca,'YScale','log');
    xlabel(ax2,'$Z(Mpc/h)$', 'interpreter', 'latex', 'fontsize', 20); ylabel('Scale parameter (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    title(strcat({'filtered continuous wavelet transformation of the ','density contrast of the 1d projected','dark matter mass (absolute value)'}),'interpreter', 'latex', 'fontsize', 20);
    
    descr = {strcat('z = ',num2str(z));
        strcat('$G\mu = $ ',num2str(Gmu,'%.1E'));
        strcat('z of wake insertion = ',num2str(ziw));
        strcat('z of simulation init = ',num2str(zi));
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
        strcat('cutoff = ',num2str(cutoff),'Mpc')};
    %axes(ax1); % sets ax1 to current axes
    %fig.CurrentAxes = ax1;
    ax1 = axes('Position',[0 0 1 1],'Visible','off');
    txt=text(0.82,0.5,descr);
    set(txt,'Parent',ax1,'interpreter', 'latex');
    hold off;
    
    if (~ischar(lim_cwt))
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_3/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/'));
            saveas(fig,strcat(tot_path_out,'dm_3/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/',num2str(lim_cwt(1)),'_',num2str(lim_cwt(2)),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    else
        if (~ischar(lim1d))
            mkdir(tot_path_out,strcat('dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_3/',num2str(lim1d(1)),'_',num2str(lim1d(2)),'lim','/','wavelet/filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        else
            mkdir(tot_path_out,strcat('dm_3/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/'));
            saveas(fig,strcat(tot_path_out,'dm_3/','minmax/wavelet/','filtered_abs_',num2str(cutoff),'MpcCut/minmax/','_',num2str(find(str2num(char(redshift_list))==z)),'_1dproj_filtered_mcwt_z_z',num2str(z),'_plot.png'));
        end
    end    
end

if ismember(1,analysis)
    mkdir(root_snan_out);
    mkdir(root_snan_out,strcat(spec,aux_path));
    mkdir(strcat(root_snan_out,spec,aux_path),strcat('snan/',aux_path_snan_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/'));
    tot_snan_path_out=strcat(root_snan_out,spec,aux_path,'snan/',aux_path_snan_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','1dproj/');
    st_proj1d_dc_icwt = std(proj1d_dc_icwt);
    max_proj1d_dc_icwt=max(proj1d_dc_icwt);
    snan=[max_proj1d_dc_icwt st_proj1d_dc_icwt (max_proj1d_dc_icwt)/(st_proj1d_dc_icwt)]; 
    mkdir(tot_snan_path_out,strcat('dm/','wavelet_filtered_abs_',num2str(cutoff),'MpcCut/'));
    dlmwrite(strcat(tot_snan_path_out,'dm/','wavelet_filtered_abs_',num2str(cutoff),'MpcCut/','_',num2str(find(str2num(char(redshift_list))==z)),'_snan_1dproj_cwt_z',num2str(z),'_data.txt'),snan,'delimiter','\t');
end

%tic;


end

