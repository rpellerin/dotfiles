#!/bin/env node

const { exec } = require("child_process");
const { exit } = require("process");
const https = require("https");

if (!process.env.COOKIE) {
  console.error("No environement variable named COOKIE found.");
  exit(1);
}

const fetch = async (url, options) =>
  new Promise((resolve, reject) => {
    https
      .get(url, options, (res) => {
        res.setEncoding("utf8");
        let rawData = "";
        res.on("data", (chunk) => {
          rawData += chunk;
        });
        res.on("end", () => {
          try {
            const parsedData = JSON.parse(rawData);
            resolve(parsedData);
          } catch (e) {
            reject(e);
          }
        });
      })
      .on("error", (e) => {
        reject(e);
      });
  });

const run = async () => {
  let ids = [];
  let body;
  let page = 1;
  do {
    body = await fetch(
      `https://www.strava.com/athlete/training_activities?keywords=&activity_type=Ride&workout_type=&commute=&private_activities=&trainer=&gear=&search_session_id=${process.env.COOKIE}&new_activity_only=false&order=&page=${page}&per_page=20`,
      {
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/72.0",
          Accept:
            "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript",
          "Accept-Language": "en-US,en;q=0.5",
          "X-Requested-With": "XMLHttpRequest",
          Cookie: process.env.COOKIE,
          Referer: "https://www.strava.com/athlete/training",
        },
      }
    );
    ids = ids.concat(body.models.map(({ id }) => id));
    page += 1;
    console.log(ids.length);
  } while (ids.length < body.total);
  ids.forEach((id, index, array) => {
    exec(
      `curl 'https://www.strava.com/activities/${id}/export_gpx' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/72.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://www.strava.com/activities/${id}' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Cookie: ${process.env.COOKIE}' -H 'Upgrade-Insecure-Requests: 1' -L -o ~/Downloads/strava-${id}.gpx`,
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
