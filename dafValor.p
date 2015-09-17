&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEF TEMP-TABLE ttwebin
  FIELD paramName AS CHAR
  FIELD paramValue AS CHAR.

DEFINE TEMP-TABLE dafValor NO-UNDO LIKE TNA_DAF_VALOR
    FIELD valorenText AS CHAR
   {shared/web/webservice_ttaddfields.i}.

DEFINE TEMP-TABLE instrument NO-UNDO LIKE zdv_valor
   FIELD nval AS CHAR
   FIELD isin AS CHAR
   {shared/web/webservice_ttaddfields.i}.

DEFINE TEMP-TABLE dafRates NO-UNDO LIKE tna_daf_rates
   {shared/web/webservice_ttaddfields.i}.

DEF TEMP-TABLE ttRates 
  FIELD field01 AS CHAR
  FIELD field02 AS CHAR
  FIELD field03 AS CHAR
  FIELD field04 AS CHAR
  FIELD field05 AS CHAR
  FIELD field06 AS CHAR
  FIELD field07 AS CHAR
  FIELD field08 AS CHAR
  FIELD fieldError AS CHAR.

DEFINE INPUT PARAMETER TABLE FOR ttwebin.

DEFINE VARIABLE coutput        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cLine          AS CHARACTER   NO-UNDO.


coutput  = ENTRY(2,SESSION:PARAMETER).
coutput = ENTRY(1,coutput,'.') + '.json'.


{shared/web/wservices.i}

/*{src/web2/wrap-cgi.i}*/

wServiceMainStandard().


INPUT FROM VALUE(cOutput).
REPEAT:
  IMPORT UNFORMATTED cline.
  PUT UNFORMATTED cline SKIP.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15.76
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

 


/* Ende Main ********************************************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-checkValorAvail) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkValorAvail Procedure 
PROCEDURE checkValorAvail :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE cValor  AS CHARACTER   NO-UNDO.
  
  wServicePrepareResultDataSetOneTable(BUFFER dafValor:HANDLE).
  
  cValor = get-value('dafValor.NVAL').

  DO WHILE LENGTH(cValor) < 9:
    cValor = '0' + cValor.
  END.

  FIND FIRST zdv_nummer WHERE zdv_nummer.typ_cd = 'CH' AND zdv_nummer.n_val = cValor NO-LOCK NO-ERROR.
  FIND FIRST zdv_valor OF zdv_nummer NO-LOCK NO-ERROR.
      
      /*wServiceAddInformation('OK','validate','valor available').*/

  CREATE dafValor. 
  ASSIGN dafValor.NVAL        = IF AVAIL zdv_nummer THEN zdv_nummer.n_val ELSE '' 
         dafValor.valorenText = IF AVAIL zdv_valor THEN zdv_valor.tvak[1] ELSE 'Instrument does not exist'.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-convertXls2Csv) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convertXls2Csv Procedure 
PROCEDURE convertXls2Csv :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAMETER pInFiles AS CHARACTER   NO-UNDO.
DEFINE OUTPUT PARAMETER pOutFile AS CHARACTER   NO-UNDO.


DEFINE VARIABLE chExcel       AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE chWorkBook    AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE z1            AS INTEGER     NO-UNDO.
DEFINE VARIABLE cPfad         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cNewFileListe AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cdeleteFile   AS CHARACTER   NO-UNDO.

  /* ---------------------------------------------------------------------- */
  /* Umwandlung Excel - CSV */
  /* ---------------------------------------------------------------------- */
  CREATE "Excel.Application":U chExcel.
  chExcel:VISIBLE = FALSE.

  DO z1 = 1 TO NUM-ENTRIES(pInFiles):
  
    cPfad = SUBSTRING(ENTRY(z1,pInFiles), 1 , R-INDEX(ENTRY(z1,pInFiles), ".")). 
    cPfad = cPfad + "csv".
    cdeleteFile = cPfad.
    IF SEARCH(cdeleteFile) <> ? THEN OS-DELETE VALUE(cdeleteFile).
    cNewFileListe = cNewFileListe 
                    + (IF cNewFileListe = "" THEN "" ELSE ",")
                    + cPfad.

    chWorkBook = chExcel:Workbooks:OPEN(ENTRY(z1,pInFiles)).
    chWorkBook:SaveAs(cPfad,24,,,,,4,,,,).  
    chWorkBook:CLOSE(0).
      
  END.
  
  chExcel:QUIT().

  IF VALID-HANDLE(chWorkBook) THEN RELEASE OBJECT chWorkBook.
  IF VALID-HANDLE(chExcel)    THEN RELEASE OBJECT chExcel.

  pOutFile = cNewFileListe.

  /* ---------------------------------------------------------------------- */
  /* Neu generierte Files ggf. zusammenhängen */
  /* ---------------------------------------------------------------------- */
  /*
  DO z1 = 1 TO NUM-ENTRIES(cNewFileListe):
  
    edtDummy:INSERT-FILE(ENTRY(z1,cNewFileListe)) IN FRAME {&FRAME-NAME}.
      
  END.
  
  pOutFile = SESSION:TEMP-DIR + "gesamt.csv".

  edtDummy:SAVE-FILE(pOutFile).
  */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createTempRates) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createTempRates Procedure 
