      SUBROUTINE MRED2        
C        
C     THIS SUBROUTINE IS THE MRED2 MODULE WHICH PERFORMS THE MAJOR      
C     COMPUTATIONS FOR THE REDUCE COMMAND.        
C        
C     DMAP CALLING SEQUENCE        
C     MRED2    CASECC,LAMAMR,PHISS,EQST,USETMR,KAA,MAA,BAA,K4AA,PAA,DMR,
C              QSM/KHH,MHH,BHH,K4HH,PHH,POVE/STEP/S,N,DRY/POPT $        
C        
C     12 INPUT DATA BLOCKS        
C     GINO -   CASECC - CASE CONTROL DATA        
C              LAMAMR - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED 
C              PHISS  - EIGENVECTORS FOR SUBSTRUCTURE BEING REDUCED     
C              EQST   - EQSS DATA FOR BOUNDARY SET FOR SUBSTRUCTURE     
C                       BEINGREDUCED        
C              USETMR - USET TABLE FOR REDUCED SUBSTRUCTURE        
C              KAA    - SUBSTRUCTURE STIFFNESS MATRIX        
C              MAA    - SUBSTRUCTURE MASS MATRIX        
C              BAA    - SUBSTRUCTURE VISCOUS DAMPING MATRIX        
C              K4AA   - SUBSTRUCTURE STRUCTURE DAMPINF MATRIX        
C              PAA    - SUBSTRUCTURE LOAD MATRIX        
C              DMR    - FREE BODY MATRIX        
C              QSM    - MODEL REACTION MATRIX        
C     SOF  -   LAMS   - EIGENVALUE TABLE FOR ORIGINAL SUBSTRUCTURE      
C              PHIS   - EIGENVECTOR TABLE FOR ORIGINAL SUBSTRUCTURE     
C              LMTX   - STIFFNESS DECOMPOSITION PRODUCT FOR ORIGINAL    
C                       SUBSTRUCTURE        
C              GIMS   - G TRANSFORMATION MATRIX FOR BOUNDARY POINTS FOR 
C                       ORIGINAL SUBSTRUCTURE        
C              HORG   - H TRANSFORMATION MATRIX FOR ORIGINAL        
C                       SUBSTRUCTURE        
C        
C     6 OUTPUT DATA BLOCKS        
C     GINO -   KHH    - REDUCED STIFFNESS MATRIX        
C              MHH    - REDUCED MASS MATRIX        
C              BHH    - REDUCED VISCOUS DAMPING MATRIX        
C              K4HH   - REDUCED STRUCTURE DAMPING MATRIX        
C              PHH    - REDUCED LOAD MATRIX        
C              POVE   - INTERIOR POINT LOAD MATRIX        
C     SOF  -   LAMS   - EIGENVALUE TABLE FOR ORIGINAL SUBSTRUCTURE      
C              PHIS   - EIGENVECTOR TABLE FOR ORIGINAL SUBSTRUCTURE     
C              LMTX   - STIFFNESS DECOMPOSITION PRODUCT FOR ORIGINAL    
C                       SUBSTRUCTURE        
C              GIMS   - G TRANSFORMATION MATRIX FOR BOUNDARY POINTS FOR 
C                       ORIGINAL SUBSTRUCTURE        
C              HORG   - H TRANSFORMATION MATRIX FOR ORIGINAL        
C                       SUBSTRUCTURE        
C              UPRT   - PARTITIONING VECTOR FOR MREDUCE FOR ORIGINAL    
C                       SUBSTRUCTURE        
C              POVE   - INTERNAL POINT LOADS FOR ORIGINAL SUBSTRUCTURE  
C              POAP   - INTERNAL POINTS APPENDED LOADS FOR ORIGINAL     
C                       SUBSTRUCTURE        
C              EQSS   - SUBSTRUCTURE EQUIVALENCE TABLE FOR REDUCED      
C                       SUBSTRUCTURE        
C              BGSS   - BASIC GRID POINT DEFINITION TABLE FOR REDUCED   
C                       SUBSTRUCTURE        
C              CSTM   - COORDINATE SYSTEM TRANSFORMATION MATRICES FOR   
C                       REDUCED SUBSTRUCTURE        
C              LODS   - LOAD SET DATA FOR REDUCED SUBSTRUCTURE        
C              LOAP   - APPENDED LOAD SET DATA FOR REDUCED SUBSTRUCTURE 
C              PLTS   - PLOT SET DATA FOR REDUCED SUBSTRUCTURE        
C              KMTX   - STIFFNESS MATRIX FOR REDUCED SUBSTRUCTURE       
C              MMTX   - MASS MATRIX FOR REDUCED SUBSTRUCTURE        
C              PVEC   - LOAD MATRIX FOR REDUCED SUBSTRUCTURE        
C              PAPD   - APPENDED LOAD MATRIX FOR REDUCED SUBSTRUCTURE   
C              BMTX   - VISCOUS DAMPING MATRIX FOR REDUCED SUBSTRUCTURE 
C              K4MX   - STRUCTURE DAMPING MATRIX FOR REDUCED        
C                       SUBSTRUCTURE        
C        
C     11 SCRATCH DATA BLOCKS        
C        
C     PARAMETERS        
C     INPUT  - STEP   - CONTROL DATA CASECC RECORD (INTEGER)        
C              POPT   - PVEC OR PAPP OPTION FLAG (BCD)        
C     OUTPUT - DRY    - MODULE OPERATION FLAG (INTEGER)        
C     OTHERS - GBUF   - GINO BUFFERS        
C              SBUF   - SOF BUFFERS        
C              INFILE - INPUT FILE NUMBERS        
C              OTFILE - OUTPUT FILE NUMBERS        
C              ISCR   - ARRAY OF SCRATCH FILE NUMBERS        
C              ISCR11 - LII PARTITION MATRIX USED IN MRED2B AND MRED2F  
C              KORLEN - LENGTH OF OPEN CORE        
C              KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C              OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C              NEWNAM - NAME OF REDUCED SUBSTRUCTURE        
C              FREBDY - FREE BODY MODES CALCULATION FLAG        
C              RANGE  - RANGE OF FREQUENCIES TO BE USED        
C              NMAX   - MAXIMUM NUMBER OF FREQUENCIES TO BE USED        
C              USRMOD - USERMODES CALCULATION FLAG        
C              IO     - IO OPTIONS FLAG        
C              BOUNDS - OLDBOUNDS OPTION FLAG        
C              MODES  - OLDMODES OPTION FLAG        
C              RSAVE  - SAVE REDUCTION PRODUCT FLAG        
C              LAMSAP - BEGINNING ADDRESS OF MODE USE DESCRIPTION ARRAY 
C              MODPTS - NUMBER OF MODAL POINTS        
C              MODLEN - LENGTH OF MODE USE ARRAY        
C        
      EXTERNAL        ORF        
      LOGICAL         FREBDY,BOUNDS,MODES,RSAVE,PONLY        
      INTEGER         STEP,DRY,POPT,GBUF1,GBUF2,SBUF1,SBUF2,SBUF3,      
     1                OTFILE,OLDNAM,USRMOD,GBUF3,Z,SYSBUF,CASECC,ORF    
      DIMENSION       MODNAM(2),NMONIC(10),RZ(1),ITRLR(7)        
      COMMON /BLANK / STEP,DRY,POPT,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,SBUF3,
     1                INFILE(12),OTFILE(6),ISCR(10),KORLEN,KORBGN,      
     2                OLDNAM(2),NEWNAM(2),FREBDY,RANGE(2),NMAX,USRMOD,  
     3                IO,BOUNDS,MODES,RSAVE,LAMSAP,MODPTS,MODLEN,PONLY, 
     4                LSTZWD,ISCR11        
