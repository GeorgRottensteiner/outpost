NUM_SPRITE_SLOTS        = 8

SPRITE_BASE             = ( SPRITE_LOCATION % 16384 ) / 64

SPRITE_PLAYER_R1        = SPRITE_BASE + 0
SPRITE_PLAYER_L1        = SPRITE_BASE + 4
SPRITE_PLAYER_SHOT      = SPRITE_BASE + 48
SPRITE_EXPLOSION        = SPRITE_BASE + 49
SPRITE_BLOB             = SPRITE_BASE + 52

SPRITE_PLAYER_HITBACK_L = SPRITE_BASE + 54
SPRITE_PLAYER_HITBACK_R = SPRITE_BASE + 56

SPRITE_PLAYER_KNEEL_R   = SPRITE_BASE + 58
SPRITE_PLAYER_KNEEL_L   = SPRITE_BASE + 61
SPRITE_PLAYER_UP        = SPRITE_BASE + 36
SPRITE_PLAYER_DOWN      = SPRITE_BASE + 32

SPRITE_BIG_BLOB_L       = SPRITE_BASE + 64

TYPE_PLAYER             = 1
TYPE_PLAYER_SHOT        = 3
TYPE_EXPLOSION          = 4
TYPE_BLOB               = 5
TYPE_BIG_BLOB           = 6
;7 = blob bottom

OBJECT_HEIGHT           = 16

SPRITE_CENTER_OFFSET_X  = 8
SPRITE_CENTER_OFFSET_Y  = 11

SCREEN_PANEL_POS        = SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + GAME_FIELD_HEIGHT_IN_TILES * 2 + 1 ) * 40



!zone RemoveAllObjects
RemoveAllObjects
          ldx #0
          txa
-
          sta SPRITE_ACTIVE,x
          inx
          cpx #8
          bne -

          sta SPRITES_ENABLED
          sta ACTIVE_ENEMY_COUNT
          rts


;------------------------------------------------------------
;move object left if not blocked
;x = object index
;return 1 if moved, 0 if blocked
;------------------------------------------------------------
!zone ObjectMoveLeftBlocking
ObjectMoveLeftBlocking
          lda SPRITE_TILE_POS_X_DELTA,x
          beq .CheckCanMoveLeft

.CanMoveLeft
          jsr ObjectMoveLeft
          lda #1
          rts

.CheckCanMoveLeft
          ldy SPRITE_TILE_POS_X,x
          dey
          lda CURRENT_MAP_DATA
          clc
          adc MAP_DATA_OFFSET_LO,y
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_DATA + 1
          adc MAP_DATA_OFFSET_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #4
          lda (ZEROPAGE_POINTER_1),y
          jsr IsTileBlocking
          beq .CanMoveLeft

          ;blocked
          lda #0
          rts



;------------------------------------------------------------
;move object left
;x = object index
;------------------------------------------------------------
!zone ObjectMoveLeft
ObjectMoveLeft

          lda SPRITE_CHAR_POS_X_DELTA,x
          bne .NoCharStep

          lda #8
          sta SPRITE_CHAR_POS_X_DELTA,x
          dec SPRITE_CHAR_POS_X,x

.NoCharStep
          dec SPRITE_CHAR_POS_X_DELTA,x

          lda SPRITE_TILE_POS_X_DELTA,x
          bne .NoTileStep

          lda #32
          sta SPRITE_TILE_POS_X_DELTA,x
          dec SPRITE_TILE_POS_X,x

.NoTileStep
          dec SPRITE_TILE_POS_X_DELTA,x

          lda SPRITE_COUNT,x
          sta PARAM12
-
          dec PARAM12
          beq .Done1

          lda SPRITE_CHAR_POS_X,x
          sta SPRITE_CHAR_POS_X + 1,x
          lda SPRITE_POS_X,x
          sta SPRITE_POS_X + 1,x

          inx
          jmp -

.Done1
          ldx CURRENT_INDEX

          lda SPRITE_COUNT,x
          sta PARAM12
-
          jsr MoveSpriteLeft

          dec PARAM12
          beq .Done

          inx
          jmp -

.Done
          ldx CURRENT_INDEX
          rts


!zone ObjectShiftLeft
ObjectShiftLeft

          lda SPRITE_CHAR_POS_X_DELTA,x
          bne .NoCharStep

          lda #8
          sta SPRITE_CHAR_POS_X_DELTA,x
          dec SPRITE_CHAR_POS_X,x

.NoCharStep
          dec SPRITE_CHAR_POS_X_DELTA,x

          lda SPRITE_COUNT,x
          sta PARAM12
-
          jsr MoveSpriteLeft

          dec PARAM12
          beq .Done
          inx
          jmp -

.Done
          ldx CURRENT_INDEX
          rts



;------------------------------------------------------------
;Move Sprite Left
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteLeft
MoveSpriteLeft
          lda SPRITE_POS_X,x
          bne .NoChangeInExtendedFlag

          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND

.NoChangeInExtendedFlag
          ;going outside left?
          lda SPRITE_CHAR_POS_X,x
          bmi .Disable

          cmp #39
          beq .ComingInFromRight
          bcs .Disable
          bne .PlainEnable

.ComingInFromRight
          ;extended x
          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND

.PlainEnable
          ;enable
          lda BIT_TABLE,x
          ora SPRITES_ENABLED
          sta SPRITES_ENABLED
          jmp .Enabled

.Disable
          lda BIT_TABLE,x
          eor #$ff
          and SPRITES_ENABLED
          sta SPRITES_ENABLED

.Enabled
          dec SPRITE_POS_X,x
          rts


;move object right if not blocked
;x = object index
;retuens a = 1 if moved, 0 if blocked
!zone ObjectMoveRightBlocking
ObjectMoveRightBlocking
          lda SPRITE_TILE_POS_X_DELTA,x
          cmp #16
          beq .CheckCanMoveRight

.CanMoveRight
          jsr ObjectMoveRight
          lda #1
          rts

.CheckCanMoveRight
          ldy SPRITE_TILE_POS_X,x
          iny
          lda CURRENT_MAP_DATA
          clc
          adc MAP_DATA_OFFSET_LO,y
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_DATA + 1
          adc MAP_DATA_OFFSET_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #4
          lda (ZEROPAGE_POINTER_1),y
          jsr IsTileBlocking
          beq .CanMoveRight

          ;blocked
          lda #0
          rts



;------------------------------------------------------------
;move object right
;x = object index
;------------------------------------------------------------
!zone ObjectMoveRight
ObjectMoveRight
          inc SPRITE_CHAR_POS_X_DELTA,x

          lda SPRITE_CHAR_POS_X_DELTA,x
          cmp #8
          bne .NoCharStep

          lda #0
          sta SPRITE_CHAR_POS_X_DELTA,x
          inc SPRITE_CHAR_POS_X,x

.NoCharStep
          inc SPRITE_TILE_POS_X_DELTA,x

          lda SPRITE_TILE_POS_X_DELTA,x
          cmp #32
          bne .NoTileStep

          lda #0
          sta SPRITE_TILE_POS_X_DELTA,x
          inc SPRITE_TILE_POS_X,x
