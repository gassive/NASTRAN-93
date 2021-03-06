      SUBROUTINE SOFI        
C        
C     MODULE USED TO COPY SELECTED ITEMS FROM SELECTED SUBSTRUCTURES    
C     ONTO NASTRAN MATRIX FILES.   THE CALLING SEQUENCE TO THE MODULE   
C     IS        
C     SOFI   /A,B,C,D,E/V,N,DRY/C,N,NAME/C,N,IA/C,N,IB/C,N,IC/C,N,ID/   
C                       C,N,IE $        
C        
      INTEGER         DRY,FILE,SYSBUF,XXXX        
      DIMENSION       FILE(5),MODNAM(2),MCB(7)        
      CHARACTER       UFM*23,UWM*25        
      COMMON /XMSSG / UFM,UWM        
      COMMON /BLANK / DRY,NAME(2), ITEMS(2,5)        
CZZ   COMMON /ZZSOFI/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /SYSTEM/ SYSBUF,NOUT        
      DATA    FILE  / 201,202,203,204,205 /        
      DATA    IBLNK , XXXX/4H    ,4HXXXX  /        
      DATA    MODNAM/ 4HSOFI,4H           /        
C        
      DO 5 I = 1,5        
      IF (ITEMS(1,I).EQ.XXXX .OR. ITEMS(1,I).EQ.0) ITEMS(1,I) = IBLNK   
    5 CONTINUE        
C        
      NZ = KORSZ(IZ)        
      IF (3*SYSBUF .GT. NZ) CALL MESAGE (-8,0,MODNAM(1))        
      IB1 = NZ  - SYSBUF + 1        
      IB2 = IB1 - SYSBUF - 1        
      IB3 = IB2 - SYSBUF        
      CALL SOFOPN (IZ(IB1),IZ(IB2),IZ(IB3))        
      IF (DRY .GE. 0) GO TO 60        
C        
C     CHECK THE EXISTENCE OF THE SOF FILE.        
C        
      DO 50 I = 1,5        
      IF (ITEMS(1,I) .EQ. IBLNK) GO TO 50        
      MCB(1) = FILE(I)        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 50        
      CALL SOFTRL (NAME(1),ITEMS(1,I),MCB)        
      ITEST = MCB(1)        
      GO TO (50,50,20,30,40), ITEST        
   20 WRITE (NOUT,1020) UWM,ITEMS(1,I),NAME(1),NAME(2)        
      GO TO 45        
   30 WRITE (NOUT,1030) UWM,NAME(1),NAME(2)        
      DRY = -2        
      GO TO 130        
   40 WRITE (NOUT,1040) UWM,ITEMS(1,I)        
   45 DRY = -2        
   50 CONTINUE        
      GO TO 130        
C        
C     COPY SOF DATA INTO NASTRAN DATA BLOCKS        
C        
   60 DO 120 I = 1,5        
      IF (ITEMS(1,I) .EQ. IBLNK) GO TO 120        
      MCB(1) = FILE(I)        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LT. 0) GO TO 120        
      CALL MTRXI (FILE(I),NAME(1),ITEMS(1,I),0,ITEST)        
      GO TO (120,70,80,90,100,120), ITEST        
   70 WRITE (NOUT,1050) UWM,ITEMS(1,I),NAME(1),NAME(2)        
      GO TO 110        
   80 WRITE (NOUT,1020) UWM,ITEMS(1,I),NAME(1),NAME(2)        
      GO TO 120        
   90 WRITE (NOUT,1030) UWM,NAME(1),NAME(2)        
      DRY = -2        
      GO TO 130        
  100 WRITE (NOUT,1040) UWM,ITEMS(1,I)        
  110 DRY = -2        
  120 CONTINUE        
  130 CALL SOFCLS        
      RETURN        
C        
C     ERROR MESSAGES.        
C        
 1020 FORMAT (A25,' 6216, MODULE SOFI - ITEM ',A4,' OF SUBSTRUCTURE ',  
     1        2A4,' DOES NOT EXIST.')        
 1030 FORMAT (A25,' 6212, MODULE SOFI - THE SUBSTRUCTURE ',2A4,        
     1        ' DOES NOT EXIST.')        
 1040 FORMAT (A25,' 6213, MODULE SOFI - ',A4,' IS AN ILLEGAL ITEM NAME')
 1050 FORMAT (A25,' 6215, MODULE SOFI - ITEM ',A4,' OF SUBSTRUCTURE ',  
     1        2A4,' PSEUDO-EXISTS ONLY.')        
      END        
