unit MsgExPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� MsgExPool
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgExImpl,
  CommonLock,
  CommonPool,
  Generics.Collections;

type

  // MsgExPool
  TMsgExPool = class(TObjectPool)
  private
  protected
    // Create
    function DoCreate: TObject; override;
    // Destroy
    procedure DoDestroy(AObject: TObject); override;
    // Allocate Before
    procedure DoAllocateBefore(AObject: TObject); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(AObject: TObject); override;
  public
  end;

implementation

{ TMsgExPool }

function TMsgExPool.DoCreate: TObject;
begin
  Result := TMsgExImpl.Create;
  TMsgExImpl(Result).Update(0, '');
end;

procedure TMsgExPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

procedure TMsgExPool.DoAllocateBefore(AObject: TObject);
begin

end;

procedure TMsgExPool.DoDeAllocateBefore(AObject: TObject);
begin
  if AObject <> nil then begin
    TMsgExImpl(AObject).Update(0, '');
  end;
end;

end.