.NoTileStep

          lda SPRITE_COUNT,x
          sta PARAM12
-
          dec PARAM12
          beq .Done1

          lda SPRITE_CHAR_POS_X,x
          sta SPRITE_CHAR_POS_X + 1,x
          lda SPRITE_POS_X,x
          sta SPRITE_POS_X + 1,x

          inx
          jmp -

.Done1
          ldx CURRENT_INDEX

          lda SPRITE_COUNT,x
          sta PARAM12
-
          jsr MoveSpriteRight

          dec PARAM12
          beq .Done

          inx
          jmp -

.Done
          ldx CURRENT_INDEX
          rts



!lzone ObjectShiftRight
          inc SPRITE_CHAR_POS_X_DELTA,x

          lda SPRITE_CHAR_POS_X_DELTA,x
          cmp #8
          bne .NoCharStep

          lda #0
          sta SPRITE_CHAR_POS_X_DELTA,x
          inc SPRITE_CHAR_POS_X,x

.NoCharStep
          lda SPRITE_COUNT,x
          sta PARAM12
-
          jsr MoveSpriteRight

          dec PARAM12
          beq .Done
          inx
          jmp -

.Done
          ldx CURRENT_INDEX
          rts


;------------------------------------------------------------
;Move Sprite Right
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteRight
MoveSpriteRight
          inc SPRITE_POS_X,x
          lda SPRITE_POS_X,x
          bne .NoChangeInExtendedFlag

          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND

.NoChangeInExtendedFlag
          ;going outside left?
          lda SPRITE_CHAR_POS_X,x
          bmi .Disable

          cmp #39
          bcs .Disable

          ;enable
          lda BIT_TABLE,x
          ora SPRITES_ENABLED
          sta SPRITES_ENABLED

          lda SPRITE_CHAR_POS_X,x
          bne .Enabled

          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND

          jmp .Enabled

.Disable
          lda BIT_TABLE,x
          eor #$ff
          and SPRITES_ENABLED
          sta SPRITES_ENABLED

.Enabled
          rts



;------------------------------------------------------------
;Move Sprite Up
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteUp
MoveSpriteUp
          dec SPRITE_POS_Y,x
          rts



;------------------------------------------------------------
;Move Sprite Down
;expect x as sprite index (0 to 7)
;------------------------------------------------------------
!zone MoveSpriteDown
MoveSpriteDown
          inc SPRITE_POS_Y,x
          rts


;------------------------------------------------------------
;move object up if not blocked
;x = object index
;A = 1 when moved
;------------------------------------------------------------
!zone ObjectMoveUpBlocking
ObjectMoveUpBlocking
          lda SPRITE_CHAR_POS_Y_DELTA,x
          beq .CheckCanMoveUp

.CanMoveUp
          jsr ObjectMoveUp
          lda #1
          rts

.CheckCanMoveUp
          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .BlockedUp
          beq .BlockedUp

          lda SPRITE_WIDTH_CHARS,x
          sta PARAM1

          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .NoSecondCharCheckNeeded
          inc PARAM1
.NoSecondCharCheckNeeded

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          tay
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy SPRITE_CHAR_POS_X,x
          dey
-
          iny

          lda (ZEROPAGE_POINTER_1),y

          jsr IsCharBlocking
          bne .BlockedUp

          dec PARAM1
          bne -

          jmp .CanMoveUp

.BlockedUp
          lda #0
          rts



;------------------------------------------------------------
;move object up
;x = object index
;------------------------------------------------------------
!zone ObjectMoveUp
ObjectMoveUp

          dec SPRITE_CHAR_POS_Y_DELTA,x

          lda SPRITE_CHAR_POS_Y_DELTA,x
          cmp #$ff
          bne .NoCharStep

          lda SPRITE_CHAR_POS_Y,x
          bne +

          lda #24
          sta SPRITE_CHAR_POS_Y,x

          dec SPRITE_SECTOR,x

+
          dec SPRITE_CHAR_POS_Y,x
          lda #7
          sta SPRITE_CHAR_POS_Y_DELTA,x

.NoCharStep
          lda SPRITE_COUNT,x
          sta PARAM12
-
          jsr MoveSpriteUp

          dec PARAM12
          beq .Done
          inx
          jmp -

.Done
          ldx CURRENT_INDEX
          rts



!zone CheckCanMoveDown
;returns 0 if blocked, 1 if move is possible
CheckCanMoveDown
          lda SPRITE_WIDTH_CHARS,x
          sta PARAM1

          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .NoSecondCharCheckNeeded
          inc PARAM1
.NoSecondCharCheckNeeded

          ldy SPRITE_CHAR_POS_Y,x
          iny

          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy SPRITE_CHAR_POS_X,x
          dey
-
          iny

          lda (ZEROPAGE_POINTER_1),y
          jsr IsCharBlocking
          bne .BlockedDown
          dec PARAM1
          bne -

          ;not blocked
          lda #1
          rts

.BlockedDown
          lda #0
          rts



;------------------------------------------------------------
;move object down if not blocked
;x = object index
;returns 0 = blocked, 1 = moved
;------------------------------------------------------------
!zone ObjectMoveDownBlocking
ObjectMoveDownBlocking

          lda SPRITE_CHAR_POS_Y_DELTA,x
          bne +

          jsr CheckCanMoveDown
          bne +

          lda #0
          rts
+

          jsr ObjectMoveDown
          lda #1
          rts

;------------------------------------------------------------
;move object down
;x = object index
;------------------------------------------------------------
!zone ObjectMoveDown
ObjectMoveDown

          inc SPRITE_CHAR_POS_Y_DELTA,x

          lda SPRITE_CHAR_POS_Y_DELTA,x
          cmp #8
          bne .NoCharStep

          lda #0
          sta SPRITE_CHAR_POS_Y_DELTA,x
          inc SPRITE_CHAR_POS_Y,x

          ;wrap at 24
          lda SPRITE_CHAR_POS_Y,x
          cmp #24
          bne +

          lda #0
          sta SPRITE_CHAR_POS_Y,x

          inc SPRITE_SECTOR,x
+

.NoCharStep
          lda SPRITE_COUNT,x
          sta PARAM12
-
          jsr MoveSpriteDown

          dec PARAM12
          beq .Done
          inx
          jmp -

.Done
          ldx CURRENT_INDEX
          rts


;------------------------------------------------------------
;IsCharBlockingL
;checks if a char is blocking
;PARAM1 = char_pos_x
;PARAM2 = char_pos_y
;returns 1 for blocking, 0 for not blocking
;------------------------------------------------------------
!zone IsCharBlocking
IsCharBlocking
          cmp #124
          bcc .NotBlocking

;.Blocking
          lda #1
          rts

.NotBlocking
          lda #0
          rts




!zone IsTileBlocking
IsTileBlocking
          cmp #10
          bne .NotBlocking

          lda #1
          rts

