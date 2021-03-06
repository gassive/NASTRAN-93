      SUBROUTINE ALG11        
C        
      REAL            LOSS,LAMI,LAMIP1,LAMIM1        
      DIMENSION       XM(21),PPG(21),V(21),PT(21),PS(21),WT(21),PN(21), 
     1                P1(21),DELTP(21,30),TS(21),SOLID(21),DELTB(21),   
     2                TR(21,30),RMDV(21,6),IDATA(6),RDATA(6),NAME1(2),  
     3                NAME2(2)        
      COMMON /SYSTEM/ KSYSTM(90),LPUNCH        
      COMMON /UD3PRT/ IPRTC,ISTRML,IPGEOM        
      COMMON /ALGINO/ ISCR        
      COMMON /UDSTR2/ NBLDES,STAG(21),CHORDD(21)        
      COMMON /UDSIGN/ NSIGN        
      COMMON /UD300C/ NSTNS,NSTRMS,NMAX,NFORCE,NBL,NCASE,NSPLIT,NREAD,  
     1NPUNCH,NPAGE,NSET1,NSET2,ISTAG,ICASE,IFAILO,IPASS,I,IVFAIL,IFFAIL,
     2NMIX,NTRANS,NPLOT,ILOSS,LNCT,ITUB,IMID,IFAIL,ITER,LOG1,LOG2,LOG3, 
     3LOG4,LOG5,LOG6,IPRINT,NMANY,NSTPLT,NEQN,NSPEC(30),NWORK(30),      
     4NLOSS(30),NDATA(30),NTERP(30),NMACH(30),NL1(30),NL2(30),NDIMEN(30)
     5,IS1(30),IS2(30),IS3(30),NEVAL(30),NDIFF(4),NDEL(30),NLITER(30),  
     6NM(2),NRAD(2),NCURVE(30),NWHICH(30),NOUT1(30),NOUT2(30),NOUT3(30),
     7NBLADE(30),DM(11,5,2),WFRAC(11,5,2),R(21,30),XL(21,30),X(21,30),  
     8H(21,30),S(21,30),VM(21,30),VW(21,30),TBETA(21,30),DIFF(15,4),    
     9FDHUB(15,4),FDMID(15,4),FDTIP(15,4),TERAD(5,2),DATAC(100),        
     1DATA1(100),DATA2(100),DATA3(100),DATA4(100),DATA5(100),DATA6(100),
     2DATA7(100),DATA8(100),DATA9(100),FLOW(10),SPEED(30),SPDFAC(10),   
     3BBLOCK(30),BDIST(30),WBLOCK(30),WWBL(30),XSTN(150),RSTN(150),     
     4DELF(30),DELC(100),DELTA(100),TITLE(18),DRDM2(30),RIM1(30),       
     5XIM1(30),WORK(21),LOSS(21),TANEPS(21),XI(21),VV(21),DELW(21),     
     6LAMI(21),LAMIM1(21),LAMIP1(21),PHI(21),CR(21),GAMA(21),SPPG(21),  
     7CPPG(21),HKEEP(21),SKEEP(21),VWKEEP(21),DELH(30),DELT(30),VISK,   
     8SHAPE,SCLFAC,EJ,G,TOLNCE,XSCALE,PSCALE,PLOW,RLOW,XMMAX,RCONST,    
     9FM2,HMIN,C1,PI,CONTR,CONMX        
      EQUIVALENCE    (IDATA(1),RDATA(1))        
      DATA    NAME1, NAME2 /4HPLOA,4HD2  ,4HTEMP,4H    /        
C        
      OPR   = 0.0        
      OEFF  = 1.0        
      PFAC  = 550.0        
      ILAST = NSTNS        
