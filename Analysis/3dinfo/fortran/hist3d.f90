!! cic_power.f90 Parallelized: Hugh Merz Jun 15, 2005, modified by
!Disrael Cunha 2018
!! This version is used to calculate the power spectrum of the
!initial conditions
!! Compile with: mpif77 -fpp -g -w -O3 -axN cic_power.f90 -o
!!cic_power  -L/home/merz/lib/fftw-2.1.5_intel8/lib
!!-I/home/merz/lib/fftw-2.1.5_intel8/include -lsrfftw_mpi -lsrfftw
!!-lsfftw_mpi -lsfftw -lm -ldl

program hist3d
        implicit none
        include 'mpif.h'

! frequently changed parameters are found in this header file:
        include 'parameters'

  character(len=*), parameter ::checkpoints='checkpoints'

  !! nc is the number of cells per box length
  integer, parameter :: hc=nc/2
  real, parameter    :: ncr=nc
  real, parameter    :: hcr=hc
    
  !! np is the number of particles
  !! np should be set to nc (1:1), hc (1:2), or qc (1:4)
  integer, parameter :: np= hc!nc
  real, parameter    :: npr=np

  !! internals
  integer, parameter :: max_checkpoints=100
  real, dimension(max_checkpoints) :: z_checkpoint
  integer num_checkpoints, cur_checkpoint
            
  !! internal parallelization parameters
  integer(4), parameter :: nc_node_dim = nc/nodes_dim
  integer(4), parameter :: np_node_dim = np/nodes_dim
  integer(4), parameter :: np_buffer = 0.35*np_node_dim**3
  integer(4), parameter :: max_np = np_node_dim**3 + np_buffer
  integer(4), parameter :: nodes = nodes_dim * nodes_dim * nodes_dim
  integer(4), parameter :: nodes_slab = nodes_dim * nodes_dim
  integer(4), parameter :: nc_slab = nc / nodes
                            
  !! parallelization variables
  integer(4), dimension(0:nodes_dim-1,0:nodes_dim-1) :: slab_neighbor
  integer(4), dimension(6) :: cart_neighbor
  integer(4), dimension(3) :: slab_coord, cart_coords
  integer(4) :: slab_rank, mpi_comm_cart, cart_rank, rank, ierr
                                      
  integer(4) :: np_local
                                        
  integer(8) :: plan, iplan
                                          
  logical :: firstfftw
                                            
! :: simulation variables
                                            
  !! Other parameters
  real, parameter :: pi=3.14159
                                                
#ifdef KAISER
  real, parameter :: a = 1/(1+z_i)
#endif

  !! Dark matter arrays
  real, dimension(6,max_np) :: xvp
  real, dimension(3,np_buffer) :: xp_buf
  real, dimension(3*np_buffer) :: send_buf, recv_buf

  !! Power spectrum arrays
  real, dimension(2,nc) :: pkdm
  real, dimension(3,nc) :: pktsum,pksum
#ifdef PLPLOT
  real*8, dimension(3,nc) :: pkplot
#endif

  !! arrays
  real, dimension(nc_node_dim,nc_node_dim,nc_node_dim) :: cube
  real, dimension(nc_node_dim,nc_node_dim,nc_slab,0:nodes_slab-1) :: recv_cube
  real, dimension(nc+2,nc,nc_slab) :: slab, slab_work
  real, dimension(0:nc_node_dim+1,0:nc_node_dim+1,0:nc_node_dim+1) :: den
  real, dimension(0:nc_node_dim+1,0:nc_node_dim+1) :: den_buf

  !! Equivalence arrays to save memory
  equivalence (den,slab_work,recv_cube,xp_buf)
  equivalence (xvp,cube,slab)
  equivalence (send_buf,den_buf)
  equivalence (recv_buf,pktsum,pkdm)

  !! Common block
#ifdef PLPLOT
  common xvp,den,recv_buf,send_buf,pkplot,pksum
#else
  common xvp,den,recv_buf,send_buf,pksum
#endif


!!---start main--------------------------------------------------------------!!

  call mpi_initialize
  if (rank == 0) call writeparams
  call read_checkpoint_list
  do cur_checkpoint=1,num_checkpoints
    call initvar
    call read_particles 
    call pass_particles   
    call darkmatter
  enddo

!  call initvar
!  call read_particles
  call mpi_finalize(ierr)

contains