.NotBlocking
          lda #0
          rts



;TYPE_PLAYER             = 1

ENEMY_BEHAVIOUR_TABLE_LO
          !byte <BHPlayer
          !byte <BHNone     ;player part #2
          !byte <BHPlayerShot
          !byte <BHExplosion
          !byte <BHBlob
          !byte <BHBigBlob
          !byte <BHBigBlob2 ;part #2

ENEMY_BEHAVIOUR_TABLE_HI
          !byte >BHPlayer
          !byte >BHNone     ;player part #2
          !byte >BHPlayerShot
          !byte >BHExplosion
          !byte >BHBlob
          !byte >BHBigBlob
          !byte >BHBigBlob2     ;part #2




!zone BHNone
BHNone
          rts



!zone BHExplosion
BHExplosion
          inc SPRITE_ANIM_DELAY,x
          lda SPRITE_ANIM_DELAY,x
          lsr
          lsr
          tay

          cpy #3
          bne +

          jmp RemoveObject

+
          lda EXPLOSION_COLOR,y
          sta VIC.SPRITE_COLOR,x
          tya
          clc
          adc #SPRITE_EXPLOSION
          sta SPRITE_IMAGE,x
          rts


EXPLOSION_COLOR
          !byte 1,7,7




!zone BHPlayerShot
BHPlayerShot
          jsr CheckCollisions
          bcc .NotColliding2

          ldx CURRENT_INDEX

          lda SPRITE_ACTIVE,y
          cmp #TYPE_BLOB
          bne .NotColliding1

          dec ACTIVE_ENEMY_COUNT
          jsr RemoveObject
          sty CURRENT_SUB_INDEX

          ldy #SFX_EXPLODE
          jsr PlaySoundEffect

          ldx CURRENT_SUB_INDEX
          lda #TYPE_EXPLOSION
          jsr SetupSpriteInSlot

          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jmp MoveSpriteUp



.NotColliding1
          cmp #TYPE_BIG_BLOB
          bne .NotColliding2

          ldx CURRENT_SUB_INDEX
          dec SPRITE_HP,x
          bne .ExplodeShot

          ;mark as killed
          ldy SPRITE_VALUE,x
          lda #1
          sta SPECIAL_INDEX_ENEMY_KILLED,y

          lda #TYPE_EXPLOSION
          jsr SetupSpriteInSlot
          ldx CURRENT_SUB_INDEX
          inx
          lda #TYPE_EXPLOSION
          jsr SetupSpriteInSlot

          ldy #SFX_EXPLODE
          jsr PlaySoundEffect

.ExplodeShot
          ldx CURRENT_INDEX
          lda #TYPE_EXPLOSION
          jsr SetupSpriteInSlot

          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jmp MoveSpriteUp


.NotColliding2
          ldx CURRENT_INDEX

          lda #12
          sta PARAM2

          lda SPRITE_DIRECTION,x
          beq .GoR

.GoL
          jsr ObjectMoveLeftBlocking
          beq .Blocked

          dec PARAM2
          bne .GoL

          lda SPRITE_CHAR_POS_X,x
          bmi .Outside
          rts


.GoR
          jsr ObjectMoveRightBlocking
          beq .Blocked

          dec PARAM2
          bne .GoR

          lda SPRITE_CHAR_POS_X,x
          cmp #39
          bcs .Outside
          rts

.Outside
          jmp RemoveObject



.Blocked
          lda #TYPE_EXPLOSION
          jmp SetupSpriteInSlot



;state = 0 > fly left/right (towards player)
;      = 1 > swarm over player
!lzone BHBlob
          inc SPRITE_ANIM_DELAY,x
          lda SPRITE_ANIM_DELAY,x
          and #$03
          bne +
          lda SPRITE_IMAGE,x
          eor #$01
          sta SPRITE_IMAGE,x
+

          inc SPRITE_MOVE_POS,x
          lda SPRITE_MOVE_POS,x
          and #$0f
          tay
          lda BLOB_DELTA_Y,y
          beq .NoDeltaY
          sta PARAM2
          bmi .GoUp

          ;go down
-
          jsr ObjectMoveDown
          dec PARAM2
          bne -
          jmp .NoDeltaY

.GoUp
-
          jsr ObjectMoveUp
          inc PARAM2
          bne -

.NoDeltaY
          lda SPRITE_STATE,x
          cmp #$80
          bne .NoCooldown

          lda SPRITE_STATE_POS,x
          beq .NoUpdate
          dec SPRITE_STATE_POS,x
          bne .NoUpdate

          ;collidable again
          lda #0
          sta SPRITE_STATE,x

.NoUpdate
.NoCooldown
          lda SPRITE_STATE,x
          and #$7f
          beq .PlainMovement

          inc SPRITE_STATE_POS,x
          lda SPRITE_STATE_POS,x
          cmp #10
          bne +

          ;revert to movement
          lda #$80
          sta SPRITE_STATE,x

          ;and turn over
          jmp .Blocked

+

          ;still try to follow the player
          lda SPRITE_CHAR_POS_X
          cmp SPRITE_CHAR_POS_X,x
          beq .WereGood
          bcc .GoLeft
          jmp ObjectMoveRightBlocking

.GoLeft
          jsr ObjectMoveLeftBlocking

.WereGood
          rts

.PlainMovement
          lda #3
          sta PARAM2

          lda SPRITE_DIRECTION,x
          beq .GoR

.GoL
          jsr ObjectMoveLeftBlocking
          beq .Blocked

          dec PARAM2
          bne .GoL

          rts


.GoR
          jsr ObjectMoveRightBlocking
          beq .Blocked

          dec PARAM2
          bne .GoR

          rts

.Blocked
          lda SPRITE_DIRECTION,x
          eor #$01
          sta SPRITE_DIRECTION,x
          rts



BLOB_DELTA_Y
          !byte $03,$02,$01,$00,$ff,$fe,$fd
          !byte $fd,$fd,$fe,$ff,$00,$01,$02
          !byte $03,$03



!lzone BHBigBlob
          inc SPRITE_ANIM_DELAY,x
          lda SPRITE_ANIM_DELAY,x
          and #$03
          bne +
          lda SPRITE_IMAGE,x
          eor #$01
          sta SPRITE_IMAGE,x
+
          ;auto-remove homing state
          lda #0
          sta SPRITE_STATE,x

          lda BIT_TABLE,x
          and SPRITES_ENABLED
          bne .Visible
.SkipMove
          rts

.Visible
          inc SPRITE_MOVE_POS,x
          lda SPRITE_MOVE_POS,x
          and #$01
          bne .SkipMove

          lda SPRITE_CHAR_POS_X
          cmp SPRITE_CHAR_POS_X,x
          bmi .GoLeft
          beq .Blocked

          lda SPRITE_DIRECTION,x
          beq .LookingRAlready

          lda #0
          sta SPRITE_DIRECTION,x
          lda #SPRITE_BIG_BLOB_L + 4
          sta SPRITE_IMAGE,x
          lda #SPRITE_BIG_BLOB_L + 6
          sta SPRITE_IMAGE + 1,x

