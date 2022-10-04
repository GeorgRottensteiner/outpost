NUM_SPRITE_SLOTS        = 8

SPRITE_BASE             = ( SPRITE_LOCATION % 16384 ) / 64

SPRITE_PLAYER_R1        = SPRITE_BASE + 0
SPRITE_PLAYER_L1        = SPRITE_BASE + 4
SPRITE_PLAYER_SHOT      = SPRITE_BASE + 48
SPRITE_EXPLOSION        = SPRITE_BASE + 49
SPRITE_BLOB             = SPRITE_BASE + 52

SPRITE_PLAYER_HITBACK_L = SPRITE_BASE + 54
SPRITE_PLAYER_HITBACK_R = SPRITE_BASE + 56

TYPE_PLAYER             = 1
TYPE_PLAYER_SHOT        = 3
TYPE_EXPLOSION          = 4
TYPE_BLOB               = 5


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

          sta VIC.SPRITE_ENABLE
          sta ACTIVE_ENEMY_COUNT
          rts


;------------------------------------------------------------
;move object left if not blocked
;x = object index
;return 1 if moved, 0 if blocked
;------------------------------------------------------------

!zone ObjectMoveLeftBlocking
ObjectMoveLeftBlocking
          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .CheckCanMoveLeft

.CanMoveLeft
          jsr ObjectMoveLeft
          lda #1
          rts

.CheckCanMoveLeft
          lda SPRITE_CHAR_POS_X,x
          beq .BlockedLeft

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .BlockedLeft
          tay
          iny
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1

          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda SPRITE_HEIGHT_CHARS,x
          sta PARAM6

          lda SPRITE_CHAR_POS_Y_DELTA,x
          beq +
          inc PARAM6
+

--
          ldy SPRITE_CHAR_POS_X,x
          dey

          lda (ZEROPAGE_POINTER_1),y
          jsr IsCharBlocking
          bne .BlockedLeft

          dec PARAM6
          beq .CanMoveLeft

          lda ZEROPAGE_POINTER_1
          clc
          adc #40
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+
          jmp --

.BlockedLeft
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
          dec SPRITE_POS_X,x
          rts


;move object right if not blocked
;x = object index
;retuens a = 1 if moved, 0 if blocked
!zone ObjectMoveRightBlocking
ObjectMoveRightBlocking
          lda SPRITE_CHAR_POS_X_DELTA,x
          beq .CheckCanMoveRight

.CanMoveRight
          jsr ObjectMoveRight
          lda #1
          rts

.CheckCanMoveRight
          lda SPRITE_CHAR_POS_X,x
          cmp #39
          beq .BlockedRight

          lda SPRITE_CHAR_POS_Y,x
          sec
          sbc SPRITE_HEIGHT_CHARS,x
          bmi .BlockedRight
          tay
          iny
          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          lda SPRITE_HEIGHT_CHARS,x
          sta PARAM6

          lda SPRITE_CHAR_POS_Y_DELTA,x
          beq +
          inc PARAM6
+

--
          lda SPRITE_CHAR_POS_X,x
          clc
          adc SPRITE_WIDTH_CHARS,x
          tay

          lda (ZEROPAGE_POINTER_1),y
          jsr IsCharBlocking
          bne .BlockedRight

          dec PARAM6
          beq .CanMoveRight

          lda ZEROPAGE_POINTER_1
          clc
          adc #40
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+
          jmp --

.BlockedRight
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

.Blocking
          lda #1
          rts

.NotBlocking
          lda #0
          rts




!zone IsCharBlockingD
IsCharBlockingD
          cmp #80
          bcc .NotBlocking

          ;platforms and ladders
          cmp #224
          bcs .Blocking

          cmp #220
          bcs .NotBlocking

.Blocking
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

ENEMY_BEHAVIOUR_TABLE_HI
          !byte >BHPlayer
          !byte >BHNone     ;player part #2
          !byte >BHPlayerShot
          !byte >BHExplosion
          !byte >BHBlob



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
          bcc .NotColliding

          lda SPRITE_ACTIVE,y
          cmp #TYPE_BLOB
          bne .NotColliding

          dec ACTIVE_ENEMY_COUNT
          jsr RemoveObject
          tya
          tax

          lda #TYPE_EXPLOSION
          jsr SetupSpriteInSlot

          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jsr MoveSpriteUp
          jmp MoveSpriteUp