C        
C     LOCATE COMPUTING STATION NUMBER AT THE BLADE LEADING EDGE AND     
C     AT THE BLADE TRAILING EDGE.        
C        
      LEDGEB = 0        
      ITRLEB = 0        
      DO 10 IBLE = 1,NSTNS        
      NOUT3S = NOUT3(IBLE)/10        
      IF (NOUT3(IBLE).EQ.1 .OR. NOUT3S.EQ.1) LEDGEB = IBLE        
      IF (NOUT3(IBLE).EQ.2 .OR. NOUT3S.EQ.2) ITRLEB = IBLE        
   10 CONTINUE        
      IF (IFAILO .NE. 0) ILAST = IFAILO        
      DO 700 I = 1,ILAST        
      CALL ALG03 (LNCT,7+NSTRMS)        
      IF (IPRTC .EQ. 1) WRITE(LOG2,100) I        
  100 FORMAT (//10X,'STATION',I3,'  FLOW-FIELD DESCRIPTION', /10X,      
     1        34(1H*), //,'  STREAM      -----MESH-POINT COORDS------', 
     2        3X,16(1H-),'V E L O C I T I E S,16(1H-)    RADIUS OF  ',  
     3        'STREAMLINE   STATION',/,'  -LINE       RADIUS    X-COORD'
     4,       '    L-COORD   MERIDIONAL TANGENTIAL   AXIAL',6X,'RADIAL',
     5        4X,'TOTAL    CURVATURE SLOPE ANGLE LEAN ANGLE',/)        
      CALL ALG01 (R(1,I),X(1,I),NSTRMS,R(1,I),X1,GAMA,NSTRMS,0,1)       
      IF (I.NE.1 .AND. I.NE.NSTNS) GO TO 130        
      L1 = 1        
      L2 = 2        
      IF (I .EQ. 1) GO TO 110        
      L2 = NSTNS        
      L1 = L2 - 1        
  110 DO 120 J = 1,NSTRMS        
      CR(J)  = 0.0        
  120 PHI(J) = ATAN2(R(J,L2)-R(J,L1),X(J,L2)-X(J,L1))        
      GO TO 150        
  130 DO 140 J = 1,NSTRMS        
      X1 = SQRT((R(J,I+1)-R(J,I))**2+(X(J,I+1)-X(J,I))**2)        
      X2 = SQRT((R(J,I)-R(J,I-1))**2+(X(J,I)-X(J,I-1))**2)        
      X3 = ATAN2(R(J,I+1)-R(J,I),X(J,I+1)-X(J,I))        
      X4 = ATAN2(R(J,I)-R(J,I-1),X(J,I)-X(J,I-1))        
      CR(J) = (X3-X4)/(X1+X2)*2.0        
      IF (CR(J) .NE. 0.0) CR(J) = 1.0/CR(J)        
  140 PHI(J) = (X3+X4)/2.0        
  150 DO 160 J = 1,NSTRMS        
      VA = VM(J,I)*COS(PHI(J))        
      VR = VM(J,I)*SIN(PHI(J))        
      FI = PHI(J)*C1        
      GA = ATAN(GAMA(J))*C1        
      PPG(J) = FI + GA        
      V(J) = SQRT(VM(J,I)**2+VW(J,I)**2)        
C        
C     STORE RADIUS AT BLADE LEADING AND TRAILING EDGES, ALL STREAMLINES 
C        
      IF (ICASE.EQ.1 .AND. I.EQ.LEDGEB) RMDV(J,5) = R(J,I)        
      IF (ICASE.EQ.1 .AND. I.EQ.ITRLEB) RMDV(J,6) = R(J,I)        
  160 IF (IPRTC .EQ. 1) WRITE (LOG2,170) J,R(J,I),X(J,I),XL(J,I),       
     1    VM(J,I),VW(J,I),VA,VR,V(J),CR(J),FI,GA        
  170 FORMAT (I6,F14.4,2F11.4,5F11.2,1X,F10.2,2F11.3)        
      CALL ALG03 (LNCT,NSTRMS+4)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,180)        
  180 FORMAT (/8H  STREAM,7X,4HMACH,6X,4(1H-),9HPRESSURES,4(1H-),5X,    
     1       17H---TEMPERATURES--,4X,8HSPECIFIC,4X,17H---ENTHALPIES----,
     2       4X,7HENTROPY,6X,4HFLOW,3X,11H(PHI+GAMMA), /,7H  -LINE,7X,  
     3       6HNUMBER,5X,5HTOTAL,6X,6HSTATIC,5X,5HTOTAL,6X,6HSTATIC,5X, 
     4       6HWEIGHT,5X,5HTOTAL,6X,6HSTATIC,16X,5HANGLE,/)        
      DO 190 J = 1,NSTRMS        
      DELTB(J) = 0.0        
      HS = H(J,I) - V(J)**2/(2.0*G*EJ)        
      IF (HS .LT. HMIN) HS = HMIN        
      XM(J) = SQRT(ALG9(HS,S(J,I),V(J)**2))        
      PT(J) = ALG4(H(J,I),S(J,I))        
      PTINS = PT(J)/SCLFAC**2        
      PS(J) = ALG4(HS,S(J,I))        
      PSINS = PS(J)/SCLFAC**2        
      TT    = ALG7(H(J,I),S(J,I))        
      TS(J) = ALG7(HS,S(J,I))        
      WT(J) = ALG5(HS,S(J,I))        
      ALPHA = 0.0        
      IF (I.NE.ISTAG .OR. J.NE.1) ALPHA = C1*ATAN(VW(J,I)/VM(J,I))      
