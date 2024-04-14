unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls,
  System.Messaging,
  Androidapi.Helpers, Androidapi.JNI.Net,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os, Androidapi.JNI.App, FMX.Objects, System.IOUtils,
  Androidapi.JNI.Widget,
  Androidapi.JNI.JavaTypes, FMX.TabControl, Androidapi.JNI.Provider,
  FMX.Platform.Android,
  Androidapi.JNIBridge, FMX.Surfaces, FMX.Helpers.Android, Androidapi.JNI.Media,
  Androidapi.JNI.Webkit, Androidapi.Jni, Posix.Unistd, Androidapi.JNI.Support;

type
  TForm1 = class(TForm)
    btnOpenAFile: TButton;
    btnAllowAccessAnArray: TButton;
    btnDocumentDelete: TButton;
    TabControl1: TTabControl;
    tiUriAl: TTabItem;
    tiSAF1: TTabItem;
    btnVirtualFileInputStream: TButton;
    btnOpenAVirtualFile: TButton;
    btnDocumentEdit: TButton;
    btnDocumentOpenEntryFlow: TButton;
    tiIlave1: TTabItem;
    btnTextFileRead: TButton;
    btnPdfShow: TButton;
    btnPdfChoose: TButton;
    btnPermanentPermissions: TButton;
    ImageControl1: TImageControl;
    btnShowPicture: TButton;
    tiIlave2: TTabItem;
    btnFileCopyInternalToExternal: TButton;
    btnFileCopyExternalToInternal: TButton;
    btnFilesShare: TButton;
    btnExamineDocumentMetaData: TButton;
    btnDocumentOpenBitmap: TButton;
    tiSAF2: TTabItem;
    Panel1: TPanel;
    Memo1: TMemo;
    MemoUri: TMemo;
    btnGetAnyFileUri: TButton;
    btnFileProvider: TButton;
    btnKanSelectDirectory: TButton;
    procedure btnAllowAccessAnArrayClick(Sender: TObject);
    procedure ButtonYeniBirDosyaOluþturunClick(Sender: TObject);
    procedure btnOpenAFileClick(Sender: TObject);
    procedure btnDocumentDeleteClick(Sender: TObject);
    procedure btnPermanentPermissionsClick(Sender: TObject);
    procedure btnTextFileReadClick(Sender: TObject);
    procedure btnPdfChooseClick(Sender: TObject);
    procedure btnPdfShowClick(Sender: TObject);
    procedure MemoUriTap(Sender: TObject; const Point: TPointF);
    procedure btnDocumentOpenBitmapClick(Sender: TObject);
    procedure btnShowPictureClick(Sender: TObject);
    procedure btnExamineDocumentMetaDataClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure btnDocumentOpenEntryFlowClick(Sender: TObject);
    procedure btnDocumentEditClick(Sender: TObject);
    procedure btnFileCopyInternalToExternalClick(Sender: TObject);
    procedure btnFileCopyExternalToInternalClick(Sender: TObject);
    procedure btnFilesShareClick(Sender: TObject);
    procedure btnOpenAVirtualFileClick(Sender: TObject);
    procedure btnGetAnyFileUriClick(Sender: TObject);
    procedure btnVirtualFileInputStreamClick(Sender: TObject);
    procedure btnFileProviderClick(Sender: TObject);
    procedure btnKanSelectDirectoryClick(Sender: TObject);
  private
    procedure Capture_Message_Activity(const Sender: TObject; const M: TMessage);
    procedure OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent);
    procedure PdfShow(Uri: JNet_Uri);
    procedure ImageViewer(Uri: JNet_Uri; Picture: TImageControl);
    procedure FileCopy_InternalToExternal(xFile: string);
    procedure FileCopier_ExternalToInternal;
    procedure Notification(cNotification: string);
    function TextFileReader(Uri: JNet_Uri): string;
    function FileDeleter(Uri: JNet_Uri): boolean;
    function File_name(Uri: JNet_Uri): string;
    function FileUri(Uri: JNet_Uri): JNet_Uri;
  const
    Create_File: integer = 11; // CREATE_FILE = 1
    Select_Pdf_File: integer = 22; // PICK_PDF_FILE = 2
    Open_Doc_Tree: integer = 33;
    File_Delete: integer = 44;
    Select_Text_File: integer = 55;
    Picture_Show: integer = 66;
    Any_File_Select: integer = 77;
    File_Copy_Internal_To_External: integer = 88;
    File_Copy_From_External_Internal: integer = 99;

  var
    UriLive: JNet_Uri;
    FileCopied: string;
    RootDirectory: JNet_Uri;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btnTextFileReadClick(Sender: TObject);
