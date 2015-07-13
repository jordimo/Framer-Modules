


class exports.DeckCard extends Layer


      constructor : (opts ={}) ->

            opts.width        = 680
            opts.height       = 550
            opts.backgroundColor = 'white'
            opts.shadowY       = 8
            opts.shadowBlur    = 8
            opts.shadowColor   = 'rgba(0, 0, 0, .3)'
            opts.superLayer   ?= null
            super opts

            @nameField = new Layer
                  backgroundColor : false
                  superLayer      : @
                  y     : 480
                  width : @width

            @nameField.style = {
                  'color' : '#555',
                  'font-size' : '20pt',
                  'text-align'     : 'center'
            }

      @define 'title',
            set : (nameStr) ->
                  @nameField.html = nameStr


      @define 'img',
            set : (imgUrl) ->

                  _img = new Layer
                        superLayer : @
                        x : 44
                        y : 44
                        width : @width - 88
                        height : @height - 148
                        image : imgUrl                  