PROCEDURE createTempRates :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pInFile  AS CHARACTER   NO-UNDO.

    DEFINE VARIABLE iCounter   AS INTEGER     NO-UNDO.
    DEFINE VARIABLE cMonthList AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cLine      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cField     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cMonth     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cYear      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cDay       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE dDate      AS DATE        NO-UNDO.
    DEFINE VARIABLE iMonth     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iDay       AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iYear      AS INTEGER     NO-UNDO.
    DEFINE VARIABLE cMessage  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cRate      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE dRate      AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE hRates     AS HANDLE      NO-UNDO.

    cMonthList = 'Jan,Feb,Mar,Apr,Mai,Jun,Jul,Aug,Sep,Okt,Nov,Dec'.

    INPUT FROM VALUE(pInFile).
    REPEAT:
      IMPORT UNFORMATTED cLine .
      IF NUM-ENTRIES(cLine,';') <> 8 THEN NEXT.
      cMessage = ''.
      DO iCounter = 1 TO NUM-ENTRIES(cLine,';'):

        cField = ENTRY(iCounter,cLine,';').

        /* Check date */
        IF iCounter = 1 THEN DO:
          /* erstes Feld muss mit Monat beginnen */
          IF LOOKUP(SUBSTR(cField,1,3),cMonthList) = 0 THEN LEAVE.

          CREATE ttRates.
          hRates = BUFFER ttRates:HANDLE.
          /* Year */
          IF NUM-ENTRIES(cField,',') <> 2 THEN DO:
            ASSIGN cMessage = cMessage + '/' + 'Invalid date format' dDate = ?.
          END.
          cYear = TRIM(ENTRY(2,cField,',')).
          ASSIGN iYear = INT(cYear) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            ASSIGN cMessage = cMessage + '/' + 'Invalid year' dDate = ?.
          END.
          /* Month */
          cMonth = SUBSTR(cField,1,3).
          IF LOOKUP(cMonth,cMonthList) = 0 THEN DO:
            ASSIGN cMessage = cMessage + '/' + 'Invalid month' dDate = ?.
          END.
          iMonth = LOOKUP(cMonth,cMonthList).
          /* Day */        
          cDay = ENTRY(1,cField,',').
          cDay = TRIM(SUBSTR(cDay,4)).
          ASSIGN iDay = INT(cDay) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            ASSIGN cMessage = cMessage + '/' + 'Invalid day' dDate = ?.
          END.
          ASSIGN dDate = DATE(imonth,iday,iyear) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            ASSIGN cMessage = cMessage + '/' + 'Invalid date fromat' dDate = ?.
          END.
          IF dDate <> ? THEN ttRates.field01 = STRING(dDate,'99.99.9999').
          ELSE ttRates.field01 = cField.        
        END.
        ELSE IF iCounter = 3 THEN DO:
          cRate = REPLACE(cField,',','').
          ASSIGN dRate = DEC(cRate) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            ASSIGN cMessage = cMessage + '/' + 'Invalid decimal format' dRate = ?.
          END.
          IF dRate <> ? THEN ttRates.field03 = STRING(dRate,'>>>,>>>,>>9.999999999').
          ELSE ttRates.field03 = cField.        
        END.
        ELSE DO:
          hRates:BUFFER-FIELD('field' + STRING(iCounter,'99')):BUFFER-VALUE = cField.      
        END.
      END.

    END.
    INPUT CLOSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-deleteDafValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deleteDafValor Procedure 
