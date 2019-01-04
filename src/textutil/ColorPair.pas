unit ColorPair;

interface

uses
  Graphics;

const

    COLOR_BOX_COUNT = 6;

    DEFAULT_PALETTE_HEAD : array [0..COLOR_BOX_COUNT-1] of string =
      ( 'clDefault', '$00C080FF', 'clDefault', 'clDefault', 'clDefault', 'clDefault');
    DEFAULT_PALETTE_BACK : array [0..COLOR_BOX_COUNT-1] of string =
      ( 'clDefault', 'clDefault', '$00FFC0C0', '$00C0FFA0', '$00D0D0FF', '$00C0FFFF');

type

    TCellColorConfig = record
        Head: TColor;
        Back: TColor;
    end;


implementation

end.