begin
  Memo1.Text := TextFileReader(UriLive);
end;

procedure TForm1.btnPdfShowClick(Sender: TObject);
begin
  PdfShow(UriLive);
  Memo1.Text := 'PdfShow : ' + JStringToString(UriLive.GetPath);
end;

procedure TForm1.btnShowPictureClick(Sender: TObject);
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT)
    .addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE)
    .setType(StringToJString('image/*'));
  if Intent.resolveActivity(TAndroidHelper.Context.getPackageManager) <> nil
  then
  begin
    MainActivity.startActivityForResult(Intent, Picture_Show);
    ImageControl1.Parent := TabControl1.ActiveTab;
  end
  else
    Notification('No picture received!');
end;

procedure TForm1.btnOpenAVirtualFileClick(Sender: TObject);
  function SanalDosyami(Uri: JNet_Uri): boolean; (* isVirtualFile *)
  var
    flags: integer;
    cursor: JCursor;
    s: TJavaObjectArray<JString>;
  begin
    if (not TJDocumentsContract.JavaClass.isDocumentUri(TAndroidHelper.Context,
      Uri)) then
    begin
      result := false;
      exit;
    end;
    s := TJavaObjectArray<JString>.Create(0);
    s[0] := TJDocumentsContract_Document.JavaClass.COLUMN_FLAGS;
    cursor := TAndroidHelper.Activity.getContentResolver.query(Uri, s, nil,
      nil, nil);
    flags := 0;
    if (cursor.moveToFirst) then
      flags := cursor.getInt(0);
    cursor.close;
    result := (flags and TJDocumentsContract_Document.JavaClass.
      FLAG_VIRTUAL_DOCUMENT) <> 0;
  end;
begin
  SanalDosyami(UriLive);
end;

procedure TForm1.btnVirtualFileInputStreamClick(Sender: TObject);
  function SanalDosyaIcinGirisAkisiAl(Uri: JNet_Uri; mimeTypeFilter: String)
    : JInputStream; (* getInputStreamForVirtualFile *)
  var
    openableMimeTypes: TJavaObjectArray<JString>;
    resolver: JContentResolver;
  begin
    resolver := TAndroidHelper.Activity.getContentResolver;
    openableMimeTypes := resolver.getStreamTypes(Uri,
      StringToJString(mimeTypeFilter));
    if ((openableMimeTypes = nil) or (openableMimeTypes.Length < 1)) then
    begin
      Notification('File not found!');
      result := nil;
      exit;
    end;
    result := resolver.openTypedAssetFileDescriptor(Uri, openableMimeTypes[0],
      nil).createInputStream;
  end;

begin
  SanalDosyaIcinGirisAkisiAl(UriLive, '*/*');
end;

procedure TForm1.btnPdfChooseClick(Sender: TObject);
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('application/pdf'));
  TAndroidHelper.Activity.startActivityForResult(Intent, Select_Pdf_File);
end;

procedure openDirectory(uriToLoad : JNet_Uri);  (* DizinAc *)
// Choose a directory using the system's file picker.
var
  Intent : JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT_TREE);

  // Optionally, specify a URI for the directory that should be opened in
  // the system file picker when it loads.
  Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI, JParcelable(uriToLoad));

  Mainactivity.startActivityForResult(Intent, TForm1.Open_Doc_Tree);
end;

procedure TForm1.btnKanSelectDirectoryClick(Sender: TObject);
begin
   //openDirectory(
end;

procedure TForm1.btnDocumentOpenBitmapClick(Sender: TObject);
  function UridenBiteslemAl(Uri: JNet_Uri): JBitmap; (* getBitmapFromUri *)
  var
    fileDescriptor: JFileDescriptor;
    parcelFileDescriptor: JParcelFileDescriptor;
    image: JBitmap;
  begin
    result := nil;
    try
      parcelFileDescriptor := TAndroidHelper.Activity.getContentResolver.
        openFileDescriptor(Uri, StringToJString('r'));
      fileDescriptor := parcelFileDescriptor.getFileDescriptor;
      image := TJBitmapFactory.JavaClass.decodeFileDescriptor(fileDescriptor);
      parcelFileDescriptor.close;
      result := image;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;

