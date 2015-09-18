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

DEFINE TEMP-TABLE ttBenutzer NO-UNDO LIKE adb_benutzer
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
   Other Settings: CODE-ONLY COMPILE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB Procedure 
/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{shared/web/wservices.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

  wServiceMainStandard().

/* Ende Main ********************************************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
     MESSAGE cNewFileListe
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
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
          cRate = REPLACE(cField,',','.').
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

&IF DEFINED(EXCLUDE-getData) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getData Procedure 
PROCEDURE getData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*
DEFINE DATASET dsOrder FOR ttOrder, ttOline, ttItem
      DATA-RELATION OrderLine FOR ttOrder, ttOline
          RELATION-FIELDS (OrderNum, OrderNum)
      DATA-RELATION LineItem FOR ttOline, ttItem
          RELATION-FIELDS (ItemNum, ItemNum).   
          
        */
/*        
DEFINE VAR bCustomer    AS HANDLE NO-UNDO.
DEFINE VAR h-ttCustomer AS HANDLE NO-UNDO.   
DEFINE VAR httCustomer  AS HANDLE NO-UNDO. 
DEFINE VAR hDsSource    AS HANDLE NO-UNDO.
DEFINE VAR hDs          AS HANDLE NO-UNDO.

CREATE BUFFER bCustomer FOR TABLE "Customer".
CREATE TEMP-TABLE h-ttCustomer.
h-ttCustomer:CREATE-LIKE(bCustomer).
h-ttCustomer:TEMP-TABLE-PREPARE("tt-Customer").
httCustomer = h-ttCustomer:DEFAULT-BUFFER-HANDLE.

/* we need a ProDataSet to fill*/      
CREATE DATASET hDs.
hDs:ADD-BUFFER(httCustomer).
      
CREATE DATA-SOURCE hDsSource.
hDsSource:ADD-SOURCE-BUFFER(bCustomer,?).
httCustomer:ATTACH-DATA-SOURCE(hDsSource).
hDsSource:FILL-WHERE-STRING = "WHERE". /*...*/
hDs:FILL().
httCustomer:DETACH-DATA-SOURCE().
*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUserlist) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getUserlist Procedure 
PROCEDURE getUserlist :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE iZahler    AS INTEGER NO-UNDO.
  DEFINE VARIABLE cNachname  AS CHARACTER   NO-UNDO.
  
  wServicePrepareResultDataSetOneTable(BUFFER ttBenutzer:HANDLE).

  cNachname = get-value('searchUser'). 

  FOR EACH adb_benutzer WHERE adb_benutzer.nachname begins cnachname NO-LOCK:

      CREATE ttBenutzer.
      BUFFER-COPY adb_benutzer TO ttBenutzer.
      wServiceRegisterResultDataSet (BUFFER ttBenutzer:HANDLE, RECID(adb_benutzer)).

  END.

  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-processRates) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processRates Procedure 
PROCEDURE processRates :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE cFile AS  CHAR NO-UNDO.
  DEFINE VARIABLE lcData AS LONGCHAR NO-UNDO.

  lcData = wServiceGetRequestData().

  wServiceShowRequestInformation().
   
  cfile = get-value('fileName').
  
  cFile = REPLACE(cfile,'xlsx','csv').
  cFile = REPLACE(cfile,'xls','csv').

  cFile = SESSION:TEMP-DIR + cFile.
  IF SEARCH(cFile) <> ? THEN DO:
      /*RUN convertXls2Csv(INPUT cFile, OUTPUT cFile).*/
      wServicePrepareResultDataSetOneTable(BUFFER ttRates:HANDLE).
      RUN createTempRates(INPUT cFile).
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-saveRates) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveRates Procedure 
PROCEDURE saveRates :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE lcData AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE cdata  AS CHARACTER   NO-UNDO.

  lcData = wServiceGetRequestData().

  /*wServiceShowRequestInformation().*/
  
  wServicePrepareResultDataSetOneTable(BUFFER ttRates:HANDLE).
  
  MESSAGE 'alles ok'
      VIEW-AS ALERT-BOX INFO BUTTONS OK.

  dsWebService:read-xml('longchar', lcData, "empty", ?, ?, ?, ? ).

  FOR EACH ttRates EXCLUSIVE:
    DISP ttRates.

  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUserlist) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUserlist Procedure 
PROCEDURE setUserlist :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE VARIABLE lcData AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE cdata  AS CHARACTER   NO-UNDO.

  lcData = wServiceGetRequestData().

  /*wServiceShowRequestInformation().*/
  
  wServicePrepareResultDataSetOneTable(BUFFER ttBenutzer:HANDLE).
  
  dsWebService:read-xml('longchar', lcData, "empty", ?, ?, ?, ? ).

  FOR EACH ttBenutzer EXCLUSIVE:
    ttBenutzer.wsModState = ttbenutzer.benutzer.
    wServiceDebugLog ("User: " + ttBenutzer.wsModState).

  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-uploadFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE uploadFile Procedure 
PROCEDURE uploadFile :
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
  DEFINE VARIABLE ctvak      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cDate      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cExtention AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cType      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cMessage   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE dDate      AS DATE        NO-UNDO.
  DEFINE VARIABLE cFileCsv   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cMonthList AS CHARACTER   NO-UNDO.

  cMonthList = 'Jan,Feb,Mar,Apr,Mai,Jun,Jul,Aug,Sep,Okt,Nov,Dec'.


  lcData = wServiceGetRequestData().

  wServiceShowRequestInformation().
   
  cfile = get-value('file').
  cIndex = get-value('data').

  ASSIGN cType = '' cMessage = ''.
  IF NUM-ENTRIES(cFile,'_') <> 2 THEN 
      ASSIGN cType = 'danger' cMessage = 'File has wrong format!'.
  ELSE IF NUM-ENTRIES(cFile,'.') <> 2 THEN 
      ASSIGN cType = 'danger' cMessage = 'File has no extention!'.
  ELSE IF LOOKUP(ENTRY(2,cFile,'.'),'xls,xlsx,csv') = 0 THEN 
      ASSIGN cType = 'danger' cMessage = 'File has wrong extention!'.
  ELSE DO:
    ASSIGN cISIN = ENTRY(1,cFile,'_')
           cDate = ENTRY(2,cFile,'_')
           cExtention = ENTRY(2,cDate,'.')
           cDate = ENTRY(1,cDate,'.').
    /* 
    FIND FIRST zdv_nummer WHERE zdv_nummer.typ_cd = 'ISIN' AND 
        zdv_nummer.n_val = cISIN NO-LOCK NO-ERROR.
    IF NOT AVAIL zdv_nummer THEN DO:
        ASSIGN cType = 'danger' cMessage = 'Instrument does not exist'.
    END.
    ELSE
      FIND FIRST zdv_valor OF zdv_nummer NO-LOCK NO-ERROR.
      IF AVAIL zdv_valor THEN ctvak = zdv_valor.tvak[1]. 
    */
    DO:
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
        IF LOOKUP(ENTRY(2,cFile,'.'),'xls,xlsx') > 0 THEN
          RUN convertXls2Csv(INPUT cFile, OUTPUT cFile).
        wServicePrepareResultDataSetOneTable(BUFFER ttRates:HANDLE).
        RUN createTempRates(INPUT cFile).
        wServiceAddInformation('panel-heading','','Rates for '  + cisin + ' ' + ctvak + ' '  + ENTRY(INT(SUBSTR(cDate,5,2)),cMonthList) + ' ' + SUBSTR(cDate,1,4)).
      END.
      
  END.

  wServiceAddInformation(cType,'',cMessage).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