.LookingRAlready
          jmp ObjectMoveRightBlocking

.GoLeft
          lda SPRITE_DIRECTION,x
          bne .LookingLAlready

          lda #1
          sta SPRITE_DIRECTION,x
          lda #SPRITE_BIG_BLOB_L
          sta SPRITE_IMAGE,x
          lda #SPRITE_BIG_BLOB_L + 2
          sta SPRITE_IMAGE + 1,x

.LookingLAlready


          jmp ObjectMoveLeftBlocking

.Blocked
          rts



!lzone BHBigBlob2
          lda SPRITE_CHAR_POS_X - 1,x
          sta SPRITE_CHAR_POS_X,x
          lda SPRITE_CHAR_POS_X_DELTA - 1,x
          sta SPRITE_CHAR_POS_X_DELTA,x
          lda SPRITE_TILE_POS_X - 1,x
          sta SPRITE_TILE_POS_X,x
          lda SPRITE_TILE_POS_X_DELTA - 1,x
          sta SPRITE_TILE_POS_X_DELTA,x
          lda SPRITE_POS_X - 1,x
          sta SPRITE_POS_X,x

          ;remove our flag
          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND

          lda BIT_TABLE - 1,x
          and SPRITE_POS_X_EXTEND
          beq +

          ;our bit must be set
          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
+


          inc SPRITE_ANIM_DELAY,x
          lda SPRITE_ANIM_DELAY,x
          and #$03
          bne +
          lda SPRITE_IMAGE,x
          eor #$01
          sta SPRITE_IMAGE,x
+
          rts



;Enemy Behaviour
!lzone ObjectControl
          ldx #0

.ObjectLoop
          stx CURRENT_INDEX
          ;does object exist?
          ldy SPRITE_ACTIVE,x
          beq .NextObject

          ;enemy is active
          dey
          lda ENEMY_BEHAVIOUR_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda ENEMY_BEHAVIOUR_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ;set up return address for rts
          lda #>( .NextObject - 1 )
          pha
          lda #<( .NextObject - 1 )
          pha

          jmp (ZEROPAGE_POINTER_1)

.NextObject
          ldx CURRENT_INDEX
          inx
          cpx #8
          bne .ObjectLoop
          rts



;check joystick (player control)
;state   0: normal playing
!lzone BHPlayer
          lda SPRITE_HIT_BACK
          beq .NoHitBack

          dec SPRITE_HIT_BACK

          lda SPRITE_DIRECTION
          beq .HitBackL

          lda SPRITE_POS_X
          cmp #168
          bcc .MoveRightB

          jsr ScrollRightToLeft
          beq .ScrolledB

.MoveRightB
          jsr ObjectMoveRightBlocking

.ScrolledB
          jmp .UpdateMapObjectUnderPlayer


.HitBackL
          lda SPRITE_POS_X_EXTEND
          and #$01
          bne .MoveLeftB
          lda SPRITE_POS_X
          cmp #168
          bcs .MoveLeftB

          jsr ScrollLeftToRight
          beq .Scrolled2B

.MoveLeftB
          jsr ObjectMoveLeftBlocking

.Scrolled2B
          jmp .UpdateMapObjectUnderPlayer

.DoorHandlingDone
          rts

.NoHitBack
          lda SPRITE_STATE
          cmp #4
          bne .NotClosingDoor

          ;closing door
          inc DOOR_OPEN_DELAY
          lda DOOR_OPEN_DELAY
          and #$01
          bne .DoorHandlingDone

          ldy DOOR_OPEN_POS
          lda DOOR_TOP_TILES,y
          sta PARAM3

          cpy #0
          bne +

          ldy #SFX_DOOR
          jsr PlaySoundEffect
+

          ldx OPEN_DOOR_X_POS
          ldy #4
          lda PARAM3
          jsr DrawTile
          ldx OPEN_DOOR_X_POS
          ldy #6
          lda PARAM3
          clc
          adc #1
          jsr DrawTile
          ldx OPEN_DOOR_X_POS
          ldy #8
          lda PARAM3
          clc
          ;adc #2
          adc #1
          jsr DrawTile

          dec DOOR_OPEN_POS
          bmi .DoorHandlingDone3
          rts

.DoorHandlingDone3
          ;door is open
          inc SPRITE_STATE
          rts

.NotClosingDoor
          cmp #3
          bne .NotWalkingOut

          inc SPRITE_ANIM_POS
          lda SPRITE_ANIM_POS
          lsr
          and #$03
          clc
          adc #SPRITE_PLAYER_DOWN
          sta SPRITE_IMAGE
          clc
          adc #8
          sta SPRITE_IMAGE + 1

          jsr ObjectMoveDown

          lda SPRITE_POS_Y
          cmp #95
          bne .DoorHandlingDone

          lda OPEN_DOOR_TILE
          cmp #DOOR_TILE_CLOSED
          beq .CloseDoor
          inc SPRITE_STATE
.CloseDoor
          inc SPRITE_STATE
          lda #4
          sta DOOR_OPEN_POS
          rts

.NotWalkingOut
          cmp #1
          bne .NoDoor

          lda SPRITE_STATE_POS
          beq .OpeningDoor
          cmp #1
          bne .NotWalkingUp

          inc SPRITE_ANIM_POS
          lda SPRITE_ANIM_POS
          lsr
          and #$03
          clc
          adc #SPRITE_PLAYER_UP
          sta SPRITE_IMAGE
          clc
          adc #8
          sta SPRITE_IMAGE + 1

          jsr ObjectMoveUp

          lda SPRITE_POS_Y
          cmp #85
          bne .DoorHandlingDone2

          inc SPRITE_STATE

.NotWalkingUp
          jmp .DoorHandlingDone

.OpeningDoor
          inc DOOR_OPEN_DELAY
          lda DOOR_OPEN_DELAY
          and #$01
          bne .DoorHandlingDone2

          ldy DOOR_OPEN_POS
          lda DOOR_TOP_TILES,y
          sta PARAM3

          ldx OPEN_DOOR_X_POS
          ldy #4
          lda PARAM3
          jsr DrawTile
          ldx OPEN_DOOR_X_POS
          ldy #6
          lda PARAM3
          clc
          adc #1
          jsr DrawTile
          ldx OPEN_DOOR_X_POS
          ldy #8
          lda PARAM3
          clc
          adc #1
          jsr DrawTile

          inc DOOR_OPEN_POS
          lda DOOR_OPEN_POS
          cmp #5
          bne .DoorHandlingDone2

          inc SPRITE_STATE_POS
          lda #SPRITE_PLAYER_UP
          sta SPRITE_IMAGE
          lda #SPRITE_PLAYER_UP + 4
          sta SPRITE_IMAGE + 1

          jmp .DoorHandlingDone

.DoorHandlingDone2
          rts


