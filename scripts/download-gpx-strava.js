const { exec } = require("child_process");
const fetch = require("node-fetch");
const { exit } = require("process");
const run = async () => {
  let ids = [];
  let body;
  let page = 1;
  do {
    const result = await fetch(
      `https://www.strava.com/athlete/training_activities?keywords=&activity_type=Ride&workout_type=&commute=&private_activities=&trainer=&gear=&search_session_id=REPLACE&new_activity_only=false&order=&page=${page}&per_page=20`,
      {
        credentials: "include",
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/72.0",
          Accept:
            "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript",
          "Accept-Language": "en-US,en;q=0.5",
          "X-Requested-With": "XMLHttpRequest",
          Cookie: "REPLACE",
        },
        referrer: "https://www.strava.com/athlete/training",
        method: "GET",
        mode: "cors",
      }
    );
    body = await result.json();
    ids = ids.concat(body.models.map(({ id }) => id));
    page += 1;
    console.log(ids.length);
  } while (ids.length < body.total);
  ids.forEach((id, index, array) => {
    exec(
      `curl 'https://www.strava.com/activities/${id}/export_gpx' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/72.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://www.strava.com/activities/${id}' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Cookie: REPLACE' -H 'Upgrade-Insecure-Requests: 1' -L -o ~/Downloads/gpx-strava/${id}.gpx`,
      (error, stdout, stderr) => {
        console.log(`>>>>>> ${index}/${array.length}`);
        if (error) {
          console.error(`exec error: ${error}`);
          return;
        }
        console.log(`stdout: ${stdout}`);
      }
    );
  });
};
run();