CZZ   COMMON /ZZMRD2/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,IPRNTR        
      EQUIVALENCE     (CASECC,INFILE(1)), (RZ(1),Z(1))        
      DATA    NMONIC/ 4HNAMA,4HNAMB,4HFREE,4HRANG,4HNMAX,4HUSER,4HOUTP, 
     1                4HOLDB,4HOLDM,4HRSAV/        
      DATA    IBLANK, NHLODS,NHLOAP/4H    ,4HLODS,4HLOAP/        
      DATA    MODNAM/ 4HMRED,4H2   /        
      DATA    ITRLR / 106   ,6*0   /        
C        
C     COMPUTE OPEN CORE AND DEFINE GINO, SOF BUFFERS        
C        
      IF (DRY .EQ. -2) RETURN        
      NOZWDS = KORSZ(Z(1))        
      LSTZWD = NOZWDS- 1        
      GBUF1  = NOZWDS- SYSBUF - 2        
      GBUF2  = GBUF1 - SYSBUF        
      GBUF3  = GBUF2 - SYSBUF        
      SBUF1  = GBUF3 - SYSBUF        
      SBUF2  = SBUF1 - SYSBUF - 1        
      SBUF3  = SBUF2 - SYSBUF        
      KORLEN = SBUF3 - 1        
      KORBGN = 1        
      IF (KORLEN .LE. KORBGN) GO TO 290        