.NoDoor
          jsr CheckCollisions
          bcc .NotColliding

          sty PARAM3
          lda SPRITE_ACTIVE,y
          tay
          lda TYPE_IS_ENEMY,y
          cmp #1
          bne .NotColliding

          ;enemy hit us
          lda #15
          sta SPRITE_HIT_BACK

          ;mark enemy as homed in
          ldy PARAM3
          lda SPRITE_STATE,y
          bne .AlreadyHoming
          lda #$81
          sta SPRITE_STATE,y
          lda #0
          sta SPRITE_STATE_POS,x
.AlreadyHoming

          ldy SPRITE_DIRECTION
          lda PLAYER_HITBACK_SPRITE,y
          sta SPRITE_IMAGE
          sta SPRITE_IMAGE + 1
          inc SPRITE_IMAGE + 1

          lda PLAYER_HEALTH
          sec
          sbc #10
          sta PLAYER_HEALTH

          ldy #SFX_HURT
          jsr PlaySoundEffect

          ldx #10

          lda #<( SCREEN_PANEL_POS + $9a )
          sta ZEROPAGE_POINTER_1
          lda #>( SCREEN_PANEL_POS + $9a )
          sta ZEROPAGE_POINTER_1 + 1
-
          jsr DecreaseValue

          dex
          bne -

          rts

.NotColliding
          lda #0
          sta PLAYER_KNEELING

          lda #JOY_DOWN
          and JOY_VALUE
          bne .NotDown

          inc PLAYER_KNEELING

.NotDown


          lda #JOY_BUTTON
          jsr JoyReleasedControlPressed
          bne +

          ;shoot
          lda PLAYER_CARRIES_GUN
          beq +

          ;no energy
          lda PLAYER_ENERGY
          ora PLAYER_ENERGY + 1
          bne .HasEnergy

          ldy #SFX_GUN_EMPTY
          jsr PlaySoundEffect
          ldx #0
          jmp +

.HasEnergy
          jsr FindEmptySpriteSlot
          beq .NoFreeSlot

          lda PLAYER_ENERGY
          sec
          sbc #1
          sta PLAYER_ENERGY
          bcs ++
          dec PLAYER_ENERGY + 1
++
          lda #<( SCREEN_PANEL_POS + $112 )
          sta ZEROPAGE_POINTER_1
          lda #>( SCREEN_PANEL_POS + $112 )
          sta ZEROPAGE_POINTER_1 + 1
          jsr DecreaseValue


          lda SPRITE_TILE_POS_X
          sec
          sbc X_OFFSET_TILE
          asl
          asl
          clc
          sta PARAM1

          ;add on offset of player
          lda SPRITE_TILE_POS_X_DELTA
          lsr
          lsr
          lsr
          clc
          adc PARAM1
          sta PARAM1


          lda SPRITE_CHAR_POS_Y
          sta PARAM2
          lda PLAYER_KNEELING
          beq .NotKneeling
          inc PARAM2
.NotKneeling
          lda #TYPE_PLAYER_SHOT
          sta PARAM3
          jsr SpawnObjectInSlot

          lda SPRITE_DIRECTION
          sta SPRITE_DIRECTION,x
          lda SPRITE_TILE_POS_X_DELTA
          sta SPRITE_TILE_POS_X_DELTA,x

          ldy #SFX_SHOOT
          jsr PlaySoundEffect

          ldx #0

.NoFreeSlot
+
          ;toggle items (space)
          lda PRESSED_KEY
          cmp #32
          bne +

          ldx ACTIVE_ITEM
.CheckNextItem
          inx
          cpx #NUM_KNOWN_ITEMS
          bne .XOk

          ldx #0
.XOk
          stx ACTIVE_ITEM
          lda ITEM_COLLECTED,x
          beq .CheckNextItem

          jsr DisplayInventory

          lda #0
          sta PLAYER_CARRIES_GUN

          ldy #SFX_BLIP
          jsr PlaySoundEffect

          lda ACTIVE_ITEM
          cmp #ITEM_PISTOL
          bne +

          lda #16
          sta PLAYER_CARRIES_GUN
+

          ldx #0
          stx CURRENT_INDEX

          ;search/enter
          lda #JOY_UP
          jsr JoyReleasedControlPressed
          bne +

          ldy PLAYER_MAP_OBJECT
          bmi .NotInFrontOfObject

          lda MAP_OBJECT_TYPE,y
          tay

          lda MAP_OBJECT_ACTION_LO,y
          sta .MapObjectAction
          lda MAP_OBJECT_ACTION_HI,y
          sta .MapObjectAction + 1

.MapObjectAction = * + 1
          jmp $ffff

.NotInFrontOfObject
          ;in front of door?
          ldy SPRITE_TILE_POS_X,x
          lda CURRENT_MAP_DATA
          clc
          adc MAP_DATA_OFFSET_LO,y
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_DATA + 1
          adc MAP_DATA_OFFSET_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #4
          lda (ZEROPAGE_POINTER_1),y
          cmp #DOOR_TILE_OPEN
          beq .OpenDoor
          cmp #DOOR_TILE_CLOSED
          bne +

          ;closed/locked door

.OpenDoor
          ;walk in door
          sta OPEN_DOOR_TILE
          ldy SPRITE_TILE_POS_X,x
          jsr WalkInDoor

          jmp .UpdateMapObjectUnderPlayer
+

          lda #JOY_RIGHT
          and JOY_VALUE
          bne .NotR

          lda #0
          sta SPRITE_DIRECTION

          lda PLAYER_KNEELING
          bne .NoMovingR

          inc SPRITE_MOVE_POS

          lda #2
          sta PARAM10

--
          lda SPRITE_POS_X
          cmp #168
          bcc .MoveRight

          ;if scrolled we also need to add up tile_pos_x_delta (and char_pos_x_delta?)
          jsr ObjectMoveRightBlocking
          beq .BlockedR
          jsr ScrollRightToLeft
          jmp .Scrolled

.MoveRight
          jsr ObjectMoveRightBlocking

.Scrolled
          dec PARAM10
          bne --

.BlockedR
          jsr .UpdateMapObjectUnderPlayer

.NoMovingR
.NotR
          lda #JOY_LEFT
          and JOY_VALUE
          bne .NotL

          lda #1
          sta SPRITE_DIRECTION

          lda PLAYER_KNEELING
          bne .NoMovingL

          inc SPRITE_MOVE_POS

          lda #2
          sta PARAM10

--
          lda SPRITE_POS_X_EXTEND
          and #$01
          bne .MoveLeft
          lda SPRITE_POS_X
          cmp #168
          bcs .MoveLeft

          ;if scrolled we also need to add up tile_pos_x_delta (and char_pos_x_delta?)
          jsr ObjectMoveLeftBlocking
          beq .BlockedL
          jsr ScrollLeftToRight
          jmp .Scrolled2

.MoveLeft
          jsr ObjectMoveLeftBlocking

.Scrolled2
          dec PARAM10
          bne --

.BlockedL
          jsr .UpdateMapObjectUnderPlayer

