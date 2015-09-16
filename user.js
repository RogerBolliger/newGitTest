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

&IF DEFINED(EXCLUDE-convertXlsToCsv) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convertXlsToCsv Procedure 
PROCEDURE convertXlsToCsv :
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


  /* ---------------------------------------------------------------------- */
  /* Umwandlung Excel - CSV */
  /* ---------------------------------------------------------------------- */
  CREATE "Excel.Application":U chExcel.
  chExcel:VISIBLE = FALSE.

  DO z1 = 1 TO NUM-ENTRIES(pInFiles):
  
    cPfad = SUBSTRING(ENTRY(z1,pInFiles), 1 , R-INDEX(ENTRY(z1,pInFiles), ".")). 
    cPfad = cPfad + "csv".
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

  pOutFile = SESSION:TEMP-DIR + "gesamt.csv".

  /*
  /* ---------------------------------------------------------------------- */
  /* Neu generierte Files ggf. zusammenhängen */
  /* ---------------------------------------------------------------------- */
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
  ELSE IF ENTRY(2,cFile,'.') <> 'xls' THEN 
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
      ASSIGN cType = 'success' cMessage = 'File validation OK'.
      /* Für bianry files */
      ASSIGN mFile = get-binary-data('file').
      IF mFile <> ? THEN DO:             
        ASSIGN cfile = SESSION:TEMP-DIRECTORY + cfile. 
        COPY-LOB FROM mFile TO FILE cFile NO-CONVERT.

        RUN convertXlsToCsv(INPUT cFile, OUTPUT cFileCsv).

      END.
      
  END.

  wServiceAddInformation(cType,'',cMessage).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