.NotColliding

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



!zone BHBlob
BHBlob
          lda #3
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
          dec ACTIVE_ENEMY_COUNT
          jmp RemoveObject



.Blocked
          lda SPRITE_DIRECTION,x
          eor #$01
          sta SPRITE_DIRECTION,x
          rts



;x = enemy index
!zone DamageEnemy
DamageEnemy
          inc SPRITE_DAMAGE,x
          ldy SPRITE_ACTIVE,x
          lda SPRITE_DAMAGE,x
          cmp TYPE_MAX_DAMAGE,y
          beq .Killed

          rts

.Killed
          jmp RemoveObject



;------------------------------------------------------------
;Enemy Behaviour
;------------------------------------------------------------
!zone ObjectControl
ObjectControl
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



;------------------------------------------------------------
;check joystick (player control)
;state   0: normal playing
;      129: dying animation flying up
;      130: dying animation falling down
;------------------------------------------------------------

!zone BHPlayer
BHPlayer
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


.NoHitBack

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

          ldy SPRITE_DIRECTION
          lda PLAYER_HITBACK_SPRITE,y
          sta SPRITE_IMAGE
          sta SPRITE_IMAGE + 1
          inc SPRITE_IMAGE + 1

          dec PLAYER_HEALTH

          lda #<( SCREEN_PANEL_POS + $9a )
          sta ZEROPAGE_POINTER_1
          lda #>( SCREEN_PANEL_POS + $9a )
          sta ZEROPAGE_POINTER_1 + 1
          jsr DecreaseValue

          rts

.NotColliding

          lda #JOY_BUTTON
          jsr JoyReleasedControlPressed
          bne +

          ;shoot
          lda PLAYER_CARRIES_GUN
          beq +

          ;no energy
          lda PLAYER_ENERGY
          ora PLAYER_ENERGY + 1
          beq +

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


          lda SPRITE_CHAR_POS_X
          sta PARAM1
          lda SPRITE_CHAR_POS_Y
          sta PARAM2
          lda #TYPE_PLAYER_SHOT
          sta PARAM3
          jsr SpawnObject
          lda SPRITE_DIRECTION
          sta SPRITE_DIRECTION,x

          ldx #0


+
          ;toggle items
          lda #JOY_DOWN
          jsr JoyReleasedControlPressed
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

          lda ACTIVE_ITEM
          cmp #ITEM_PISTOL
          bne +

          lda #16
          sta PLAYER_CARRIES_GUN
+
          ldx #0

          ;search/enter
          lda #JOY_UP
          jsr JoyReleasedControlPressed
          bne +

          lda PLAYER_MAP_OBJECT
          bmi .NotInFrontOfObject

          jmp PlayerSearchObject

.NotInFrontOfObject
          ;in front of door?
          lda SCREEN_LINE_OFFSET_TABLE_LO + 9
          sta ZEROPAGE_POINTER_1
          lda SCREEN_LINE_OFFSET_TABLE_HI + 9
          sta ZEROPAGE_POINTER_1 + 1
          ldy SPRITE_CHAR_POS_X
          lda (ZEROPAGE_POINTER_1),y
          cmp #81
          bne +

          ;walk in door
          jsr WalkInDoor

          jmp .UpdateMapObjectUnderPlayer
+

          lda #JOY_RIGHT
          and JOY_VALUE
          bne .NotR

          lda #0
          sta SPRITE_DIRECTION

          inc SPRITE_MOVE_POS

          lda SPRITE_POS_X
          cmp #168
          bcc .MoveRight
          ;inc VIC.BORDER_COLOR
          jsr ScrollRightToLeft
          jsr ScrollRightToLeft
          beq .Scrolled

.MoveRight
          jsr ObjectMoveRightBlocking
          jsr ObjectMoveRightBlocking
          ;dec VIC.BORDER_COLOR

.Scrolled
          jsr .UpdateMapObjectUnderPlayer

.NotR
          lda #JOY_LEFT
          and JOY_VALUE
          bne .NotL

          lda #1
          sta SPRITE_DIRECTION

          inc SPRITE_MOVE_POS

          lda SPRITE_POS_X_EXTEND
          and #$01
          bne .MoveLeft
          lda SPRITE_POS_X
          cmp #168
          bcs .MoveLeft

          ;inc VIC.BORDER_COLOR
          jsr ScrollLeftToRight
          jsr ScrollLeftToRight
          beq .Scrolled2