.NoMovingL
.NotL
          ;update sprite
          ldy SPRITE_DIRECTION
          lda PLAYER_KNEELING
          beq .NoKneeling

          lda PLAYER_SPRITE_KNEEL,y
          sta SPRITE_IMAGE
          clc
          adc #1
          sta SPRITE_IMAGE + 1

          lda PLAYER_CARRIES_GUN
          beq +

          inc SPRITE_IMAGE + 1

+
          rts

.NoKneeling

          lda SPRITE_MOVE_POS
          lsr
          lsr
          and #$03
          clc
          adc PLAYER_BASE_SPRITE,y
          adc PLAYER_CARRIES_GUN
          sta SPRITE_IMAGE
          clc
          adc #8
          sta SPRITE_IMAGE + 1

          rts

PLAYER_SPRITE_KNEEL
          !byte SPRITE_PLAYER_KNEEL_R
          !byte SPRITE_PLAYER_KNEEL_L

.UpdateMapObjectUnderPlayer
          lda SPRITE_TILE_POS_X
          sta PARAM1

          ldy #0
-
          cpy NUM_MAP_OBJECTS
          beq .NoObjectFound

          lda MAP_OBJECT_X_POS,y
          cmp PARAM1
          beq .ObjectFound

          iny
          jmp -


.ObjectFound
          cpy PLAYER_MAP_OBJECT
          bne .ObjectChanged

          sty PLAYER_MAP_OBJECT
          rts


.NoObjectFound
          ldy #$ff
          cpy PLAYER_MAP_OBJECT
          bne .ObjectChanged

          rts


;y = map object index or $ff
.ObjectChanged
          sty PLAYER_MAP_OBJECT

          ;update display
          lda MAP_OBJECT_TYPE,y
          tay
          lda MAP_OBJECT_NAME_LO,y
          sta ZEROPAGE_POINTER_1
          lda MAP_OBJECT_NAME_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda #<( SCREEN_PANEL_POS + $5a + 40 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_PANEL_POS + $5a + 40 )
          sta ZEROPAGE_POINTER_2 + 1

          ldy #0

          lda PLAYER_MAP_OBJECT
          bmi .ObjectNameFinished

-
          lda (ZEROPAGE_POINTER_1),y
          beq .ObjectNameFinished
          sta (ZEROPAGE_POINTER_2),y
          iny
          jmp -


.ObjectNameFinished
          ;fill with blanks
          lda #$20
-
          sta (ZEROPAGE_POINTER_2),y
          iny
          cpy #20
          bne -

          rts


;PLAYER_MAP_OBJECT  = object on map (charger)
;ACTIVE_ITEM        = Item in Hand
!lzone ChargeObject
          lda ACTIVE_ITEM
          cmp #ITEM_PISTOL
          bne .DoesntWork

          lda #100
          sta PLAYER_ENERGY

          lda #'1'
          sta SCREEN_PANEL_POS + $112
          lda #'0'
          sta SCREEN_PANEL_POS + $112 + 1
          sta SCREEN_PANEL_POS + $112 + 2

          ldy #SFX_CHARGE
          jsr PlaySoundEffect

          lda #TEXT_CHARGED
          jmp AddText


.DoesntWork
          lda #TEXT_DOESNT_WORK
          jmp AddText



!lzone NavCom
          ldy #SFX_COMPUTER
          jsr PlaySoundEffect

          ldy PLAYER_MAP_OBJECT
          lda MAP_OBJECT_CONTENT,y
          cmp #11
          bne +

          lda #1
          sta GAME_KNOW_ABOUT_BIO_LAB_DOORS
          lda #11

+
          jmp AddText


!lzone Elevator
          ldy PLAYER_MAP_OBJECT
          lda MAP_OBJECT_CONTENT,y
          jmp HandleElevator



!lzone ControlPanel
          ldy #SFX_COMPUTER
          jsr PlaySoundEffect

          lda GAME_KNOW_ABOUT_BIO_LAB_DOORS
          bne .Know

          lda #TEXT_OVERRIDE
          jmp AddText


.Know
          ldy PLAYER_MAP_OBJECT
          lda MAP_OBJECT_CONTENT,y
          tay
          lda UNLOCKED_DOOR,y
          bne .AlreadyUnlocked

          lda #1
          sta UNLOCKED_DOOR,y

          ;the bio lab door?
          cpy #5
          bne .AlreadyUnlocked

          inc GAME_PROGRESS

.AlreadyUnlocked
          lda #TEXT_UNLOCKED
          jmp AddText



!lzone ControlPanelBridge
          ldy #SFX_COMPUTER
          jsr PlaySoundEffect

          lda UNLOCKED_DOOR + 7
          bne .AlreadyUnlocked

          ;unlock escape pods
          lda #1
          sta UNLOCKED_DOOR + 7

          inc GAME_PROGRESS

.AlreadyUnlocked
          ldy PLAYER_MAP_OBJECT
          lda MAP_OBJECT_CONTENT,y
          jmp AddText



!lzone EscapePod
          lda ACTIVE_ITEM
          cmp #ITEM_NONE
          bne +

          lda #TEXT_DOOR_LOCKED
          jmp AddText
+
          cmp #ITEM_CROWBAR
          bne +

          lda #1
          sta GAME_COMPLETED
          lda #TEXT_POD_OPEN
          jmp AddText

+
          lda #TEXT_DOESNT_WORK
          jmp AddText


!lzone PlayerSearchObject
          ldy #SFX_SEARCH
          jsr PlaySoundEffect

          ldy PLAYER_MAP_OBJECT
          lda MAP_OBJECT_CONTENT,y
          beq .Empty

          tay
          lda ITEM_COLLECTED,y
          bne .Empty

          lda #1
          sta ITEM_COLLECTED,y

          cpy #ITEM_PISTOL
          beq .Gun
          cpy #ITEM_KEYCARD_2
          beq .Keycard
          cpy #ITEM_KEYCARD_BRIDGE
          beq .KeycardBridge
          cpy #ITEM_CROWBAR
          beq .Crowbar

          jmp .Empty

.Gun
          lda #1
          sta GAME_PROGRESS

          jsr DisplayInventory

          lda #TEXT_FOUND_PISTOL
          jmp AddText

.Keycard
          jsr DisplayInventory

          lda #TEXT_FOUND_KEYCARD_2
          jmp AddText

.Crowbar
          jsr DisplayInventory

          lda #TEXT_FOUND_CROWBAR
          jmp AddText

.KeycardBridge
          jsr DisplayInventory

          inc GAME_PROGRESS

          lda #TEXT_FOUND_KEYCARD_BRIDGE
          jmp AddText

.Empty
          lda #TEXT_FOUND_NOTHING
          jmp AddText



PLAYER_BASE_SPRITE
          !byte SPRITE_PLAYER_R1
          !byte SPRITE_PLAYER_L1

PLAYER_HITBACK_SPRITE
          !byte SPRITE_PLAYER_HITBACK_L
          !byte SPRITE_PLAYER_HITBACK_R






