c===================================================================
c          FOR GENERAL CONTRACTED SHELLS
C previously in spec_calcint.f file :
c     subroutine gcparij(nbls, indxij,npij,
c     subroutine gcparkl(nbls,indxkl,npkl,
c     subroutine gcqijkl(nbls,nbls1, index,indxij,indxkl,npij,npkl,
c     subroutine gcpairs(ij, nbls, indxp, nblok1,iis,jjs,
c     subroutine gcquart(nbls,nbls1, index,indxp,
C previously in precalc2.F     file :
c     subroutine specasg(bl,first,nbls,nbls1, index,indxij,indxkl,
C previously in asslemblx.f    file :
c     subroutine assemblg(bl,firstc,nbls,nbls1,l01,l02,ngcd,
c new routines made out of former asselg :
c     subroutine asselg_n(firstc,xt1,lt1,lt2,nbls,indx,nbls1,
c     subroutine asselg_d(firstc,xt1,lt1,lt2,nbls,indx,nbls1,
c===================================================================
c          FOR GENERAL CONTRACTED SHELLS
c
c          Used when iroute=1 (old) : tx93 
c===================================================================
      subroutine gcparij(nbls, indxij,npij,
     *                   ii,jj,ngci1,ngcj1,ngcij,
     *                   gci,gcj, gcij, nblok1,iis,jjs,indxp)
      implicit real*8 (a-h,o-z)
c
      dimension indxij(*)
      dimension gci(npij,ngci1,*),gcj(npij,ngcj1,*)
      dimension nblok1(2,*),iis(*),jjs(*)
      dimension gcij(ngcij,nbls)
      dimension indxp(*)
c-------------------------------------------------------------------
c      This is called from Erinteg and Erintsp 
c             From contraction loops
c         FOR GENERAL CONTRACTED SHELLS
c-------------------------------------------------------------------
      do 204 ijkl=1,nbls
      ijpar=indxij(ijkl)
      ijcs=nblok1(1,indxp(ijkl))
      ics=iis(ijcs)
      jcs=jjs(ijcs)
             ijpg=0
             do 2041 igc=1,ngci1
             coefi=gci(ijpar,igc,ii)
             ngcjx=ngcj1
ctry         if(jcs.eq.ics) ngcjx=igc
             do 2041 jgc=1,ngcjx
             coefj=gcj(ijpar,jgc,jj)*coefi
c in txs     if(jcs.eq.ics .and. jgc.eq.igc) coefj=coefj*0.5d0
c pnl:
ctry         if(jcs.eq.ics .and. jgc.NE.igc) coefj=coefj*2.0d0
             ijpg=ijpg+1
             gcij(ijpg,ijkl)=coefj
 2041        continue
  204 continue
c
      end
c====================================================================
      subroutine gcparkl(nbls,indxkl,npkl,
     *                   kk,ll,ngck1,ngcl1,ngckl,
     *                   gck,gcl,gckl, nblok1,iis,jjs,indxp)
      implicit real*8 (a-h,o-z)
      dimension indxkl(*)
      dimension gck(npkl,ngck1,*),gcl(npkl,ngcl1,*)
      dimension nblok1(2,*),iis(*),jjs(*)
      dimension gckl(ngckl,nbls)
      dimension indxp(*)
c-------------------------------------------------------------------
c      This is called from Erinteg and Erintsp 
c             From contraction loops (kl)
c          FOR GENERAL CONTRACTED SHELLS
c-------------------------------------------------------------------
c
      do 204 ijkl=1,nbls
      klpar=indxkl(ijkl)
      klcs=nblok1(2,indxp(ijkl))
      kcs=iis(klcs)
      lcs=jjs(klcs)
             klpg=0
             do 2042 kgc=1,ngck1
             coefk=gck(klpar,kgc,kk)
             ngclx=ngcl1
ctry         if(lcs.eq.kcs) ngclx=kgc
             do 2042 lgc=1,ngclx
             coefl=gcl(klpar,lgc,ll)*coefk
c txs        if(lcs.eq.kcs .and. lgc.eq.kgc) coefl=coefl*0.5d0
c pnl:
ctry         if(lcs.eq.kcs .and. lgc.NE.kgc) coefl=coefl*2.0d0
             klpg=klpg+1
             gckl(klpg,ijkl)=coefl
 2042        continue
c
  204 continue
c
      end
c====================================================================
      subroutine gcqijkl(nbls,nbls1, index,indxij,indxkl,npij,npkl,
     *                   ngci1,ngcj1,ngck1,ngcl1,ngcd,
     *                   nblok1,iis,jjs, indgc,gcoef,indxp,
     *                   gcij,ngcij, gckl,ngckl)
      implicit real*8 (a-h,o-z)
      dimension index(*),indxij(*),indxkl(*)
      dimension nblok1(2,*),iis(*),jjs(*)
c
      dimension indgc(nbls) 
      dimension gcoef(ngcd,nbls)
      dimension gcij(ngcij,nbls),gckl(ngckl,nbls)
      dimension indxp(*)
c-------------------------------------------------------------------
c      This is called from Erinteg and Erintsp 
c             From contraction loops
c       FOR GENERAL CONTRACTED SHELLS
c-------------------------------------------------------------------
      do 204 i=1,nbls1
      ijkl=index(i)
      ijpar=indxij(ijkl)
c
      ijcs=nblok1(1,indxp(ijkl))
      ics=iis(ijcs)
      jcs=jjs(ijcs)
c
      klpar=indxkl(ijkl)
      klcs=nblok1(2,indxp(ijkl))
      kcs=iis(klcs)
      lcs=jjs(klcs)
c
             ijpg=0
             do 2041 igc=1,ngci1
             ngcjx=ngcj1
ctry         if(jcs.eq.ics) ngcjx=igc
             do 2041 jgc=1,ngcjx
             ijpg=ijpg+1
 2041        continue
c
             klpg=0
             do 2042 kgc=1,ngck1
             ngclx=ngcl1
ctry         if(lcs.eq.kcs) ngclx=kgc
             do 2042 lgc=1,ngclx
             klpg=klpg+1
 2042        continue
c
             ijklg=0
             do 2043 ijp1=1,ijpg
             gcoefij=gcij(ijp1,ijkl)
             klpx=klpg
ckw          if(klcs.eq.ijcs) klpx=ijp1
             do 2043 klp1=1,klpx
             ijklg=ijklg+1
             gcoef(ijklg,ijkl)=gcoefij*gckl(klp1,ijkl)
ckw          if(klcs.eq.ijcs .and. klp1.ne.ijp1) then
ckw             gcoef(ijklg,ijkl)=gcoef(ijklg,ijkl)*2.d0
ckw          endif
 2043        continue
      indgc(ijkl)=ijklg
  204 continue
c
      end
c===================================================================
c===================================================================
c     Used when iroute=2 (new) : tx95
c
c===================================================================
      subroutine gcpairs(ij, nbls, indxp, nblok1,iis,jjs,
     *     lcij,ngci1,ngcj1,ngcij, gcij,
c     output :
     *     gcijx) 
      implicit real*8 (a-h,o-z)
c------------------------------------------------------
      dimension indxp(*)
      dimension nblok1(2,*),iis(*),jjs(*)
      dimension gcij(ngcj1*ngci1,*) ! (ngcj1,ngci1,*)
      dimension gcijx(ngcij,nbls)
c------------------------------------------------------
c     This is called from Erinteg and Erintsp 
c     From contraction loops
c     
c     FOR GENERAL CONTRACTED SHELLS
c     
c     for pairs IJ (ij=1) and KL (ij=2)
c------------------------------------------------------
c     
      ngci1ngcj1 = ngci1*ngcj1
      if (ngci1ngcj1 .eq. 1) then
         call dfill(nbls,gcij(1,lcij),gcijx,1)
      else
         do ijkl=1,nbls
            ijcs=nblok1(ij,indxp(ijkl))
            ics=iis(ijcs)
            jcs=jjs(ijcs)
               do ijpg = 1, ngci1ngcj1
                  gcijx(ijpg,ijkl)=gcij(ijpg,lcij)
               enddo
         enddo
      endif
c     
      end
c====================================================================
      subroutine gcquart(nbls,nbls1, index,indxp,
     *     ngci1,ngcj1,ngck1,ngcl1,ngcd,nblok1,iis,jjs, 
     *     gcij,ngcij,  gckl,ngckl,
ccc   output :
     *     indgc,gcoef)
      implicit real*8 (a-h,o-z)
c------------------------------------------------------
      dimension index(*),indxp(*)
      dimension nblok1(2,*),iis(*),jjs(*)
      dimension indgc(nbls) 
      dimension gcoef(ngcd,nbls), gcij(ngcij,nbls),gckl(ngckl,nbls)
c------------------------------------------------------
c     This is called from Erinteg and Erintsp 
c     From contraction loops
c     
c     FOR GENERAL CONTRACTED SHELLS
c------------------------------------------------------
c     
      ijpg = ngci1*ngcj1
      klpg = ngck1*ngcl1
c
      if (ngck1*ngcl1.eq.1) then
c
c     Either have ijcs.ne.klcs OR both are not generally contracted 
c     (should not happen here) ... in both cases don't need to worry 
c     about off-diagonals
c
         do i=1,nbls1
            ijkl=index(i)
            ijcs=nblok1(1,indxp(ijkl))
            ics=iis(ijcs)
            jcs=jjs(ijcs)
            do ijp1=1,ijpg
               gcoef(ijp1,ijkl)=gcij(ijp1,ijkl)*gckl(1,ijkl)
            enddo
            indgc(ijkl)=ijpg
         enddo
      else
         do i=1,nbls1
            ijkl=index(i)
c     
            ijcs=nblok1(1,indxp(ijkl))
            ics=iis(ijcs)
            jcs=jjs(ijcs)
c     
            klcs=nblok1(2,indxp(ijkl))
            kcs=iis(klcs)
            lcs=jjs(klcs)
c     
            ijklg=0
               do ijp1=1,ijpg
                  gcoefij=gcij(ijp1,ijkl)
                  do klp1=1,klpg
                     gcoef(ijklg+klp1,ijkl)=gcoefij*gckl(klp1,ijkl)
                  enddo
                  ijklg=ijklg+klpg
               enddo
            indgc(ijkl)=ijklg
         enddo
      endif
c     
      end
c====================================================================
      subroutine specasg(bl,first,nbls,nbls1, index,indxij,indxkl,
     *                   buf,buf1, const,rysx,xpqr,txxr,
     *                   ngcd,indgc,gcoef,ijkln, ndiag)
      implicit real*8 (a-h,o-z)
      logical first
      common /types/iityp,jjtyp,kktyp,lltyp, ityp,jtyp,ktyp,ltyp
      common /number/ zero,half,one,two,three,four,five,ten,ten6,tenm8,p
     1i,acc
      common /rys/ xrys,rysr(10),rysw(10),t,f0,f1,f2,f3,f4,f5,nroots
c
      common/obarai/
     * lni,lnj,lnk,lnl,lnij,lnkl,lnijkl,mmax,
     * nqi,nqj,nqk,nql,nsij,nskl,
     * nqij,nqij1,nsij1,nqkl,nqkl1,nskl1,ijbeg,klbeg
c-------------------------------------------------------------------
      dimension bl(*)
      dimension index(*),indxij(*),indxkl(*)
      dimension xpqr(3,*),txxr(3,*)
      dimension const(*),rysx(*)
cccc  dimension buf(ngcd,nbls,ijkln),buf1(nbls1,*)
      dimension buf(nbls,ijkln,ngcd),buf1(nbls1,*)
      dimension indgc(nbls)
cccc  dimension gcoef(ngcd,nbls)
      dimension gcoef(nbls,ngcd)
c***************************************************************
c**     FOR GENERAL CONTRACTED SHELLS
c**  this routine constitues the special code for
c**  two types of integrals over nbls quartets of primitive shells
c**  1. (ss|ss)
c**  2. (xs|ss),(sx|ss),(ss|xs),(ss|sx) where x=p 
c**  these integrals are also contracted here.
c**
c**  input
c**  ------
c**  all precalculated values for whole block :
c**
c**  const(nbls) - contains consts=pi3*sabcd/(pq*sqrt(ppq)) for all int.
c**  rysx(nbls) - contains  xrys i.e. arguments for fm,ft0 routines
c**  xp,xp      - geometry for p,q
c**
c**  output
c**  ------
c**  buf(ngcd,nbls,ijkln) - contains final integrals
c
c    ndiag - shows if the block is made out of the same pair-blocks(0)
c            or not (1)
c***************************************************************
c
c* memory for f00,f11 :
c
      call getmem(nbls1,if00)
      call getmem(nbls1,if11)
c
      if00=if00-1
      if11=if11-1
c
      do 100 i=1,nbls1
      xrys=rysx(i)
      call ft0
      bl(if00+i)=f0
      bl(if11+i)=f1
  100 continue
c
c *** special code for (ss ss) integrals
c
      if(mmax.eq.1) then
          do 2031 i=1,nbls1
          buf1(i,1)=const(i)*bl(if00+i)
 2031     continue
      go to 203
      endif
c
c *** special code for (ps ss), (sp ss) (ss ps) and (ss sp)
c
cxxxx if(mmax.eq.2) then
      if (ityp.gt.1) then
        do 101 i=1,nbls1
        xpqr(1,i)=xpqr(1,i)*bl(if11+i) - txxr(1,i)*bl(if00+i)
        xpqr(2,i)=xpqr(2,i)*bl(if11+i) - txxr(2,i)*bl(if00+i)
        xpqr(3,i)=xpqr(3,i)*bl(if11+i) - txxr(3,i)*bl(if00+i)
 101    continue
      else if (jtyp.gt.1) then
        do 102 i=1,nbls1
        xpqr(1,i)=xpqr(1,i)*bl(if11+i) + txxr(1,i)*bl(if00+i)
        xpqr(2,i)=xpqr(2,i)*bl(if11+i) + txxr(2,i)*bl(if00+i)
        xpqr(3,i)=xpqr(2,i)*bl(if11+i) + txxr(3,i)*bl(if00+i)
 102    continue
      else if (ktyp.gt.1) then
        do 103 i=1,nbls1
        xpqr(1,i)=-xpqr(1,i)*bl(if11+i) - txxr(1,i)*bl(if00+i)
        xpqr(2,i)=-xpqr(2,i)*bl(if11+i) - txxr(2,i)*bl(if00+i)
        xpqr(3,i)=-xpqr(3,i)*bl(if11+i) - txxr(3,i)*bl(if00+i)
 103    continue
      else
        do 104 i=1,nbls1
        xpqr(1,i)=-xpqr(1,i)*bl(if11+i) + txxr(1,i)*bl(if00+i)
        xpqr(2,i)=-xpqr(2,i)*bl(if11+i) + txxr(2,i)*bl(if00+i)
        xpqr(3,i)=-xpqr(3,i)*bl(if11+i) + txxr(3,i)*bl(if00+i)
 104    continue
      endif
c*************
        do 106 i=1,nbls1
          buf1(i,1)=-xpqr(1,i)*const(i)
          buf1(i,2)=-xpqr(2,i)*const(i)
          buf1(i,3)=-xpqr(3,i)*const(i)
106     continue
c
c**********************************************************
c
  203 continue
c
      IF(ndiag.eq.0) THEN
         if(first) then
              do 204 icx=1,lnijkl
              do 204 i=1,nbls1
              xint=buf1(i,icx)
              ijkl=index(i)
              ngcq=indgc(ijkl)
                do 2041 iqu=1,ngcq
                buf(ijkl,icx,iqu)=xint*gcoef(ijkl,iqu)
 2041           continue
  204       continue
            first=.false.
         else
              do 205 icx=1,lnijkl
              do 205 i=1,nbls1
              xint=buf1(i,icx)
              ijkl=index(i)
              ngcq=indgc(ijkl)
                do 2051 iqu=1,ngcq
                buf(ijkl,icx,iqu)=buf(ijkl,icx,iqu)+xint*gcoef(ijkl,iqu)
 2051           continue
  205         continue
         endif
      ELSE
c non-diagonal case : ngcq=ngcd (always)
         if(first) then
              do 304 iqu=1,ngcd
              do 304 icx=1,lnijkl
              do 304 i=1,nbls1
              xint=buf1(i,icx)
              ijkl=index(i)
                buf(ijkl,icx,iqu)=xint*gcoef(ijkl,iqu)
  304       continue
            first=.false.
         else
              do 305 iqu=1,ngcd
              do 305 icx=1,lnijkl
              do 305 i=1,nbls1
              xint=buf1(i,icx)
              ijkl=index(i)
                buf(ijkl,icx,iqu)=buf(ijkl,icx,iqu)+xint*gcoef(ijkl,iqu)
  305         continue
         endif
      ENDIF
c
c release memory
c
      call retmem(2)
c
      end
c====================================================================
C
C     Assembling for gen. contr.
C    
      subroutine assemblg(bl,firstc,nbls,nbls1,l01,l02,ngcd,
     *                    igcoet,ndiag)
      implicit real*8 (a-h,o-z)
      character*11 scftype
      character*4 where
      common /runtype/ scftype,where
c
      logical firstc
      common /memor4/ iwt0,iwt1,iwt2,ibuf,ibuf2,
     * ibfij1,ibfij2,ibfkl1,ibfkl2,
     * ibf2l1,ibf2l2,ibf2l3,ibf2l4,ibfij3,ibfkl3,
     * ibf3l,issss,
     * ix2l1,ix2l2,ix2l3,ix2l4,ix3l1,ix3l2,ix3l3,ix3l4,
     * ixij,iyij,izij, iwij,ivij,iuij,isij
      common /memor5b/ irppq,
     * irho,irr1,irys,irhoapb,irhocpd,iconst,ixwp,ixwq,ip1234,
     * idx1,idx2,indx
      common /memor5e/ igci,igcj,igck,igcl,indgc,igcoef,
     *                 icfg,jcfg,kcfg,lcfg, igcij,igckl
c new for grad. derivatives:
      common /memor5dd/ iaax,ibbx,iccx
c
      dimension bl(*)
c--------------------------------------------------------
c for ordinary scf integrals:
c
      if(where.eq.'buff') then
         if(ndiag.eq.0) then
           call asselg_d(firstc,bl(iwt0),l01,l02,nbls,bl(ibuf2),
     *                   bl(indx),nbls1, ngcd,bl(indgc),bl(igcoet) )
         else
           call asselg_n(firstc,bl(iwt0),l01,l02,nbls,bl(ibuf2),
     *                   bl(indx),nbls1, ngcd,bl(indgc),bl(igcoet) )
         endif
      endif
c
c--------------------------------------------------------
c for gradient integral derivatives:
c
      if(where.eq.'forc') then
         if(ndiag.eq.0) then
           call asselg_d_der(firstc,bl(iwt0),l01,l02,nbls,bl(ibuf2),
     *                   bl(indx),nbls1, ngcd,bl(indgc),bl(igcoet) ,
     *                   bl(iaax),bl(ibbx),bl(iccx))
         else
           call asselg_n_der(firstc,bl(iwt0),l01,l02,nbls,bl(ibuf2),
     *                   bl(indx),nbls1, ngcd,bl(indgc),bl(igcoet) ,
     *                   bl(iaax),bl(ibbx),bl(iccx))
         endif
      endif
c
c--------------------------------------------------------
      end
c===============================================================
      subroutine asselg_n(firstc,xt1,lt1,lt2,nbls,buf2,
     *                    indx,nbls1,ngcd,indgc,gcoef)
      implicit real*8 (a-h,o-z)
      logical firstc
      common/obarai/
     * lni,lnj,lnk,lnl,lnij,lnkl,lnijkl,mmax,
     * nqi,nqj,nqk,nql,nsij,nskl,
     * nqij,nqij1,nsij1,nqkl,nqkl1,nskl1,ijbeg,klbeg
      common /logic4/ nfu(1)
      dimension indx(*)
      dimension xt1(nbls1,lt1,lt2)
      dimension buf2(nbls,lt1,lt2,ngcd)
ccc   dimension but2(ngcd,nbls,lt1,lt2)
      dimension indgc(nbls) 
      dimension gcoef(nbls,ngcd)
ccc   dimension gcoef(ngcd,nbls)
c-------------------------------------------------------------
      ijs=nfu(nqij)+1
      kls=nfu(nqkl)+1
c-------------------------------------------------------------
c--non diagonal block : gen.con. loop goes to ngcd (always)---
c
      IF (FIRSTC) THEN
        do 501 iqu=1,ngcd
        do 501 kl=kls,lnkl
        do 501 ij=ijs,lnij
        do 501 i=1,nbls1
        ijkl=indx(i)
        xint=xt1(i,ij,kl)
ccccc     but2(iqu,ijkl,ij,kl)=xint*gcoef(iqu,ijkl)
          buf2(ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)
  501   continue
        firstc=.false.
      ELSE
        do 601 iqu=1,ngcd
        do 601 kl=kls,lnkl
        DO 601 ij=ijs,lnij
        do 601 i=1,nbls1
        ijkl=indx(i)
        xint=xt1(i,ij,kl)
ccccc     but2(iqu,ijkl,ij,kl)=but2(iqu,ijkl,ij,kl)+xint*gcoef(iqu,ijkl)
          buf2(ijkl,ij,kl,iqu)=buf2(ijkl,ij,kl,iqu)+xint*gcoef(ijkl,iqu)
  601   continue
      ENDIF
c-------------------------------------------------------------
      end
c===============================================================
      subroutine asselg_d(firstc,xt1,lt1,lt2,nbls,buf2,
     *                    indx,nbls1,ngcd,indgc,gcoef)
      implicit real*8 (a-h,o-z)
      logical firstc
      common/obarai/
     * lni,lnj,lnk,lnl,lnij,lnkl,lnijkl,mmax,
     * nqi,nqj,nqk,nql,nsij,nskl,
     * nqij,nqij1,nsij1,nqkl,nqkl1,nskl1,ijbeg,klbeg
      common /logic4/ nfu(1)
      dimension indx(*)
      dimension xt1(nbls1,lt1,lt2)
      dimension buf2(nbls,lt1,lt2,ngcd)
      dimension indgc(nbls) 
c     dimension gcoef(ngcd,nbls)
      dimension gcoef(nbls,ngcd)
c-------------------------------------------------------------
      ijs=nfu(nqij)+1
      kls=nfu(nqkl)+1
c-------------------------------------------------------------
      IF (FIRSTC) THEN
        DO 501 kl=kls,lnkl
        DO 501 ij=ijs,lnij
        do 501 i=1,nbls1
        ijkl=indx(i)
        ngcq=indgc(ijkl)
        xint=xt1(i,ij,kl)
        if(abs(xint).gt.0.d0) then
          do 502 iqu=1,ngcq
          buf2(ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)
  502     continue
        else
          do 503 iqu=1,ngcq
          buf2(ijkl,ij,kl,iqu)=0.d0
  503     continue
        endif
  501   continue
           FIRSTC=.FALSE.
      ELSE
        DO 601 kl=kls,lnkl
        DO 601 ij=ijs,lnij
        do 601 i=1,nbls1
        ijkl=indx(i)
        ngcq=indgc(ijkl)
        xint=xt1(i,ij,kl)
        if(abs(xint).gt.0.d0) then
          do 602 iqu=1,ngcq
          buf2(ijkl,ij,kl,iqu)=buf2(ijkl,ij,kl,iqu)+xint*gcoef(ijkl,iqu)
  602     continue
        endif
  601   continue
      ENDIF
c-------------------------------------------------------------
      end
c===============================================================
c
c subroutines for gradient integral derivatives
c
      subroutine asselg_n_der(firstc,xt1,lt1,lt2,nbls,buf2,
     *                        indx,nbls1,ngcd,indgc,gcoef,
     *                        aax,bbx,ccx)
      implicit real*8 (a-h,o-z)
      logical firstc
      common/obarai/
     * lni,lnj,lnk,lnl,lnij,lnkl,lnijkl,mmax,
     * nqi,nqj,nqk,nql,nsij,nskl,
     * nqij,nqij1,nsij1,nqkl,nqkl1,nskl1,ijbeg,klbeg
      common /logic4/ nfu(1)
      dimension indx(*)
      dimension xt1(nbls1,lt1,lt2)
      dimension indgc(nbls) 
      dimension gcoef(nbls,ngcd)
ccc   dimension gcoef(ngcd,nbls)
      dimension aax(nbls1),bbx(nbls1),ccx(nbls1)
C
      dimension buf2(4,nbls,lt1,lt2,ngcd)
c               buf2(1,nbls,lt1,lt2) - ordinary contraction
c               buf2(2,nbls,lt1,lt2) - rescaled with 2*a_exp
c               buf2(3,nbls,lt1,lt2) - rescaled with 2*b_exp
c               buf2(4,nbls,lt1,lt2) - rescaled with 2*c_exp
c-------------------------------------------------------------
      ijs=nfu(nqij)+1
      kls=nfu(nqkl)+1
c-------------------------------------------------------------
c--non diagonal block : gen.con. loop goes to ngcd (always)---
c
      IF (FIRSTC) THEN
        do 501 iqu=1,ngcd
        do 501 kl=kls,lnkl
        do 501 ij=ijs,lnij
        do 501 i=1,nbls1
        ijkl=indx(i)
        xint=xt1(i,ij,kl)
          buf2(1,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)
          buf2(2,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)*aax(i)
          buf2(3,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)*bbx(i)
          buf2(4,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)*ccx(i)
  501   continue
        firstc=.false.
      ELSE
        do 601 iqu=1,ngcd
        do 601 kl=kls,lnkl
        DO 601 ij=ijs,lnij
        do 601 i=1,nbls1
        ijkl=indx(i)
        xint=xt1(i,ij,kl)
          buf2(1,ijkl,ij,kl,iqu)=buf2(1,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)
          buf2(2,ijkl,ij,kl,iqu)=buf2(2,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)*aax(i)
          buf2(3,ijkl,ij,kl,iqu)=buf2(3,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)*bbx(i)
          buf2(4,ijkl,ij,kl,iqu)=buf2(4,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)*ccx(i)
  601   continue
      ENDIF
c-------------------------------------------------------------
      end
c===============================================================
      subroutine asselg_d_der(firstc,xt1,lt1,lt2,nbls,buf2,
     *                        indx,nbls1,ngcd,indgc,gcoef,
     *                        aax,bbx,ccx)
      implicit real*8 (a-h,o-z)
      logical firstc
      common/obarai/
     * lni,lnj,lnk,lnl,lnij,lnkl,lnijkl,mmax,
     * nqi,nqj,nqk,nql,nsij,nskl,
     * nqij,nqij1,nsij1,nqkl,nqkl1,nskl1,ijbeg,klbeg
      common /logic4/ nfu(1)
      dimension indx(*)
      dimension xt1(nbls1,lt1,lt2)
      dimension buf2(4,nbls,lt1,lt2,ngcd)
      dimension indgc(nbls) 
c     dimension gcoef(ngcd,nbls)
      dimension gcoef(nbls,ngcd)
      dimension aax(nbls1),bbx(nbls1),ccx(nbls1)
c-------------------------------------------------------------
      ijs=nfu(nqij)+1
      kls=nfu(nqkl)+1
c-------------------------------------------------------------
      IF (FIRSTC) THEN
        DO 501 kl=kls,lnkl
        DO 501 ij=ijs,lnij
        do 501 i=1,nbls1
        ijkl=indx(i)
        ngcq=indgc(ijkl)
        xint=xt1(i,ij,kl)
        if(abs(xint).gt.0.d0) then
          do 502 iqu=1,ngcq
          buf2(1,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)
          buf2(2,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)*aax(i)
          buf2(3,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)*bbx(i)
          buf2(4,ijkl,ij,kl,iqu)=xint*gcoef(ijkl,iqu)*ccx(i)
  502     continue
        else
          do 503 iqu=1,ngcq
          buf2(1,ijkl,ij,kl,iqu)=0.d0
          buf2(2,ijkl,ij,kl,iqu)=0.d0
          buf2(3,ijkl,ij,kl,iqu)=0.d0
          buf2(4,ijkl,ij,kl,iqu)=0.d0
  503     continue
        endif
  501   continue
           FIRSTC=.FALSE.
      ELSE
        DO 601 kl=kls,lnkl
        DO 601 ij=ijs,lnij
        do 601 i=1,nbls1
        ijkl=indx(i)
        ngcq=indgc(ijkl)
        xint=xt1(i,ij,kl)
        if(abs(xint).gt.0.d0) then
          do 602 iqu=1,ngcq
          buf2(1,ijkl,ij,kl,iqu)=buf2(1,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)
          buf2(2,ijkl,ij,kl,iqu)=buf2(2,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)*aax(i)
          buf2(3,ijkl,ij,kl,iqu)=buf2(3,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)*bbx(i)
          buf2(4,ijkl,ij,kl,iqu)=buf2(4,ijkl,ij,kl,iqu)
     *                          +xint*gcoef(ijkl,iqu)*ccx(i)
  602     continue
        endif
  601   continue
      ENDIF
c-------------------------------------------------------------
      end
c===============================================================