!!---------------------------------------------------------------------------!!

  subroutine mpi_initialize
    implicit none

    integer(4) :: i, j, nodes_returned
    integer(4) :: dims(3), ndim
    logical :: periodic(3), reorder

!! set up global mpi communicator

    call mpi_init(ierr)
    if (ierr /= mpi_success) call mpi_abort(mpi_comm_world,ierr,ierr)

    call mpi_comm_size(mpi_comm_world,nodes_returned,ierr)
    if (ierr /= mpi_success) call mpi_abort(mpi_comm_world,ierr,ierr)
    if (nodes_returned /= nodes ) then
      write(*,*) 'hist3d compiled for a different number of nodes'
      write(*,*) 'mpirun nodes=',nodes_returned,'hist3d nodes=',nodes
      call mpi_abort(mpi_comm_world,ierr,ierr)
    endif
    if (mod(nc,nodes) /= 0) then
      write(*,*) 'cannot evenly decompose mesh into slabs'
      write(*,*) 'nc=',nc,'nodes=',nodes,'mod(nc,nodes) != 0'
      call mpi_abort(mpi_comm_world,ierr,ierr)
    endif
    call mpi_comm_rank(mpi_comm_world,rank,ierr)
    if (ierr /= mpi_success) call mpi_abort(mpi_comm_world,ierr,ierr)

    if (rank==0) then
      write(*,*) 'hist3d running on',nodes,'nodes'
      write(*,*) 'using cubic distribution:',nodes_dim,'nodes per dimension'
      write(*,*) nc,'cells in mesh'
    endif

!! calculate coordinates within slab for cube processes

    slab_coord(3) = rank / nodes_slab
    slab_rank = rank - slab_coord(3) * nodes_slab
    slab_coord(2) = slab_rank / nodes_dim
    slab_coord(1) = slab_rank - slab_coord(2) * nodes_dim
    do j = 0, nodes_dim - 1
      do i = 0, nodes_dim - 1
        slab_neighbor(i,j) = i + j * nodes_dim + slab_coord(3) &
                           * nodes_slab
      enddo
    enddo

!! create cartesian communicator based on cubic decomposition

    dims(:) = nodes_dim
    periodic(:) = .true.
    reorder = .false.
    ndim = 3

    call mpi_cart_create(mpi_comm_world, ndim,dims, periodic, &
                       reorder, mpi_comm_cart, ierr)
    call mpi_comm_rank(mpi_comm_cart, cart_rank, ierr)
    call mpi_cart_coords(mpi_comm_cart, cart_rank, ndim,  &
                         cart_coords, ierr)

!! cart_neighbor(1) -> down (negative z)
!! cart_neighbor(2) -> up (positive z)
!! cart_neighbor(3) -> back (negative y)
!! cart_neighbor(4) -> front (positive y)
!! cart_neighbor(5) -> left (negative x)
!! cart_neighbor(6) -> right (positive x)

    do i = 0, ndim-1
      call mpi_cart_shift(mpi_comm_cart, i, 1, cart_neighbor(2*(i+1)-1), &
                          cart_neighbor(2*(i+1)), ierr)
    enddo

#ifdef DEBUG_LOW
  do i=0,nodes-1
    if (i==rank) write(*,'(8i4)') rank,cart_rank,cart_neighbor
    call mpi_barrier(mpi_comm_world,ierr)
  enddo
#endif

  end subroutine mpi_initialize

!!---------------------------------------------------------------------------!!

  subroutine read_checkpoint_list
!! read in list of checkpoints to calculate spectra for
    implicit none

    integer :: i,fstat

    if (rank == 0) then
      open(11,file=checkpoints,status='old',iostat=fstat)
      if (fstat /= 0) then
        print *,'error opening checkpoint list file'
        print *,'rank',rank,'file:',checkpoints
        call mpi_abort(mpi_comm_world,ierr,ierr)
      endif
      do num_checkpoints=1,max_checkpoints
        read(unit=11,err=51,end=41,fmt='(f20.10)') z_checkpoint(num_checkpoints)
      enddo
  41  num_checkpoints=num_checkpoints-1
  51  close(11)
      print *,'checkpoints to recompose:'
      do i=1,num_checkpoints
        write(*,'(f5.1)') z_checkpoint(i)
      enddo
    endif

    call mpi_bcast(num_checkpoints,1,mpi_integer,0,mpi_comm_world,ierr)

  end subroutine read_checkpoint_list