;check enemy collision with current object (CURRENT_INDEX)
;return carry set if collided, y/CURRENT_SUB_INDEX = other object index
!zone CheckCollisions
CheckCollisions
          ldx #0
          stx CURRENT_SUB_INDEX
-
          cpx CURRENT_INDEX
          beq .NextObject

          lda SPRITE_ACTIVE,x
          bne +

          inc CURRENT_SUB_INDEX
          ldx CURRENT_SUB_INDEX
          jmp ++

.NextObject
          lda CURRENT_SUB_INDEX
          tax
          clc
          adc SPRITE_COUNT,x
          tax
          stx CURRENT_SUB_INDEX
++
          cpx #8
          bne -

          ldx CURRENT_INDEX
          clc
          rts

+
          ;check for collision
          ;is in untouchable state?
          lda SPRITE_STATE,x
          bmi .NextObject

          ;is an enemy?
          lda SPRITE_ACTIVE,x
          tay
          lda TYPE_IS_ENEMY,y
          beq .NextObject

          ldy CURRENT_INDEX
          jsr IsObjectCollidingWithObject
          beq .NextObject

          ;objects collided
          ldy CURRENT_SUB_INDEX
          ldx CURRENT_INDEX
          sec
          rts



!zone IsObjectCollidingWithObject
.CalculateSimpleXPos
          ;Returns a with simple x pos (x halved + 128 if > 256)
          ;modifies y
          lda BIT_TABLE,x
          and SPRITE_POS_X_EXTEND
          beq .NoXBit

          lda SPRITE_POS_X,x
          lsr
          clc
          adc #128
          rts

.NoXBit
          lda SPRITE_POS_X,x
          lsr
          rts

;check object collision with other objects
;CURRENT_INDEX is current object
;CURRENT_SUB_INDEX is other object
;return a = 1 when colliding, a = 0 when not
IsObjectCollidingWithObject
          ldx CURRENT_INDEX
          lda BIT_TABLE,x
          and SPRITES_ENABLED
          beq .NotTouching

          ldx CURRENT_SUB_INDEX
          lda BIT_TABLE,x
          and SPRITES_ENABLED
          beq .NotTouching

          lda SPRITE_HEIGHT_CHARS,x
          asl
          asl
          asl
          sta PARAM9

          ;y expanded?
          ldy SPRITE_ACTIVE,x
          lda TYPE_START_FLAGS,y
          and #$20
          beq .NotExpanded

          asl PARAM9

.NotExpanded
          ldy CURRENT_INDEX

          ;modifies X
          ;check y pos
          lda SPRITE_POS_Y,x
          sec
          sbc PARAM9              ;offset to bottom
          cmp SPRITE_POS_Y,y
          bcs .NotTouching
          clc
          adc PARAM9
          adc PARAM9
          sec
          sbc #1
          cmp SPRITE_POS_Y,y
          bcc .NotTouching

          ;X = Index in enemy-table
          jsr .CalculateSimpleXPos
          sta PARAM1
          ;vs. player X
          tya
          tax
          jsr .CalculateSimpleXPos

          sec
          sbc #4
          ;position X-Anfang Player - 12 Pixel
          cmp PARAM1
          bcs .NotTouching
          adc #8
          cmp PARAM1
          bcc .NotTouching

          lda #1
          rts

.NotTouching
          lda #0
          rts



;x is sprite slot
;PARAM1 is X
;PARAM2 is Y
;PARAM3 is object type
;PARAM4 = color
;returns #1 in A if object added, #0 if all slots were full
!zone SpawnObject
SpawnObject
          jsr FindEmptySpriteSlot

          ;add object to sprite array
          bne .FreeSlotFound
          rts

SpawnObjectInSlot
.FreeSlotFound
          ;PARAM1 and PARAM2 hold x,y already
          jsr CalcSpritePosFromCharPos

          lda SPRITE_CHAR_POS_X,x
          bmi .Outside
          cmp #39
          bcs .Outside

          ;enable sprite
          lda BIT_TABLE,x
          ora SPRITES_ENABLED
          sta SPRITES_ENABLED

.Outside
          lda PARAM3
;x = slot, a = new type
SetupSpriteInSlot
          sta SPRITE_ACTIVE,x
          tay

          ;sprite color
          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_MULTICOLOR
          sta VIC.SPRITE_MULTICOLOR

          lda TYPE_START_COLOR,y
          sta VIC.SPRITE_COLOR,x
          bpl .SingleColor

          lda BIT_TABLE,x
          ora VIC.SPRITE_MULTICOLOR
          sta VIC.SPRITE_MULTICOLOR

.SingleColor
          ;initialise enemy values
          lda TYPE_START_SPRITE,y
          sta SPRITE_BASE_IMAGE,x
          sta SPRITE_IMAGE,x
          sta SPRITE_POINTER_BASE,x

          txa
          sta SPRITE_MAIN_INDEX,x
          lda #1
          sta SPRITE_COUNT,x

          ;look right per default
          lda #0
          sta SPRITE_DIRECTION,x
          sta SPRITE_DIRECTION_Y,x
          sta SPRITE_ANIM_POS,x
          sta SPRITE_ANIM_DELAY,x
          sta SPRITE_MOVE_POS,x
          sta SPRITE_MOVE_POS_Y,x
          sta SPRITE_STATE_POS,x
          sta SPRITE_HIT_BACK,x
          sta SPRITE_DAMAGE,x
          sta SPRITE_SECTOR,x
          sta SPRITE_TILE_POS_X_DELTA,x

          ;calc tile pos
          lda SPRITE_CHAR_POS_X,x
          jsr CalcTilePosFromCharPos
          sta SPRITE_TILE_POS_X,x

          lda TYPE_START_STATE,y
          sta SPRITE_STATE,x

          lda TYPE_START_HEIGHT,y
          sta SPRITE_HEIGHT_CHARS,x

          lda TYPE_START_HP,y
          sta SPRITE_HP,x

          lda TYPE_START_DELTA_Y,y
          sta PARAM10
          sty PARAM9

.OffsetY
          beq .NoOffsetY

          jsr MoveSpriteUp
          dec PARAM10
          jmp .OffsetY

.NoOffsetY
          ldy PARAM9

          ;expand off
          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_EXPAND_X
          sta VIC.SPRITE_EXPAND_X

          lda BIT_TABLE,x
          eor #$ff
          and VIC.SPRITE_EXPAND_Y
          sta VIC.SPRITE_EXPAND_Y

          ;re-set expand y?
          lda TYPE_START_FLAGS,y
          and #$20
          beq .NoYExpand

          lda BIT_TABLE,x
          ora VIC.SPRITE_EXPAND_Y
          sta VIC.SPRITE_EXPAND_Y

.NoYExpand

          ;re-set expand x?
          lda TYPE_START_FLAGS,y
          and #$40
          beq .NoXExpand

          lda BIT_TABLE,x
          ora VIC.SPRITE_EXPAND_X
          sta VIC.SPRITE_EXPAND_X