C        
C     STORE DENSITY AT BLADE LEADING EDGE FOR ALL STREAMLINES        
C        
      IF (ICASE.EQ.1 .AND. I.EQ.LEDGEB) RMDV(J,2) = WT(J)        
  190 IF (IPRTC .EQ. 1) WRITE (LOG2,200) J,XM(J),PTINS,PSINS,TT,TS(J),  
     1    WT(J),H(J,I),HS,S(J,I),ALPHA,PPG(J)        
  200 FORMAT (I6,F14.4,2F11.4,2F11.3,F12.6,F10.3,F11.3,F12.6,F10.3,     
     1        F11.3)        
      IF (I .NE. 1) GO TO 220        
      P1BAR = 0.0        
      H1BAR = 0.0        
      P1(1) = PT(1)        
      PN(1) = PT(1)        
      DO 210 J = 1,ITUB        
      P1(J+1) = PT(J+1)        
      PN(J+1) = PT(J+1)        
      X1    = (DELF(J+1)-DELF(J))/2.0        
      P1BAR = P1BAR + X1*(PT(J)+PT(J+1))        
  210 H1BAR = H1BAR + X1*(H(J,1)+H(J+1,1))        
      HBAR  = H1BAR        
      S1BAR = ALG3(P1BAR,H1BAR)        
      PNBAR = P1BAR        
      HNBAR = H1BAR        
      SNBAR = S1BAR        
      L1KEEP= 1        
      GO TO 700        
  220 IFLE  = 0        
      IFTE  = 0        
      IF (NWORK(I) .EQ. 0) GO TO 230        
      IFTE  = 1        
      IF (I.EQ.NSTNS .OR. NWORK(I+1).EQ.0 .OR. SPEED(I).EQ.SPEED(I+1))  
     1    GO TO 240        
      IFLE  = 1        
      GO TO 240        
  230 IF (I.EQ.NSTNS .OR. NWORK(I+1).EQ.0) GO TO 240        
      IFLE  = 1        
  240 IF (IFTE .EQ. 0) GO TO 500        
      CALL ALG03 (LNCT,NSTRMS+8)        
      XN    = SPEED(I)*SPDFAC(ICASE)        
      XBLADE= 10.0        
      IF (NBLADE(I) .NE. 0) XBLADE = ABS(FLOAT(NBLADE(I)))        
      L1    = XBLADE        
      IF (IPRTC .EQ. 1) WRITE (LOG2,250) I,XN,L1        
  250 FORMAT (/10X,'STATION',I3,' IS WITHIN OR AT THE TRAILING EDGE OF',
     1        ' A BLADE ROTATING AT',F8.1,' RPM  NUMBER OF BLADES IN ', 
     2        'ROW =',I3, /10X,109(1H*), //,'  STREAM      BLADE     ', 
     2        'RELATIVE    RELATIVE   RELATIVE  DEVIATION    BLADE    ',
     3        '  LEAN    PRESS DIFF    LOSS     DIFFUSION   DELTA P',   
     5        /,'  -LINE',7X,'SPEED     VELOCITY    MACH NO.  FLOW',    
     6        ' ANGLE   ANGLE      ANGLE      ANGLE   ACROSS BLADE  ',  
     7        'COEFF      FACTOR     ON Q',/)        
      Q = 1.0        
      IF (SPEED(I) .LT. 0.0) GO TO 290        
      IF (SPEED(I) .GT. 0.0) GO TO 280        
      IF (I .LT. 3) GO TO 290        
      II = I - 1        
  260 IF (SPEED(II) .NE. 0.0) GO TO 270        
      IF (II .EQ. 2) GO TO 290        
      II = II - 1        
      GO TO 260        
  270 IF (SPEED(II) .LT. 0.0) Q = -1.0        
      GO TO 290        
  280 Q  = -1.0        
  290 L1 = NDIMEN(I) + 1        
      GO TO (300,320,340,360), L1        
  300 DO 310 J = 1,NSTRMS        
  310 TANEPS(J) = R(J,I)        
      GO TO 380        
  320 DO 330 J = 1,NSTRMS        
  330 TANEPS(J) = R(J,I)/R(NSTRMS,I)        
      GO TO 380        
  340 DO 350 J = 1,NSTRMS        
  350 TANEPS(J) = XL(J,I)        
      GO TO 380        
  360 DO 370 J = 1,NSTRMS        
  370 TANEPS(J) = XL(J,I)/XL(NSTRMS,I)        
  380 L1 = IS2(I)        
      IF (NWORK(I).EQ.5 .OR. NWORK(I).EQ.6) CALL ALG01 (DATAC(L1),      
     1    DATA6(L1),NDATA(I),TANEPS,DELTB,X1,NSTRMS,NTERP(I),0)        
      CALL ALG01 (DATAC(L1),DATA5(L1),NDATA(I),TANEPS,SOLID,X1,NSTRMS,  
     1            NTERP(I),0)        
      CALL ALG01 (DATAC(L1),DATA3(L1),NDATA(I),TANEPS,TANEPS,X1,NSTRMS, 
     1            NTERP(I),0)        
      L1 = I + NL1(I)        
      L2 = L1        
      IF (NLOSS(I).EQ.1 .OR. NLOSS(I).EQ.4 .OR. NWORK(I).EQ.7)        
     1    L2 = I + NL2(I)        
      XN = XN*PI/(30.0*SCLFAC)        
      DO 430 J = 1,NSTRMS        
      U  = XN*R(J,I)        
      VR = SQRT(VM(J,I)**2+(VW(J,I)-U)**2)        
      XMR  = XM(J)*VR/V(J)        
      BETA = ATAN(TBETA(J,I))*C1        
      BBETA= 0.0        
      IF (NWORK(I).EQ.5 .OR. NWORK(I).EQ.6) BBETA = BETA - DELTB(J)     
      DELTB(J) = DELTB(J)*Q        
      DELP = 0.0        
      IF (I.EQ.NSTNS .OR. NWORK(I+1).EQ.0 .OR. SPEED(I).NE.SPEED(I+1))  
     1    GO TO 390        
      X1 = SQRT((R(J,I+1)-R(J,I))**2+(X(J,I+1)-X(J,I))**2)        
      X2 = SQRT((R(J,I)-R(J,I-1))**2+(X(J,I)-X(J,I-1))**2)        
      X3 = XBLADE        
      DELP = PI*R(J,I)*WT(J)/(SCLFAC**2*X3*G)*(TBETA(J,I)/        
     1       (1.0+TBETA(J,I)**2)*TS(J)*G*EJ*((S(J,I+1)-S(J,I))/X1 +     
     2       (S(J,I)-S(J,I-1))/X2)+VM(J,I)/R(J,I)*((R(J,I+1)*VW(J,I+1) -
     3       R(J,I)*VW(J,I))/X1+(R(J,I)*VW(J,I)-R(J,I-1)*VW(J,I-1))/X2))
      DELTP(J,I) = DELP        
  390 HRI  = H(J,I) - (V(J)**2-VR**2)/(2.0*G*EJ)        
      PRD  = ALG4(HRI,S(J,L1))        
      PR   = ALG4(HRI,S(J,I))        
      TR(J,I) = ALG7(HRI,S(J,I))        
      PRL2 = PR        
      PSL2 = PS(J)*SCLFAC**2        
      IF (L2 .EQ. I) GO TO 400        
      PRL2 = H(J,L2) - (VW(J,L2)**2 - (VW(J,L2) - XN*R(J,L2))**2)/      
     1       (2.0*G*EJ)        
      PRL2 = ALG4(PRL2,S(J,L2))        
      PSL2 = H(J,L2) - (VW(J,L2)**2+VM(J,L2)**2)/(2.0*G*EJ)        
      PSL2 = ALG4(PSL2,S(J,L2))        
  400 COEF = (PRD-PR)/(PRL2-PSL2)        
      DIF  = 0.0        
      IF (SOLID(J) .EQ. 0.0) GO TO 410        
      X2   = VW(J,L1) - XN*R(J,L1)        
      X1   = SQRT(VM(J,L1)**2+X2**2)        
      X3   = VW(J,I) - U        
      DIF  = 1.0 - VR/X1 + (X2-X3)/(2.0*X1*SOLID(J))*Q        
  410 PRL1 = PRL2        
      PSL1 = PSL2        
      IF (L2 .EQ. L1) GO TO 420        
      PSL1 = H(J,L1) - (VW(J,L1)**2 + VM(J,L1)**2)/(2.0*G*EJ)        
      PRL1 = PSL1 + (VM(J,L1)**2 + (VW(J,L1)-XN*R(J,L1))**2)/(2.0*G*EJ) 
      PSL1 = ALG4(PSL1,S(J,L1))        
      PRL1 = ALG4(PRL1,S(J,L1))        
  420 DPQ  = (PS(J)-PSL1)/(PRL1-PSL1)        
  430 IF (IPRTC .EQ. 1) WRITE (LOG2,434) J,U,VR,XMR,BETA,DELTB(J),BBETA,
     1    TANEPS(J),DELP,COEF,DIF,DPQ        
  434 FORMAT (I6,F14.2,F11.2,F11.4,4F11.3,F11.4,F11.5,F10.4,F11.4)      
      CALL ALG03 (LNCT,NSTRMS+5)        
      PBAR = 0.0        
      HBAR = 0.0        
      DO 440 J = 1,ITUB        
      X1   = (DELF(J+1)-DELF(J))/2.0        
      PBAR = PBAR + X1*(PT(J)+PT(J+1))        
  440 HBAR = HBAR + X1*(H(J,I)+H(J+1,I))        
      RBAR1= PBAR/P1BAR        
      DH1  = (HBAR-H1BAR)/H1BAR        
      EFF1 = 0.0        
      IF (HBAR .NE. H1BAR) EFF1 = (ALG2(S1BAR,PBAR)-H1BAR)/(HBAR-H1BAR) 
      OPR  = RBAR1        
      IF (EFF1 .NE. 0.0) OEFF = EFF1        
      IF (L1 .EQ. L1KEEP) GO TO 460        
      L1KEEP= L1        
      PNBAR = 0.0        
      HNBAR = 0.0        
      DO 444 J = 1,NSTRMS        
  444 PN(J) = ALG4(H(J,L1),S(J,L1))        
      DO 450 J = 1,ITUB        
      X1    = (DELF(J+1)-DELF(J))/2.0        
      PNBAR = PNBAR + X1*(PN(J)+PN(J+1))        
  450 HNBAR = HNBAR + X1*(H(J,L1)+H(J+1,L1))        
      SNBAR = ALG3(PNBAR,HNBAR)        
  460 EFFN  = 0.0        
      IF (HNBAR .NE. HBAR) EFFN = (ALG2(SNBAR,PBAR)-HNBAR)/(HBAR-HNBAR) 
      RBARN = PBAR/PNBAR        
      DHN   = (HBAR-HNBAR)/HNBAR        
      IF (IPRTC .EQ. 1) WRITE (LOG2,470) I,L1,I,I,L1,I,RBAR1,RBARN,EFF1,
     1    EFFN,DH1,DHN        
  470 FORMAT (/,'  STREAM',7X,'INLET THROUGH STATION',I3,7X,'STATION',  
     1       I3,' THROUGH STATION',I3,5X,'MEAN VALUES',6X,        
     2       'INLET TO STA.',I2,'   STA.',I2,' TO STA.',I2, /,        
     3       '  -LINE',6X,'PRESSURE  ISENTROPIC  DELTA H    PRESSURE  ',
     4       'ISENTROPIC  DELTA H     PRESSURE RATIO',F14.4,F19.4, /15X,
     5       'RATIO   EFFICIENCY  ON H1        RATIO   EFFICIENCY  ON ',
     6       'H1       ISEN EFFY',2F19.4, /80X,'DELTA H ON H1',F15.4,   
     7       F19.4)        
      DO 480 J = 1,NSTRMS        
      RBAR1 = PT(J)/P1(J)        
      EFF1  = 0.0        
      IF (H(J,I) .NE. H(J,1)) EFF1 = (ALG2(S(J,1),PT(J))-H(J,1))/       
     1                               (H(J,I)-H(J,1))        
      DH1   = (H(J,I)-H(J,1))/H(J,1)        
      RBARN = PT(J)/PN(J)        
      EFFN  = 0.0        
      IF (H(J,I) .NE. H(J,L1)) EFFN = (ALG2(S(J,L1),PT(J))-H(J,L1))/    
     1                                (H(J,I)-H(J,L1))        
      DHN = (H(J,I)-H(J,L1))/H(J,L1)        
  480 IF (IPRTC .EQ. 1) WRITE (LOG2,490) J,RBAR1,EFF1,DH1,RBARN,EFFN,DHN
  490 FORMAT (I6,F14.4,F10.4,F11.4,F12.4,F10.4,F11.4)        
  500 IF (IFLE .EQ. 0) GO TO 700        
      CALL ALG03 (LNCT,NSTRMS+8)        
      XN = SPEED(I+1)*SPDFAC(ICASE)        
      IP = I + 1        
      XBLADE = 10.0        
      IF (NBLADE(IP) .NE. 0) XBLADE = ABS(FLOAT(NBLADE(IP)))        
      L1 = XBLADE        
      IF (IPRTC .EQ. 1) WRITE (LOG2,510) I,XN,L1        
  510 FORMAT (/10X,'STATION',I3,' IS AT THE LEADING EDGE OF A BLADE ',  
     1        'ROATING AT',F9.1,' RPM  NUMBER OF BLADES IN ROW =',I3,   
     2        /10X,99(1H*), //,'  STREAM      BLADE     RELATIVE   ',   
     3        'RELATIVE   RELATIVE  INCIDENCE    BLADE      LEAN    ',  
     4        'PRESS DIFF', /,'  -LINE       SPEED     VELOCITY   MACH',
     5        ' NO.  FLOW ANGLE   ANGLE      ANGLE      ANGLE   ACROSS',
     6        ' BLADE',/)        
      XN = XN*PI/(30.0*SCLFAC)        
      Q  = 1.0        
      IF (SPEED(IP) .LT. 0.0) GO TO 550        
      IF (SPEED(IP) .GT. 0.0) GO TO 540        
      IF (IP .LT. 3) GO TO 550        
      II = IP - 1        
  520 IF (SPEED(II) .NE. 0.0) GO TO 530        
      IF (II .EQ. 2) GO TO 550        
      II = II - 1        
      GO TO 520        
  530 IF (SPEED(II) .LT. 0.0) Q = -1.0        
      GO TO 550        
  540 Q = -1.0        
  550 DO 560 J = 1,NSTRMS        
      CR(J) = 0.0        
  560 TANEPS(J) = 0.0        
      IF (NWORK(I).NE.0 .OR. NDATA(I).EQ.0) GO TO 660        
      L1 = NDIMEN(I) + 1        
      GO TO (570,590,610,630), L1        
  570 DO 580 J = 1,NSTRMS        
  580 TANEPS(J) = R(J,I)        
      GO TO 650        
  590 DO 600 J = 1,NSTRMS        
  600 TANEPS(J) = R(J,I)/R(NSTRMS,I)        
      GO TO 650        
  610 DO 620 J = 1,NSTRMS        
  620 TANEPS(J) = XL(J,I)        
      GO TO 650        
  630 DO 640 J = 1,NSTRMS        
  640 TANEPS(J) = XL(J,I)/XL(NSTRMS,I)        
  650 L1 = IS2(I)        
      CALL ALG01 (DATAC(L1),DATA1(L1),NDATA(I),TANEPS,CR,X1,NSTRMS,     
     1            NTERP(I),0)        
      CALL ALG01 (DATAC(L1),DATA3(L1),NDATA(I),TANEPS,TANEPS,X1,NSTRMS, 
     1            NTERP(I),0)        
  660 BBETA = 0.0        
      DO 680 J = 1,NSTRMS        
      U   = XN*R(J,I)        
      VR  = SQRT(VM(J,I)**2 + (VW(J,I)-U)**2)        
      XMR = XM(J)*VR/V(J)        
      TR(J,I) = ALG7(H(J,I)-(V(J)**2-VR**2)/(2.0*G*EJ),S(J,I))        
      BETA = ATAN((VW(J,I)-U)/VM(J,I))*C1        
