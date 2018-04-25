const http = require("http")
const https = require("https")

const URL_GPS_COORDINATES = 'http://freegeoip.net/json/'
const URL_WEATHER = (latitude, longitutde) => `https://query.yahooapis.com/v1/public/yql?q=select%20item.condition%20from%20weather.forecast%20where%20woeid%20in%20(SELECT%20woeid%20FROM%20geo.places%20WHERE%20text%3D%22(${latitude}%2C${longitutde})%22)%20and%20u%3D'c'&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys`

const getJSON = url => {
    return new Promise( (resolve, reject) => {
        (url.startsWith('https') ? https : http).get(url, (res) => {
          const statusCode = res.statusCode;
          const contentType = res.headers['content-type'];

          let error;
          if (statusCode !== 200) {
            error = new Error(`Request Failed.\n` +
                              `Status Code: ${statusCode}`);
          } else if (!/^application\/json/.test(contentType)) {
            error = new Error(`Invalid content-type.\n` +
                              `Expected application/json but received ${contentType}`);
          }
          if (error) {
            reject(error.message);
            // consume response data to free up memory
            res.resume();
            return;
          }

          res.setEncoding('utf8');
          let rawData = '';
          res.on('data', (chunk) => rawData += chunk);
          res.on('end', () => {
            try {
              let parsedData = JSON.parse(rawData);
              resolve(parsedData);
            } catch (e) {
              reject(e.message);
            }
          });
        }).on('error', (e) => {
          reject(`Got error: ${e.message}`);
        });

    })
}

let city = null

getJSON(URL_GPS_COORDINATES).then( result => {
    city = result.city
    return getJSON(URL_WEATHER(result.latitude, result.longitude))
}).then( ({query}) => {
    console.log(`${query.results.channel.item.condition.temp}°C${city ? ` in ${city}` : ''}, ${query.results.channel.item.condition.text}`)
}).catch( error => {
    console.log(error)
})