.MoveLeft
          jsr ObjectMoveLeftBlocking
          jsr ObjectMoveLeftBlocking
          ;dec VIC.BORDER_COLOR

.Scrolled2
          jsr .UpdateMapObjectUnderPlayer
.NotL
          ;update sprite
          ldy SPRITE_DIRECTION
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


.UpdateMapObjectUnderPlayer
          ;calc tile index
          lda X_OFFSET_INSIDE_TILE
          clc
          adc SPRITE_CHAR_POS_X
          lsr
          lsr
          clc
          adc X_OFFSET_TILE
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



!lzone PlayerSearchObject
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

          jmp .Empty

.Gun
          lda #1
          sta GAME_PROGRESS

          jsr DisplayInventory

          ldx #3
          ldy #14
          lda #0
          jsr DrawItem

          lda #TEXT_FOUND_PISTOL
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
;return carry set if collided, y = other object index
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



;check object collision with other objects
;CURRENT_INDEX is current object
;CURRENT_SUB_INDEX is other object)
;return a = 1 when colliding, a = 0 when not
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

IsObjectCollidingWithObject
          ldx CURRENT_SUB_INDEX
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



;------------------------------------------------------------
;x is sprite slot
;PARAM1 is X
;PARAM2 is Y
;PARAM3 is object type
;PARAM4 = color
;expects #1 in A to add object, #0 does not add
;------------------------------------------------------------
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

          ;enable sprite
          lda BIT_TABLE,x
          ora VIC.SPRITE_ENABLE
          sta VIC.SPRITE_ENABLE

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

          lda TYPE_START_STATE,y
          sta SPRITE_STATE,x

          lda TYPE_START_HEIGHT,y
          sta SPRITE_HEIGHT_CHARS,x

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

          rts



;------------------------------------------------------------
;Removed object from array
;X = index of object
;------------------------------------------------------------

!lzone RemoveObject
          ;remove from array
          lda #0
          sta SPRITE_ACTIVE,x

          ;disable sprite
          lda BIT_TABLE,x
          eor #$ff
          ;and SPRITE_ENABLED
          and VIC.SPRITE_ENABLE
          sta VIC.SPRITE_ENABLE
          ;sta SPRITE_ENABLED
          rts



!zone FindEmptySpriteSlot
;Looks for an empty sprite slot, returns in X
;#1 in A when empty slot found, #0 when full
FindEmptySpriteSlot
          ldx #0
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
SPRITE_CHAR_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_CHAR_POS_Y_DELTA
          !byte 0,0,0,0,0,0,0,0
SPRITE_POS_Y
          !byte 0,0,0,0,0,0,0,0
SPRITE_ACTIVE
          !byte 0,0,0,0,0,0,0,0
SPRITE_TILE_POS
          !fill NUM_SPRITE_SLOTS
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



TYPE_START_SPRITE = * - 1
          !byte SPRITE_PLAYER_R1
          !byte SPRITE_PLAYER_R1 + 8
          !byte SPRITE_PLAYER_SHOT
          !byte SPRITE_EXPLOSION
          !byte SPRITE_BLOB

TYPE_START_COLOR = * - 1
          !byte $86       ;player top
          !byte $86       ;player bot
          !byte $01       ;player shot
          !byte $81       ;explosion
          !byte 0         ;blob

TYPE_MAX_DAMAGE
          !byte 5   ;player top
          !byte 5   ;player bot
          !byte 1   ;player shot
          !byte 0   ;explosion
          !byte 0     ;blob


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

TYPE_START_STATE = * - 1
          !byte 0     ;player
          !byte 0     ;player bottom
          !byte 0     ;player shot
          !byte 0     ;explosion
          !byte 0     ;blob

TYPE_START_DELTA_Y = * - 1
          !byte 0     ;player
          !byte 3     ;player bot
          !byte 0     ;player shot
          !byte 0     ;explosion
          !byte 0     ;blob

TYPE_START_HEIGHT = * - 1
          !byte 5     ;player
          !byte 2     ;player bot
          !byte 1     ;player shot
          !byte 0     ;explosion
          !byte 2     ;blob



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