C        
C     STORE REL. MACH, REL. VEL AND REL. FLOW ANGLE FOR ALL STREAMLINES 
C     AT THE BLADE LEADING EDGE        
C        
      IF (ICASE.NE.1 .OR. I.NE.LEDGEB) GO TO 675        
      RMDV(J,1) = XMR        
      RMDV(J,3) = VR        
      RMDV(J,4) = BETA        
  675 CONTINUE        
      DELTB(J) = 0.0        
      IF (NWORK(I).NE.0 .OR. NDATA(I).EQ.0) GO TO 670        
      BBETA = ATAN((TAN(CR(J)/C1)*(1.0-GAMA(J)*TAN(PHI(J))) -        
     1        TAN(PHI(J))*TAN(TANEPS(J)/C1)*SQRT(1.0+GAMA(J)**2))*      
     2        COS(PHI(J)))*C1        
      DELTB(J) = (BETA-BBETA)*Q        
  670 X1   = SQRT((R(J,I+1)-R(J,I))**2+(X(J,I+1)-X(J,I))**2)        
      DELP = PI*R(J,I)*2.0*WT(J)/(SCLFAC**2*XBLADE*G)*(SIN(BETA/C1)*    
     1       COS(BETA/C1)*G*EJ*TS(J)*(S(J,I+1)-S(J,I))/X1+VM(J,I)/      
     2       (R(J,I)*X1)*(R(J,I+1)*VW(J,I+1)-R(J,I)*VW(J,I)))        
      DELTP(J,I) = DELP        
  680 IF (IPRTC .EQ. 1) WRITE (LOG2,690) J,U,VR,XMR,BETA,DELTB(J),BBETA,
     1    TANEPS(J),DELP        
  690 FORMAT (I6,F14.2,F11.2,F11.4,4F11.3,F11.4)        
  700 CONTINUE        
      IF (NBL .EQ. 0) GO TO 770        
      L1 = (ILAST-1)/10 + 1        
      CALL ALG03 (LNCT,3+5*L1)        
      IF (IPRTC .NE. 1) GO TO 770        
      WRITE  (LOG2,710)        
  710 FORMAT (/10X,'ANNULUS WALL BOUNDARY LAYER CALCULATION RESULTS',   
     1        /10X,47(1H*))        
      DO 720 K = 1,L1        
      L2 = 10*(K-1) + 1        
      L3 = L2 + 9        
      IF (L3 .GT. ILAST) L3 = ILAST        
      WRITE (LOG2,730) (I,I=L2,L3)        
      WRITE (LOG2,740) (DELH(I),I=L2,L3)        
      WRITE (LOG2,750) (DELT(I),I=L2,L3)        
      WRITE (LOG2,760) (WWBL(I),I=L2,L3)        
  720 CONTINUE        
  730 FORMAT (/,' STATION NUMBER',14X,10I10)        
  740 FORMAT (' HUB DISPLACEMENT THICKNESS',4X,10F10.5)        
  750 FORMAT (' CASE DISPLACEMENT THICKNESS',3X,10F10.5)        
  760 FORMAT (' BLOCKAGE AREA FRACTION',8X,10F10.5)        
  770 CALL ALG03 (LNCT,4)        
      IF (IPRTC.EQ.1 .AND. IVFAIL.EQ.0.AND.IFFAIL.EQ.0) WRITE (LOG2,780)
     1    ICASE,IPASS        
      IF (IFAILO .NE. 0) WRITE (LOG2,790) ICASE,IPASS,IFAILO        
      IF (IFAILO.EQ.0 .AND. (IVFAIL.NE.0.OR.IFFAIL.NE.0))        
     1    WRITE (LOG2,800) ICASE,IPASS,IVFAIL,IFFAIL        
  780 FORMAT (/10X,'POINT NO',I3,'   PASS',I3,'   THE CALCULATION IS ', 
     1       'CONVERGED', /10X,52(1H*))        
  790 FORMAT (/10X,'POINT NO',I3,'   PASS',I3,'   THE CALCULATION FAIL',
     1       'ED AT STATION',I3, /10X,60(1H*))        
  800 FORMAT (/10X,'POINT NO',I3,'   PASS',I3,'   THE CALCULATION IS ', 
     1       'NOT FULLY CONVERGED  IVFAIL =',I3,'  IFFAIL =',I3, /10X,  
     2       88(1H*))        
      POWER = FLOW(ICASE)*(HBAR-H1BAR)*EJ/PFAC        
      IF (IPRTC .EQ. 1) WRITE (LOG2,810) SPDFAC(ICASE),FLOW(ICASE),OPR, 
     1        OEFF,POWER        
  810 FORMAT (10X,'SPEED FACTOR =',F10.3,'  FLOW =',F8.3,'  TOTAL PRES',
     1        'SURE RATIO =',F7.3,'  ISENTROPIC EFFICIENCY =',F6.4,     
     2        '  POWER =',E11.4)        
      IF (IPRTC .EQ. 0) WRITE (LOG2,815) ICASE,IPASS,SPDFAC(ICASE),     
     1        FLOW(ICASE),OPR,OEFF,POWER        
  815 FORMAT  (18H     FOR POINT NO.,I3,5H PASS,I3,15H - SPEED FACTOR,  
     1        10X,1H=,F10.4 / 32X,4HFLOW,18X,1H=,F10.4, /        
     2        32X,23HTOTAL PRESSURE RATIO  =,F10.4, /32X,'ISENTROPIC ', 
     3        'EFFICIENCY =',F10.4, /32X,'POWER',17X,1H=,E10.4)        
      IF (IFAILO .NE. 0) GO TO 920        
      L1 = 2        
  820 DO 830 I = L1,NSTNS        
      NOUT3S = NOUT3(I)/10        
      IF (NOUT3S .EQ. 0) NOUT3S = NOUT3(I)        
      IF (NOUT3S.EQ.1 .OR. NOUT3S.EQ.3) GO TO 840        
  830 CONTINUE        
      GO TO 920        
  840 L2 = I        
      L3 = I + 1        
      DO 850 I = L3,NSTNS        
      NOUT3S = NOUT3(I)/10        
      NOUT3T = NOUT3(I) - NOUT3S*10        
      IF (NOUT3S .EQ. 0) NOUT3T = 1        
      IF (NOUT3S .EQ. 0) NOUT3S = NOUT3(I)        
      IF (NOUT3S.EQ.2 .OR. NOUT3S.EQ.3) GO TO 860        
  850 CONTINUE        
  860 L3 = I        
      CALL ALG03 (LNCT,10)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,870) L2,L3        
  870 FORMAT (/10X,'DATA FOR NASTRAN PROGRAM FOR BLADE BETWEEN STATIONS'
     1,      I3,' AND',I3, /10X,61(1H*),//)        
      IF (NOUT3T .EQ. 2) GO TO 891        
      IF (IPRTC  .EQ. 1) WRITE (LOG2,871)        
  871 FORMAT (' NAME   CODE    DELTA P   ELEMENT',7X,        
     1       'MESHPOINTS -  J   I',9X,'J   I',9X,'J   I',/)        
      LNCT  = LNCT - 4        
      IELEM = 0        
      XSIGN =-FLOAT(NSIGN)        
      L4    = L2 + 1        
      IDATA(1) = NAME1(1)        
      IDATA(2) = NAME1(2)        
      IDATA(3) = 60        
      DO 890 J = 1,ITUB        
      DO 890 I = L4,L3        
      CALL ALG03 (LNCT,2)        
      IELEM = IELEM + 1        
      L5 = I - 1        
      L6 = J + 1        
      IF (I .EQ. L3) GO TO 880        
      PLOAD = XSIGN*((DELTP(J,L5)+DELTP(L6,L5)+DELTP(L6,I))/3.0)        
      IF (NBLADE(I) .LT. 0) PLOAD = XSIGN*((DELTP(J,L5)+DELTP(J,I) +    
     1    DELTP(L6,L5)+DELTP(L6,I))*0.25)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,900) PLOAD,IELEM,L6,L5,L6,I,J,L5    