var
  surf: TBitmapSurface;
  NativeBitmap: JBitmap;
begin
  NativeBitmap := UridenBiteslemAl(UriLive);
  surf := TBitmapSurface.Create;
  if JBitmapToSurface(NativeBitmap, surf) then
    ImageControl1.Bitmap.Assign(surf);
  ImageControl1.Parent := TabControl1.ActiveTab;
end;

procedure TForm1.btnDocumentOpenEntryFlowClick(Sender: TObject);
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('text/*')); // plain')); //text/html
  TAndroidHelper.Activity.startActivityForResult(Intent, Select_Text_File);
end;

procedure TForm1.btnDocumentEditClick(Sender: TObject);
  procedure ChangeTextDocument(Uri: JNet_Uri); (* alterDocument *)
  var
    pfd: JParcelFileDescriptor;
    fileOutputStream: JFileOutputStream;
  begin
    try
      pfd := TAndroidHelper.Activity.getContentResolver.openFileDescriptor(Uri,
        StringToJString('w'));
      fileOutputStream := TJFileOutputStream.JavaClass.init
        (pfd.getFileDescriptor);
      fileOutputStream.write(StringToJString('overwritten ' + timetostr(Now)
        ).getBytes);
      fileOutputStream.close;
      pfd.close;
    except
      on E: Exception do
        ShowMessage(E.Message); // (IOException e) e.printStackTrace;
    end;
  end;

begin
  ChangeTextDocument(UriLive);
end;

procedure TForm1.btnExamineDocumentMetaDataClick(Sender: TObject);
  procedure ImageMetadataTexture(Uri: JNet_Uri); (* dumpImageMetaData *)
  // Because the query is applied to a single document, it returns only a single row.
  // There is no need to filter, sort or select fields.
  // Because we want all the fields for one document.
  var
    displayName, size: JString;
    sizeIndex: integer;
    cursor: JCursor;
  begin
    cursor := TAndroidHelper.Activity.getContentResolver.query(Uri, nil, nil,
      nil, nil, nil);
    try
      if (cursor <> nil) then
        if (cursor.moveToFirst) then
        begin
          displayName := cursor.getString
            (cursor.getColumnIndex(TJOpenableColumns.JavaClass.DISPLAY_NAME));
          Memo1.Lines.Add( { TAG.ToString + } 'Display Name: ' +
            JStringToString(displayName));
          sizeIndex := cursor.getColumnIndex(TJOpenableColumns.JavaClass.SIZE);
          size := nil;
          if not(cursor.isNull(sizeIndex)) then
            size := cursor.getString(sizeIndex)
          else
            size := StringToJString('Unknown');
          Memo1.Lines.Add( { TAG.ToString + } 'Dimension: ' +
            JStringToString(size));
        end;
    finally
      cursor.close;
    end;
  end;

begin
  ImageMetadataTexture(UriLive);
end;

procedure TForm1.btnDocumentDeleteClick(Sender: TObject);
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('*/*'));
  TAndroidHelper.Activity.startActivityForResult(Intent, File_Delete);
end;

procedure TForm1.btnAllowAccessAnArrayClick(Sender: TObject);
  procedure DirectoryOpen(ToBeUploadedUri: JNet_Uri);
  // Select a directory using the system file picker
  var
    Intent: JIntent;
  begin
    Intent := TJIntent.Create;
    Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT_TREE);

    // Optionally, when the system file picker is loaded
    // Specify a URI for the directory to open.
    Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI,
      JParcelable(ToBeUploadedUri));

    MainActivity.startActivityForResult(Intent, Open_Doc_Tree);
  end;

begin
  DirectoryOpen(RootDirectory);
end;

procedure TForm1.btnOpenAFileClick(Sender: TObject);
// Request code to select a PDF document.
// const Select_Pdf_File : integer = 22;  //PICK_PDF_FILE = 2

  procedure Openfile(selectiveStartUri: JNet_Uri);
  var
    Intent: JIntent;
  begin
    Intent := TJIntent.Create;
    Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
    Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
    Intent.setType(StringToJString('application/pdf'));

    // Optionally, when the system file picker is loaded
    // Specify a URI for the file to display.
    Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI,
      JParcelable(selectiveStartUri));

    MainActivity.startActivityForResult(Intent, Select_Pdf_File);
  end;

begin
  Openfile(nil);
end;

