function [  ] = displacement_evol_mem_fast_par_fix( root,root_data_out,root_plot_out,spec,aux_path,wake_type,num_cores)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% (example) []=displacement_evol_mem_fast_par( '/home/asus/Dropbox/extras/storage/graham/small_res/','/home/asus/Dropbox/extras/storage/graham/small_res/data/','/home/asus/Dropbox/extras/storage/graham/small_res/plot/','64Mpc_96c_48p_zi255_wakeGmu6t10m6zi10m','/sample1001/','test/',4)
% (example) []=displacement_evol_mem_fast_par( '/home/asus/Dropbox/extras/storage/graham/small_res/','/home/asus/Dropbox/extras/storage/graham/small_res/data/','/home/asus/Dropbox/extras/storage/graham/small_res/plot/','64Mpc_96c_48p_zi255_wakeGmu5t10m7zi63m','/sample1001/','',4)


% root='/home/asus/Dropbox/extras/storage/graham/small_res/'
% root_data_out='/home/asus/Dropbox/extras/storage/graham/small_res/data/'
% root_plot_out='/home/asus/Dropbox/extras/storage/graham/small_res/plot/'
% spec='64Mpc_96c_48p_zi255_wakeGmu5t10m7zi63m'
% aux_path='/sample1001/'
% wake_type=''
% num_cores=4


type_folder=wake_type;

myCluster = parcluster('local');
myCluster.NumWorkers=num_cores;
saveProfile(myCluster);

p = parpool(num_cores);

% 
% if wake_type==0
%    type_folder='' 
% end
% 
% if wake_type==1
%    type_folder='test/' 
% end
% 
% if wake_type==2
%    type_folder='no_vpert_in_wake_hard/' 
% end
% 
% if wake_type==3
%     type_folder='no_vpert_in_wake/'
% end
% 
% if wake_type==4
%     type_folder='half_lin_cutoff_half_tot_pert/'
% end
% 
% if wake_type==5
%     type_folder='quarter_lin_cutoff_half_tot_pert/'
% end
% %combination of 3 and 4
% 
% if wake_type==6
%     
%     type_folder='half_lin_cutoff_half_tot_pert_nvpwh/'
%     
% end
% 
% %combination of 3 and 5
% 
% if wake_type==7
%     
%     type_folder='quarter_lin_cutoff_half_tot_pert_nvpwh/'
%     
% end
% 
% if wake_type==8
%     
%     type_folder='half_lin_cutoff_half_tot_pert_nvpw/'
%     
% end
% 
% %combination of 3 and 5
% 
% if wake_type==9
%     
%     type_folder='quarter_lin_cutoff_half_tot_pert_nvpw/'
%     
% end

