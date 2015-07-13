

# Modules

require 'DraggableDeck'
require 'DeckDataSource'
Card = require 'DeckDefaultCard'

# Example Data




data = [
	{
		title 	: 'Capt. America'
		img		: 'images/america.jpg' 
	},
	{
		title	: 'Thor'
		img		: 'images/thor.jpg'
	},
	{
		title 	: 'Stark'
		img		: 'images/stark.jpg'
	}
]


# Create a background
background = new BackgroundLayer backgroundColor: "#DDD"


# Create DataSource

dataSource = new DeckDataSource
	info : data
	cardViewModel : Card.DeckCard

deck = new DraggableDeck
	width       	: Screen.width
	height      	: 600
	y           	: 250    
	backgroundColor	: false
	dataSource  	: dataSource


# the user is dragging around a card

deck.on DraggableDeck.DeckEvents.DragMove, (e) =>

	if e.left > e.right
		leftIcon.scale = Utils.modulate e.left, [0,1], [1,2], true
		rightIcon.opacity = Utils.modulate e.left, [0, 1], [1, 0.3], true
		rightIcon.scale = Utils.modulate e.left, [0, 1], [1, 0.5], true
	else
		rightIcon.scale = Utils.modulate e.right, [0,1], [1,2], true
		leftIcon.opacity = Utils.modulate e.right, [0, 1], [1, 0.3], true
		leftIcon.scale = Utils.modulate e.right, [0, 1], [1, 0.5], true

	switch e.side
		when 'neutral'
			rightIcon.mark.visible = false
			leftIcon.mark.visible = false
		when 'left'
			rightIcon.mark.visible = false
			leftIcon.mark.visible = true
		when 'right'
			rightIcon.mark.visible = true
			leftIcon.mark.visible = false
		else


# the moment the user drops a card no matter where

deck.on DraggableDeck.DeckEvents.DragEnd, =>

	leftIcon.mark.visible = false
	rightIcon.mark.visible = false

	leftIcon.animate
		properties: opacity:1, scale:1
		time : 0.4

	rightIcon.animate
		properties: opacity:1, scale:1
		time : 0.4


# once the Deck has run out of cards

deck.on DraggableDeck.DeckEvents.Empty, =>
	leftIcon.visible = rightIcon.visible = false

# left / right icons

icons = new Layer
	width		: Screen.width
	height		: 200
	y			: 900
	backgroundColor : false



leftIcon = new Layer
	superLayer : icons
	x : icons.width/2 - 150 - 50
	y : 50
	borderRadius : 50
	backgroundColor : 'red'

leftIcon.mark = new Layer
	superLayer : leftIcon
	width : 50
	height : 50
	borderRadius : 25
	backgroundColor : 'white'
	visible : false

leftIcon.mark.center()

rightIcon = new Layer
	superLayer : icons
	x : icons.width/2 + 100
	y : 50
	borderRadius : 50
	backgroundColor : 'green'


rightIcon.mark = new Layer
	superLayer : rightIcon
	width : 50
	height : 50
	borderRadius : 25
	backgroundColor : 'white'
	visible : false

rightIcon.mark.center()