procedure TForm1.FileCopy_InternalToExternal(xFile: string);
const
  bufferSize = 4096 * 2;
var
  noOfBytes: Integer;
  b: TJavaArray<Byte>;
  ReadFile: JInputStream;
  WriteFile: JFileOutputStream;
  pfd: JParcelFileDescriptor;
begin
  if not FileExists(xFile) then
  begin
    Notification(xFile + ' not found!');
    exit;
  end;
  try
    ReadFile := TAndroidHelper.Context.getContentResolver.openInputStream
      (TJnet_Uri.JavaClass.fromFile(TJFile.JavaClass.init
      (StringToJString(xFile))));
    pfd := TAndroidHelper.Activity.getContentResolver.openFileDescriptor(UriLive,
      StringToJString('w'));
    WriteFile := TJFileOutputStream.JavaClass.init(pfd.getFileDescriptor);
    b := TJavaArray<Byte>.Create(bufferSize);
    noOfBytes := ReadFile.read(b);
    while (noOfBytes > 0) do
    begin
      WriteFile.write(b, 0, noOfBytes);
      noOfBytes := ReadFile.read(b);
    end;
    WriteFile.close;
    ReadFile.close;
  except
    on E: Exception do
      Application.ShowException(E);
  end;
  Notification('File copied from Internal to External : ' + File_name(UriLive));
end;

procedure TForm1.btnFileCopyInternalToExternalClick(Sender: TObject);
(* TFile.Copy(TPath.Combine(TPath.GetDocumentsPath, 'delphican.pdf'),
  TPath.Combine(TPath.GetSharedDownloadsPath, 'delphican.pdf')); *)
  procedure CreatePdfFile(selectiveStartUri: JNet_Uri);
  var
    Intent: JIntent;
  begin
    Intent := TJIntent.Create;
    Intent.setAction(TJIntent.JavaClass.ACTION_CREATE_DOCUMENT);
    Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
    Intent.setType(StringToJString('application/pdf'));
    Intent.putExtra(TJIntent.JavaClass.EXTRA_TITLE,
      StringToJString(TPath.GetFileName(FileCopied)));
    Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI,
      JParcelable(selectiveStartUri));
    MainActivity.startActivityForResult(Intent,
      File_Copy_Internal_To_External);
  end;

begin
  FileCopied := TPath.Combine(TPath.GetDocumentsPath, 'delphican.pdf');
  CreatePdfFile(nil);
end;

procedure TForm1.FileCopier_ExternalToInternal;
const
  bufferSize = 4096 * 2;
var
  noOfBytes: Integer;
  b: TJavaArray<Byte>;
  ReadFile: JInputStream;
  WriteFile: JFileOutputStream;
  xFile: string;
  // pfd : JParcelFileDescriptor;
begin
  try
    xFile := TPath.Combine(TPath.GetPublicPath, File_name(UriLive));
    if FileExists(xFile) then
    begin
      Notification('"' + xFile + '" already available!');
      exit;
    end;
    WriteFile := TJFileOutputStream.JavaClass.init(StringToJString(xFile));
    ReadFile := TAndroidHelper.Context.getContentResolver.
      openInputStream(UriLive);
    b := TJavaArray<Byte>.Create(bufferSize);
    noOfBytes := ReadFile.read(b);
    while (noOfBytes > 0) do
    begin
      WriteFile.write(b, 0, noOfBytes);
      noOfBytes := ReadFile.read(b);
    end;
    WriteFile.close;
    ReadFile.close;
  except
    on E: Exception do
      Application.ShowException(E);
  end;
  Notification('File copied from external to internal : ' + File_name(UriLive));
end;

procedure TForm1.btnFileCopyExternalToInternalClick(Sender: TObject);
(* TFile.Copy(TPath.Combine(TPath.GetSharedDownloadsPath, 'delphican.pdf'),
  TPath.Combine(TPath.GetPublicPath, 'delphican.pdf')); *)
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);
  // ACTION_GET_CONTENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('*/*'));
  TAndroidHelper.Activity.startActivityForResult(Intent,
    File_Copy_From_External_Internal);
end;

procedure TForm1.btnFilesShareClick(Sender: TObject);
var
  Intent: JIntent;
  mime: JMimeTypeMap;
  ExtToMime: JString;
  ExtFile: string;
  xFile: string;