!!---------------------------------------------------------------------------!!

  subroutine read_particles
    implicit none

    real z_write,np_total
    integer i,j,fstat, blocksize, nplow, nphigh, num_writes
    character(len=7) :: z_string
    character(len=4) :: rank_string
    character(len=100) :: check_name

    !! these are unnecessary headers from the checkpoint
    real(4) :: a,t,tau,dt_f_acc,dt_c_acc,dt_pp_acc,mass_p
    integer(4) :: nts,sim_checkpoint,sim_projection,sim_halofind

!! generate checkpoint names on each node
    if (rank==0) then
      z_write = z_checkpoint(cur_checkpoint)
      print *,'calculating spectrum for z=',z_write
    endif

    call mpi_bcast(z_write,1,mpi_real,0,mpi_comm_world,ierr)

    write(z_string,'(f7.3)') z_write
    z_string=adjustl(z_string)

    write(rank_string,'(i4)') rank
    rank_string=adjustl(rank_string)

    if(z_write .eq. z_i) then
       check_name=ic_path//'xv'//rank_string(1:len_trim(rank_string))//'.ic'
    else
       check_name=output_path//z_string(1:len_trim(z_string))//'xv'// &
               rank_string(1:len_trim(rank_string))//'.dat'
    endif
!! open checkpoint    
!#ifdef BINARY
!    open(unit=21,file=check_name,status='old',iostat=fstat,form='binary')
!#else
!    open(unit=21,file=check_name,status='old',iostat=fstat,form='unformatted')
!#endif

    open(unit=21,file=check_name,status="old",iostat=fstat,access="stream")

    if (fstat /= 0) then
      write(*,*) 'error opening checkpoint'
      write(*,*) 'rank',rank,'file:',check_name
      call mpi_abort(mpi_comm_world,ierr,ierr)
    endif

!! read in checkpoint header data
    if(z_write .eq. z_i)then
       read(21) np_local
       a = 1.0/(1.0 + z_i)
    else
#ifdef PPINT
    read(21) np_local,a,t,tau,nts,dt_f_acc,dt_pp_acc,dt_c_acc,sim_checkpoint, &
               sim_projection,sim_halofind,mass_p
#else
    read(21) np_local,a,t,tau,nts,dt_f_acc,dt_c_acc,sim_checkpoint, &
               sim_projection,sim_halofind,mass_p
#endif
    endif

    if (np_local > max_np) then
      write(*,*) 'too many particles to store'
      write(*,*) 'rank',rank,'np_local',np_local,'max_np',max_np
      call mpi_abort(mpi_comm_world,ierr,ierr)
    endif

!! tally up total number of particles
    call mpi_reduce(real(np_local,kind=4),np_total,1,mpi_real, &
                         mpi_sum,0,mpi_comm_world,ierr)
    if (rank == 0) write(*,*) 'number of particles =', int(np_total,8)

    !--------------------
    if(z_write .eq. z_i)then
    !read as IC:
       do j=1,np_local
         read(21) xvp(:,j)
       enddo
    else
#ifdef BINARY
       read(21) xvp(:,:np_local)
#else
       blocksize = (32*1024*1024)/24
       num_writes = np_local/blocksize+1
       do i=1,num_writes
         nplow=(i-1)*blocksize+1
         nphigh=min(i*blocksize,np_local)
   !!      print *,rank,nplow,nphigh,np_local
         do j=nplow,nphigh
           read(21) xvp(:,j)
         enddo
       enddo
#endif
    endif
!----------
    close(21)

#ifdef KAISER

    !Red Shift Distortion: x_z -> x_z +  v_z/H(Z)   
    !Converting seconds into simulation time units
    !cancels the H0...

    xvp(3,:)=xvp(3,:) + xvp(6,:)*1.5/sqrt(a*(1+a*(1-omega_m-omega_l)/omega_m + omega_l/omega_m*a**3))

    call pass_particles

    if(rank==0) then
       write(*,*) '**********************'
       write(*,*) 'Included Kaiser Effect'
       write(*,*) 'Omega_m =', omega_m, 'a =', a
       !write(*,*) '1/H(z) =', 1.5*sqrt(omegam/cubepm_a)
       write(*,*) '1/H(z) =', 1.5/sqrt(a*(1+a*(1-omega_m-omega_l)/omega_m + omega_l/omega_m*a**3))
       write(*,*) '**********************'
    endif
#endif

  end subroutine read_particles


