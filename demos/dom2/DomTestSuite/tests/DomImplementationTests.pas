unit DomImplementationTests;

interface

uses
  TestFrameWork,
  xDom2,
  DomSetup;

type

  TDomImplementationFundamentalTests = class(TTestCase)
    private
      fDomImplementation : IDomImplementation;

    public
      procedure setup; override;
      procedure tearDown; override;

    published
      procedure hasFeatureXMLTest1;
      procedure hasFeatureXMLTest2;
      procedure hasFeatureXMLTest3;
      procedure hasFeatureXMLTest4;
      procedure hasFeatureXMLTest5;

      procedure hasFeatureCoreTest1;
      procedure hasFeatureCoreTest2;
      procedure hasFeatureCoreTest3;

      procedure createDocMalFormedXMLNSTest; //*
      procedure createDocNullXMLNSTest;      //*

      procedure createEmptyDocumentTest;
      procedure createDocumentNoDocTypeTest;
      procedure createDocXMLNSDifferentDocTest; //*

      procedure createDocumentTypeTest;
      procedure createDocTypeMalFormedXMLNSTest; //**
      procedure ceateDocTypeXMLNSIllegalCharTest; //*
  end;

  function getUnitTests : ITestSuite;

implementation

uses
  SysUtils;

procedure TDomImplementationFundamentalTests.setup;
begin
  fDomImplementation :=
          DomSetup.getCurrentDomSetup.getDocumentBuilder.domImplementation;
end;

procedure TDomImplementationFundamentalTests.tearDown;
begin
  fDomImplementation := nil;
end;


(* tests if dom has XML (uppercase) feature version 1 *)
procedure TDomImplementationFundamentalTests.hasFeatureXMLTest1;
begin
  check(fDomImplementation.hasFeature('XML', '1.0'),
          'Feature XML (version=1.0) should exist');
end;

(* tests if dom has XML (lowercase) feature version 1 *)
procedure TDomImplementationFundamentalTests.hasFeatureXMLTest2;
begin
  check(fDomImplementation.hasFeature('xml', '1.0'),
          'Feature xml (version=1.0) should exist');
end;

(* tests if dom has xml feature with empty version*)
procedure TDomImplementationFundamentalTests.hasFeatureXMLTest3;
begin
  check(fDomImplementation.hasFeature('xml', ''),
          'Feature xml (version='''') should exist');
end;

(* tests if dom has xml feature version 2 *)
procedure TDomImplementationFundamentalTests.hasFeatureXMLTest4;
begin
  check(fDomImplementation.hasFeature('xml', '2.0'),
          'Feature xml (version=2.0) should exist');
end;

(* tests if dom xml feature testing is case sensitive *)
procedure TDomImplementationFundamentalTests.hasFeatureXMLTest5;
begin
  check(fDomImplementation.hasFeature('xMl', ''),
          'Feature xMl (version='''') should exist');
end;

(* tests if dom has core (lowercase) feature version 2 *)
procedure TDomImplementationFundamentalTests.hasFeatureCoreTest1;
begin
  check(fDomImplementation.hasFeature('core', '2.0'),
          'Feature core (version=2.0) should exist');
end;

(* tests if dom has core feature with empty version *)
procedure TDomImplementationFundamentalTests.hasFeatureCoreTest2;
begin
  check(fDomImplementation.hasFeature('core', ''),
          'Feature core (version='''') should exist');
end;

(* tests if core feature testing is case sensitive *)
procedure TDomImplementationFundamentalTests.hasFeatureCoreTest3;
begin
  check(fDomImplementation.hasFeature('cOrE', ''),
          'Feature cOrE (version='''') should exist');
end;

(* checks if creating an empty document succeeds *)
procedure TDomImplementationFundamentalTests.createEmptyDocumentTest;
var
  document : IDomDocument;
begin
  document := fDomImplementation.createDocument('', '', nil);
  checkNotNull(document, 'document should be <> nil');
end;

(*
 * checks if creating a document with ns, qualified name and no doctype succeeds
*)
procedure TDomImplementationFundamentalTests.createDocumentNoDocTypeTest;
var
  document      : IDomDocument;
  namespaceURI  : DomString;
  qualifiedName : DomString;
begin
  namespaceURI  := 'http://www.pingpolice.com';
  qualifiedName := 'x:y';
  document := fDomImplementation.createDocument(
          namespaceURI, qualifiedName, nil);
  checkNotNull(document, 'document should be <> nil');
  check(document.nodeName = '#document');
  checkNull(document.ownerDocument);
end;


(*
 * checks if creating a document with a malformed name results in the correct
 * exception
 * (converted from: domimplementationCreateDocMalFormedXMLNS.js)
*)
procedure TDomImplementationFundamentalTests.createDocMalFormedXMLNSTest;
var
  document      : IDomDocument;
  namespaceURI  : DomString;
  qualifiedName : DomString;
begin
  namespaceURI  := '"http://www.ecommerce.org/';
  qualifiedName := 'prefix::local';
  try
    document := fDomImplementation.createDocument(
            namespaceURI, qualifiedName, nil);
    fail('EDomException etNamespaceErr should have been thrown but was not');
  except
    on e : EDomException do
      check(e.code = NAMESPACE_ERR,
              'etNamespaceErr should be thrown but was: ' + e.message);
  end;
end;