begin
  xFile := File_name(UriLive);
  ExtFile := AnsiLowerCase(StringReplace(TPath.GetExtension(xFile),
    '.', '', []));
  mime := TJMimeTypeMap.JavaClass.getSingleton();
  ExtToMime := mime.getMimeTypeFromExtension(StringToJString(ExtFile));
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_SEND);
  Intent.setDataAndType(UriLive, ExtToMime);
  Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, JParcelable(UriLive));
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(TJIntent.JavaClass.createChooser(Intent,
    StrToJCharSequence('Share Lets See: ')));
end;

procedure TForm1.btnGetAnyFileUriClick(Sender: TObject);
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_OPEN_DOCUMENT);  // ACTION_GET_CONTENT);
  Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
  Intent.setType(StringToJString('*/*'));
  TAndroidHelper.Activity.startActivityForResult(Intent, Any_File_Select);
end;

procedure TForm1.btnPermanentPermissionsClick(Sender: TObject);
var
  TakeFlags: integer;
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  TakeFlags := Intent.getFlags and
    (TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION or
    TJIntent.JavaClass.FLAG_GRANT_WRITE_URI_PERMISSION);
  // Check out the latest data
  TAndroidHelper.Activity.getContentResolver.takePersistableUriPermission
    (UriLive, TakeFlags);
end;

function TForm1.FileDeleter(Uri: JNet_Uri): boolean;
begin
  result := TJDocumentsContract.JavaClass.deleteDocument
    (TAndroidHelper.contentResolver, Uri);
end;

procedure TForm1.ButtonYeniBirDosyaOluþturunClick(Sender: TObject);
// Request code for PDF document creation.
// const Create_File : integer = 11;  //CREATE_FILE = 1

  procedure CreatePdfFile(selectiveStartUri: JNet_Uri);
  var
    Intent: JIntent;
  begin
    Intent := TJIntent.Create;
    Intent.setAction(TJIntent.JavaClass.ACTION_CREATE_DOCUMENT);
    Intent.addCategory(TJIntent.JavaClass.CATEGORY_OPENABLE);
    Intent.setType(StringToJString('application/pdf'));
    Intent.putExtra(TJIntent.JavaClass.EXTRA_TITLE,
      StringToJString('fatura.pdf'));

    // Optionally, when your application creates the file
    // Specify a URI for the directory to be opened by the system file picker.
    Intent.putExtra(TJDocumentsContract.JavaClass.EXTRA_INITIAL_URI,
      JParcelable(selectiveStartUri));
    MainActivity.startActivityForResult(Intent, Create_File);
  end;

var
  SelectiveStartUri_: JNet_Uri;
begin
  SelectiveStartUri_ := RootDirectory;
  // TJnet_Uri.JavaClass.fromFile(TJFile.JavaClass.init(StringToJString( TPath.GetSharedDownloadsPath)));
  CreatePdfFile(SelectiveStartUri_);
end;

constructor TForm1.Create(AOwner: TComponent);
const
  Authority: string = 'com.android.externalstorage.documents';
begin
  inherited;
  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification,
    Capture_Message_Activity);
  try
    TabControl1.ActiveTab := tiUriAl;
    Memo1.Lines.Add('Android ' + JStringToString
      (TJBuild_VERSION.JavaClass.RELEASE) + '   ' + 'SDK ' +
      inttostr(TJBuild_VERSION.JavaClass.SDK_INT) + sLineBreak +
      JStringToString(TJBuild.JavaClass.BRAND) + '  ' +
      JStringToString(TJBuild.JavaClass.MODEL) + '  ' +
      JStringToString(TJBuild.JavaClass.CPU_ABI) + '  ' +
      JStringToString(TJBuild.JavaClass.BOARD));
    RootDirectory := TJDocumentsContract.JavaClass.buildTreeDocumentUri
      (StringToJString(Authority), StringToJString('primary:')); // roottree
  finally
  end;
end;

destructor TForm1.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification,
    Capture_Message_Activity);
  inherited;
end;

procedure TForm1.Capture_Message_Activity(const Sender: TObject; const M: TMessage);
begin
  if M is TMessageResultNotification then
    OnActivityResult(TMessageResultNotification(M).RequestCode,
      TMessageResultNotification(M).ResultCode,
      TMessageResultNotification(M).Value);
end;

procedure TForm1.OnActivityResult(RequestCode, ResultCode: Integer;
  Data: JIntent);
var
  Uri: JNet_Uri;
  Ad: string;
