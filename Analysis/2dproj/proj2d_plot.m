function [  ] = proj2d_plot( path,spec,aux_path,filename,lenght_factor,resol_factor,pivot,rot_angle,lim) 
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



path_in=strcat(path,spec,aux_path);

cd('../preprocessing');

[ nodes_list redshift_list ] = preprocessing_many_nodes(path,spec,aux_path );

[ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in header i_node j_node k_node number_node_dim ] = preprocessing_nodes_all_but_phasespace( path,spec,aux_path,filename);

cd('../2dproj');

proj2d_data_out( path,spec,aux_path,filename,lenght_factor,resol_factor,pivot,rot_angle);
proj2d=dlmread(char(strcat(path_in,strcat('data/','2dproj/dc/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/'),'2dproj_z',num2str(z),'_data.txt')));

%cell_bins1d=[0:nc/(np*resol_factor):nc/lenght_factor];
%cell_bins1d(end)=[];
 
fig=figure('Visible', 'off');

hold on;

gcc_to_mpc=size_box/nc;
pvy=pivot(2)*gcc_to_mpc;
pvz=pivot(3)*gcc_to_mpc;

axis([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy -size_box/(2*lenght_factor)+size_box/(2)+pvz size_box/(2*lenght_factor)+size_box/(2)+pvz])
if (~ischar(lim))
    clims = lim;
    imagesc([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy],[ -size_box/(2*lenght_factor)+size_box/(2)+pvz size_box/(2*lenght_factor)+size_box/(2)+pvz],proj2d,clims);
else 
    imagesc([-size_box/(2*lenght_factor)+size_box/(2)+pvy size_box/(2*lenght_factor)+size_box/(2)+pvy],[ -size_box/(2*lenght_factor)+size_box/(2)+pvz size_box/(2*lenght_factor)+size_box/(2)+pvz],proj2d);
end
colorbar;
xlabel('$z(Mpc)$', 'interpreter', 'latex', 'fontsize', 20);
ylabel('$y(Mpc)$', 'interpreter', 'latex', 'fontsize', 20);
set(gca,'FontName','FixedWidth');
set(gca,'FontSize',16);
set(gca,'linewidth',2);
title({strcat('Density contrast of the 2d projection'),strcat('at z =',num2str(z),' for $G\mu=$ ',num2str(Gmu,'%.1E'))},'interpreter', 'latex', 'fontsize', 20);
hold off;

if (~ischar(lim))
    mkdir(path_in,strcat('plots/','2dproj/dc/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra_',strcat(num2str(lim(1)),'-',num2str(lim(2))),'lim','/'));
    saveas(fig,strcat(path_in,'plots/','2dproj/dc/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra_',strcat(num2str(lim(1)),'-',num2str(lim(2))),'lim','/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_z',num2str(z),'_plot.png'));
else
    mkdir(path_in,strcat('plots/','2dproj/dc/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra_','minmax','/'));
    saveas(fig,strcat(path_in,'plots/','2dproj/dc/',num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra_','minmax','/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_z',num2str(z),'_plot.png'));
end



end