PROCEDURE deleteDafValor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE lcData AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE cdata  AS CHARACTER   NO-UNDO.

  
  lcData = wServiceGetRequestData().
  
  /*wServiceShowRequestInformation().*/
   
  wServicePrepareResultDataSetOneTable(BUFFER dafValor:HANDLE).
    
  dsWebService:read-json('longchar', lcData, "empty" ).

  FIND FIRST dafValor NO-LOCK NO-ERROR.
  IF AVAIL dafValor THEN DO:
    FIND FIRST tna_daf_valor WHERE RECID(tna_daf_valor) = dafValor.wsRecid EXCLUSIVE NO-ERROR.
    IF NOT AVAIL tna_daf_valor THEN DO:
      /* Valor in der Zwischenzeit gelöscht */

    END.
    ELSE DO:
      /* check ob gelöscht werden kann */
      /* ja */
      /* ........
      */
      /* nein */
      wServiceAddInformation('error','suberror','Deletion not possible because of pending dependencies').
    END.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDafValorenList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDafValorenList Procedure 
PROCEDURE getDafValorenList :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  wServicePrepareResultDataSetOneTable(BUFFER dafValor:HANDLE).
  
  /*cName = get-value('searchUsers').*/

  FOR EACH tna_daf_valor NO-LOCK,
    FIRST ZDV_Nummer WHERE ZDV_Nummer.N_VAL =  TNA_DAF_VALOR.nval AND 
        ZDV_Nummer.Typ_CD = 'CH' AND ZDV_Nummer.Val_ID <> 0 NO-LOCK,
    FIRST ZDV_Valor OF ZDV_Nummer NO-LOCK:
    
      CREATE dafValor.
      BUFFER-COPY tna_daf_valor TO dafValor.
      dafValor.valorenText = zdv_valor.tvak[1].

      wServiceRegisterResultDataSet (BUFFER dafValor:HANDLE, RECID(tna_daf_valor)).


  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getInstrument) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getInstrument Procedure 
PROCEDURE getInstrument :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE iCounter AS INTEGER     NO-UNDO.

  DEF BUFFER bzdv_nummer FOR zdv_nummer.

  wServicePrepareResultDataSetOneTable(BUFFER instrument:HANDLE).
  
  FOR EACH zdv_nummer NO-LOCK WHERE ZDV_Nummer.typ_cd = 'CH',
    FIRST ZDV_Valor OF ZDV_Nummer NO-LOCK:
    iCounter = iCounter + 1.
    IF iCounter = 200 THEN LEAVE.
    
    FIND FIRST bzdv_nummer WHERE bzdv_nummer.typ_cd = 'ISIN' AND
      bzdv_nummer.val_id = zdv_nummer.val_id NO-LOCK NO-ERROR.

    CREATE instrument.
    BUFFER-COPY zdv_valor TO instrument.
    instrument.nval = zdv_nummer.n_val.
    ASSIGN instrument.isin = IF AVAIL bzdv_nummer THEN bzdv_nummer.n_val ELSE ''.

    wServiceRegisterResultDataSet (BUFFER instrument:HANDLE, RECID(zdv_valor)).

  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-newDafValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE newDafValor Procedure 
PROCEDURE newDafValor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  wServicePrepareResultDataSetOneTable(BUFFER dafValor:HANDLE).  
 
  CREATE dafValor.
  ASSIGN dafValor.valorenText = 'new Instrument'.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDafValor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDafValor Procedure 
PROCEDURE setDafValor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE lcData AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE cdata  AS CHARACTER   NO-UNDO.

  
  lcData = wServiceGetRequestData().
  
  /*wServiceShowRequestInformation().*/
   
  wServicePrepareResultDataSetOneTable(BUFFER dafValor:HANDLE).
    
  dsWebService:read-json('longchar', lcData, "empty" ).

  FIND FIRST dafValor NO-LOCK NO-ERROR.
  IF AVAIL dafValor THEN DO:
    FIND FIRST tna_daf_valor WHERE RECID(tna_daf_valor) = dafValor.wsRecid EXCLUSIVE NO-ERROR.
    IF NOT AVAIL tna_daf_valor THEN DO:
      /* Valor in der Zwischenzeit gelöscht */

    END.
    ELSE DO:

      ASSIGN tna_daf_valor.bemerkung  = dafValor.bemerkung
             tna_daf_valor.erf_datum  = dafValor.erf_datum
             tna_daf_valor.aktiv      = dafValor.aktiv
             tna_daf_valor.whrc       = dafValor.whrc
             tna_daf_valor.berechnung = dafValor.berechnung.
      wServiceRegisterResultDataSet (BUFFER dafValor:HANDLE, RECID(tna_daf_valor)).
    END.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-test) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test Procedure 