begin
  Memo1.Lines.Clear;
  if ResultCode = TJActivity.JavaClass.RESULT_OK then
  begin
    // Result data user selected
    // Contains a URI for the document or directory.
    Uri := nil;
    if Assigned(Data) then
    begin
      if (Data = nil) then
      begin
        Memo1.Lines.Add('Could not get uri!');
        exit;
      end;
      Uri := Data.getData;
      UriLive := Uri;
      Ad := '"' + File_name(Uri) + '" ';
      // (' + TPath.GetFileName(JStringToString(uri.getPath) + ') ');

      // Perform operations on the document using its URI.
      if RequestCode = Create_File then
      begin
        Notification('Create new pdf file : ' + Ad);
      end;
      if RequestCode = Select_Pdf_File then
      begin
        PdfShow(Uri);
        Notification('Read pdf file: ' + Ad);
      end;
      if RequestCode = Open_Doc_Tree then
      begin
        Notification(Ad + ' Permission granted to access items in directory.');
      end;
      if RequestCode = File_Delete then
      begin
        FileDeleter(Uri);
        Notification(Ad + 'deleted');
        UriLive := nil;
      end;
      if RequestCode = Select_Text_File then
      begin
        Notification('Read text file: ' + Ad + sLineBreak +
          TextFileReader(Uri));
      end;
      if RequestCode = Picture_Show then
      begin
        ImageViewer(Uri, ImageControl1);
        Notification('show picture: ' + Ad);
      end;
      if RequestCode = Any_File_Select then
      begin
        Notification('File selected: ' + Ad);
      end;
      if RequestCode = File_Copy_Internal_To_External then
      begin
        FileCopy_InternalToExternal(FileCopied);
      end;
      if RequestCode = File_Copy_From_External_Internal then
      begin
        FileCopier_ExternalToInternal;
      end;
    end;
    Memo1.Lines.Add(' ');
    Memo1.GoToTextEnd;
  end
  else if ResultCode = TJActivity.JavaClass.RESULT_CANCELED then
  begin
    Notification('The activity has been cancelled!');
  end;
  if UriLive <> nil then
    MemoUri.Text := JStringToString(UriLive.toString)
  else
    MemoUri.Text := '';
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
  Panel1.Parent := TabControl1.ActiveTab;
end;

procedure TForm1.Notification(cNotification: string);
begin
  Memo1.Lines.Add(cNotification + sLineBreak);
  Application.ProcessMessages;
  TThread.Synchronize(nil,
    procedure
    begin
      TJToast.JavaClass.makeText(TAndroidHelper.Context,
        StrToJCharSequence(cNotification), TJToast.JavaClass.LENGTH_LONG).show;
    end);
end;

function TForm1.File_name(Uri: JNet_Uri): string;
var
  C: JCursor;
begin
  result := '';
  try
    C := TAndroidHelper.Activity.getContentResolver.query(Uri, nil, nil,
      nil, nil, nil);
    if (C = nil) then
      exit;
    C.moveToFirst;
    result := JStringToString
      (C.getString(C.getColumnIndex(TJOpenableColumns.JavaClass.DISPLAY_NAME)));
  finally
    C.close;
  end;
end;

function TForm1.FileUri(Uri: JNet_Uri): JNet_Uri;
var
  C: JCursor;
  FilePath : JString;
begin
  result := nil;
  try
    C := TAndroidHelper.Activity.getContentResolver.query(Uri, nil, nil,
      nil, nil, nil);
    if (C = nil) then
      exit;
    C.moveToFirst;
    FilePath := C.getString(0);
   //LUri := TAndroidHelper.JFileToJURI(TJFile.JavaClass.init(StringToJString(Filename(UriCan)))); // StringToJString(AFileName)));
    result := TAndroidHelper.JFileToJURI(TJFile.JavaClass.init(FilePath)); //JStringToString(C.getString(C.getColumnIndex(TJOpenableColumns.JavaClass.DISPLAY_NAME)));
  finally
    C.close;
  end;
end;

procedure TForm1.btnFileProviderClick(Sender: TObject);
var
  FileList: TStringDynArray;
  DocDir, xFile, s: string;
