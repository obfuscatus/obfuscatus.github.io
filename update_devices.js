const Request = require('ndx_base_modules/request').Request
const Parser = require('xml2js').Parser
const fs = require('fs')
const cheerio = require('cheerio')

class Background {
	static async getDesktopUaByOs(os, page = 1, result = []) {
		let url = 'https://developers.whatismybrowser.com/useragents/explore/operating_system_name/'

		switch(os) {
			case 'windows':
				url += 'windows/'
				break
			case 'linux':
				url += 'linux/'
				break
			case 'macosx':
				url += 'mac-os-x/'
				break
			case 'macos':
				url += 'macos/'
				break
		}
		if(page > 1) {
			url += page
		}
		let
			content = await new Request({
				url: url,
			}).exec().catch(e => {
				content = ''
			}),
			$ = cheerio.load(content),
			finder = $('.table-useragents tr'),
			length = finder.length,
			isBreaked = false,
			accept = ['Very common', 'Common']

		if(os === 'windows') {
			accept.push('Average')
		}

		for(let i=1; i<length; i++) {
			const 
				find = $(finder[i]).find('td'),
				ua = $(find[0]).text(),
				popularity = $(find[4]).text()

			if(accept.includes(popularity)) {
				result.push({
					ua,
					// type: 'desktop',
					details: {
						os: os
					}
				})
			} else {
				isBreaked = true
				break
			}
		}

		if(!isBreaked) {
			return Background.getDesktopUaByOs(os, ++page, result)
		}
		return result
	}
	static async getDesktopUa() {
		const result = []
		await Promise.all(['windows', 'linux', 'macosx', 'macos'].map(os => {
			return Background.getDesktopUaByOs(os, 1, result)
		}))
		return result
	}
	async updateDeviceUa() {
		const 
			headers = await new Request({
				url: 'https://static.tung.pro/wurfl.xml',
				getOnlyHeader: true
			}).exec(),
			lastModifiedOnServer = new Date(headers['last-modified']).getTime()

			console.log('Start updating device user agents....')
			const
				content = await new Request({
					url: 'https://static.tung.pro/wurfl.xml',
				}).exec(),
				parser = new Parser(),
				mobile = [],
				tablet = []

			parser.parseString(content, function (err, result) {
				for(let j=0, l1=result.wurfl.devices[0].device.length; j<l1; j++) {
					let device = {
						ua: result.wurfl.devices[0].device[j].$.user_agent,
						details: {}
					}
					if(device.ua.indexOf('Nokia') === -1 && device.ua.indexOf('DO_NOT_MATCH') === -1 && device.ua.indexOf(' ') > -1) {
						if(result.wurfl.devices[0].device[j].group) {
							for(let i=0, l=result.wurfl.devices[0].device[j].group.length; i<l; i++) {
								const group = result.wurfl.devices[0].device[j].group[i]
								if(group.$.id === 'display') {
									for(let k=0, k2=group.capability.length; k<k2; k++) {
										const v = group.capability[k].$
										switch(v.name) {
											case 'resolution_height':
												device.height = Number(v.value)
												break
											case 'resolution_width':
												device.width = Number(v.value)
												break
										}
									}
								}
								if(group.$.id === 'product_info') {
									for(let k=0, k2=group.capability.length; k<k2; k++) {
										const v = group.capability[k].$
										switch(v.name) {
											case 'is_tablet':
												device.type = 'tablet'
												break
											case 'brand_name':
												device.details.brand_name = v.value
												break
											case 'model_name':
												device.details.model_name = v.value
												break
										}
									}
								}
							}
							if(device.width && device.height) {
								if(!device.type) {
									// device.type = 'mobile'
									mobile.push(device)
								} else {
									delete device.type
									tablet.push(device)
								}
							}
						}
					}
				}
			})


			

			const desktop = await Background.getDesktopUa()

			// const db = DeviceDB.init()
			// await db.connect()
			// await db.clear()
			// await db.bulkInsert([...desktop_devices, ...devices])
			// localStorage.setItem('lastModifiedOnClient', Date.now() + "")


			const obj = {
				desktop_sizes: [[768, 1280], [1080, 1920], [1280, 800], [1366, 768], [1440, 900], [1600, 900], [1680, 1050], [1920, 1080], [1921, 1080], [2160, 3840], [2304, 1440], [2560, 1440], [2880, 1800], [3000, 2000], [3840, 2160], [4096, 2304], [5120, 2880]],
				mobile, tablet, desktop
			}

			fs.writeFileSync('./device.json', JSON.stringify(obj))

			console.log('Updated device user agents.')

	}
}
(new Background).updateDeviceUa()