C     WRITE (LOG3,910) PLOAD,IELEM        
      RDATA(4) = PLOAD        
      IDATA(5) = IELEM        
      CALL WRITE (ISCR,IDATA,5,1)        
      IELEM = IELEM + 1        
      IF (NBLADE(I) .GE. 0) PLOAD = XSIGN*((DELTP(J,L5)+DELTP(L6,I)+    
     1    DELTP(J,I))/3.0)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,900) PLOAD,IELEM,J,L5,L6,I,J,I      
C     WRITE (LOG3,910) PLOAD,IELEM        
      RDATA(4) = PLOAD        
      IDATA(5) = IELEM        
      CALL WRITE (ISCR,IDATA,5,1)        
      GO TO 890        
  880 PLOAD    = XSIGN*((DELTP(J,L5)+DELTP(L6,L5))/3.0)        
      IF (NBLADE(I) .LT. 0) PLOAD = PLOAD*0.75        
      IF (IPRTC .EQ. 1) WRITE (LOG2,900) PLOAD,IELEM,J,L5,L6,L5,L6,I    
C     WRITE (LOG3,910) PLOAD,IELEM        
      RDATA(4) = PLOAD        
      IDATA(5) = IELEM        
      CALL WRITE (ISCR,IDATA,5,1)        
      IELEM    = IELEM + 1        
      IF (NBLADE(I) .GE. 0) PLOAD = XSIGN*(DELTP(J,L5)/3.0)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,900) PLOAD,IELEM,J,L5,L6,I,J,I      