begin
  with Memo1 do
  begin
    DocDir := TPath.GetHomePath;
    Text := ('GetHomePath :');
    FileList := TDirectory.GetFiles(DocDir);
    for s in FileList do
      Lines.Add(TPath.GetFileName(s));
    DocDir := TPath.GetPublicPath;
    Lines.Add(sLineBreak + 'GetPublicPath :');
    FileList := TDirectory.GetFiles(DocDir);
    for s in FileList do
      Lines.Add(TPath.GetFileName(s));
    xFile := 'delphican.pdf';
    Lines.Add(' ');
    if (FileExists(TPath.Combine(TPath.GetDocumentsPath, xFile))) then
      Lines.Add(xFile + ' available in internal folder')
    else
      Lines.Add(xFile + ' not in internal folder');
    xFile := 'delphican.pdf';
    if (FileExists(TPath.Combine(TPath.GetSharedDownloadsPath, xFile))) then
      Lines.Add(xFile + ' available in external folder')
    else
      Lines.Add(xFile + ' not in external folder');
    Lines.Add(' ');
    GoToTextEnd;
  end;
end;

procedure TForm1.MemoUriTap(Sender: TObject; const Point: TPointF);
begin
  if UriLive <> nil then
    MemoUri.Text := JStringToString(UriLive.toString)
  else
    MemoUri.Text := '';
end;

function TForm1.TextFileReader(Uri: JNet_Uri): string;
(* readTextFromUri *)
const
  bufferSize = 4096 * 2;
var
  inputStream: JInputStream;
  b: TJavaArray<Byte>;
  ms: TMemoryStream;
  sl: TStringList;
  bufflen: Integer;
begin
  result := '';
  try
    inputStream := TAndroidHelper.Context.getContentResolver.
      openInputStream(Uri);
    ms := TMemoryStream.Create;
    bufflen := inputStream.available;
    b := TJavaArray<Byte>.Create(bufflen);
    inputStream.read(b);
    ms.write(b.Data^, bufflen);
    ms.position := 0;
    sl := TStringList.Create;
    sl.LoadFromStream(ms);
    result := sl.Text;
    sl.Free;
    b.Free;
    ms.Free;
    inputStream.close;
  except
    on E: Exception do
      Application.ShowException(E);
  end;
end;

procedure TForm1.PdfShow(Uri: JNet_Uri);
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setDataAndType(UriLive, StringToJString('application/pdf'));
  Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, JParcelable(UriLive));
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  TAndroidHelper.Activity.startActivity(Intent);
end;

procedure TForm1.ImageViewer(Uri: JNet_Uri; Picture: TImageControl);
  procedure GetEXIF(const AFileName: JInputStream);
  var
    LEXIF: JExifInterface;
    LLatLong: TJavaArray<Single>;
  begin
    try
      LEXIF := TJExifInterface.JavaClass.init(AFileName);
      Memo1.Lines.Add('Date Taken: ' +
        JStringToString(LEXIF.getAttribute
        (TJExifInterface.JavaClass.TAG_DATETIME)));
      Memo1.Lines.Add('Camera Brand: ' +
        JStringToString(LEXIF.getAttribute
        (TJExifInterface.JavaClass.TAG_MAKE)));
      Memo1.Lines.Add('Camera Model: ' +
        JStringToString(LEXIF.getAttribute
        (TJExifInterface.JavaClass.TAG_MODEL)));
      LLatLong := TJavaArray<Single>.Create(2);
      try
        if LEXIF.getLatLong(LLatLong) then
        begin
          Memo1.Lines.Add('Latitude: ' + LLatLong.Items[0].toString);
          Memo1.Lines.Add('Longitude: ' + LLatLong.Items[1].toString);
        end;
      finally
        LLatLong.Free;
      end;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
    Memo1.GoToTextEnd;
  end;

var
  FullPhotoUri: JNet_Uri;
  jis: JInputStream;
  NativeBitmap: JBitmap;
  surf: TBitmapSurface;
begin
  try
    try
      FullPhotoUri := Uri;
      jis := TAndroidHelper.Context.getContentResolver.openInputStream
        (FullPhotoUri);
      GetEXIF(jis);
      jis.close;
      jis := TAndroidHelper.Context.getContentResolver.openInputStream
        (FullPhotoUri);
      NativeBitmap := TJBitmapFactory.JavaClass.decodeStream(jis);
      surf := TBitmapSurface.Create;
      if JBitmapToSurface(NativeBitmap, surf) then
        ImageControl1.Bitmap.Assign(surf);
    except
      on E: Exception do
        Application.ShowException(E);
    end;
  finally
    jis.close;
  end; // https://stackoverflow.com/questions/60155948/deplhi-trying-to-get-exif-data-on-library-images-in-android
end;

end.
