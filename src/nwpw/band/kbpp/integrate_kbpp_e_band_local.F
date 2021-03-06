*
* $Id$
*

      subroutine integrate_kbpp_e_band_local(version,
     >                            nrho,drho,lmax,locp,nmax,
     >                            n_extra,n_expansion,zv,
     >                            vp,wp,rho,f,cs,sn,
     >                            nfft1,nfft2,nfft3,nprj,
     >                            G,vl,
     >                            n_prj,l_prj,m_prj,vnlnrm,
     >                            semicore,rho_sc_r,rho_sc_k,
     >                            ierr)
      implicit none
      integer          version
      integer          nrho
      double precision drho
      integer          lmax
      integer          locp
      integer          nmax
      integer          n_extra,n_expansion(0:lmax)
      double precision zv
      double precision vp(nrho,0:lmax)
      double precision wp(nrho,0:(lmax+n_extra))
      double precision rho(nrho)
      double precision f(nrho)
      double precision cs(nrho)
      double precision sn(nrho)

      integer nfft1,nfft2,nfft3,nprj
      double precision G(nfft1,nfft2,nfft3,3)
      double precision vl(nfft1,nfft2,nfft3)
      integer          n_prj(nprj),l_prj(nprj),m_prj(nprj)
      double precision vnlnrm(nmax,nmax,0:lmax)


      logical semicore
      double precision rho_sc_r(nrho,2)
      double precision rho_sc_k(nfft1,nfft2,nfft3,4)

      integer ierr

#include "bafdecls.fh"

      integer np,taskid,MASTER
      parameter (MASTER=0)

*     *** local variables ****
      logical value
      integer lcount,task_count,nfft3d
      integer k1,k2,k3,i,l,n,nb,n1,n2
      double precision pi,twopi,forpi
      double precision p0,p1,p2,p3,p
      double precision gx,gy,gz,a,q,d
      integer indx(5,0:3)
      logical small_cell

*     **** external functions ****
      double precision dsum,simp
      external         dsum,simp
      logical  control_psp_semicore_small
      external control_psp_semicore_small


*     **** set up indx(n,l) --> to wp ****
      nb = lmax+1
      do l=0,lmax
         indx(1,l) = l
         do n=2,n_expansion(l)
            indx(n,l) = nb
            nb = nb+1
         end do
      end do

      call Parallel_np(np)
      call Parallel_taskid(taskid)

      small_cell = control_psp_semicore_small()

      nfft3d = (nfft1)*nfft2*nfft3
      pi=4.0d0*datan(1.0d0)
      twopi=2.0d0*pi
      forpi=4.0d0*pi

      if ((nrho/2)*2.eq.nrho) then
        write(*,*)"local pseudopotential not computed: nrho is not odd"
        ierr=2
        return
      end if

      P0=DSQRT(FORPI)
      P1=DSQRT(3.0d0*FORPI)
      P2=DSQRT(15.0d0*FORPI)
      P3=DSQRT(105.0d0*FORPI)

*::::::::::::::::::  Define non-local pseudopotential  ::::::::::::::::
      do l=0,lmax
        if (l.ne.locp) then
          do i=1,nrho
            vp(i,l)=vp(i,l)-vp(i,locp)
          end do
        end if
      end do

*:::::::::::::::::::::  Normarization constants  ::::::::::::::::::::::
      lcount = 0
      do l=0,lmax
        if (l.eq.locp) then
           do n2 = 1, n_expansion(l)
           do n1 = n2,n_expansion(l)
              vnlnrm(n1,n2,l) = 0.0d0
              vnlnrm(n2,n1,l) = 0.0d0
           end do
           end do
        else
           do n2 = 1, n_expansion(l)
              do i=1,nrho
                 f(i)=vp(i,l)*wp(i,indx(n2,l))**2
              end do
              a=simp(nrho,f,drho)
              vnlnrm(n2,n2,l) = a
              do n1 = n2+1,n_expansion(l)
                 do i=1,nrho
                    f(i)=vp(i,l)*wp(i,indx(n1,l))*wp(i,indx(n2,l))
                 end do
                 a=simp(nrho,f,drho)
                 vnlnrm(n1,n2,l) = a
                 vnlnrm(n2,n1,l) = a
              end do
           end do
           if (n_expansion(l).eq.1) then
              vnlnrm(1,1,l) = 1/a
           else if (n_expansion(l).eq.2) then
              d = vnlnrm(1,1,l)*vnlnrm(2,2,l)
     >          - vnlnrm(1,2,l)*vnlnrm(2,1,l)
              q = vnlnrm(1,1,l)
              vnlnrm(1,1,l) = vnlnrm(2,2,l)/d
              vnlnrm(2,2,l) = q/d
              vnlnrm(1,2,l) = -vnlnrm(1,2,l)/d
              vnlnrm(2,1,l) = -vnlnrm(2,1,l)/d
           else
              call nwpw_matrix_invert(n_expansion(l),vnlnrm(1,1,l),nmax)
           end if
        end if
      end do