C     WRITE (LOG3,910) PLOAD,IELEM        
      RDATA(4) = PLOAD        
      IDATA(5) = IELEM        
      CALL WRITE (ISCR,IDATA,5,1)        
  890 CONTINUE        
  900 FORMAT (' PLOAD2   60',F12.5,I7,14X,3(I10,I4))        
C 910 FORMAT ('PLOAD2   60',F13.5,I8)        
      L1 = L3        
  891 IF (NOUT3T .EQ. 1) GO TO 820        
C        
C     OUTPUT RELATIVE TOTAL TEMPERATURES AT NODES ON *TEMP* CARDS       
C        
      CALL ALG03 (LNCT,10)        
      LNCT = LNCT - 6        
      IF (IPRTC .EQ. 1) WRITE (LOG2,892)        
  892 FORMAT (//,' NAME   CODE    DELTA T   NODE',10X,'MESHPOINTS -  ', 
     1        'J   I   COORDINATES -   RADIAL       AXIAL',/)        
      INODE = 1        
      IDATA(1) = NAME2(1)        
      IDATA(2) = NAME2(2)        
      IDATA(3) = 70        
      DO 894 J = 1,NSTRMS        
      DO 894 I = L2,L3        
      CALL ALG03(LNCT,1)        
      IDATA(4) = INODE        
      RDATA(5) = TR(J,I)        
      CALL WRITE (ISCR,IDATA,5,1)        
