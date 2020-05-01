let args = process.argv.slice(2)
if (args.length < 1 || args.length > 2)
	process.exit(1)
const input = args[0]
const output = (args.length > 1) ? args[1] : input

const yaml = require('js-yaml')
const fs = require('fs')
const mjpage = require('mathjax-node-page').mjpage

mjpage(fs.readFileSync(input, 'utf8'), {
	format: ['AsciiMath'],
	output: 'svg',
	cssInline: false,
	MathJax: {
		ascii2jax: {
			delimiters: [['\\(', '\\)'], ['\\[', '\\]']],
		},
	},
	displayMessages: true,
	displayErrors: true,
}, {
	linebreaks: true,
	ex: 9, width: 60,
	useGlobalCache: true,
}, (doc) => {
	require('jsdom-global')(doc)
	window.d3 = require('d3')
	const functionPlot = require('function-plot')

	const elements = document.querySelectorAll('.function-plot')
	for (const target of elements) {
		const text = target.textContent
		target.innerHTML = ''

		functionPlot({
			target: target,
			disableZoom: true,
			...yaml.load(text),
		})

		const plot = target.firstChild
		const [ width, height ] = [
			plot.getAttribute('width'),
			plot.getAttribute('height') - 2,
		]
		plot.removeAttribute('width')
		plot.removeAttribute('height')
		plot.setAttribute('viewBox', `0 0 ${width} ${height}`)

		plot.remove()
		target.parentNode.insertBefore(plot, target)
		target.remove()
	}

	fs.writeFileSync(output, `<!doctype html>${document.documentElement.outerHTML}`, 'utf8')
})