!!---------------------------------------------------------------------------!!

  subroutine writeparams
    implicit none

    real time1,time2
    call cpu_time(time1)

    write(*,*) 'nodes   ', nodes
    write(*,*) 'nc      ', nc
    write(*,*) 'np      ', np
    write(*,*) 'np total',int(np,kind=8)**3
    write(*,*) 'box      ',box
    write(*,*)

    call cpu_time(time2)
    time2=time2-time1
    write(*,"(f8.2,a)") time2,'  Called write params'
    return
  end subroutine writeparams

!!------------------------------------------------------------------!!

 subroutine darkmatter
    implicit none
    integer :: i,j,k, fstat
    integer :: i1,j1,k1
    real    :: d,dmin,dmax,sum_dm,sum_dm_local,dmint,dmaxt,z_write
    real*8  :: dsum,dvar,dsumt,dvart
    real, dimension(3) :: dis
    character(len=7) :: z_string
    character(len=4) :: rank_string
    character(len=100) :: check_name


    real time1,time2
    call cpu_time(time1)

    !! Initialized density field to be zero
    !! could do OMP loop here
    do k=0,nc_node_dim+1
       den(:,:,k)=0
    enddo

    !! Assign masses to grid to compute dm power spectrum
    call cicmass

    !! have to accumulate buffer density 
!   call mesh_buffer
    cube=den(1:nc_node_dim,1:nc_node_dim,1:nc_node_dim)

!#ifdef write_den
!! generate checkpoint names on each node
    if (rank==0) then
       z_write = z_checkpoint(cur_checkpoint)
       print *,'Wrinting density to file for z = ',z_write
    endif

    call mpi_bcast(z_write,1,mpi_real,0,mpi_comm_world,ierr)

    write(z_string,'(f7.3)') z_write
    z_string=adjustl(z_string)
    write(rank_string,'(i4)') rank
    rank_string=adjustl(rank_string)

!#ifdef KAISER
!    check_name=output_path//z_string(1:len_trim(z_string))//'den'// &
!               rank_string(1:len_trim(rank_string))//'-rsd.dat'
!#else 
    check_name=output_path//z_string(1:len_trim(z_string))//'den'// &
               rank_string(1:len_trim(rank_string))//'.dat'
!#endif

!! open and write density file   
!#ifdef BINARY
!    open(unit=21,file=check_name,status='replace',iostat=fstat,form='binary')
!#else
!    open(unit=21,file=check_name,status='replace',iostat=fstat,form='unformatted')
!#endif

!open(unit=21,file=check_name,status="old",iostat=fstat,access="stream")
open(unit=21,file=check_name,status="replace",iostat=fstat,access="stream")

    if (fstat /= 0) then
      write(*,*) 'error opening density file'
      write(*,*) 'rank',rank,'file:',check_name
      call mpi_abort(mpi_comm_world,ierr,ierr)
    endif

    write(21) cube
!#endif

    sum_dm_local=sum(cube)
    call mpi_reduce(sum_dm_local,sum_dm,1,mpi_real,mpi_sum,0,mpi_comm_world,ierr)
    if (rank == 0) print *,'DM total mass=',sum_dm

    !! Convert dm density field to delta field
    dmin=0
    dmax=0
    dsum=0
    dvar=0

    do k=1,nc_node_dim
       do j=1,nc_node_dim
          do i=1,nc_node_dim
             cube(i,j,k)=cube(i,j,k)-1.0
             d=cube(i,j,k)
             dsum=dsum+d
             dvar=dvar+d*d
             dmin=min(dmin,d)
             dmax=max(dmax,d)
          enddo
       enddo
    enddo

    call mpi_reduce(dsum,dsumt,1,mpi_double_precision,mpi_sum,0,mpi_comm_world,ierr)
    call mpi_reduce(dvar,dvart,1,mpi_double_precision,mpi_sum,0,mpi_comm_world,ierr)
    call mpi_reduce(dmin,dmint,1,mpi_real,mpi_min,0,mpi_comm_world,ierr)
    call mpi_reduce(dmax,dmaxt,1,mpi_real,mpi_max,0,mpi_comm_world,ierr)

    if (rank==0) then
      dsum=dsumt/real(nc)**3
      dvar=sqrt(dvart/real(nc)**3)
      write(*,*)
      write(*,*) 'DM min    ',dmint
      write(*,*) 'DM max    ',dmaxt
      write(*,*) 'Delta sum ',real(dsum,8)
      write(*,*) 'Delta var ',real(dvar,8)
      write(*,*)
    endif

    !! Forward FFT dm delta field
!    call cp_fftw(1)

    !! Compute dm power spectrum