C        
C     INITIALIZE SOF        
C        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
C        
C     INITIALIZE CASE CONTROL PARAMETERS        
C        
      DO 2 I = 1,12        
    2 INFILE(I) = 100 + I        
      DO 4 I = 1,6        
    4 OTFILE(I) = 200 + I        
      DO 6 I = 1, 10        
    6 ISCR(I) = 300 + I        
      ISCR11  = 311        
      DO 10 I = 1, 2        
      OLDNAM(I) = IBLANK        
   10 NEWNAM(I) = IBLANK        
      RANGE(1) = 0.0        
      RANGE(2) = 1.0E+35        
      FREBDY = .FALSE.        
      NMAX   = 2147483647        
      USRMOD = -1        
      IO     = 0        
      NRANGE = 0        
      BOUNDS = .FALSE.        
      MODES  = .FALSE.        
      RSAVE  = .FALSE.        
      PONLY  = .FALSE.        
C        
C     ** PROCESS CASE CONTROL        
C        
      IFILE  = CASECC        
      CALL OPEN (*260,CASECC,Z(GBUF2),0)        
      IF (STEP) 20,40,20        
   20 DO 30 I = 1, STEP        
   30 CALL FWDREC (*280,CASECC)        
C        
C     READ CASECC        
C        
   40 CALL READ (*270,*280,CASECC,Z(KORBGN),2,0,NWDSRD)        
      NWDSCC = Z(KORBGN+1)        
      DO 200 I = 1,NWDSCC,3        
      CALL READ (*270,*280,CASECC,Z(KORBGN),3,0,NWDSRD)        
C        
C     TEST CASE CONTROL MNEMONICS        
C        
      DO 50 J = 1,10        
      IF (Z(KORBGN) .EQ. NMONIC(J)) GO TO 60        
   50 CONTINUE        
      GO TO 200        
C        
C     SELECT DATA TO EXTRACT        
C        
   60 GO TO (70,90,110,120,140,150,160,170,180,190), J        
C        
C     EXTRACT NAME OF SUBSTRUCTURE BEING REDUCED        
C        
   70 DO 80 K = 1,2        
   80 OLDNAM(K) = Z(KORBGN+K)        
      GO TO 200        
C        
C     EXTRACT NAME OF REDUCED SUBSTRUCTURE        
C        
   90 DO 100 K = 1,2        
  100 NEWNAM(K) = Z(KORBGN+K)        
      GO TO 200        
C        
C     EXTRACT FREEBODY MODES FLAG        
C        
  110 FREBDY = .TRUE.        
      GO TO 200        
C        
C     EXTRACT FREQUENCY RANGE        
C        
  120 IF (NRANGE .EQ. 1) GO TO 130        
      NRANGE = 1        
      RANGE(1) = RZ(KORBGN+2)        
      GO TO 200        
  130 RANGE(2) = RZ(KORBGN+2)        
      GO TO 200        
