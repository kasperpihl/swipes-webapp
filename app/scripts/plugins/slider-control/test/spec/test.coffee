el = document.querySelector "#test .slider-control"
###
describe "AMD support", ->
	it "Should be AMD compatible and sub-load all requirements"
	it "Should load ThrowProps if physics are enabled via the options object"
###

describe "Basic functionality", ->
	it "Should have a 'value' property at all times holding the current slider value", ->
		slider = new SliderControl el
		expect( slider ).to.have.ownProperty "value"

	it "Should accept value as an argument when instantiated and update the handle to reflect that value", ->
		slider = new SliderControl( el, {}, 0.8 )
		expect( slider.value ).to.equal 0.8
		
	it "Should expose the original Draggable object via the 'draggable' property", ->
		slider = new SliderControl el
		expect( slider.draggable ).to.exist

	it "Should support stepped movement along the track"

	it "Should maintain handle position and value during and after resize"

describe "Setting options", ->
	it "Should properly extend a set of base options", ->
		slider1 = new SliderControl( el, { zIndexBoost: yes } )
		slider2 = new SliderControl el

		expect( slider1.opts ).to.exist
		expect( slider1.opts.zIndexBoost ).to.not.equal slider2.opts.zIndexBoost
		expect( slider2.opts.zIndexBoost ).to.equal no

describe "Dragging", ->
	it "Should have a handleDrag method that is called whenever the slider is updated", ->
		expect( SliderControl ).to.respondTo "handleDrag"
	it "Should have a handleDragEnd end metod that is called whenever the slider has come to a stop after beging dragged", ->
		expect( SliderControl ).to.respondTo "handleDragEnd"

describe "Memory management and disable/enable functionality", ->
	it "Should remove all event listeners when calling the destroy method", ->
		expect( SliderControl ).to.respondTo "destroy"