*======================  Fourier transformation  ======================
      call dcopy(nfft3d,0.0d0,0,VL,1)
      call dcopy(4*nfft3d,0.0d0,0,rho_sc_k,1)
      task_count = -1
      DO 700 k3=1,nfft3
      DO 700 k2=1,nfft2
      DO 700 k1=1,nfft1
        task_count = task_count + 1
        if (mod(task_count,np).ne.taskid) go to 700

        Q=DSQRT(G(k1,k2,k3,1)**2
     >         +G(k1,k2,k3,2)**2
     >         +G(k1,k2,k3,3)**2)

        if ((k1.eq.1).and.(k2.eq.1).and.(k3.eq.1)) go to 700

        
        GX=G(k1,k2,k3,1)/Q
        GY=G(k1,k2,k3,2)/Q
        GZ=G(k1,k2,k3,3)/Q
        DO I=1,NRHO
          CS(I)=DCOS(Q*RHO(I))
          SN(I)=DSIN(Q*RHO(I))
        END DO

*::::::::::::::::::::::::::::::  local  :::::::::::::::::::::::::::::::
  600   CONTINUE

        DO  I=1,NRHO
          F(I)=RHO(I)*VP(I,locp)*SN(I)
        END DO
        vl(k1,k2,k3)=SIMP(nrho,f,drho)*forpi/Q-ZV*forpi*cs(nrho)/(Q*Q)
 

*::::::::::::::::::::: semicore density :::::::::::::::::::::::::::::::
        if (semicore) then
           if (small_cell) then
              do i=1,nrho
                 f(i) = rho(i)*(rho_sc_r(i,1))*sn(i)
              end do
           else
              do i=1,nrho
                 f(i) = rho(i)*dsqrt(rho_sc_r(i,1))*sn(i)
              end do
           end if
           rho_sc_k(k1,k2,k3,1) = SIMP(nrho,f,drho)*forpi/Q

           do i=1,nrho
             f(i)=(sn(i)/(Q*rho(i))-cs(i))*rho_sc_r(i,2)*rho(i)
           end do
           P = SIMP(nrho,f,drho)*forpi/Q
           rho_sc_k(k1,k2,k3,2)=P*GX
           rho_sc_k(k1,k2,k3,3)=P*GY
           rho_sc_k(k1,k2,k3,4)=P*GZ

        end if
    
  700 CONTINUE

      call Parallel_Vector_SumAll(4*nfft3d,rho_sc_k)
      call Parallel_Vector_SumAll(nfft3d,VL)

*:::::::::::::::::::::::::::::::  G=0  ::::::::::::::::::::::::::::::::      

      DO I=1,NRHO
        F(I)=VP(I,locp)*RHO(I)**2
      END DO
      VL(1,1,1)=FORPI*SIMP(NRHO,F,DRHO)+TWOPI*ZV*RHO(NRHO)**2

*     **** semicore density ****
      if (semicore) then
         if (small_cell) then
            do i=1,nrho
               f(i) = (rho_sc_r(i,1))*rho(i)**2
            end do
         else
            do i=1,nrho
               f(i) = dsqrt(rho_sc_r(i,1))*rho(i)**2
            end do
         end if
         rho_sc_k(1,1,1,1) = forpi*SIMP(nrho,f,drho)
         rho_sc_k(1,1,1,2) = 0.0d0
         rho_sc_k(1,1,1,3) = 0.0d0
         rho_sc_k(1,1,1,4) = 0.0d0
      end if


*     ********************************
*     **** define n_prj and l_prj ****
*     ********************************
      lcount = nprj+1
      GO TO (950,940,930,920), lmax+1

        !::::::  f-wave  :::::::
  920   CONTINUE
        if (locp.ne.3) then
          do n=1,n_expansion(3)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = -3

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = -2

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = -1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 0

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 2

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 3
             m_prj(lcount) = 3
          end do
        end if

        !::::  d-wave  ::::
  930   CONTINUE
        if (locp.ne.2) then
          do n=1,n_expansion(2)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = -2

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = -1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = 0

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = 1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 2
             m_prj(lcount) = 2
          end do
        end if

        !::::  p-wave  ::::
  940   CONTINUE
        if (locp.ne.1) then
          do n=1,n_expansion(1)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 1
             m_prj(lcount) = -1

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 1
             m_prj(lcount) = 0

             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 1
             m_prj(lcount) = 1
          end do
        end if

        !::::  s-wave  ::::
  950   CONTINUE
        if (locp.ne.0) then
          do n=1,n_expansion(0)
             lcount = lcount-1
             n_prj(lcount) = n
             l_prj(lcount) = 0
             m_prj(lcount) = 0
          end do
        end if

      ierr=0
      return
      end