(*
 * checks if creating a document with qualified name but nameSpaceURI = ''
 * results in EDomException etNamespaceErr
 * (converted from: domimplementationCreateDocNullXMLNS.js)
*)
procedure TDomImplementationFundamentalTests.createDocNullXMLNSTest;
var
  document      : IDomDocument;
  namespaceURI  : DomString;
  qualifiedName : DomString;
begin
  namespaceURI  := '';
  qualifiedName := 'x:y';
  try
    document := fDomImplementation.createDocument(
            namespaceURI, qualifiedName, nil);
    fail('EDomException etNamespaceErr should have been thrown but was not');
  except
    on e : EDomException do
      check(e.code = NAMESPACE_ERR,
              'etNamespaceErr should be thrown but was: ' + e.message);
  end;
end;


(*
 * checks if creating a document with a docType belonging to another document
 * results in EDomException etWrongDocumentErr
 * (converted from: domimplementationCreateDocXMLNSDifferentDoc.js)
 *)
procedure TDomImplementationFundamentalTests.createDocXMLNSDifferentDocTest;
var
  document1     : IDomDocument;
  document2     : IDomDocument;
  docType       : IDomDocumentType;
  xml           : DomString;
  namespaceURI  : DomString;
  qualifiedName : DomString;

begin
  namespaceURI  := 'http://www.pingpolice.com';
  qualifiedName := 'x:y';

  xml := '<?xml version=''1.0''?>' +
         '  <!DOCTYPE testDoc [' +
         '  <!ELEMENT testDoc (#PCDATA)>' +
         '  ]>' +
         '  <testDoc>some text</testDoc>';
  {parse the xml so a new document will be created}
  document1 := DomSetup.getCurrentDomSetup.getDocumentBuilder.parse(xml);
  docType   := document1.docType;
  check(docType.ownerDocument as IUnknown = document1 as IUnknown);
  try
    {now try to insert the docType into another document}
    document2 := fDomImplementation.createDocument(
            namespaceURI, qualifiedName, docType);
    fail(
        'EDomException etWrongDocumentErr should have been thrown but was not');
  except
    on e : EDomException do
      check(e.code = WRONG_DOCUMENT_ERR,
              'etWrongDocumentErr should be thrown but was: ' + e.message);
  end;
end;



(* checks if creating a documentType  succeeds *)
procedure TDomImplementationFundamentalTests.createDocumentTypeTest;
var
  qualifiedName : DomString;
  publicId      : DomString;
  systemId      : DomString;
  docType       : IDomDocumentType;
begin
  qualifiedName := 'x:y';
	publicId      := 'http://www.localhost.com';
	systemId      := 'myDoc.dtd';
	docType       := fDomImplementation.createDocumentType(
                           qualifiedName, publicId, systemId);
  checkNotNull(docType);
  check(docType.name = qualifiedName);
  checkNull(docType.ownerDocument);
end;


(*
 * checks if creating a documentType with a malformed qualified name results in
 * EDomException etNamespaceErr
 * (converted from: domimplementationCreateDocTypeMalFormedXMLNS.js)
*)
procedure TDomImplementationFundamentalTests.createDocTypeMalFormedXMLNSTest;
var
  malformedName : DomString;
  publicId      : DomString;
  systemId      : DomString;
  docType       : IDomDocumentType;
begin
  malformedName := 'prefix::local';
	publicId      := 'ID';
	systemId      := 'id';

  try
    docType := fDomImplementation.createDocumentType(
                       malformedName, publicId, systemId);
    fail('EDomException etNamespaceErr should have been thrown but was not');
  except
    on e : EDomException do
      check(e.code = NAMESPACE_ERR,
              'etNamespaceErr should be thrown but was: ' + e.message);
  end;
end;

(*
 * checks if creating a documentType with a qualified name using illegal chars
 * results in EDomException etInvalidCharacterErr
 * (converted from: domimplementationCreateDocTypeXMLNSIllegalChar.js)
*)
procedure TDomImplementationFundamentalTests.ceateDocTypeXMLNSIllegalCharTest;
var
  qualifiedName : DomString;
  prefix        : DomString;
  publicId      : DomString;
  systemId      : DomString;
  docType       : IDomDocumentType;
  i             : Integer;
begin
	publicId := 'http://www.localhost.com';
	systemId := 'myDoc.dtd';
  prefix   := 'prefix:';
  for i := low(DomSetup.illegalChars) to high(DomSetup.illegalChars) do
  begin
    try
      qualifiedName := prefix + DomSetup.illegalChars[i];
      docType := fDomImplementation.createDocumentType(
                         qualifiedName, publicId, systemId);
      fail('EDomException etInvalidCharacterErr should have been thrown ' + 
           'but was not');
    except
      on e : EDomException do
        check(e.code = INVALID_CHARACTER_ERR,
                'etInvalidCharacterErr should be thrown but was: ' + e.message);
    end;
  end;
end;






(******************************************************************************)
(******************************************************************************)
(******************************************************************************)
(*
 * returns a testSuite containing all tests within this suite
 * if new test cases are created they should be added to this function
*)
function getUnitTests : ITestSuite;
var
 suite : TTestSuite;
begin
 suite := TTestSuite.create('Dom Implementation fundamental tests');
 suite.addSuite(TDomImplementationFundamentalTests.suite);
 result := suite;
end;


end.