!    call powerspectrum(slab,pkdm)

!    call cpu_time(time2)
!    time2=(time2-time1)
    if (rank == 0) write(*,"(f8.2,a)") time2,'  Called dm'
    return
  end subroutine darkmatter

!!------------------------------------------------------------------!!



  subroutine pass_particles
    implicit none

    integer i,pp,np_buf,np_exit,npo,npi
    integer*8 np_final
    real x(3),lb,ub
    integer, dimension(mpi_status_size) :: status,sstatus,rstatus
    integer :: tag,srequest,rrequest,sierr,rierr
    real(4), parameter :: eps = 1.0e-03

    lb=0.0
    ub=real(nc_node_dim)

    np_buf=0
    pp=1
    do
      if (pp > np_local) exit
      x=xvp(:3,pp)
      if (x(1) < lb .or. x(1) >= ub .or. x(2) < lb .or. x(2) >= ub .or. &
          x(3) < lb .or. x(3) >= ub ) then
!        write (*,*) 'PARTICLE OUT',xv(:,pp)
        np_buf=np_buf+1
        if (np_buf > np_buffer) then
          print *,rank,'np_buffer =',np_buffer,'exceeded - np_buf =',np_buf
          call mpi_abort(mpi_comm_world,ierr,ierr)
        endif
        xp_buf(:,np_buf)=xvp(:3,pp)
        xvp(:,pp)=xvp(:,np_local)
        np_local=np_local-1
        cycle
      endif
      pp=pp+1
    enddo

    call mpi_reduce(np_buf,np_exit,1,mpi_integer,mpi_sum,0, &
                    mpi_comm_world,ierr)

#ifdef DEBUG
    do i=0,nodes-1
      if (rank==i) print *,rank,'np_exit=',np_buf
      call mpi_barrier(mpi_comm_world,ierr)
    enddo
#endif 

    if (rank == 0) print *,'total exiting particles =',np_exit

! pass +x

    tag=11
    npo=0
    pp=1
    do
      if (pp > np_buf) exit
      if (xp_buf(1,pp) >= ub) then
        npo=npo+1
        send_buf((npo-1)*3+1:npo*3)=xp_buf(:,pp)
        xp_buf(:,pp)=xp_buf(:,np_buf)
        np_buf=np_buf-1
        cycle
      endif
      pp=pp+1
    enddo

#ifdef DEBUG
    do i=0,nodes-1
      if (rank==i) print *,rank,'np_out=',npo
      call mpi_barrier(mpi_comm_world,ierr)
    enddo
#endif 

    npi = npo

    call mpi_sendrecv_replace(npi,1,mpi_integer,cart_neighbor(6), &
                              tag,cart_neighbor(5),tag,mpi_comm_world, &
                              status,ierr)

    call mpi_isend(send_buf,npo*3,mpi_real,cart_neighbor(6), &
                   tag,mpi_comm_world,srequest,sierr)
    call mpi_irecv(recv_buf,npi*3,mpi_real,cart_neighbor(5), &
                   tag,mpi_comm_world,rrequest,rierr)
    call mpi_wait(srequest,sstatus,sierr)
    call mpi_wait(rrequest,rstatus,rierr)

    do pp=1,npi
      xp_buf(:,np_buf+pp)=recv_buf((pp-1)*3+1:pp*3)
      xp_buf(1,np_buf+pp)=max(xp_buf(1,np_buf+pp)-ub,lb)
    enddo

#ifdef DEBUG
    do i=0,nodes-1
      if (rank==i) print *,rank,'x+ np_local=',np_local
      call mpi_barrier(mpi_comm_world,ierr)
    enddo
#endif 
    pp=1
    do
      if (pp > npi) exit
      x=xp_buf(:,np_buf+pp)
      if (x(1) >= lb .and. x(1) < ub .and. x(2) >= lb .and. x(2) < ub .and. &
          x(3) >= lb .and. x(3) < ub ) then
        np_local=np_local+1
        xvp(:3,np_local)=x
        xp_buf(:,np_buf+pp)=xp_buf(:,np_buf+npi)
        npi=npi-1
        cycle
      endif
      pp=pp+1
    enddo

    np_buf=np_buf+npi

#ifdef DEBUG
    do i=0,nodes-1
      if (rank==i) print *,rank,'x+ np_exit=',np_buf,np_local
      call mpi_barrier(mpi_comm_world,ierr)
    enddo
#endif 