PROCEDURE test :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE cFile AS CHARACTER   NO-UNDO.
  
  cFile = SESSION:TEMP-DIR + 'table.xlsx'.

  RUN convertXls2Csv(INPUT cFile, OUTPUT cFile).
  RUN createTempRates(INPUT cFile).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-uploadFiles) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE uploadFiles Procedure 
PROCEDURE uploadFiles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
  
[UBroker.WS]
    4glSrcCompile=0
    applicationURL=
    binaryUploadMaxSize=-1 Angepasst
    classMain=com.progress.ubroker.broker.ubroker
    debuggerEnabled=0
    defaultCookieDomain=
    defaultCookiePath=
    defaultService=0
    description=WebSpeed Broker
    fileUploadDirectory=@{WorkPath} Angepasst
  
  
  DEFINE TEMP-TABLE ttWsRequest NO-UNDO
       FIELD statusCode AS INTEGER
       FIELD statusText AS CHARACTER
       FIELD serviceName AS CHARACTER
       FIELD elapsedTime AS INTEGER.

wServiceAddInformation:
 RETURNS LOGICAL
  ( cType AS CHARACTER,
    cSubject AS CHARACTER,
    cFullText AS CHARACTER ) :
/*----------------------------------------------------------------------------*/

  giInfoSortNo = giInfoSortNo + 1.

  /* neue Welt */
  CREATE ttWsInformation.
  ASSIGN ttWsInformation.num = giInfoSortNo
         ttWsInformation.TYPE = cType
         ttWsInformation.subject = cSubject
         ttWsInformation.body = cFullText.


  RETURN FALSE.   /* Function return value. */

END FUNCTION.



 
------------------------------------------------------------------------------*/
  DEFINE VARIABLE mfile AS  MEMPTR NO-UNDO.
  DEFINE VARIABLE cFile AS  CHAR NO-UNDO.
  DEFINE VARIABLE lcData AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE cdata  AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cIndex AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE cISIN      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cDate      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cExtention AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cType      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cMessage   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE dDate      AS DATE        NO-UNDO.
  DEFINE VARIABLE cFileCsv   AS CHARACTER   NO-UNDO.

  lcData = wServiceGetRequestData().

  wServiceShowRequestInformation().
   
  cfile = get-value('file').
  cIndex = get-value('data').

  ASSIGN cType = '' cMessage = ''.
  IF NUM-ENTRIES(cFile,'_') <> 2 THEN 
      ASSIGN cType = 'danger' cMessage = 'File has wrong format!'.
  ELSE IF NUM-ENTRIES(cFile,'.') <> 2 THEN 
      ASSIGN cType = 'danger' cMessage = 'File has no extention!'.
  ELSE IF ENTRY(2,cFile,'.') <> 'xls' AND ENTRY(2,cFile,'.') <> 'xlsx' THEN 
      ASSIGN cType = 'danger' cMessage = 'File has wrong extention!'.
  ELSE DO:
    ASSIGN cISIN = ENTRY(1,cFile,'_')
           cDate = ENTRY(2,cFile,'_')
           cExtention = ENTRY(2,cDate,'.')
           cDate = ENTRY(1,cDate,'.').
    
    FIND FIRST zdv_nummer WHERE zdv_nummer.typ_cd = 'ISIN' AND 
        zdv_nummer.n_val = cISIN NO-LOCK NO-ERROR.
    IF NOT AVAIL zdv_nummer THEN DO:
        ASSIGN cType = 'danger' cMessage = 'Instrument does not exist'.
    END.
    ELSE DO:
        IF LENGTH(cDate) <> 6 THEN 
            ASSIGN cType = 'danger' cMessage = "Date has wrong format! expected 'yyyymm'".
        ELSE DO:
          ASSIGN dDate = DATE(INT(SUBSTR(cDate,5,2)),01,INT(SUBSTR(cDate,1,4))) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            ASSIGN cType = 'danger' cMessage = "Date has wrong format! expected 'yyyymm'".
          END.
        END.
    END.
  END.
  IF cType = '' THEN DO:
      /* Für bianry files */
      ASSIGN mFile = get-binary-data('file').
      IF mFile <> ? THEN DO:             
        ASSIGN cfile = SESSION:TEMP-DIRECTORY + cfile. 
        COPY-LOB FROM mFile TO FILE cFile NO-CONVERT.
        ASSIGN cType = 'success' cMessage = 'File validation ok'.
        RUN convertXls2Csv(INPUT cFile, OUTPUT cFile).
        wServicePrepareResultDataSetOneTable(BUFFER ttRates:HANDLE).
        RUN createTempRates(INPUT cFile).
      END.
      
  END.

  wServiceAddInformation(cType,'',cMessage).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

