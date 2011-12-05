
describe("currency_converter", function() {
	it("should give value in euro", function() {
		expect(converter.usdToEuro(2)).toEqual(1);
	});

    it("should give another value in euro", function() {
    	expect( converter.usdToEuro(1) ).toEqual(.5);
    });
});