! pass -x

    tag=12
    npo=0
    pp=1
    do
      if (pp > np_buf) exit
      if (xp_buf(1,pp) < lb) then
        npo=npo+1
        send_buf((npo-1)*3+1:npo*3)=xp_buf(:,pp)
        xp_buf(:,pp)=xp_buf(:,np_buf)
        np_buf=np_buf-1
        cycle
      endif
      pp=pp+1
    enddo

    npi = npo

    call mpi_sendrecv_replace(npi,1,mpi_integer,cart_neighbor(5), &
                              tag,cart_neighbor(6),tag,mpi_comm_world, &
                              status,ierr)

    call mpi_isend(send_buf,npo*3,mpi_real,cart_neighbor(5), &
                   tag,mpi_comm_world,srequest,sierr)
    call mpi_irecv(recv_buf,npi*3,mpi_real,cart_neighbor(6), &
                   tag,mpi_comm_world,rrequest,rierr)
    call mpi_wait(srequest,sstatus,sierr)
    call mpi_wait(rrequest,rstatus,rierr)

    do pp=1,npi
      xp_buf(:,np_buf+pp)=recv_buf((pp-1)*3+1:pp*3)
      xp_buf(1,np_buf+pp)=min(xp_buf(1,np_buf+pp)+ub,ub-eps)
    enddo

    pp=1
    do
      if (pp > npi) exit
      x=xp_buf(:,np_buf+pp)
      if (x(1) >= lb .and. x(1) < ub .and. x(2) >= lb .and. x(2) < ub .and. &
          x(3) >= lb .and. x(3) < ub ) then
        np_local=np_local+1
        xvp(:3,np_local)=x
        xp_buf(:,np_buf+pp)=xp_buf(:,np_buf+npi)
        npi=npi-1
        cycle
      endif
      pp=pp+1
    enddo

    np_buf=np_buf+npi

! pass +y

    tag=13
    npo=0
    pp=1
    do
      if (pp > np_buf) exit
      if (xp_buf(2,pp) >= ub) then
        npo=npo+1
        send_buf((npo-1)*3+1:npo*3)=xp_buf(:,pp)
        xp_buf(:,pp)=xp_buf(:,np_buf)
        np_buf=np_buf-1
        cycle
      endif
      pp=pp+1
    enddo

    npi = npo

    call mpi_sendrecv_replace(npi,1,mpi_integer,cart_neighbor(4), &
                              tag,cart_neighbor(3),tag,mpi_comm_world, &
                              status,ierr)

    call mpi_isend(send_buf,npo*3,mpi_real,cart_neighbor(4), &
                   tag,mpi_comm_world,srequest,sierr)
    call mpi_irecv(recv_buf,npi*3,mpi_real,cart_neighbor(3), &
                   tag,mpi_comm_world,rrequest,rierr)
    call mpi_wait(srequest,sstatus,sierr)
    call mpi_wait(rrequest,rstatus,rierr)

    do pp=1,npi
      xp_buf(:,np_buf+pp)=recv_buf((pp-1)*3+1:pp*3)
      xp_buf(2,np_buf+pp)=max(xp_buf(2,np_buf+pp)-ub,lb)
    enddo

    pp=1
    do
      if (pp > npi) exit
      x=xp_buf(:,np_buf+pp)
      if (x(1) >= lb .and. x(1) < ub .and. x(2) >= lb .and. x(2) < ub .and. &
          x(3) >= lb .and. x(3) < ub ) then
        np_local=np_local+1
        xvp(:3,np_local)=x
        xp_buf(:,np_buf+pp)=xp_buf(:,np_buf+npi)
        npi=npi-1
        cycle
      endif
      pp=pp+1
    enddo

    np_buf=np_buf+npi

