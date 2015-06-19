      SUBROUTINE AKP2
C
      COMPLEX AI
C
      COMMON/BLK1/SCRK,SPS,SNS,DSTR,AI,PI,DEL,SIGMA,BETA,RES
C
      GAM=SQRT(DEL**2-SCRK**2)
      S1=SNS*GAM
      C1=(SIGMA-S1)/2.0
      C2=(SIGMA+S1)/2.0
      DGDA=DEL/GAM
      D1=SPS/2.0
      D2=SNS/2.0*DGDA
      DC1DA=D1-D2
      DC2DA=D1+D2
      RES=1.0/GAM*DGDA+SNS*COS(S1)/SIN(S1)*DGDA
     1-COS(C1)/SIN(C1)*DC1DA-COS(C2)/SIN(C2)*DC2DA
      RETURN
      END