C        
C     EXTRACT MAXIMUM NUMBER OF FREQUENCIES        
C        
  140 IF (Z(KORBGN+2) .EQ. 0) GO TO 200        
      NMAX = Z(KORBGN+2)        
      GO TO 200        
C        
C     EXTRACT USERMODE FLAG        
C        
  150 USRMOD = Z(KORBGN+2)        
      GO TO 200        
C        
C     EXTRACT OUTPUT FLAGS        
C        
  160 IO = ORF(IO,Z(KORBGN+2))        
      GO TO 200        
C        
C     EXTRACT OLDBOUND FLAG        
C        
  170 BOUNDS = .TRUE.        
      GO TO 200        
C        
C     EXTRACT OLDMODES FLAG        
C        
  180 MODES = .TRUE.        
      GO TO 200        
C        
C     EXTRACT REDUCTION SAVE FLAG        
C        
  190 RSAVE = .TRUE.        
C        
  200 CONTINUE        
      CALL CLOSE (CASECC,1)        
C        
C     TEST FOR RUN = GO        
C        
      MRD2G = 1        
      IF (DRY .EQ. 0) GO TO 230        
C        
C     CHECK FOR USERMODE = TYPE 2        
C        
      IF (USRMOD .EQ. 2) GO TO 210        
C        
C     CHECK FOR STIFFNESS PROCESSING        
C        
      CALL RDTRL (ITRLR)        
      IF (ITRLR(1) .GT. 0) GO TO 208        
C        
C     CHECK FOR LOADS ONLY        
C        
      CALL SFETCH (NEWNAM,NHLODS,3,ITEST)        
      IF (ITEST .EQ. 3) GO TO 204        
      CALL SFETCH (NEWNAM,NHLOAP,3,ITEST)        
      IF (ITEST .EQ. 3) GO TO 204        
      MRD2G = 4        
      GO TO 230        
  204 MRD2G = 3        
      PONLY = .TRUE.        
      GO TO 230        
C        
C     PROCESS STIFFNESS MATRIX        
C        
  208 MRD2G = 2        
      CALL MRED2A        
C        
C     PROCESS OLDBOUND FLAG        
C        
      CALL MRED2B        
C        
C     PROCESS OLDMODES FLAG        
C        
      CALL MRED2C (1)        
      GO TO 220        
C        
C     PROCESS USERMODES FLAG        
C        
  210 CALL MRED2D        
      CALL MRED2C (3)        
      GO TO 240        
C        
C     CALCULATE MODAL TRANSFORMATION MATRIX        
C        
  220 CALL MRED2E        
      CALL MRED2C (2)        
C        
C     CALCULATE FREE BODY EFFECTS        
C        
      CALL MRED2F        
C        
C     CALCULATE STRUCTURAL MATRICES        
C        
C     MRD2G .EQ. 1, M,B,K4,P/PA PROCESSING (RUN = GO)        
C     MRD2G .EQ. 2, K,M,B,K4,P/PA PROCESSING        
C     MRD2G .EQ. 3, P/PA PROCESSING (ONLY)        
C     MRD2G .EQ. 4, M,B,K4,P/PA PROCESSING (RUN = STEP)        
C        
  230 CALL MRED2G (MRD2G)        
      IF (MRD2G .EQ. 1) GO TO 250        
C        
C     PROCESS NEW TABLE ITEMS        
C        
  240 CALL MRED2H        
C        
C     CLOSE ANY OPEN FILES        
C        
  250 CALL SOFCLS        
      IF (DRY .EQ. -2) WRITE (IPRNTR,900)        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  260 IMSG = -1        
      GO TO 300        
  270 IMSG = -2        
      GO TO 300        
  280 IMSG = -3        
      GO TO 300        
  290 IMSG = -8        
      IFILE = 0        
  300 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
  900 FORMAT (//,'  MODULE MREDUCE TERMINATING DUE TO ABOVE ERRORS.')   
C        
      END        