C     WRITE (LOG3,913) INODE,TR(J,I)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,912) TR(J,I),INODE,J,I,R(J,I),X(J,I)
  894 INODE = INODE + 1        
  912 FORMAT (' TEMP     70',F12.5,I6,21X,2I4,16X,F10.4,2X,F10.4)       
C 913 FORMAT ('TEMP    70',6X,I8,F8.3)        
      GO TO 820        
  920 CONTINUE        
C        
C     PUNCH STREAML2 BULK DATA CARDS FOR EACH STREAMLINE        
C     CHANGE THE SIGN ON THE STAGGER AND FLOW ANGLES FOR STREAML2 CARDS.
C     THIS CHANGE IS NECESSARY BECAUSE OF THE AERODYNAMIC PROGRAMS IN   
C     NASTRAN MODULE AMG THAT USE THESE ANGLES.        
C        
      IF (LEDGEB*ITRLEB .EQ. 0) GO TO 940        
      IF (ISTRML.EQ.-1 .OR. ISTRML.EQ.1) GO TO 940        
      WRITE (LOG2,931)        
      NSTNSX = ITRLEB - LEDGEB + 1        
      DO 930 ILEB = 1,NSTRMS        
      RADIUS = (RMDV(ILEB,5)+RMDV(ILEB,6))/2.0        
      BSPACE = (6.283185*RADIUS)/FLOAT(NBLDES)        
      STAG(ILEB  ) = -1.0*STAG(ILEB  )        
      RMDV(ILEB,4) = -1.0*RMDV(ILEB,4)        
      WRITE (LPUNCH,932) ILEB,NSTNSX,STAG(ILEB),CHORDD(ILEB),RADIUS,    
     1       BSPACE,RMDV(ILEB,1),RMDV(ILEB,2),ILEB,ILEB,RMDV(ILEB,3),   
     2       RMDV(ILEB,4)        
      WRITE (LOG2,933) ILEB,NSTNSX,STAG(ILEB),CHORDD(ILEB),RADIUS,      
     1       BSPACE,RMDV(ILEB,1),RMDV(ILEB,2),RMDV(ILEB,3),RMDV(ILEB,4) 
  930 CONTINUE        
  931 FORMAT (//10X,47HNASTRAN - STREAML2 - COMPRESSOR BLADE BULK DATA, 
     1       /10X,49(1H*), /,'  SLN  NSTNS  STAGGER    CHORD    RADIUS',
     2       '    BSPACE     MACH       DEN       VEL      FLOWA',/)    
  932 FORMAT (8HSTREAML2,2I8,F8.3,3F8.5,2F8.6,5H+STRL,I2,5H+STRL,I2,    
     1        F8.1,F8.3 )        
  933 FORMAT (I5,I6,2X,F8.3,3(2X,F8.5),2(2X,F8.6),2X,F8.1,2X,F8.3)      
  940 CONTINUE        
      RETURN        
      END        