.NoXExpand

          ;use start direction
          lda TYPE_START_FLAGS,y
          and #$10
          beq .NoRandomMovePos

          jsr GenerateRandomNumber
          sta SPRITE_MOVE_POS,x

.NoRandomMovePos
          lda TYPE_START_FLAGS,y
          and #$03
          cmp #3
          beq .RandomLeftRightNothing
          cmp #2
          bne .SetDirX
          jmp .RandomLeftRight

.RandomLeftRightNothing
          jsr GenerateRandomNumber
          and #$03
          cmp #2
          beq .SetDirX

.RandomLeftRight
          jsr GenerateRandomNumber
          and #$01
.SetDirX
          sta SPRITE_DIRECTION,x

          lda TYPE_START_FLAGS,y
          and #$0c
          lsr
          lsr
          cmp #3
          beq .RandomUpDownNothing
          cmp #2
          bne .SetDirY
          jmp .RandomUpDown

.RandomUpDownNothing
          jsr GenerateRandomNumber
          and #$03
          cmp #2
          beq .SetDirY

.RandomUpDown
          jsr GenerateRandomNumber
          and #$01
.SetDirY
          sta SPRITE_DIRECTION_Y,x

          lda #1
          rts



;Removed object from array
;X = index of object
!lzone RemoveObject
          ;remove from array
          lda #0
          sta SPRITE_ACTIVE,x

          ;disable sprite
          lda BIT_TABLE,x
          eor #$ff
          and SPRITES_ENABLED
          sta SPRITES_ENABLED
          rts



!zone FindEmptySpriteSlot
;Looks for an empty sprite slot, returns in X
;#1 in A when empty slot found, #0 when full
FindEmptySpriteSlot
          ldx #0
;Looks for an empty sprite slot, returns in X
;#1 in A when empty slot found, #0 when full
FindEmptySpriteSlotWithStartingX

.CheckSlot
          lda SPRITE_ACTIVE,x
          beq .FoundSlot

          inx
          cpx #8
          bne .CheckSlot

          lda #0
          rts

.FoundSlot
          lda #1
          rts




;combined extended x flag for all sprites
SPRITE_POS_X_EXTEND
          !byte 0

SPRITE_BASE_IMAGE
          !byte 0,0,0,0,0,0,0,0
SPRITE_IMAGE
          !byte 0,0,0,0,0,0,0,0
SPRITE_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_X_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_TILE_POS_X
          !byte 0,0,0,0,0,0,0,0
SPRITE_TILE_POS_X_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_ACTIVE
          !byte 0,0,0,0,0,0,0,0
SPRITE_DAMAGE
          !fill NUM_SPRITE_SLOTS
SPRITE_HIT_BACK
          !fill NUM_SPRITE_SLOTS

;0 = on screen, 1 = below screen, 255 = above screen
SPRITE_SECTOR
          !fill NUM_SPRITE_SLOTS

;0 = right, 1 = left
SPRITE_DIRECTION
          !byte 0,0,0,0,0,0,0,0
SPRITE_DIRECTION_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_ANIM_POS
          !byte 0,0,0,0,0,0,0,0
SPRITE_ANIM_DELAY
          !byte 0,0,0,0,0,0,0,0
SPRITE_MOVE_POS
          !byte 0,0,0,0,0,0,0,0
SPRITE_MOVE_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_STATE
          !byte 0,0,0,0,0,0,0,0
SPRITE_STATE_POS
          !byte 0,0,0,0,0,0,0,0
SPRITE_WIDTH_CHARS
          !byte 1,1,1,1,1,1,1,1
SPRITE_HEIGHT_CHARS
          !fill 8
SPRITE_MAIN_INDEX
          !fill 8
SPRITE_COUNT
          !fill 8,1
SPRITE_HP
          !fill 8,1
SPRITE_VALUE
          !fill 8


TYPE_START_SPRITE = * - 1
          !byte SPRITE_PLAYER_R1
          !byte SPRITE_PLAYER_R1 + 8
          !byte SPRITE_PLAYER_SHOT
          !byte SPRITE_EXPLOSION
          !byte SPRITE_BLOB
          !byte SPRITE_BIG_BLOB_L
          !byte SPRITE_BIG_BLOB_L + 2

TYPE_START_COLOR = * - 1
          !byte $86       ;player top
          !byte $86       ;player bot
          !byte $01       ;player shot
          !byte $81       ;explosion
          !byte 0         ;blob
          !byte 0     ;big blob
          !byte 0     ;big blob bottom

TYPE_START_HP = * - 1
          !byte 5     ;player top
          !byte 5     ;player bot
          !byte 1     ;player shot
          !byte 0     ;explosion
          !byte 1     ;blob
          !byte 10     ;big blob
          !byte 10     ;big blob bottom


; 0 : no enemy
; 1 : enemy, kills on touch
; 2 : pickup
; 3 : players shot
TYPE_IS_ENEMY = * - 1
          !byte 0     ;player
          !byte 0     ;player bottom
          !byte 3     ;player shot
          !byte 0     ;explosion
          !byte 1     ;blob
          !byte 1     ;big blob
          !byte 1     ;big blob bottom

;enemy start direction, 2 bits per dir.
;        NXYmyyxx
;              xx : start direction in x
;              00 : move right
;              01 : move left
;              10 : random left or right
;              11 : random left, right or nothing
;            yy   : start direction in y
;            00   : move down
;            01   : move up
;            10   : random up or down
;            11   : random up, down or nothing
;           m     : init movepos
;           0     :   with 0
;           1     :   with random
;          Y      : 1 = expand in y
;         X       : 1 = expand in x
TYPE_START_FLAGS = * - 1
          !byte 0     ;player
          !byte 0     ;player bot
          !byte 0     ;player shot
          !byte 0     ;explosion
          !byte 0     ;blob
          !byte 1     ;big blob
          !byte 1     ;big blob bottom

TYPE_START_STATE = * - 1
          !byte 0     ;player
          !byte 0     ;player bottom
          !byte 0     ;player shot
          !byte 0     ;explosion
          !byte 0     ;blob
          !byte 0     ;big blob
          !byte 0     ;big blob bottom

TYPE_START_DELTA_Y = * - 1
          !byte 0     ;player
          !byte 3     ;player bot
          !byte 0     ;player shot
          !byte 0     ;explosion
          !byte 0     ;blob
          !byte 0     ;big blob
          !byte 3     ;big blob bot

TYPE_START_HEIGHT = * - 1
          !byte 5     ;player
          !byte 2     ;player bot
          !byte 1     ;player shot
          !byte 0     ;explosion
          !byte 2     ;blob
          !byte 5     ;big blob
          !byte 2     ;big blob bottom




SCREEN_LINE_OFFSET_TABLE_LO
!for ROW = 0 to 24
          !byte <( SCREEN_CHAR + ROW * 40 )
!end

SCREEN_LINE_OFFSET_TABLE_HI
!for ROW = 0 to 24
          !byte >( SCREEN_CHAR + ROW * 40 )
!end


BIT_TABLE
          !byte 1,2,4,8,16,32,64,128
