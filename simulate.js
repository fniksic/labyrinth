/* The following Javascript code simulates key presses. Paste it into the
 * browser's Javascript console. Paste the solution string as an argument
 * in the call to simulate.
 *
 * For instance, the call at the end might look like this:
 *
 *   simulate('RRPLUULLLP')
 */
var k = { 'U': 38, 'D': 40, 'L': 37, 'R': 39, 'P': 13 };
var simulate = function(str) { for (var i = 0; i < str.length; ++i) { $.event.trigger({ type : 'keydown', which : k[str[i]] }); }};
simulate('')