! pass -y

    tag=14
    npo=0
    pp=1
    do
      if (pp > np_buf) exit
      if (xp_buf(2,pp) < lb) then
        npo=npo+1
        send_buf((npo-1)*3+1:npo*3)=xp_buf(:,pp)
        xp_buf(:,pp)=xp_buf(:,np_buf)
        np_buf=np_buf-1
        cycle
      endif
      pp=pp+1
    enddo

    npi = npo

    call mpi_sendrecv_replace(npi,1,mpi_integer,cart_neighbor(3), &
                              tag,cart_neighbor(4),tag,mpi_comm_world, &
                              status,ierr)

    call mpi_isend(send_buf,npo*3,mpi_real,cart_neighbor(3), &
                   tag,mpi_comm_world,srequest,sierr)
    call mpi_irecv(recv_buf,npi*3,mpi_real,cart_neighbor(4), &
                   tag,mpi_comm_world,rrequest,rierr)
    call mpi_wait(srequest,sstatus,sierr)
    call mpi_wait(rrequest,rstatus,rierr)


    do pp=1,npi
      xp_buf(:,np_buf+pp)=recv_buf((pp-1)*3+1:pp*3)
      xp_buf(2,np_buf+pp)=min(xp_buf(2,np_buf+pp)+ub,ub-eps)
    enddo

    pp=1
    do
      if (pp > npi) exit
      x=xp_buf(:,np_buf+pp)
      if (x(1) >= lb .and. x(1) < ub .and. x(2) >= lb .and. x(2) < ub .and. &
          x(3) >= lb .and. x(3) < ub ) then
        np_local=np_local+1
        xvp(:3,np_local)=x
        xp_buf(:,np_buf+pp)=xp_buf(:,np_buf+npi)
        npi=npi-1
        cycle
      endif
      pp=pp+1
    enddo

    np_buf=np_buf+npi

! pass +z

    tag=15
    npo=0
    pp=1
    do
      if (pp > np_buf) exit
      if (xp_buf(3,pp) >= ub) then
        npo=npo+1
        send_buf((npo-1)*3+1:npo*3)=xp_buf(:,pp)
        xp_buf(:,pp)=xp_buf(:,np_buf)
        np_buf=np_buf-1
        cycle
      endif
      pp=pp+1
    enddo

    npi = npo

    call mpi_sendrecv_replace(npi,1,mpi_integer,cart_neighbor(2), &
                              tag,cart_neighbor(1),tag,mpi_comm_world, &
                              status,ierr)

    call mpi_isend(send_buf,npo*3,mpi_real,cart_neighbor(2), &
                   tag,mpi_comm_world,srequest,sierr)
    call mpi_irecv(recv_buf,npi*3,mpi_real,cart_neighbor(1), &
                   tag,mpi_comm_world,rrequest,rierr)
    call mpi_wait(srequest,sstatus,sierr)
    call mpi_wait(rrequest,rstatus,rierr)


    do pp=1,npi
      xp_buf(:,np_buf+pp)=recv_buf((pp-1)*3+1:pp*3)
      xp_buf(3,np_buf+pp)=max(xp_buf(3,np_buf+pp)-ub,lb)
    enddo

    pp=1
    do
      if (pp > npi) exit
      x=xp_buf(:,np_buf+pp)
      if (x(1) >= lb .and. x(1) < ub .and. x(2) >= lb .and. x(2) < ub .and. &
          x(3) >= lb .and. x(3) < ub ) then
        np_local=np_local+1
        xvp(:3,np_local)=x
        xp_buf(:,np_buf+pp)=xp_buf(:,np_buf+npi)
        npi=npi-1
        cycle
      endif
      pp=pp+1
    enddo

    np_buf=np_buf+npi

! pass -z

    tag=16
    npo=0
    pp=1
    do
      if (pp > np_buf) exit
      if (xp_buf(3,pp) < lb) then
        npo=npo+1
        send_buf((npo-1)*3+1:npo*3)=xp_buf(:,pp)
        xp_buf(:,pp)=xp_buf(:,np_buf)
        np_buf=np_buf-1
        cycle
      endif
      pp=pp+1
    enddo

    npi = npo

    call mpi_sendrecv_replace(npi,1,mpi_integer,cart_neighbor(1), &
                              tag,cart_neighbor(2),tag,mpi_comm_world, &
                              status,ierr)

    call mpi_isend(send_buf,npo*3,mpi_real,cart_neighbor(1), &
                   tag,mpi_comm_world,srequest,sierr)
    call mpi_irecv(recv_buf,npi*3,mpi_real,cart_neighbor(2), &
                   tag,mpi_comm_world,rrequest,rierr)
    call mpi_wait(srequest,sstatus,sierr)
    call mpi_wait(rrequest,rstatus,rierr)

    do pp=1,npi
      xp_buf(:,np_buf+pp)=recv_buf((pp-1)*3+1:pp*3)
      xp_buf(3,np_buf+pp)=min(xp_buf(3,np_buf+pp)+ub,ub-eps)
    enddo

    pp=1
    do
      if (pp > npi) exit
      x=xp_buf(:,np_buf+pp)
      if (x(1) >= lb .and. x(1) < ub .and. x(2) >= lb .and. x(2) < ub .and. &
          x(3) >= lb .and. x(3) < ub ) then
        np_local=np_local+1
        xvp(:3,np_local)=x
        xp_buf(:,np_buf+pp)=xp_buf(:,np_buf+npi)
        npi=npi-1
        cycle
      endif
      pp=pp+1
    enddo

    np_buf=np_buf+npi

