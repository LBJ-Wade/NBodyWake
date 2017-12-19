function [ cell_bins1d_y,cell_bins1d_z,count_sum] = proj2d_dm_data_out( root,root_out,spec,aux_path,aux_path_out,filename,lenght_factor,resol_factor,pivot,rot_angle,data_stream)
%Computes the 2d projections aconding to the input specifications and stores (and returns) the resulting data

%   (example) [ cell_bins1d_y,cell_bins1d_z,count_sum] = proj2d_dm_data_out('/home/asus/Dropbox/extras/storage/graham/small_res/','/home/asus/Dropbox/extras/storage/graham/small_res/data/','64Mpc_96c_48p_zi255_nowakem','/sample1001/','','0.000xv0.dat',1,1,[0,0,0],[0,0],[1,2]);


cd('../preprocessing');

[ nodes_list redshift_list ] = preprocessing_many_nodes(root,spec,aux_path );

[ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos ] = preprocessing_nodes( root,spec,aux_path,filename);

cell_bins1d_y=[(nc/2)-(nc/(2*lenght_factor))+pivot(2):nc/(np*resol_factor):(nc/2)+(nc/(2*lenght_factor))+pivot(2)];
cell_bins1d_z=[(nc/2)-(nc/(2*lenght_factor))+pivot(3):nc/(np*resol_factor):(nc/2)+(nc/(2*lenght_factor))+pivot(3)];
cell_bins1d_y(end)=[];
cell_bins1d_z(end)=[];
count_sum=zeros(numel(cell_bins1d_y),numel(cell_bins1d_z));

theta=rot_angle(1);
phi=rot_angle(2);

%for node = 1 : 1
for node = 1 : length(nodes_list)
    
    cell_bins1d_y=[(nc/2)-(nc/(2*lenght_factor))+pivot(2):nc/(np*resol_factor):(nc/2)+(nc/(2*lenght_factor))+pivot(2)];
    cell_bins1d_z=[(nc/2)-(nc/(2*lenght_factor))+pivot(3):nc/(np*resol_factor):(nc/2)+(nc/(2*lenght_factor))+pivot(3)];
    
    
    path_in=strcat(root,spec,aux_path);
    file_name = dir(strcat(path_in,num2str(z),'*xv',char(nodes_list(node)),'.dat'));
    filename=file_name.name;
    
    [ size_box nc np zi wake_or_no_wake multiplicity_of_files Gmu ziw z path_file_in Pos ] = preprocessing_nodes( root,spec,aux_path,filename);
    
    Pos=mod(Pos,nc);
    
    Pos(1,:)=Pos(1,:)-(nc/2)-pivot(1);
    Pos(2,:)=Pos(2,:)-(nc/2)-pivot(2);
    Pos(3,:)=Pos(3,:)-(nc/2)-pivot(3);
    
    Ry = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
    Rz = [cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0; 0 0 1];
    Pos=Rz*Pos;
    Pos=Ry*Pos;
    %Pos=Rz*Pos;
    
    liminf=-(1/(2*lenght_factor))*nc;
    limsup= (1/(2*lenght_factor))*nc;
    conditionsx=Pos(1,:)<=liminf|Pos(1,:)>=limsup;
    conditionsy=Pos(2,:)<=liminf|Pos(2,:)>=limsup;
    conditionsz=Pos(3,:)<=liminf|Pos(3,:)>=limsup;
    conditions=conditionsx|conditionsy|conditionsz;
    Pos(:,conditions)=[];
    
    Pos(1,:)=Pos(1,:)+(nc/2)+pivot(1);
    Pos(2,:)=Pos(2,:)+(nc/2)+pivot(2);
    Pos(3,:)=Pos(3,:)+(nc/2)+pivot(3);
    
    Pos=transpose(Pos);
    
    
    [count edges mid loc] = histcn(Pos,1,cell_bins1d_y,cell_bins1d_z);
    count=count(1:1,1:numel(cell_bins1d_y)-1,1:numel(cell_bins1d_z)-1);
    %     average=mean2(count);
    %     count=(count-average)/average;
    count=squeeze(count);
    
    %    cell_bins1d(end)=[];
    count_sum=count_sum+count;
end

% average=mean2(count_sum);
% count_sum=(count_sum-average)/average;

if ~ismember(0,data_stream)
    
    mkdir(root_out);
    mkdir(root_out,strcat(spec,aux_path));
    
    path_out=strcat(strcat(root_out,spec,aux_path),'data/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','2dproj/dm/');
    mkdir(strcat(root_out,spec,aux_path),strcat('data/',aux_path_out,num2str(lenght_factor),'lf_',num2str(resol_factor),'rf_',strcat(num2str(pivot(1)),'-',num2str(pivot(2)),'-',num2str(pivot(3))),'pv_',strcat(num2str(rot_angle(1)),'-',num2str(rot_angle(2))),'ra','/','2dproj/dm/'));
    
    
    mkdir(path_out,'dc/');
    
   
    if ismember(1,data_stream)        
        fileID = fopen(strcat(path_out,'dc/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_z',num2str(z),'_data.bin'),'w');
        fwrite(fileID,count_sum, 'float32','l');
        fclose(fileID);
    end

    if ismember(2,data_stream)
        dlmwrite(strcat(path_out,'dc/','_',num2str(find(str2num(char(redshift_list))==z)),'_2dproj_z',num2str(z),'_data.txt'),count_sum,'delimiter','\t');
    end
    
end


cd('../2dproj');

end



