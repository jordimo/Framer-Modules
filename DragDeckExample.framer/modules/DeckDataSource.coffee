
Card = require 'DeckDefaultCard'

class window.DeckDataSource extends Framer.BaseClass


      constructor : (opts = {}) ->

            opts.cardViewModel      ?= Card.DeckCard
            opts.info               ?= null

            @cardType = opts.cardViewModel


            @view = new Layer
                  name : '__deckDataSourceViewContainer'
                  x :0
                  y :0
                  clip : true
                  backgroundColor : false

            @cards = []

            if opts.info
                  @createCards opts.info

      @define 'cardView',
            get : () -> @cardType
            set : (viewClass) ->
                  @cardType = viewClass


      createCards : (infoObj) ->

            for obj in infoObj
                  c = new @cardType
                        name : "DeckCard " + @cards.length
                  c.superLayer = @view

                  for p, v of obj
                        c[p] = v

                  @cards.push c


      getAll : () ->
            @cards