% mkdir(strcat(root_out))
mkdir(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/'))
mkdir(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/half/'))

mkdir(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/'))

mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/'))
mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/'))

cd('../../../preprocessing')

% test_particle_id=10000;

[ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw ] = preprocessing_from_spec( spec);
[~,redshift_list,nodes_list,~,~,~,~,~,~,~,~] = preprocessing_info(root,spec,strcat(aux_path ,type_folder));

tnp=np^3;

% for rds=1:length(redshift_list)
%    
%     displacement_info=tall(zeros(tnp));
%     
% end
% 
% create the empth files for the positions to be stored
% 
% for rds=1:length(redshift_list)
% 
%     filename_out=strcat(root_data_out,spec,aux_path,'check/displ/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_Check_Zel_pos_z',char(redshift_list(rds)),'.dat');
%     fid = fopen(filename_out,'w');
%     for node=1:length(nodes_list)
%         fwrite(fid,zeros(3,tnp/length(nodes_list)),'float32','l');        
%     end
%     fclose(fid);
% end

%stores the z positions of the particles for the no wake case

spec_nowake=strcat(string(size_box),'Mpc_',string(nc),'c_',string(np),'p_zi',string(zi),'_nowakem');

% for rds=1:length(redshift_list)
% 
%     filename_xv=cellstr(strcat(root,spec_nowake,aux_path,char(redshift_list(rds)),'xv',char(nodes_list),'.dat'));
%     xv_ds = fileDatastore(filename_xv,'ReadFcn',@read_bin,'FileExtensions','.dat');
%     xv=cell2mat(tall(xv_ds));
%     
%     filename_pid=cellstr(strcat(root,spec_nowake,aux_path,char(redshift_list(rds)),'PID',char(nodes_list),'.dat'));
%     pid_ds = fileDatastore(filename_pid,'ReadFcn',@read_pid,'FileExtensions','.dat');
%     pid=cell2mat(tall(pid_ds));
%     
%     pid_posZ_nowake=[pid;xv(:,3)];
%     
% end


for rds=1:length(redshift_list)
    % for rds=5:5
    
%     pos_z=[];
%     part_id=[];
    
    number_node_dim=nthroot(numel(nodes_list), 3);
    
    parfor node=1:length(nodes_list)

	filename_out=strcat(root_data_out,spec,aux_path,type_folder,'check/displ/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_node',char(nodes_list(node)),'_Check_Zel_wpid_posZ_displ_z',char(redshift_list(rds)),'.dat');
    fid_o = fopen(filename_out,'w');
    
    filename_out_half=strcat(root_data_out,spec,aux_path,type_folder,'check/displ/half/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_node',char(nodes_list(node)),'_Check_Zel_wpid_half_posZ_displ_z',char(redshift_list(rds)),'.dat');
    fid_o_half = fopen(filename_out_half,'w');
        
        filename=strcat(root,spec_nowake,aux_path,char(redshift_list(rds)),'xv',char(nodes_list(node)),'.dat');
        fid = fopen(filename);
        fread(fid, [12 1], 'float32','l') ;
        xv=fread(fid, [6 Inf], 'float32','l');
        fclose(fid);
        
        node_ID=node-1;
        k_node=floor(node_ID/number_node_dim^2);
        
        pos_z=xv(3,:)+(nc/number_node_dim)*k_node;
        
        particle_ID_cat=strcat(root,spec_nowake,aux_path,char(redshift_list(rds)),'PID',char(nodes_list(node)),'.dat');
        fid = fopen(particle_ID_cat);
        fread(fid,6,'int64');
        part_id=fread(fid,[1 Inf],'int64');
        fclose(fid);
        
        [sorted_ sort_inx]=sort(part_id);
        sorted_pos_z=pos_z(sort_inx);
%         pid_posZ=[part_id(sort_inx);pos_z(sort_inx)];                
        
        
        %now with wake
        
        filename=strcat(root,spec,aux_path,type_folder,char(redshift_list(rds)),'xv',char(nodes_list(node)),'.dat');
        fid = fopen(filename);
        fread(fid, [12 1], 'float32','l') ;
        xv=fread(fid, [6 Inf], 'float32','l');
        fclose(fid);
        
        node_ID=node-1;
        k_node=floor(node_ID/number_node_dim^2);
        
        pos_z=xv(3,:)+(nc/number_node_dim)*k_node;
        
        particle_ID_cat=strcat(root,spec,aux_path,type_folder,char(redshift_list(rds)),'PID',char(nodes_list(node)),'.dat');
        fid = fopen(particle_ID_cat);
        fread(fid,6,'int64');
        part_id=fread(fid,[1 Inf],'int64');
        fclose(fid);

        [sorted_w_ sort_inx]=sort(part_id);
        sorted_pos_z_w=pos_z(sort_inx);
%         pid_posZ_w=[part_id(sort_inx);pos_z(sort_inx)];  
        
        
%         find(sorted_w_(:)==sorted_
        
%         displacement=pid_posZ_w(:,2)-pid_posZ(find(sorted_w_(:)==sorted_),2);

%         lent_out=length(find(sorted_w_(:)==sorted_));
        [comom_ID,com_id_w,com_id_nw]=intersect(sorted_w_,sorted_);
        part_z_nw=sorted_pos_z(com_id_nw);
        part_z_w=sorted_pos_z_w(com_id_w);
        displac_list=part_z_w-part_z_nw;
        displac_list(displac_list>nc/2)=displac_list(displac_list>nc/2)-nc;
        displac_list(displac_list<-nc/2)=displac_list(displac_list<-nc/2)+nc;
        
        fwrite(fid_o,[comom_ID;part_z_w;displac_list],'float32','l');
    fclose(fid_o);  
    
        comom_ID_half=comom_ID(part_z_w>nc/4&part_z_w<3*nc/4);
        part_z_w_half=part_z_w(part_z_w>nc/4&part_z_w<3*nc/4);
        displac_list_half=displac_list(part_z_w>nc/4&part_z_w<3*nc/4);
        
        comom_ID_half=[comom_ID_half 0];
        part_z_w_half=[part_z_w_half nc/2];
        displac_list_half=[displac_list_half 0];
        
        
        fwrite(fid_o_half,[comom_ID_half;part_z_w_half;displac_list_half],'float32','l');
        fclose(fid_o_half);
    
    end

end





cd('../wake_detection/consist_check/Zeldovich/')


for rds=1:length(redshift_list)
    filename_out=cellstr(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_node',char(nodes_list),'_Check_Zel_wpid_posZ_displ_z',char(redshift_list(rds)),'.dat'));
    pos_diff_ds = fileDatastore(filename_out,'ReadFcn',@read_bin,'FileExtensions','.dat');
    pos_diff=cell2mat(tall(pos_diff_ds));
    
    fig2=figure('Visible', 'off');
    h2=histogram2(mod(pos_diff(:,2),nc)*size_box/nc,pos_diff(:,3)*size_box/nc,nc/2,'DisplayStyle','tile','ShowEmptyBins','on');colorbar;
    xlabel('Position (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/'));
    saveas(fig2,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displacement_z',char(redshift_list(rds)),'_plot.png'));
    
    fig2_=figure('Visible', 'off');
    imagesc((h2.XBinEdges'),h2.YBinEdges',flip(log(h2.Values')));colorbar;
    xlabel('Position (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    saveas(fig2_,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displacement_z',char(redshift_list(rds)),'_plot_log.png'));
    close(fig2_);
        
    close(fig2);
    
    fig=figure('Visible', 'off');
    h=histogram(pos_diff(:,3)*size_box/nc);
    hold on
    set(gca,'YScale','log')
    ylim ([0.9 inf]); 
    xlabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Number Count', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/hist/'));    
    saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/hist/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displacement_z',char(redshift_list(rds)),'_plot.png'));
    close(fig);
    
    posit_values=pos_diff(pos_diff(:,3)>0,3);
    mn_pos(rds)=gather(mean(posit_values));
    std_pos(rds)=gather(std(posit_values,1));
    
    negat_values=pos_diff(pos_diff(:,3)<0,3);
    mn_neg(rds)=gather(mean(negat_values));
    std_neg(rds)=gather(std(negat_values,1));
    
end

for rds=1:length(redshift_list)
    filename_out=cellstr(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/half/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_node',char(nodes_list),'_Check_Zel_wpid_half_posZ_displ_z',char(redshift_list(rds)),'.dat'));
    pos_diff_ds = fileDatastore(filename_out,'ReadFcn',@read_bin,'FileExtensions','.dat');
    pos_diff=cell2mat(tall(pos_diff_ds));
    
    fig2=figure('Visible', 'off');
    h2=histogram2(mod(pos_diff(:,2),nc)*size_box/nc,pos_diff(:,3)*size_box/nc,nc/4,'DisplayStyle','tile','ShowEmptyBins','on');
    colorbar;
    xlabel('Position (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/'));
    saveas(fig2,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displacement_z',char(redshift_list(rds)),'_plot.png'));
    
    fig2_=figure('Visible', 'off');
    imagesc((h2.XBinEdges'),h2.YBinEdges',flip(log(h2.Values')));colorbar;
    xlabel('Position (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    saveas(fig2_,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displacement_z',char(redshift_list(rds)),'_plot_log.png'));    
    close(fig2_);
    
    fig=figure('Visible', 'off');
    h=histogram(pos_diff(:,3)*size_box/nc);
    hold on
    set(gca,'YScale','log')
    ylim ([0.9 inf]);
    xlabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Number Count', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/hist/'));    
    saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/hist/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displacement_z',char(redshift_list(rds)),'_plot.png'));
    close(fig);
    
    half_posit_values=pos_diff(pos_diff(:,3)>0,3);
    half_mn_pos(rds)=gather(mean(half_posit_values));
    half_std_pos(rds)=gather(std(half_posit_values,1));
    
    half_negat_values=pos_diff(pos_diff(:,3)<0,3);
    half_mn_neg(rds)=gather(mean(half_negat_values));
    half_std_neg(rds)=gather(std(half_negat_values,1));
    
    Pos_Bin_Centers=mean([h2.XBinEdges(1:end-1);h2.XBinEdges(2:end)]);
    Disp_Bin_Centers=mean([h2.YBinEdges(1:end-1);h2.YBinEdges(2:end)]);
    Hist2_val=h2.Values;
    close(fig2);
    
    mean_disp_per_slice=(Hist2_val*Disp_Bin_Centers')./sum(Hist2_val')';     
    mean_disp_per_slice(isinf(mean_disp_per_slice)|isnan(mean_disp_per_slice)) = 0;
    fig=figure('Visible', 'off');
    plot(Pos_Bin_Centers,mean_disp_per_slice)
    xlabel('Position (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/'));    
    saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displ_z',char(redshift_list(rds)),'_plot.png'));    
    close(fig);
    
    fig=figure('Visible', 'off');
    h=histogram(mean_disp_per_slice)
    hold on
    set(gca,'YScale','log')
    ylim ([0.9 inf]);
    xlabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Number Count', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/hist/'));    
    saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/hist/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_displ_z',char(redshift_list(rds)),'_plot.png'));    
    close(fig);
    
    half_mp_mn(rds)=(mean(abs(mean_disp_per_slice)));
    half_mp_std(rds)=(std(abs(mean_disp_per_slice)));
    
    half_mp_med(rds)=(median(abs(mean_disp_per_slice)));
    
    mean_disp_per_slice_=round(mean_disp_per_slice,3);
    mean_disp_per_slice_(mean_disp_per_slice_==0)=[];
    half_mp_mod(rds)=(mode(abs(mean_disp_per_slice_)));
    
%     indx_quart=[length(Pos_Bin_Centers)/8:3*length(Pos_Bin_Centers)/8,5*length(Pos_Bin_Centers)/8:7*length(Pos_Bin_Centers)/8];
    indx_quart=[length(Pos_Bin_Centers)/8:2*length(Pos_Bin_Centers)/8,6*length(Pos_Bin_Centers)/8:7*length(Pos_Bin_Centers)/8];
    Pos_Bin_Centers_quart=Pos_Bin_Centers(indx_quart);
    mean_vel_per_slice_quart=mean_disp_per_slice(indx_quart);
    fig=figure('Visible', 'off');
    plot(Pos_Bin_Centers_quart,mean_vel_per_slice_quart);
    xlabel('Position (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/'));
    saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_vel_z',char(redshift_list(rds)),'_plot.png'));        
    close(fig);
    
    fig=figure('Visible', 'off');
    h=histogram(mean_vel_per_slice_quart);
    hold on
    set(gca,'YScale','log')
    ylim ([0.9 inf]);
    xlabel('Induced Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
    ylabel('Number Count', 'interpreter', 'latex', 'fontsize', 20);
    set(gca,'FontName','FixedWidth');
    set(gca,'FontSize',16);
    set(gca,'linewidth',2);
    mkdir(strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/hist/'));
    saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/hist/','_',num2str(find(str2num(char(redshift_list))==str2num(char(redshift_list(rds))))),'_vel_z',char(redshift_list(rds)),'_plot.png'));        
    close(fig);
    
    quart_mp_mn(rds)=(mean(abs(mean_vel_per_slice_quart)));
    quart_mp_std(rds)=(std(abs(mean_vel_per_slice_quart)));
    
    quart_mp_med(rds)=(median(abs(mean_vel_per_slice_quart)));
    
    mean_displ_per_slice_quart_=round(mean_vel_per_slice_quart,3);
    mean_displ_per_slice_quart_(mean_displ_per_slice_quart_==0)=[];
    quart_mp_mod(rds)=(mode(abs(mean_displ_per_slice_quart_)));
    
    
end

cd('../../../../parameters')
    
for rds=1:length(redshift_list)    
    [ ~, displacement, ~ ] = wake( Gmu,str2num(char(redshift_list(rds))));
    wake_displacement_zeld(rds,1)=displacement;
    
end

cd('../Analysis/wake_detection/consist_check/Zeldovich/')


%plot positive values

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,mn_pos*size_box/nc,std_pos*size_box/nc)
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon: positive')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/','_Check_Zel_pos','.png'));
dlmwrite(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/','_Check_Zel_pos.txt'),[(str2num(char(redshift_list))+1).^-1,mn_pos'*size_box/nc,std_pos'*size_box/nc],'delimiter','\t')


%plot negative values

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,abs(mn_neg)*size_box/nc,std_neg*size_box/nc)
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon: negative')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/','_Check_Zel_neg','.png'));
dlmwrite(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/','_Check_Zel_neg.txt'),[(str2num(char(redshift_list))+1).^-1,abs(mn_neg')*size_box/nc,std_neg'*size_box/nc],'delimiter','\t')


%plot total values

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,((mn_pos+abs(mn_neg))/2)*size_box/nc,((std_pos+std_neg)/2)*size_box/nc)
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/','_Check_Zel','.png'));
dlmwrite(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/','_Check_Zel.txt'),[(str2num(char(redshift_list))+1).^-1,((mn_pos'+abs(mn_neg'))/2)*size_box/nc,((std_pos'+std_neg')/2)*size_box/nc],'delimiter','\t')



%do the same with the half_box

%plot positive values

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,half_mn_pos*size_box/nc,half_std_pos*size_box/nc)
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon: positive')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/','_Check_Zel_pos','.png'));
dlmwrite(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/half/','_Check_Zel_pos.txt'),[(str2num(char(redshift_list))+1).^-1,half_mn_pos'*size_box/nc,half_std_pos'*size_box/nc],'delimiter','\t')

%plot negative values

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,abs(half_mn_neg)*size_box/nc,half_std_neg*size_box/nc)
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon: negative')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/','_Check_Zel_neg','.png'));
dlmwrite(strcat(root_data_out,spec,aux_path,type_folder,'check/displ/half/','_Check_Zel_neg.txt'),[(str2num(char(redshift_list))+1).^-1,abs(half_mn_neg')*size_box/nc,half_std_neg'*size_box/nc],'delimiter','\t')


%plot total values

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,((half_mn_pos+abs(half_mn_neg))/2)*size_box/nc,((half_std_pos+half_std_neg)/2)*size_box/nc)
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/','_Check_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_totmn_Zel.txt'),[(str2num(char(redshift_list))+1).^-1,((half_mn_pos'+abs(half_mn_neg'))/2)*size_box/nc,((half_std_pos'+half_std_neg')/2)*size_box/nc],'delimiter','\t')














%same for half plot

%plot total values using mean_position way

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,(half_mp_mn),(half_mp_std))
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/','_Check_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_mn_Zel.txt'),[(str2num(char(redshift_list))+1).^-1,(half_mp_mn'),(half_mp_std')],'delimiter','\t')

%plot total values using mean_position median way

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,(half_mp_med),(half_mp_std))
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/','_Check_med_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_med_Zel.txt'),[(str2num(char(redshift_list))+1).^-1,(half_mp_med'),(half_mp_std')],'delimiter','\t')


%plot total values using mean_position, mode way

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,(half_mp_mod),(half_mp_std))
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/mean_pos/','_Check_mod_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_mod_Zel.txt'),[(str2num(char(redshift_list))+1).^-1,(half_mp_mod'),(half_mp_std')],'delimiter','\t')








%same for quart plot

%plot total values using mean_position way

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,(quart_mp_mn),(quart_mp_std))
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/','_Check_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_mn_Zel_quart.txt'),[(str2num(char(redshift_list))+1).^-1,(quart_mp_mn'),(quart_mp_std')],'delimiter','\t')

%plot total values using mean_position median way

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,(quart_mp_med),(quart_mp_std))
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/','_Check_med_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_med_Zel_quart.txt'),[(str2num(char(redshift_list))+1).^-1,(quart_mp_med'),(quart_mp_std')],'delimiter','\t')


%plot total values using mean_position, mode way

fig=figure('Visible', 'off');
% fig=figure;
errorbar((str2num(char(redshift_list))+1).^-1,(quart_mp_mod),(quart_mp_std))
hold on
plot((str2num(char(redshift_list))+1).^-1,wake_displacement_zeld)

%xlim ([-inf inf]);
xlim ([0.08 0.26]);    %for paper
xlabel('Scale factor', 'interpreter', 'latex', 'fontsize', 20);
ylabel('Displacement (Mpc/h)', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Displacement comparizon')},'interpreter', 'latex', 'fontsize', 20);
legend(strcat('G\mu = ',num2str(Gmu,'%.1E')),"Zel'dovich",'Location','northwest')
hold off;

saveas(fig,strcat(root_plot_out,spec,aux_path,type_folder,'check/displ/half/quart/','_Check_mod_Zel','.png'));
dlmwrite(strcat(root_data_out,'check/',spec,aux_path,type_folder,'check/displ/half/','_Check_mod_Zel_quart.txt'),[(str2num(char(redshift_list))+1).^-1,(quart_mp_mod'),(quart_mp_std')],'delimiter','\t')








delete(gcp('nocreate'))

end