function fullSizeUrl(fbid) {
    return { url: `https://m.facebook.com/photo/view_full_size/?fbid=${fbid}&ref_component=mbasic_photo_permalink`, fbid }
}


let photos = document.querySelectorAll('a[href*="https://www.facebook.com/photo.php?fbid"]')
let ids = Array.from(photos).map(node => node.href.match(/fbid=(\d+)/)[1])
let urls = ids.map(fullSizeUrl)

urls

// copy object urls in console, go to m.facebook.com. In console write let urls = <paste here>

function openLink({ url, fbid }) {
    const a = document.createElement('a')
    a.href = url
    a.target = '_blank'
    //a.setAttribute('download', `${fbid}.jpg`)
    document.body.appendChild(a)
    a.click()
}

function reqListener(fbid, callback) {
    return function () {
        const body = this.responseText
        const url = body.match(/<meta http-equiv="refresh" content="0;url=([^"]+)"/)[1].replace(/amp;/g, '')
        callback({ url, fbid })
    }
}

function downloadPage({ url, fbid }) {
    return new Promise(function (res, rej) {
        var oReq = new XMLHttpRequest();
        oReq.addEventListener("load", reqListener(fbid, res));
        oReq.open("GET", url);
        oReq.send();
    })
}

let finalArray
Promise.all(urls.map(downloadPage)).then(array => {
    finalArray = array
    console.log('FINISHED')
})

// when FINISHED shows up, type finalArray and copy the object
// execute the following script

// const { execSync } = require('child_process')

// const download = ({ url, fbid }) => execSync(`wget "${url}" -O /tmp/FB2/${fbid}.jpg`).toString()

// const urls = <paste here>

// for (let i = 0; i < urls.length; i++) {
//     console.log(download(urls[i]))
//     console.log(i + 1)
// }

