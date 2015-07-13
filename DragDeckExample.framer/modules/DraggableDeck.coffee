require 'DeckDataSource'
Card = require 'DeckDefaultCard'

class window.DraggableDeck extends Framer.Layer

      @DeckEvents =
            DragStart   : 'dragstart'
            DragMove    : 'dragging'
            DragEnd     : 'dragmove'
            DropLeft    : 'dropleft'
            DropRight   : 'dropright'
            DropCenter  : 'dropcenter'
            Empty       : 'empty'
            Next        : 'next'


      REVEAL_TYPE =
            revealAll : 'revealall'
            onebyone : 'onebyone'


      constructor : (opts = {}) ->

            throw new Error "NO DATA SOURCE? " if !opts.dataSource

            opts.width              ?= Screen.width
            opts.height             ?= Screen.height
            opts.backgroundColor    ?= false
            opts.perspective        = 500
            opts.clip               ?= false
            opts.paddingY           ?= 0
            opts.dataSource         ?= null

            super opts

            opts.verificationFn     = null
            opts.startZ             ?= 0
            opts.cardPadding        ?= 15
            opts.cardZPadding       ?= 10


            @type             = REVEAL_TYPE.revealAll
            @startZ           = opts.startZ
            @cardPadding      = opts.cardPadding
            @cardZPadding     = opts.cardZPadding
            @paddingY         = opts.paddingY
            @selectionThreshold = 100


            @cardsList = []

            if opts.dataSource
                  @_dataSource = opts.dataSource
                  @loadCards()




      loadCards : () ->

            # only works for REVEAL_ALL

            allCards = @_dataSource.getAll().reverse()
            @cardsList = []


            for card,i in allCards

                  card.superLayer = @
                  card.centerX()
                  card.y = @paddingY + (allCards.length - i - 1) * @cardPadding
                  card.z =  -@startZ + (allCards.length - i - 1 ) * -@cardZPadding
                  card.startX = card.x
                  card.startY = @paddingY

                  @cardsList.push card

                  @makeCardDraggable card


      nextCard : (card) ->

            for c,i in @cardsList
                  if c is card
                        @cardsList.splice(i, 1)
                        break

            if @cardsList.length == 0
                  @emit DraggableDeck.DeckEvents.Empty
                  return


            for c, i in @cardsList
                  c.animate
                        properties :
                              y : @paddingY + (@cardsList.length - i - 1) * @cardPadding
                              z : -@startZ + (@cardsList.length - i - 1 ) * -@cardZPadding
                        time : .2





      rejectCard : (card) ->

            cardOut = card.animate
                  properties : x : -1400
                  curve : "cubic-bezier(0.0, 0.0, 0.2, 1"
                  time : 0.2

            if @verificationFn
                  cardOut.on Events.AnimationEnd, =>
                        @nextCard(card)
            else
                  @nextCard(card)


      acceptCard : (card) ->

            cardOut = card.animate
                  properties:
                        x : @width + 1400
                  curve : "cubic-bezier(0.0, 0.0, 0.2, 1"
                  time : 0.2

            if @verificationFn
                  cardOut.on Events.AnimationEnd, =>
                        if !@verificationFn(card)
                              @nextCard(card)
            else
                  @nextCard(card)

      checkMatch : (card) ->
            # print "card = #{card}"
            false


      makeCardDraggable : (card) ->

            card.draggable.enabled = true
            card.draggable.constraints =
                  x : card.x
                  y : card.y
                  width : 1015
                  height : 955

            card.draggable.overdragScale = 1.1

            card.on Events.DragStart, =>
                  @emit DraggableDeck.DeckEvents.DragStart


            card.on Events.Drag, =>


                  eventObj =
                        x : card.x
                        side : 'neutral'


                  if card.x > card.draggable.constraints.x
			# like
                        # setIconState(true)
                        start = card.draggable.constraints.x
                        end = card.draggable.constraints.x + card.width/2
                        card.rotation = Utils.modulate card.x, [start,1080], [0,14], true
                        eventObj.left = Utils.modulate card.x, [start, end], [0, -1], true
                        eventObj.right = Utils.modulate card.x, [start, end],  [0, 1], true


                  else if card.x <= card.draggable.constraints.x
			# reject
                        # setIconState(false)
                        start = card.draggable.constraints.x
                        end = card.draggable.constraints.x-card.width/2
                        card.rotation = Utils.modulate card.x, [start,-1080], [0,-14], true
                        eventObj.left = Utils.modulate card.x, [start, end], [0, 1], true
                        eventObj.right = Utils.modulate card.x, [start, end], [0, -1], true

                  card.scale = Utils.modulate card.x, [start,end], [1,0.9], true

                  if Math.abs(card.x-card.draggable.constraints.x) > @selectionThreshold
                        eventObj.side = if card.x < card.draggable.constraints.x then 'left'  else 'right'

                  @emit DraggableDeck.DeckEvents.DragMove, eventObj


            card.on Events.DragEnd, =>
                  # reject

                  if card.x < -350
                        @rejectCard card
                        @emit DraggableDeck.DeckEvents.DropLeft
                        # reject card
                  #accept
                  else if card.x > 380
                        @acceptCard card
                        @emit DraggableDeck.DeckEvents.DropRight
                        # match card
                  # neither
                  else
                        @emit DraggableDeck.DeckEvents.DropCenter
                        card.animate
                              properties:
                                    x : card.startX
                                    y : card.startY
                                    rotation:0
                                    opacity:1
                                    scale:1
                              curve : "cubic-bezier(0.0, 0.0, 0.2, 1"
                              time : 0.4

                  @emit DraggableDeck.DeckEvents.DragEnd