#ifdef DEBUG
    do i=0,nodes-1
      if (rank==i) print *,rank,'particles left in buffer=',np_buf
      call mpi_barrier(mpi_comm_world,ierr)
    enddo
#endif 

    call mpi_reduce(np_buf,np_exit,1,mpi_integer,mpi_sum,0, &
                    mpi_comm_world,ierr)

    if (rank == 0) print *,'total buffered particles =',np_exit

    call mpi_reduce(np_local,np_final,1,mpi_integer,mpi_sum,0, &
                    mpi_comm_world,ierr)

    if (rank == 0) then
      print *,'total particles =',int(np_final,8)
      if (np_final /= (int(np,8))**3) then
        print *,'ERROR: total number of particles incorrect after passing'
      endif
    endif

!!  Check for particles out of bounds

    do i=1,np_local
      if (xvp(1,i) < 0 .or. xvp(1,i) >= nc_node_dim .or. &
          xvp(2,i) < 0 .or. xvp(2,i) >= nc_node_dim .or. &
          xvp(3,i) < 0 .or. xvp(3,i) >= nc_node_dim) then
        print *,'particle out of bounds',rank,i,xvp(:3,i),nc_node_dim
      endif
    enddo

  end subroutine pass_particles

!------------------------------------------------------------!

  subroutine cicmass
    implicit none
    real, parameter :: mp=(ncr/np)**3

    integer :: i,i1,i2,j1,j2,k1,k2
    real    :: x,y,z,dx1,dx2,dy1,dy2,dz1,dz2,vf,v(3)

    do i=1,np_local
       x=xvp(1,i)-0.5
       y=xvp(2,i)-0.5
       z=xvp(3,i)-0.5

       i1=floor(x)+1
       i2=i1+1
       dx1=i1-x
       dx2=1-dx1
       j1=floor(y)+1
       j2=j1+1
       dy1=j1-y
       dy2=1-dy1
       k1=floor(z)+1
       k2=k1+1
       dz1=k1-z
       dz2=1-dz1

       if (i1 < 0 .or. i2 > nc_node_dim+1 .or. j1 < 0 .or. &
           j2 > nc_node_dim+1 .or. k1 < 0 .or. k2 > nc_node_dim+1) then
         print *,'particle out of bounds',i1,i2,j1,j2,k1,k2,nc_node_dim
       endif

       dz1=mp*dz1
       dz2=mp*dz2
       den(i1,j1,k1)=den(i1,j1,k1)+dx1*dy1*dz1
       den(i2,j1,k1)=den(i2,j1,k1)+dx2*dy1*dz1
       den(i1,j2,k1)=den(i1,j2,k1)+dx1*dy2*dz1
       den(i2,j2,k1)=den(i2,j2,k1)+dx2*dy2*dz1
       den(i1,j1,k2)=den(i1,j1,k2)+dx1*dy1*dz2
       den(i2,j1,k2)=den(i2,j1,k2)+dx2*dy1*dz2
       den(i1,j2,k2)=den(i1,j2,k2)+dx1*dy2*dz2
       den(i2,j2,k2)=den(i2,j2,k2)+dx2*dy2*dz2
    enddo

    return
  end subroutine cicmass


!------------------------------------------------------------!




  subroutine initvar
    implicit none
    integer :: k

    real time1,time2
    call cpu_time(time1)

    do k=1,max_np
       xvp(:,k)=0
    enddo
    do k=0,nc_node_dim+1
       den(:,:,k)=0
    enddo
    do k=1,3*np_buffer
       send_buf(k)=0
    enddo
    do k=1,3*np_buffer
       recv_buf(k)=0
    enddo
    do k=1,nc
       pktsum(:,k)=0
    enddo
    do k=1,nc
       pksum(:,k)=0
    enddo
#ifdef PLPLOT
    do k=1,nc
       pkplot(:,k)=0
    enddo
#endif

    call cpu_time(time2)
    time2=(time2-time1)
    if (rank == 0) write(*,"(f8.2,a)") time2,'  Called init var'
    return
  end subroutine initvar

!!------------------------------------------------------------------!!


end program hist3d
